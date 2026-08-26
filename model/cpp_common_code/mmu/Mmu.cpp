//Mmu.cpp

#include "Mmu.h"
#include "Addresses.h"
#include "../AsiValues.h"
#include "../BitManipulation.h"
#include "../CoreLogger.h"
#include <cassert>
#include <string>

Mmu::Mmu(PhysicalMemoryInterface& downstream, int threadId)
	: mmuIsPresent(true), independentMmuContextPerThread(true), tlbEnabled(MMU_TLB_PRESENT),
	  downstream_(downstream), threadId_(threadId), logger_(0), simulatedTime_(0)
{
	for (int i = 0; i < MAX_THREADS; i++)
	{
		controlRegister_[i] = 0;
		contextTablePointerRegister_[i] = 0;
		contextRegister_[i] = 0;
		faultStatusRegister_[i] = 0;
		faultAddressRegister_[i] = 0;
		faultClass_[i] = NO_FAULT;
	}
}

void Mmu::setLogger(CoreLogger* logger, const unsigned long* simulatedTime)
{
	logger_ = logger;
	simulatedTime_ = simulatedTime;
}

void Mmu::log(const std::string& event, const std::string& detail)
{
	if (logger_ && simulatedTime_)
		logger_->log_generic(*simulatedTime_, event, detail);
}

bool Mmu::mmuEnabled() const
{
	return readBits(controlRegister_[threadId_ & 1], MmuControlBits::E_BIT, MmuControlBits::E_BIT) != 0;
}

bool Mmu::alwaysCacheable() const
{
	return readBits(controlRegister_[threadId_ & 1], MmuControlBits::ALWAYS_CACHEABLE_BIT, MmuControlBits::ALWAYS_CACHEABLE_BIT) != 0;
}

//Ref Appendix H.3 (Control Register, NF field): "When NF = 1, a fault
//detected by the MMU causes FSR and FAR to be updated, [and] a fault on
//an access to ASI 9 is handled as when NF = 0 [i.e. traps normally];
//a fault on an access to any other ASI causes FSR and FAR to be updated
//but no fault is generated to the processor." ASI 9 is Supervisor
//Instruction (Ref Appendix I, p.259) -- not Supervisor Data (0xB), which
//IS suppressible under NF like any other non-ASI-9 access. Only
//meaningful once a fault has actually been recorded (a disabled MMU or a
//successful translation never reaches this) -- callers check this
//exactly where they'd otherwise set mae=true.
bool Mmu::noFaultSuppressesTrap(uint32_t asi) const
{
	bool nf = readBits(controlRegister_[threadId_ & 1], MmuControlBits::NF_BIT, MmuControlBits::NF_BIT) != 0;
	return nf && asi != ASI_SUPERVISOR_INSTRUCTION;
}

bool Mmu::tlbActive() const
{
	assert((!tlbEnabled || MMU_TLB_PRESENT) &&
	       "Mmu::tlbEnabled is true but MMU_TLB_PRESENT (MmuConfig.h) is false -- "
	       "can't enable a TLB that wasn't compiled in");
	return tlbEnabled;
}

//---------------------------------------------------------------------
// VirtualMemoryInterface interface
//---------------------------------------------------------------------

void Mmu::access(const VirtualMemoryRequest& request, VirtualMemoryResponse& response)
{
	response.valid     = true;
	response.readWord0 = 0;
	response.readWord1 = 0;
	response.mae        = false;

	switch (request.accessType)
	{
		case MemAccessType::IFETCH:
			handleReadAccess(request.address, request.asi, /*isInstructionFetch=*/true, /*readSecondWord=*/false,
			                  response.readWord0, response.readWord1, response.mae);
			break;
		case MemAccessType::LOAD:
			handleReadAccess(request.address, request.asi, /*isInstructionFetch=*/false, /*readSecondWord=*/true,
			                  response.readWord0, response.readWord1, response.mae);
			break;
		case MemAccessType::STORE:
			handleWriteAccess(request.address, request.word0, request.word1, request.byteMask, request.asi, response.mae);
			break;
		case MemAccessType::ATOMIC_LS:
			handleAtomicAccess(request.address, request.word0, request.word1, request.byteMask, request.asi,
			                    response.readWord0, response.readWord1, response.mae);
			break;
		case MemAccessType::FLUSH:
		case MemAccessType::NO_ACCESS:
		default:
			//FLUSH computes an address but touches no memory in this
			//model (Ref MemoryInterfaces.h) -- nothing reaches the MMU
			//for it today. NO_ACCESS is trivially a no-op.
			break;
	}
}

