//AparaCore.h
//
//Functional model of one APARA engine: four hardware threads sharing an
//instruction memory (IMEM), a data memory (DMEM) and the execution units.
//
//This is our own implementation of the engine's architecture. Its
//reference is the APARA reference model (McodeMachine/McodeAccelerator
//in engine_isp/assembler of the APARA repository): it matches the
//reference's results except for the deviations listed in
//docs/source/apara/deviations.md, each of which is marked "Deviation" below.
//
//Architectural state per thread: a PC (in instruction words), 32 64-bit
//registers ($r0 reads as 0), a return-address stack (RAS) of depth 64,
//active and halted flags, and an ERROR register:
//  bit 26     RAS error (push into a full RAS, return from an empty one)
//  bit 25     the thread executed $halt
//  bit 24     an exception stopped the thread
//  [23:0]     a 3-bit exception code per bundle slot (slot s in bits
//             [3s+2:3s]), see ExceptionCode.
//
//Execution is bundle by bundle. A step of a thread:
//  1. fetch: the bundle starts at the PC (its first word has bit 31 set)
//     and holds the following words of the same 8-word IMEM line up to
//     the next start bit, a zero word, or the end of the line. The bundle
//     must be complete and aligned: 8 slots if it holds a control
//     transfer, memory access, divide or square root, otherwise 1, 2, 4
//     or 8 slots, and its address a multiple of its size. In an 8-slot
//     bundle a control transfer must be in slot 0, a divide or square
//     root in slot 1, and loads and stores in slots 4 to 7 (the
//     hardware's slot rules; the assembler places them so).
//  2. read: every slot reads its source registers; all slots see the
//     registers as they were before the bundle.
//  3. execute: the slots compute in slot order. Exceptions are detected
//     here, before any memory access.
//  4. memory and commit: if no slot raised an exception, the memory
//     accesses happen in slot order (a load sees a store of an earlier
//     slot of the same bundle), then the register writes are applied in
//     slot order (on a conflict the later slot wins), then the PC. A
//     bundle that raises an exception changes nothing: the thread halts
//     at the bundle's PC with the exception codes in ERROR.
//
//Data memory addresses are byte addresses. DMEM holds 64-bit words in
//big-endian byte order: the byte at an address with (address & 7) == 0
//is bits [63:56]. How an address maps to DMEM is OffIslandMode's choice.

#ifndef APARA_CORE_H
#define APARA_CORE_H

#include <stdint.h>
#include <string>
#include <vector>
#include <functional>
#include "AparaInstruction.h"
#include "AparaOperations.h"

namespace apara
{
	const unsigned int THREADS_PER_ENGINE = 4;
	const unsigned int REGISTERS          = 32;
	const unsigned int RAS_DEPTH          = 64;
	const unsigned int IMEM_WORDS         = 4096; //16 KB (Deviation: the reference has 2048 words)
	const unsigned int DMEM_DWORDS        = 8192; //64 KB
	const unsigned int DMEM_BYTES         = DMEM_DWORDS * 8;
	const unsigned int BUNDLE_MAX_SLOTS   = 8;

	const uint32_t ERROR_RAS       = 1u << 26;
	const uint32_t ERROR_HALT      = 1u << 25;
	const uint32_t ERROR_EXCEPTION = 1u << 24;

	//Where data addresses go.
	enum class OffIslandMode
	{
		//Standalone engine: every address aliases into DMEM, modulo its
		//size (as the reference model does).
		ALIAS_TO_LOCAL,
		//Engine in a system: addresses below DMEM_BYTES and addresses in
		//the engine's own DMEM window (Config::dmemWindowBase) are DMEM,
		//all others go to the off-island port.
		SYSTEM_BUS
	};

	//A memory outside the engine, for OffIslandMode::SYSTEM_BUS. Addresses
	//are byte addresses of 64-bit words (multiples of 8); the lane mask has
	//bit i set for bits [8i+7:8i] of the word, data in place.
	class OffIslandPort
	{
		public:
		virtual ~OffIslandPort() {}
		virtual uint64_t readDword(uint32_t address, uint8_t laneMask) = 0;
		virtual void     writeDword(uint32_t address, uint8_t laneMask, uint64_t data) = 0;
	};

	struct ThreadState
	{
		uint32_t pc = 0;
		uint64_t r[REGISTERS] = {};
		std::vector<uint32_t> ras;
		bool     active = false;
		bool     halted = false;
		uint32_t error  = 0;
		uint64_t bundlesExecuted = 0;

