//AparaCore.cpp

#include "AparaCore.h"
#include <cstring>

namespace apara
{

//What one slot of a bundle does, worked out in the execute phase and
//applied in the memory and commit phases.
struct AparaCore::SlotWork
{
	ExceptionCode exception = ExceptionCode::NONE;
	PendingWrite  write[5];
	unsigned int  writeCount = 0;

	//memory access
	bool     memory  = false;
	bool     store   = false;
	uint32_t address = 0;
	unsigned bytes   = 0;
	unsigned regs    = 0;
	bool     signExtendLoad = false;
	uint8_t  rd      = 0;
	uint64_t storeData[4] = {0, 0, 0, 0};
	bool     incrementBase = false; //write rs2 + increment after the loaded registers
	uint8_t  rs2     = 0;
	uint64_t nextRs2 = 0;

	//control
	bool     setsPc   = false;
	uint32_t nextPc   = 0;
	int      rasOp    = 0;     //+1 push, -1 pop
	uint32_t rasPush  = 0;
	bool     rasError = false;
	bool     halt     = false;

	void addWrite(unsigned int reg, uint64_t value)
	{
		write[writeCount].reg = (uint8_t) (reg & 31);
		write[writeCount].value = value;
		writeCount++;
	}
};

AparaCore::AparaCore() : AparaCore(Config()) {}

AparaCore::AparaCore(const Config& config) : config_(config)
{
	std::memset(imem_, 0, sizeof(imem_));
	std::memset(dmem_, 0, sizeof(dmem_));
	bundleCache_.resize(IMEM_WORDS);
	bundleCached_.assign(IMEM_WORDS, false);
	resetThreads();
}

void AparaCore::resetThreads()
{
	for (unsigned int t = 0; t < THREADS_PER_ENGINE; t++)
		threads_[t] = ThreadState();
	nextThread_ = 0;
}

void AparaCore::startThread(unsigned int t, uint32_t pc)
{
	ThreadState& ts = threads_[t & 3];
	ts.pc     = pc;
	ts.active = true;
	ts.halted = false;
	ts.error  = 0;
	ts.ras.clear();
}

bool AparaCore::anyRunnable() const
{
	for (unsigned int t = 0; t < THREADS_PER_ENGINE; t++)
		if (threads_[t].runnable())
			return true;
	return false;
}

void AparaCore::writeImemWord(uint32_t index, uint32_t word)
{
	if (index >= IMEM_WORDS)
		return;
	imem_[index] = word;
	for (uint32_t i = index & ~7u; i < (index & ~7u) + 8; i++)
		bundleCached_[i] = false;
}

//----------------------------------------------------------------------
//Fetch
//----------------------------------------------------------------------

Bundle AparaCore::fetchBundle(uint32_t pc) const
{
	Bundle b;
	b.pc = pc;
	uint32_t line = pc & ~7u, offset = pc & 7u;
	uint32_t first = imemWord(pc);
	if (pc >= IMEM_WORDS)       { b.problem = "the PC is beyond IMEM"; return b; }
	if (first == 0)             { b.problem = "no instruction at the PC"; return b; }
	if (!(first >> 31))         { b.problem = "no bundle starts at the PC"; return b; }

	unsigned int n = 0, controls = 0;
	bool full = false;
	for (uint32_t i = offset; i < 8; i++)
	{
		uint32_t w = imemWord(line + i);
		if (w == 0 || (i > offset && (w >> 31)))
			break;
		b.slot[n] = Instruction::decode(w);
		const Instruction& in = b.slot[n];
		unsigned int s = i - offset;
		if ((in.isControl() && s != 0) || ((in.opcode == Opcode::DIV || in.opcode == Opcode::FSQRT) && s != 1)
		    || (in.klass == InstructionClass::MEMORY && s < 4))
			b.misplaced |= (uint8_t) (1u << s);
		full = full || in.needsFullBundle();
		controls += b.slot[n].isControl() ? 1 : 0;
		n++;
	}
	b.size = n;
	//A bundle is padded to its capacity (Ref the reference's
	//Calculate_Capacity): 8 slots if it needs the full bundle, otherwise
	//the next power of two.
	if (full && n != 8)                    b.problem = "a bundle with a control transfer, memory access, divide or square root must have 8 slots";
	else if (n != 1 && n != 2 && n != 4 && n != 8) b.problem = "a bundle must have 1, 2, 4 or 8 slots";
	else if (pc % n != 0)                  b.problem = "a bundle's address must be a multiple of its size";
	else if (controls > 1)                 b.problem = "a bundle can hold one control transfer";
	b.valid = b.problem.empty();
	return b;
}

const Bundle& AparaCore::bundleAt(uint32_t pc)
{
	if (pc >= IMEM_WORDS)
	{
		beyond_ = fetchBundle(pc);
		return beyond_;
	}
	if (!bundleCached_[pc])
	{
		bundleCache_[pc] = fetchBundle(pc);
		bundleCached_[pc] = true;
	}
	return bundleCache_[pc];
}

//----------------------------------------------------------------------
//Execute
//----------------------------------------------------------------------

void AparaCore::executeSlot(const ThreadState& ts, const Bundle& b, unsigned int s, SlotWork& w)
{
	const Instruction& in = b.slot[s];
	const uint32_t address = b.pc + s; //this instruction's own address
	auto R = [&](unsigned int r) { return ts.r[r & 31]; };

	if (!in.valid || (b.misplaced >> s) & 1)
	{
		w.exception = ExceptionCode::ILLEGAL;
		return;
	}

	OpResult result;
	bool hasResult = false;
	switch (in.opcode)
	{
		case Opcode::NOP:
		case Opcode::NULL_OP:
			return;

		case Opcode::HALT:
			w.halt = true;
			return;

		//A call's target is relative to the call's own address, by a
		//label offset or by a register value. It pushes the address of
		//the next bundle.
		case Opcode::CALL:
			w.setsPc  = true;
			w.nextPc  = address + (in.immediate ? (uint32_t) in.jump : (uint32_t) R(in.rs2));
			w.rasOp   = 1;
			w.rasPush = b.pc + b.size;
			w.rasError = ts.ras.size() >= RAS_DEPTH; //Deviation: the reference asserts
			return;

		//Deviation: the reference's return reads the top of the RAS without
		//popping it, so only one level of calls returns correctly.
		case Opcode::RETURN:
			if (ts.ras.empty()) { w.rasError = true; return; }
			w.setsPc = true;
			w.nextPc = ts.ras.back();
			w.rasOp  = -1;
			return;

		case Opcode::BRANCH:
			if (conditionHolds(in.condition, in.type, R(in.rs2)))
			{
				w.setsPc = true;
				w.nextPc = address + (uint32_t) in.jump;
			}
			if (in.increment != 0)
				w.addWrite(in.rs2, R(in.rs2) + (uint64_t) (int64_t) in.increment);
			return;

		//$rd = $rs1 if $rs2 satisfies the condition. Deviations: the
		//reference writes $rs2 back (as its test value plus the increment)
		//even with no increment, and does not sign-extend the increment.
		case Opcode::CMOV:
			if (in.increment != 0)
				w.addWrite(in.rs2, R(in.rs2) + (uint64_t) (int64_t) in.increment);
			if (conditionHolds(in.condition, in.type, R(in.rs2)))
				w.addWrite(in.rd, R(in.rs1));
			return;

		case Opcode::SET:
			w.addWrite(in.rd, (uint64_t) in.setValue << (8 * in.setByteIndex));
			return;

		case Opcode::SLICE:
			w.addWrite(in.rd, slice(R(in.rs2), in.sliceHigh, in.sliceLow));
			return;

		case Opcode::PACK:
		{
			unsigned int n = (in.packedBits + in.wordBits - 1) / in.wordBits;
			uint64_t v[32];
			for (unsigned int i = 0; i < n; i++)
				v[i] = R(in.rs2 + i);
			result = pack(in.packedBits, in.wordBits, v, n);
			hasResult = true;
			break;
		}

		case Opcode::CAST:
		{
			unsigned int n = 1;
			if (in.castSource.isVector && in.type.bits < in.castSource.bits)
				n = in.castSource.bits / in.type.bits;
			uint64_t v[2] = {R(in.rs2), R(in.rs2 + 1)};
			result = cast(in.destType, in.castSource, v, n);
			hasResult = true;
			break;
		}

		case Opcode::FSQRT:
			result = squareRoot(in.type, R(in.rs1));
			hasResult = true;
			break;

		case Opcode::DOT:
			result = dot(in.type, R(in.rs1), R(in.rs2), in.flag, R(in.rd));
			hasResult = true;
			break;

		case Opcode::VREDUCE:
			result = vectorReduce(in.subOpcode, in.type, R(in.rs1));
			hasResult = true;
			break;

		case Opcode::LOAD:
		case Opcode::STORE:
		{
			uint32_t offset = in.immediate ? (uint32_t) in.immValue : (uint32_t) R(in.rs2);
			w.memory  = true;
			w.store   = in.opcode == Opcode::STORE;
			w.address = (uint32_t) R(in.rs1) + offset;
			w.bytes   = in.transferBytes();
			w.regs    = in.transferRegisters();
			w.rd      = in.rd;
			w.signExtendLoad = in.type.isSigned();
			//Deviation: the reference checks 32-byte transfers for 2-byte
			//alignment only.
			if (w.address % w.bytes != 0)
			{
				w.exception = ExceptionCode::UNALIGNED;
				return;
			}
			if (w.store)
				for (unsigned int k = 0; k < w.regs; k++)
					w.storeData[k] = R(in.rd + k);
			if (!in.immediate && in.increment != 0)
			{
				w.incrementBase = true;
				w.rs2     = in.rs2;
				w.nextRs2 = R(in.rs2) + (uint64_t) ((int64_t) w.bytes * in.increment);
			}
			return;
		}

		default: //ALU and VALU
			if (in.isVector)
				result = vectorAlu(in.opcode, in.type, R(in.rs1), R(in.rs2), in.flag);
			else
				result = scalarAlu(in.opcode, in.type, R(in.rs1),
				                   in.immediate ? (uint64_t) (int64_t) in.immValue : R(in.rs2));
			hasResult = true;
			break;
	}

	if (hasResult)
	{
		w.exception = result.exception;
		if (w.exception == ExceptionCode::NONE)
			for (unsigned int i = 0; i < result.count; i++)
				w.addWrite(in.rd + i, result.value[i]);
	}
}

StepResult AparaCore::step(unsigned int t)
{
	ThreadState& ts = threads_[t & 3];
	StepResult res;
	res.thread = t & 3;
	if (!ts.runnable())
		return res;

	res.executed = true;
	res.pc = ts.pc;
	const Bundle& b = bundleAt(ts.pc);
	res.bundle = &b;

	if (!b.valid)
	{
		ts.error |= ERROR_EXCEPTION | (uint32_t) ExceptionCode::ILLEGAL;
		ts.halted = true;
		res.exception = res.halted = true;
		res.nextPc = ts.pc;
		return res;
	}

	//Read and execute (the registers do not change until the commit).
	SlotWork work[BUNDLE_MAX_SLOTS];
	uint32_t codes = 0;
	bool rasError = false;
	for (unsigned int s = 0; s < b.size; s++)
	{
		executeSlot(ts, b, s, work[s]);
		codes |= (uint32_t) work[s].exception << (3 * s);
		rasError = rasError || work[s].rasError;
	}
	if (codes != 0 || rasError)
	{
		ts.error |= codes | (codes ? ERROR_EXCEPTION : 0) | (rasError ? ERROR_RAS : 0);
		ts.halted = true;
		res.exception = res.halted = true;
		res.nextPc = ts.pc;
		return res;
	}

	//Memory, in slot order.
	for (unsigned int s = 0; s < b.size; s++)
	{
		SlotWork& w = work[s];
		if (!w.memory)
			continue;
		MemoryAccess& m = res.memoryAccess[res.memoryAccessCount++];
		m.slot = (uint8_t) s;
		m.store = w.store;
		m.address = w.address;
		m.bytes = (uint16_t) w.bytes;
		m.offIsland = isOffIsland(w.address);

		if (w.regs > 1) //128 and 256 bits: whole words
		{
			for (unsigned int k = 0; k < w.regs; k++)
			{
				if (w.store) writeDword(w.address + 8 * k, 0xFF, w.storeData[k]);
				else         w.addWrite(w.rd + k, readDword(w.address + 8 * k, 0xFF));
			}
		}
		else
		{
			//The transfer's place in its big-endian 64-bit word.
			//Deviation: the reference picks the half of a 4-byte load by
			//address bit 1 (its store uses bit 2, as here).
			unsigned int shift = 8 * (8 - w.bytes - (w.address & 7));
			uint8_t lanes = (uint8_t) (lowMask(w.bytes) << (shift / 8));
			uint64_t valueMask = lowMask(8 * w.bytes);
			if (w.store)
				writeDword(w.address, lanes, (w.storeData[0] & valueMask) << shift);
			else
			{
				uint64_t v = (readDword(w.address, lanes) >> shift) & valueMask;
				w.addWrite(w.rd, w.signExtendLoad ? signExtend(v, 8 * w.bytes) : v);
			}
		}
		if (w.incrementBase)
			w.addWrite(w.rs2, w.nextRs2);
	}

	//Commit, in slot order.
	uint32_t nextPc = b.pc + b.size;
	bool halt = false;
	for (unsigned int s = 0; s < b.size; s++)
	{
		const SlotWork& w = work[s];
		for (unsigned int i = 0; i < w.writeCount; i++)
			if (w.write[i].reg != 0)
				ts.r[w.write[i].reg] = w.write[i].value;
		if (w.rasOp > 0) ts.ras.push_back(w.rasPush);
		if (w.rasOp < 0) ts.ras.pop_back();
		if (w.setsPc) nextPc = w.nextPc;
		halt = halt || w.halt;
	}
	res.redirect = nextPc != b.pc + b.size;
	res.nextPc = nextPc;
	ts.pc = nextPc;
	ts.bundlesExecuted++;
	if (halt)
	{
		ts.halted = true;
		ts.error |= ERROR_HALT;
		res.halted = true;
	}
	return res;
}

StepResult AparaCore::tick()
{
	for (unsigned int i = 0; i < THREADS_PER_ENGINE; i++)
	{
		unsigned int t = (nextThread_ + i) & 3;
		if (threads_[t].runnable())
		{
			nextThread_ = (t + 1) & 3;
			return step(t);
		}
	}
	return StepResult();
}

//----------------------------------------------------------------------
//Data memory
//----------------------------------------------------------------------

bool AparaCore::isOffIsland(uint32_t address) const
{
	if (config_.offIslandMode == OffIslandMode::ALIAS_TO_LOCAL)
		return false;
	return address >= DMEM_BYTES && (address - config_.dmemWindowBase) >= DMEM_BYTES;
}

uint64_t AparaCore::readDword(uint32_t address, uint8_t laneMask)
{
	if (isOffIsland(address))
		return offIsland_ ? offIsland_->readDword(address & ~7u, laneMask) : 0;
	return dmem_[(address >> 3) % DMEM_DWORDS];
}

void AparaCore::writeDword(uint32_t address, uint8_t laneMask, uint64_t data)
{
	if (isOffIsland(address))
	{
		if (offIsland_)
			offIsland_->writeDword(address & ~7u, laneMask, data);
		return;
	}
	uint64_t mask = 0;
	for (unsigned int i = 0; i < 8; i++)
		if (laneMask & (1u << i))
			mask |= 0xFFULL << (8 * i);
	uint64_t& d = dmem_[(address >> 3) % DMEM_DWORDS];
	d = (d & ~mask) | (data & mask);
}

}