void Mmu::handleReadAccess(uint32_t address, uint32_t asi, bool isInstructionFetch, bool readSecondWord,
                            uint32_t& readWord0, uint32_t& readWord1, bool& mae)
{
	mae = false;

	if (!mmuIsPresent)
	{
		stats.bypassAccesses++;
		readWord0 = readPhysicalWord(address, mae);
		if (readSecondWord) { bool mae1 = false; readWord1 = readPhysicalWord(address + 4, mae1); mae = mae || mae1; }
		return;
	}

	if (asiIsCacheTagOrData((uint8_t) asi) || asiIsIcacheFlush((uint8_t) asi) || asiIsDcacheFlush((uint8_t) asi))
	{
		//No cache present in this configuration yet -- a no-op, matching
		//"gated on cache presence" in Plan_MMU_integration.md. Once the
		//caches block exists, this dispatches to it instead.
		return;
	}

	if (asi == ASI_MMU_FLUSH_PROBE)
	{
		stats.probeRequests++;
		uint32_t pte = 0;
		bool found = probe(address, pte);
		log("MMU_PROBE", "va=" + std::to_string(address) + (found ? " found" : " not found"));
		readWord0 = found ? pte : 0;
		return;
	}

	if (asi == ASI_MMU_REGISTER)
	{
		readWord0 = readRegister(address);
		return;
	}

	if (asi == ASI_MMU_DIAGNOSTIC_I || asi == ASI_MMU_DIAGNOSTIC_I_D || asi == ASI_MMU_DIAGNOSTIC_IO)
	{
		//Optional and implementation-dependent per the manual; not
		//implemented here. Ajit exit()s the whole simulator on access --
		//failing gracefully (returning 0, no fault) instead is one of
		//the documented deviations in Plan_MMU_integration.md.
		log("MMU_DIAGNOSTIC_UNIMPLEMENTED", "asi=" + std::to_string(asi));
		return;
	}

	if (asiMmuPassThrough((uint8_t) asi))
	{
		stats.bypassAccesses++;
		log("MMU_BYPASS", "addr=" + std::to_string(address));
		readWord0 = readPhysicalWord(address, mae);
		if (readSecondWord) { bool mae1 = false; readWord1 = readPhysicalWord(address + 4, mae1); mae = mae || mae1; }
		return;
	}

	//CASE 6: an ordinary instruction/data access. A LOAD's second word
	//reuses this same translation (+4) rather than translating it
	//separately -- Ref Mmu.h's own comment on handleReadAccess() for why
	//that's safe.
	uint64_t physAddr = 0; bool cacheable = false; uint8_t acc = 0;
	bool ok = translate(address, asi, isInstructionFetch, /*isWrite=*/false, /*isAtomic=*/false, physAddr, cacheable, acc);
	if (!ok) { mae = !noFaultSuppressesTrap(asi); return; }
	readWord0 = readPhysicalWord(physAddr, mae);
	if (readSecondWord)
	{
		bool mae1 = false;
		readWord1 = readPhysicalWord(physAddr + 4, mae1);
		mae = mae || mae1;
	}
}

void Mmu::handleWriteAccess(uint32_t address, uint32_t word0, uint32_t word1, uint32_t byte_mask, uint32_t asi, bool& mae)
{
	mae = false;

	if (!mmuIsPresent)
	{
		stats.bypassAccesses++;
		writePhysicalMaskedDoubleWord(address, word0, word1, byte_mask, mae);
		return;
	}

	if (asiIsCacheTagOrData((uint8_t) asi) || asiIsIcacheFlush((uint8_t) asi) || asiIsDcacheFlush((uint8_t) asi))
		return; //no cache present yet -- no-op

	if (asi == ASI_MMU_FLUSH_PROBE)
	{
		stats.flushRequests++;
		flush(address);
		log("MMU_FLUSH", "type=" + std::to_string(readBits(address, 11, 8)));
		return;
	}

	if (asi == ASI_MMU_REGISTER)
	{
		writeRegister(address, word0, word1, byte_mask);
		return;
	}

	if (asi == ASI_MMU_DIAGNOSTIC_I || asi == ASI_MMU_DIAGNOSTIC_I_D || asi == ASI_MMU_DIAGNOSTIC_IO)
	{
		log("MMU_DIAGNOSTIC_UNIMPLEMENTED", "asi=" + std::to_string(asi));
		return;
	}

	if (asiMmuPassThrough((uint8_t) asi))
	{
		stats.bypassAccesses++;
		log("MMU_BYPASS", "addr=" + std::to_string(address));
		writePhysicalMaskedDoubleWord(address, word0, word1, byte_mask, mae);
		return;
	}

	//CASE 6: an ordinary data store.
	uint64_t physAddr = 0; bool cacheable = false; uint8_t acc = 0;
	bool ok = translate(address, asi, /*isInstructionFetch=*/false, /*isWrite=*/true, /*isAtomic=*/false, physAddr, cacheable, acc);
	if (!ok) { mae = !noFaultSuppressesTrap(asi); return; }
	writePhysicalMaskedDoubleWord(physAddr, word0, word1, byte_mask, mae);
}

