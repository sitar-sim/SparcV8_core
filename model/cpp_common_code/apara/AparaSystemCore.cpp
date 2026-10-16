//AparaSystemCore.cpp
//Original author: Madhav Desai, IITB
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the APARA engine specification and
//reference C implementation developed by Prof. Madhav Desai, IITB

#include "AparaSystemCore.h"

namespace apara
{

using SystemAddressMap::aparaDmemBase;
using SystemAddressMap::aparaCcuBase;
using SystemAddressMap::aparaDmaBase;
using SystemAddressMap::APARA_UNIT_BYTES;

namespace
{
	AparaCore::Config systemConfig(uint64_t dmemBase)
	{
		AparaCore::Config c;
		c.offIslandMode = OffIslandMode::SYSTEM_BUS;
		c.dmemWindowBase = (uint32_t) dmemBase;
		return c;
	}

	bool inWindow(uint64_t a, uint64_t base, uint64_t bytes) { return a >= base && a - base < bytes; }

	//Bus mask bit of byte k (0..7) of a doubleword.
	uint8_t busBit(unsigned int k) { return (uint8_t) (1u << (k < 4 ? 3 - k : 11 - k)); }
}

AparaSystemCore::AparaSystemCore(unsigned int cluster, unsigned int engineIndex)
	: engine(systemConfig(aparaDmemBase(cluster, engineIndex))),
	  dmemBase(aparaDmemBase(cluster, engineIndex)),
	  ccuBase(aparaCcuBase(cluster, engineIndex)),
	  dmaBase(aparaDmaBase(cluster, engineIndex))
{
	engine.setOffIslandPort(this);
}

bool AparaSystemCore::contains(uint64_t a) const
{
	return inWindow(a, dmemBase, DMEM_BYTES) || inWindow(a, ccuBase, APARA_UNIT_BYTES) || inWindow(a, dmaBase, APARA_UNIT_BYTES);
}

//----------------------------------------------------------------------
//Host side
//----------------------------------------------------------------------

void AparaSystemCore::access(const PhysicalMemoryRequest& request, PhysicalMemoryResponse& response)
{
	response.valid = true;
	response.mae = false;
	response.readData = 0;
	bool read = request.accessType == PhysicalAccessType::READ;
	uint64_t a = request.physicalAddress & ~7ULL;
	uint8_t mask = request.byteMask;
	if (read && mask == 0)
		mask = 0xFF;

	if (inWindow(a, dmemBase, DMEM_BYTES))
	{
		uint32_t index = (uint32_t) ((a - dmemBase) >> 3);
		if (read)
			response.readData = busToDmem(engine.dmemDword(index));
		else
		{
			uint8_t lanes = busMaskToDmemLanes(mask);
			uint64_t m = 0;
			for (unsigned int i = 0; i < 8; i++)
				if (lanes & (1u << i)) m |= 0xFFULL << (8 * i);
			uint64_t d = engine.dmemDword(index);
			engine.writeDmemDword(index, (d & ~m) | (busToDmem(request.data) & m));
		}
		return;
	}
	bool ccu = inWindow(a, ccuBase, APARA_UNIT_BYTES);
	if (!ccu && !inWindow(a, dmaBase, APARA_UNIT_BYTES))
		return;
	uint64_t base = ccu ? ccuBase : dmaBase;
	for (unsigned int half = 0; half < 2; half++)
	{
		uint8_t lanes = (mask >> (4 * half)) & 0xF;
		if (!lanes)
			continue;
		uint64_t offset = a + 4 * half - base;
		unsigned int unit = (unsigned int) ((offset >> 5) & 3), reg = (unsigned int) ((offset >> 2) & 7);
		if (read)
		{
			uint32_t v = ccu ? control.readRegister(unit, reg) : dma.readRegister(unit, reg);
			response.readData |= (uint64_t) v << (32 * half);
		}
		else
		{
			uint32_t v = (uint32_t) (request.data >> (32 * half));
			if (ccu) control.writeRegister(unit, reg, v, lanes);
			else     dma.writeRegister(unit, reg, v, lanes, cycle);
		}
	}
}

//----------------------------------------------------------------------
//One cycle
//----------------------------------------------------------------------

void AparaSystemCore::tick()
{
	runCommands();
	if (engine.anyRunnable())
	{
		StepResult r = engine.tick();
		if (r.executed)
		{
			bundles++;
			if (r.halted)
				control.threadStopped(r.thread, engine.thread(r.thread).error, engine.thread(r.thread).pc);
		}
	}
	movePiece();
	cycle++;
}

//The CCU's commands, each carried out at once.
void AparaSystemCore::runCommands()
{
	for (unsigned int t = 0; t < THREADS_PER_ENGINE; t++)
		if (completionWaiting_[t] && control.completionReady(t))
		{
			control.finishCommand(t, AparaControlCore::Result());
			completionWaiting_[t] = false;
		}
	int t;
	while ((t = control.commandReady()) >= 0)
	{
		AparaControlCore::Request q = control.beginCommand((unsigned int) t);
		AparaControlCore::Result r;
		switch (q.command)
		{
			case AparaControlCore::READ_IMEM:      r.imemWord = engine.imemWord(q.r2); break;
			case AparaControlCore::WRITE_IMEM:     engine.writeImemWord(q.r2, q.r3); break;
			case AparaControlCore::RESET_THREAD:   engine.resetThread(q.thread); break;
			case AparaControlCore::RUN_THREAD:     engine.startThread(q.thread, q.r1); break;
			case AparaControlCore::READ_REGISTER:  r.registerValue = engine.readRegister(q.thread, q.r2); break;
			case AparaControlCore::WRITE_REGISTER: engine.writeRegister(q.thread, q.r2, ((uint64_t) q.r6 << 32) | q.r7); break;
			case AparaControlCore::STEP:
			{
				//One bundle at R1; the thread is then stopped again.
				engine.startThread(q.thread, q.r1);
				engine.step(q.thread);
				r.nextPc = engine.thread(q.thread).pc;
				engine.thread(q.thread).active = false;
				break;
			}
			case AparaControlCore::READ_RAS_STATE:
			{
				const ThreadState& ts = engine.thread(q.rasThread);
				r.rasDepth = (uint32_t) ts.ras.size();
				r.rasTop = ts.ras.empty() ? 0 : ts.ras.back();
				break;
			}
			case AparaControlCore::READ_TIMER:     r.cycles = cycle; break;
			default: break;
		}
		if (q.command == AparaControlCore::COMPLETION && control.completionWaits(q.thread) && !control.completionReady(q.thread))
			completionWaiting_[q.thread] = true;
		else
			control.finishCommand(q.thread, r);
	}
}

//One DMA piece.
void AparaSystemCore::movePiece()
{
	AparaDmaCore::Piece p;
	if (!dma.nextPiece(p))
		return;
	unsigned int sysOffset = (unsigned int) (p.systemAddress & 7), dmemOffset = p.dmemAddress & 7;
	uint64_t sysWord = p.systemAddress & ~7ULL;
	uint32_t dmemIndex = p.dmemAddress >> 3;
	uint64_t dmemWord = engine.dmemDword(dmemIndex);
	uint8_t busMask = 0;
	for (unsigned int k = 0; k < p.bytes; k++)
		busMask |= busBit(sysOffset + k);
	if (p.toDmem)
	{
		uint64_t sys = busToDmem(systemRead(sysWord, busMask)); //big-endian bytes
		for (unsigned int k = 0; k < p.bytes; k++)
		{
			uint64_t byte = (sys >> (56 - 8 * (sysOffset + k))) & 0xFF;
			unsigned int shift = 56 - 8 * (dmemOffset + k);
			dmemWord = (dmemWord & ~(0xFFULL << shift)) | (byte << shift);
		}
		engine.writeDmemDword(dmemIndex, dmemWord);
	}
	else
	{
		uint64_t out = 0;
		for (unsigned int k = 0; k < p.bytes; k++)
		{
			uint64_t byte = (dmemWord >> (56 - 8 * (dmemOffset + k))) & 0xFF;
			out |= byte << (56 - 8 * (sysOffset + k));
		}
		systemWrite(sysWord, busMask, busToDmem(out));
	}
	dma.pieceDone(p, cycle);
}

//----------------------------------------------------------------------
//System side
//----------------------------------------------------------------------

uint64_t AparaSystemCore::systemRead(uint64_t address, uint8_t busMask)
{
	if (!system_)
		return 0;
	PhysicalMemoryRequest q{true, PhysicalAccessType::READ, false, address, 0, busMask};
	PhysicalMemoryResponse r{false, 0, false};
	system_->access(q, r);
	return r.readData;
}

void AparaSystemCore::systemWrite(uint64_t address, uint8_t busMask, uint64_t busData)
{
	if (!system_)
		return;
	PhysicalMemoryRequest q{true, PhysicalAccessType::WRITE, false, address, busData, busMask};
	PhysicalMemoryResponse r{false, 0, false};
	system_->access(q, r);
}

uint64_t AparaSystemCore::readDword(uint32_t address, uint8_t laneMask)
{
	return busToDmem(systemRead(address, busMaskToDmemLanes(laneMask)));
}

void AparaSystemCore::writeDword(uint32_t address, uint8_t laneMask, uint64_t data)
{
	systemWrite(address, busMaskToDmemLanes(laneMask), busToDmem(data));
}

}