		bool runnable() const { return active && !halted; }
	};

	//A fetched bundle.
	struct Bundle
	{
		uint32_t    pc    = 0;
		unsigned    size  = 0;    //slots
		bool        valid = false;
		std::string problem;      //why it is not valid
		Instruction slot[BUNDLE_MAX_SLOTS];
		uint8_t     misplaced = 0; //slots holding an instruction its slot cannot run
		                           //(raises ILLEGAL there, as the hardware's
		                           //instruction_alignment_error halts the thread)
	};

	//One memory access of a bundle, for the timing model.
	struct MemoryAccess
	{
		uint8_t  slot      = 0;
		bool     store     = false;
		uint32_t address   = 0;     //byte address
		uint16_t bytes     = 0;
		bool     offIsland = false;
	};

	//What one step of a thread did.
	struct StepResult
	{
		bool          executed  = false; //false: the thread was not runnable
		unsigned int  thread    = 0;
		const Bundle* bundle    = nullptr;
		uint32_t      pc        = 0;
		uint32_t      nextPc    = 0;
		bool          redirect  = false; //nextPc is not pc + size (taken branch, call, return)
		bool          halted    = false; //the thread halted at this bundle
		bool          exception = false;
		unsigned int  memoryAccessCount = 0;
		MemoryAccess  memoryAccess[BUNDLE_MAX_SLOTS];
	};

	class AparaCore
	{
		public:
		struct Config
		{
			OffIslandMode offIslandMode  = OffIslandMode::ALIAS_TO_LOCAL;
			uint32_t      dmemWindowBase = 0; //SYSTEM_BUS: where the system sees this DMEM
		};

		AparaCore();
		explicit AparaCore(const Config& config);

		void setOffIslandPort(OffIslandPort* port) { offIsland_ = port; }

		//Reset all threads: inactive, PC 0, registers 0, RAS empty, ERROR 0.
		void resetThreads();
		//Start thread t at pc (clears halted and ERROR, keeps registers).
		void startThread(unsigned int t, uint32_t pc);

		//Run one bundle on thread t.
		StepResult step(unsigned int t);
		//Run one bundle on the next runnable thread in round-robin order.
		StepResult tick();
		bool anyRunnable() const;

		//State access (for loaders, the host-side units and tests).
		ThreadState&       thread(unsigned int t)       { return threads_[t & 3]; }
		const ThreadState& thread(unsigned int t) const { return threads_[t & 3]; }
		uint64_t readRegister(unsigned int t, unsigned int r) const { return threads_[t & 3].r[r & 31]; }
		void     writeRegister(unsigned int t, unsigned int r, uint64_t v) { if (r & 31) threads_[t & 3].r[r & 31] = v; }

		uint32_t imemWord(uint32_t index) const { return index < IMEM_WORDS ? imem_[index] : 0; }
		void     writeImemWord(uint32_t index, uint32_t word);
		uint64_t dmemDword(uint32_t index) const { return dmem_[index % DMEM_DWORDS]; }
		void     writeDmemDword(uint32_t index, uint64_t value) { dmem_[index % DMEM_DWORDS] = value; }

		//The bundle at pc (decoded once per address and cached).
		const Bundle& bundleAt(uint32_t pc);

		const Config& config() const { return config_; }

		private:
		struct PendingWrite { uint8_t reg; uint64_t value; };
		struct SlotWork;

		Config         config_;
		ThreadState    threads_[THREADS_PER_ENGINE];
		unsigned int   nextThread_ = 0;
		uint32_t       imem_[IMEM_WORDS];
		uint64_t       dmem_[DMEM_DWORDS];
		OffIslandPort* offIsland_ = nullptr;

		std::vector<Bundle> bundleCache_;
		std::vector<bool>   bundleCached_;
		Bundle              beyond_; //the (invalid) bundle at a PC beyond IMEM

		Bundle fetchBundle(uint32_t pc) const;
		void   executeSlot(const ThreadState& ts, const Bundle& b, unsigned int s, SlotWork& w);

		bool     isOffIsland(uint32_t address) const;
		uint64_t readDword(uint32_t address, uint8_t laneMask);
		void     writeDword(uint32_t address, uint8_t laneMask, uint64_t data);
	};
}

#endif