void Mmu::handleAtomicAccess(uint32_t address, uint32_t word0, uint32_t word1, uint32_t byte_mask, uint32_t asi,
                              uint32_t& readWord0, uint32_t& readWord1, bool& mae)
{
	mae = false;
	readWord0 = 0; readWord1 = 0;

	if (!mmuIsPresent)
	{
		stats.bypassAccesses++;
		atomicReadModifyWritePhysical(address, word0, word1, byte_mask, readWord0, readWord1, mae);
		return;
	}

	//Atomic load-store always targets ordinary data space in practice;
	//unlike handleReadAccess()/handleWriteAccess(), no MMU-register/
	//flush/probe/diagnostic dispatch is attempted here. isAtomic=true:
	//checked as a single, precise operation requiring both load and store
	//permission (Ref translate()'s own comment, and Mmu.h's -- this is
	//option 3 from the docs/compliance/ write-up, a deliberate deviation
	//from Ajit's own split-transaction behavior). That precision is
	//entirely a permission-check-time property, resolved here, above the
	//physical interface -- what actually happens physically once
	//translation succeeds is an ordinary locked-read-then-write pair
	//(Ref atomicReadModifyWritePhysical()), matching AJIT's own real bus
	//behavior and MemoryInterfaces.h's "no ATOMIC_LS on the physical
	//side" design.
	uint64_t physAddr = 0; bool cacheable = false; uint8_t acc = 0;
	bool ok = translate(address, asi, /*isInstructionFetch=*/false, /*isWrite=*/true, /*isAtomic=*/true, physAddr, cacheable, acc);
	if (!ok) { mae = !noFaultSuppressesTrap(asi); return; }
	atomicReadModifyWritePhysical(physAddr, word0, word1, byte_mask, readWord0, readWord1, mae);
}

//---------------------------------------------------------------------
// Translation
//---------------------------------------------------------------------

bool Mmu::translate(uint32_t va, uint32_t asi, bool isInstructionFetch, bool isWrite, bool isAtomic,
                     uint64_t& physicalAddr, bool& cacheable, uint8_t& acc)
{
	if (!mmuIsPresent || !mmuEnabled())
	{
		cacheable = !mmuIsPresent || alwaysCacheable();
		acc = 3; //full access -- nothing left to check
		physicalAddr = va;
		stats.bypassAccesses++;
		return true;
	}

	uint32_t context = contextRegister_[threadId_ & 1];
	uint32_t pte = 0; uint8_t level = 0; uint64_t phyAddrOfPte = 0;

	//With the TLB inactive (Ref MmuConfig.h's MMU_TLB_PRESENT / Mmu.h's
	//tlbEnabled), it is never looked at at all -- not even to record a
	//"miss" -- every access walks the page tables directly.
	bool hit = false;
	if (tlbActive())
	{
		hit = tlb_.lookup(va, context, pte, level, phyAddrOfPte);
		if (hit) stats.tlbHitsAtLevel[level]++;
		else stats.tlbMisses++;
	}
	if (!hit)
		walkPageTables(va, context, pte, level, phyAddrOfPte); //fills pte/level/phyAddrOfPte regardless of success

	//An atomic load-store (LDSTUB/SWAP) is checked as a single, precise
	//operation requiring *both* load and store permission against this
	//PTE's ACC value -- faulting, on whichever direction actually fails,
	//before any memory access happens at all. This is option 3 from
	//docs/compliance/'s write-up on this: it deliberately deviates from
	//Ajit's own split-transaction behavior (a locked plain read that can
	//complete and become visible before a separate unlocked plain write
	//faults), on the grounds that the manual's own default trap model
	//(Ref Chapter 7) requires an ordinary MMU fault on a "multiple-access"
	//instruction -- its own term, naming LDSTUB/SWAP/LDD explicitly -- to
	//be precise, unlike the one exception it carves out (non-resumable
	//machine-check faults, not ordinary protection/privilege faults).
	uint8_t at = computeAccessType(asi, isWrite);
	uint8_t faultType = computeFaultType(at, pte);
	if (isAtomic && faultType == FaultType::NONE)
	{
		uint8_t otherAt = computeAccessType(asi, !isWrite);
		uint8_t otherFaultType = computeFaultType(otherAt, pte);
		if (otherFaultType != FaultType::NONE) { at = otherAt; faultType = otherFaultType; }
	}
	if (faultType != FaultType::NONE)
	{
		recordFault(at, faultType, level, va, isInstructionFetch);
		return false;
	}

	if (!hit && tlbActive())
		tlb_.insert(va, context, pte, level, phyAddrOfPte);

	physicalAddr = constructPhysicalAddr(pte, level, va);
	cacheable = readBits(pte, PteBits::C_BIT, PteBits::C_BIT) != 0;
	acc = (uint8_t) readBits(pte, PteBits::ACC_HIGH_BIT, PteBits::ACC_LOW_BIT);

	//Referenced/Modified bit update, Ref Appendix H.7: a successful
	//translation sets R; a successful write additionally sets M. Written
	//back to memory (and the cached TLB copy) only if something actually
	//changed -- which, since both bits are sticky, only happens the
	//first time a page is read or (separately) written.
	bool setR = readBits(pte, PteBits::R_BIT, PteBits::R_BIT) == 0;
	bool setM = isWrite && readBits(pte, PteBits::M_BIT, PteBits::M_BIT) == 0;
	if (setR || setM)
	{
		uint32_t updatedPte = pte;
		if (setR) writeBits(updatedPte, PteBits::R_BIT, PteBits::R_BIT, 1);
		if (setM) writeBits(updatedPte, PteBits::M_BIT, PteBits::M_BIT, 1);
		writePageTableEntryToMemory(phyAddrOfPte, updatedPte);
		if (tlbActive()) tlb_.updatePte(va, context, level, updatedPte);
		if (setR) stats.referencedBitWriteBacks++;
		if (setM) stats.modifiedBitWriteBacks++;
	}

	stats.translatedAccesses++;
	return true;
}

bool Mmu::walkPageTables(uint32_t va, uint32_t context, uint32_t& pte, uint8_t& level, uint64_t& phyAddrOfPte)
{
	uint32_t l1Index = readBits(va, PageTableWalk::L1_INDEX_HIGH_BIT, PageTableWalk::L1_INDEX_LOW_BIT);
	uint32_t l2Index = readBits(va, PageTableWalk::L2_INDEX_HIGH_BIT, PageTableWalk::L2_INDEX_LOW_BIT);
	uint32_t l3Index = readBits(va, PageTableWalk::L3_INDEX_HIGH_BIT, PageTableWalk::L3_INDEX_LOW_BIT);

	uint8_t curLevel = 0;
	uint64_t phyAddr = getPhyAddrFromPTD(contextTablePointerRegister_[threadId_ & 1], context);
	uint32_t curPte = readPageTableEntryFromMemory(phyAddr);

	if (readBits(curPte, PteBits::ET_HIGH_BIT, PteBits::ET_LOW_BIT) == PteBits::ET_PTD)
	{
		curLevel = 1;
		phyAddr = getPhyAddrFromPTD(curPte, l1Index);
		curPte = readPageTableEntryFromMemory(phyAddr);

		if (readBits(curPte, PteBits::ET_HIGH_BIT, PteBits::ET_LOW_BIT) == PteBits::ET_PTD)
		{
			curLevel = 2;
			phyAddr = getPhyAddrFromPTD(curPte, l2Index);
			curPte = readPageTableEntryFromMemory(phyAddr);

			if (readBits(curPte, PteBits::ET_HIGH_BIT, PteBits::ET_LOW_BIT) == PteBits::ET_PTD)
			{
				curLevel = 3;
				phyAddr = getPhyAddrFromPTD(curPte, l3Index);
				curPte = readPageTableEntryFromMemory(phyAddr);
			}
		}
	}

	bool found = readBits(curPte, PteBits::ET_HIGH_BIT, PteBits::ET_LOW_BIT) == PteBits::ET_PTE;
	pte = curPte; level = curLevel; phyAddrOfPte = phyAddr;

	if (found) stats.walksTerminatedAtLevel[curLevel]++;
	else stats.walksNotFound++;

	return found;
}

bool Mmu::probe(uint32_t va, uint32_t& resultPte)
{
	resultPte = 0;
	uint8_t probeType = (uint8_t) readBits(va, 11, 8); //Ref Table H-6
	uint32_t context = contextRegister_[threadId_ & 1];

	if (probeType == 4) //entire: whatever a normal lookup/walk actually finds
	{
		uint32_t pte = 0; uint8_t level = 0; uint64_t phyAddr = 0;
		bool hit = tlbActive() && tlb_.lookup(va, context, pte, level, phyAddr);
		if (!hit) hit = walkPageTables(va, context, pte, level, phyAddr);
		if (hit) resultPte = pte;
		return hit;
	}

	if (probeType > 3) return false; //reserved types (Table H-4): undefined, treated as not-found

	//page(0)->level 3, segment(1)->level 2, region(2)->level 1, context(3)->level 0.
	uint8_t targetLevel = (uint8_t) (3 - probeType);

	uint32_t l1Index = readBits(va, PageTableWalk::L1_INDEX_HIGH_BIT, PageTableWalk::L1_INDEX_LOW_BIT);
	uint32_t l2Index = readBits(va, PageTableWalk::L2_INDEX_HIGH_BIT, PageTableWalk::L2_INDEX_LOW_BIT);
	uint32_t l3Index = readBits(va, PageTableWalk::L3_INDEX_HIGH_BIT, PageTableWalk::L3_INDEX_LOW_BIT);

	uint64_t phyAddr = getPhyAddrFromPTD(contextTablePointerRegister_[threadId_ & 1], context);
	uint32_t pte = readPageTableEntryFromMemory(phyAddr);
	uint8_t level = 0;

	while (level < targetLevel && readBits(pte, PteBits::ET_HIGH_BIT, PteBits::ET_LOW_BIT) == PteBits::ET_PTD)
	{
		level++;
		uint32_t index = (level == 1) ? l1Index : (level == 2) ? l2Index : l3Index;
		phyAddr = getPhyAddrFromPTD(pte, index);
		pte = readPageTableEntryFromMemory(phyAddr);
	}

	if (level != targetLevel) return false; //never reached the probed level (Table H-4: 0)

	uint32_t et = readBits(pte, PteBits::ET_HIGH_BIT, PteBits::ET_LOW_BIT);
	if (et == PteBits::ET_RESERVED) return false; //Table H-4: "res" always returns 0

	//Table H-4: at the probed level, a PTE or an invalid (ET=0) entry is
	//returned as-is ("*" -- the page table entry itself) for every probe
	//type. A PTD is also returned as-is for segment/region/context probes
	//(the probed level genuinely holds a PTD rather than a leaf there) --
	//except for a page probe (probeType 0, target level 3), where a PTD
	//makes no structural sense (there is no level-4 table for it to point
	//to) and the table specifies 0 instead.
	if (et == PteBits::ET_PTD && probeType == 0) return false;

	resultPte = pte;
	return true;
}

void Mmu::flush(uint32_t va)
{
	if (!tlbActive()) return; //nothing cached to flush
	uint8_t flushType = (uint8_t) readBits(va, 11, 8); //Ref Table H-6, same VA[11:8] convention as probe
	tlb_.flush(flushType, va, contextRegister_[threadId_ & 1]);
}

//---------------------------------------------------------------------
// Registers
//---------------------------------------------------------------------

uint32_t Mmu::readRegister(uint32_t addr)
{
	uint32_t registerId = readBits(addr, 31, 8); //Ref Table H-5
	uint32_t result = 0;
	if (registerId == MmuRegisterSelect::CONTROL) result = controlRegister_[threadId_ & 1];
	else if (registerId == MmuRegisterSelect::CONTEXT_TABLE_POINTER) result = contextTablePointerRegister_[threadId_ & 1];
	else if (registerId == MmuRegisterSelect::CONTEXT) result = contextRegister_[threadId_ & 1];
	else if (registerId == MmuRegisterSelect::FAULT_STATUS)
	{
		//A read to the FSR clears it (Ref Appendix H.5).
		result = faultStatusRegister_[threadId_ & 1];
		faultStatusRegister_[threadId_ & 1] = 0;
		faultClass_[threadId_ & 1] = NO_FAULT;
	}
	else if (registerId == MmuRegisterSelect::FAULT_ADDRESS) result = faultAddressRegister_[threadId_ & 1];

	stats.registerReads++;
	log("MMU_REGISTER_READ", "id=" + std::to_string(registerId) + " value=" + std::to_string(result));
	return result;
}

void Mmu::writeRegister(uint32_t addr, uint32_t word0, uint32_t word1, uint32_t byteMask)
{
	uint32_t registerId = readBits(addr, 31, 8);
	//A plain (non-double) STA lands its 32-bit value in whichever of
	//word0/word1 the doubleword-alignment happens to select -- mirrors
	//Ajit's own byte_mask-based selection (0x0f -> low word, 0xf0 -> high).
	uint32_t data = (byteMask == 0xF0) ? word1 : word0;

	stats.registerWrites++;
	log("MMU_REGISTER_WRITE", "id=" + std::to_string(registerId) + " value=" + std::to_string(data));

	if (registerId == MmuRegisterSelect::CONTROL)
	{
		controlRegister_[threadId_ & 1] = data;
		if (!independentMmuContextPerThread) for (int i = 0; i < MAX_THREADS; i++) controlRegister_[i] = data;
	}
	else if (registerId == MmuRegisterSelect::CONTEXT_TABLE_POINTER)
	{
		contextTablePointerRegister_[threadId_ & 1] = data;
		if (!independentMmuContextPerThread) for (int i = 0; i < MAX_THREADS; i++) contextTablePointerRegister_[i] = data;
		//Writing the context-table pointer invalidates the whole TLB
		//(Ref Appendix H.7's "Miss Processing" implies stale translations
		//from a since-replaced table must not survive) -- whole-TLB, not
		//selective, matching Ajit; this is a register-write side effect,
		//distinct from the selective ASI_MMU_FLUSH_PROBE flush above.
		if (tlbActive()) tlb_.clear();
	}
	else if (registerId == MmuRegisterSelect::CONTEXT)
	{
		contextRegister_[threadId_ & 1] = data;
		if (!independentMmuContextPerThread) for (int i = 0; i < MAX_THREADS; i++) contextRegister_[i] = data;
		stats.contextRegisterWrites++;
	}
	//Writes to the Fault Status/Address Registers are ignored (Ref Appendix H.6).
}

//---------------------------------------------------------------------
// Page-table memory access
//---------------------------------------------------------------------

uint32_t Mmu::readPageTableEntryFromMemory(uint64_t physAddr)
{
	bool mae = false;
	uint32_t value = readPhysicalWord(physAddr, mae);
	stats.pageTableMemoryAccesses++;
	return value;
}

void Mmu::writePageTableEntryToMemory(uint64_t physAddr, uint32_t value)
{
	//Single-half write: put value in whichever of word0/word1 physAddr's
	//own bit 2 selects, mask off the other half entirely so
	//writePhysicalMaskedDoubleWord() (and MainMemory beneath it) leaves
	//it untouched.
	uint64_t dwAddr = physAddr & ~0x7ULL;
	bool lowHalf = (physAddr & 0x4u) == 0;
	uint32_t word0 = lowHalf ? value : 0;
	uint32_t word1 = lowHalf ? 0 : value;
	uint32_t mask = lowHalf ? 0x0Fu : 0xF0u;
	bool mae = false;
	writePhysicalMaskedDoubleWord(dwAddr, word0, word1, mask, mae);
	stats.pageTableMemoryAccesses++;
}

//---------------------------------------------------------------------
// Half-select adaptation to PhysicalMemoryInterface (Ref MemoryInterfaces.h)
//---------------------------------------------------------------------

uint32_t Mmu::readPhysicalWord(uint64_t physAddr, bool& mae)
{
	uint64_t alignedAddr = physAddr & ~0x7ULL;
	PhysicalMemoryRequest request{true, PhysicalAccessType::READ, /*lock=*/false, alignedAddr, 0, 0};
	PhysicalMemoryResponse response{false, 0, false};
	downstream_.access(request, response);
	mae = response.mae;
	uint32_t word0 = (uint32_t) (response.readData & 0xFFFFFFFFu); //low 32 bits of the doubleword
	uint32_t word1 = (uint32_t) (response.readData >> 32);          //high 32 bits
	return ((physAddr & 0x4u) == 0) ? word0 : word1;
}

void Mmu::writePhysicalMaskedDoubleWord(uint64_t physAddr, uint32_t word0, uint32_t word1, uint32_t byte_mask, bool& mae)
{
	//Packing convention (this port's own choice, not AJIT's RTL bit
	//assignment -- Ref MemoryInterfaces.h): word0 -> data bits[31:0],
	//word1 -> data bits[63:32]. byte_mask's own low/high nibble already
	//select word0's/word1's bytes respectively (Ref MemCore.h's
	//mergeMaskedBytes(), the same convention used at the virtual
	//interface), so it maps onto PhysicalMemoryInterface's 8-bit mask
	//with no reordering needed.
	uint64_t data = (((uint64_t) word1) << 32) | (uint64_t) word0;
	PhysicalMemoryRequest request{true, PhysicalAccessType::WRITE, /*lock=*/false, physAddr, data, (uint8_t) byte_mask};
	PhysicalMemoryResponse response{false, 0, false};
	downstream_.access(request, response);
	mae = response.mae;
}

void Mmu::atomicReadModifyWritePhysical(uint64_t physAddr, uint32_t word0, uint32_t word1, uint32_t byte_mask,
                                         uint32_t& readWord0, uint32_t& readWord1, bool& mae)
{
	//No ATOMIC_LS at the physical interface (Ref MemoryInterfaces.h's
	//file comment): a locked READ, immediately followed by an ordinary
	//WRITE, both to physAddr -- matching AJIT's own actual bus behavior
	//(confirmed directly in its C model) and how a future multi-island
	//arbitration point would enforce the lock (Ref
	//Notes_multi_core_modeling.md's "Atomic load-store in a multi-core
	//model" section: mimic AJIT's global-lock-by-core-id, not modeled
	//yet, `lock` reserved for it).
	PhysicalMemoryRequest readRequest{true, PhysicalAccessType::READ, /*lock=*/true, physAddr, 0, 0};
	PhysicalMemoryResponse readResponse{false, 0, false};
	downstream_.access(readRequest, readResponse);

	readWord0 = (uint32_t) (readResponse.readData & 0xFFFFFFFFu);
	readWord1 = (uint32_t) (readResponse.readData >> 32);

	uint64_t writeData = (((uint64_t) word1) << 32) | (uint64_t) word0;
	PhysicalMemoryRequest writeRequest{true, PhysicalAccessType::WRITE, /*lock=*/false, physAddr, writeData, (uint8_t) byte_mask};
	PhysicalMemoryResponse writeResponse{false, 0, false};
	downstream_.access(writeRequest, writeResponse);

	mae = readResponse.mae || writeResponse.mae;
}

//---------------------------------------------------------------------
// Pure helpers (no MMU state needed -- Ref Appendix H)
//---------------------------------------------------------------------

uint64_t Mmu::getPhyAddrFromPTD(uint32_t ptd, uint32_t index)
{
	uint64_t phyAddr = ptd & ~0x3u; //clear the ET field
	phyAddr = phyAddr << 4;         //PTD's page-table-pointer field (PTD bits 31:2) -> physical address bits 35:6 (Ref Figure H-7)
	phyAddr = phyAddr | ((uint64_t) index << 2);
	return phyAddr;
}

uint64_t Mmu::constructPhysicalAddr(uint32_t pte, uint8_t level, uint32_t va)
{
	uint32_t pageOffset;
	if      (level == 3) pageOffset = readBits(va, 11, 0);
	else if (level == 2) pageOffset = readBits(va, 17, 0);
	else if (level == 1) pageOffset = readBits(va, 23, 0);
	else                  pageOffset = readBits(va, 31, 0);

	uint32_t ppn = readBits(pte, PteBits::PPN_HIGH_BIT, PteBits::PPN_LOW_BIT);
	return (((uint64_t) ppn) << 12) | pageOffset;
}

uint8_t Mmu::computeAccessType(uint32_t asi, bool isWrite)
{
	bool userData = (asi == ASI_USER_DATA);
	bool supervisorData = (asi == ASI_SUPERVISOR_DATA);
	bool userInstruction = (asi == ASI_USER_INSTRUCTION);
	bool supervisorInstruction = (asi == ASI_SUPERVISOR_INSTRUCTION);

	if (isWrite)
	{
		if (userData) return AccessType::STORE_USER_DATA;
		if (supervisorData) return AccessType::STORE_SUPERVISOR_DATA;
		if (userInstruction) return AccessType::STORE_USER_INSTRUCTION;
		if (supervisorInstruction) return AccessType::STORE_SUPERVISOR_INSTRUCTION;
	}
	else
	{
		//Covers both an ordinary load and a genuine instruction fetch --
		//both produce the same AT when asi is instruction-space, and a
		//fetch never uses data-space asi in practice (Ref
		//MemoryInterfaces.h's file comment).
		if (userData) return AccessType::LOAD_USER_DATA;
		if (supervisorData) return AccessType::LOAD_SUPERVISOR_DATA;
		if (userInstruction) return AccessType::LOAD_USER_INSTRUCTION;
		if (supervisorInstruction) return AccessType::LOAD_SUPERVISOR_INSTRUCTION;
	}
	return 0;
}

uint8_t Mmu::computeFaultType(uint8_t at, uint32_t pte)
{
	uint32_t et  = readBits(pte, PteBits::ET_HIGH_BIT, PteBits::ET_LOW_BIT);
	uint32_t acc = readBits(pte, PteBits::ACC_HIGH_BIT, PteBits::ACC_LOW_BIT);

	if (et == PteBits::ET_INVALID) return FaultType::INVALID_ADDRESS_ERROR;
	if (et == PteBits::ET_PTD || et == PteBits::ET_RESERVED) return FaultType::TRANSLATION_ERROR;

	//et == ET_PTE: check the ACC x AT permission matrix, Ref Appendix H.5.
	switch (acc)
	{
		case 0: switch (at) { case 2: case 3: case 4: case 5: case 6: case 7: return FaultType::PROTECTION_ERROR; default: return FaultType::NONE; }
		case 1: switch (at) { case 2: case 3: case 6: case 7: return FaultType::PROTECTION_ERROR; default: return FaultType::NONE; }
		case 2: switch (at) { case 4: case 5: case 6: case 7: return FaultType::PROTECTION_ERROR; default: return FaultType::NONE; }
		case 3: return FaultType::NONE;
		case 4: switch (at) { case 0: case 1: case 4: case 5: case 6: case 7: return FaultType::PROTECTION_ERROR; default: return FaultType::NONE; }
		case 5: switch (at) { case 2: case 3: case 4: case 6: case 7: return FaultType::PROTECTION_ERROR; default: return FaultType::NONE; }
		case 6:
			switch (at)
			{
				case 5: case 7: return FaultType::PROTECTION_ERROR;
				case 0: case 2: case 4: case 6: return FaultType::PRIVILEGE_VIOLATION;
				default: return FaultType::NONE;
			}
		case 7:
			switch (at)
			{
				case 0: case 2: case 4: case 6: return FaultType::PRIVILEGE_VIOLATION;
				default: return FaultType::NONE;
			}
		default: return FaultType::NONE;
	}
}

//---------------------------------------------------------------------
// Fault recording
//---------------------------------------------------------------------

void Mmu::recordFault(uint8_t at, uint8_t faultType, uint8_t level, uint32_t va, bool isInstructionFetch)
{
	uint32_t fsr = 0;
	writeBits(fsr, MmuFsrBits::EBE_HIGH_BIT, MmuFsrBits::EBE_LOW_BIT, 0); //external bus errors not modeled
	writeBits(fsr, MmuFsrBits::L_HIGH_BIT, MmuFsrBits::L_LOW_BIT, level);
	writeBits(fsr, MmuFsrBits::AT_HIGH_BIT, MmuFsrBits::AT_LOW_BIT, at);
	writeBits(fsr, MmuFsrBits::FT_HIGH_BIT, MmuFsrBits::FT_LOW_BIT, faultType);
	writeBits(fsr, MmuFsrBits::FAV_BIT, MmuFsrBits::FAV_BIT, 1);

	uint8_t faultClass = isInstructionFetch ? IACCESS_FAULT : DACCESS_FAULT;
	updateFsrFar(fsr, va, faultClass);

	switch (faultType)
	{
		case FaultType::INVALID_ADDRESS_ERROR: stats.faultsInvalidAddress++; break;
		case FaultType::PROTECTION_ERROR:      stats.faultsProtection++; break;
		case FaultType::PRIVILEGE_VIOLATION:   stats.faultsPrivilege++; break;
		case FaultType::TRANSLATION_ERROR:     stats.faultsTranslationError++; break;
	}

	log("FAULT", "type=" + std::to_string(faultType) + " at=" + std::to_string(at) + " va=" + std::to_string(va));
}

void Mmu::updateFsrFar(uint32_t fsrVal, uint32_t farVal, uint8_t faultClass)
{
	int tid = threadId_ & 1;

	//OW (Overwrite) is set only when a fault of the same class overwrites
	//an unread one (Ref Appendix H.5).
	bool overwrite = (faultClass_[tid] == faultClass) && (faultClass == IACCESS_FAULT || faultClass == DACCESS_FAULT);
	writeBits(fsrVal, MmuFsrBits::OW_BIT, MmuFsrBits::OW_BIT, overwrite ? 1 : 0);

	//An instruction-access fault may never overwrite a data-access fault
	//(Ref Appendix H.5): update unless the existing fault is a
	//DACCESS_FAULT and the new one is not.
	bool canUpdate = (faultClass_[tid] == NO_FAULT) || (faultClass_[tid] == IACCESS_FAULT) || (faultClass == DACCESS_FAULT);
	if (!canUpdate) return;

	faultStatusRegister_[tid] = fsrVal;
	faultAddressRegister_[tid] = farVal;
	faultClass_[tid] = faultClass;

	if (!independentMmuContextPerThread)
	{
		for (int i = 0; i < MAX_THREADS; i++)
		{
			faultStatusRegister_[i] = fsrVal;
			faultAddressRegister_[i] = farVal;
			faultClass_[i] = faultClass;
		}
	}

	log("FSR_FAR_UPDATE", "fsr=" + std::to_string(fsrVal) + " far=" + std::to_string(farVal));
}
