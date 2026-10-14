//AparaDmaCore.h
//
//The APARA engine's DMA unit as seen by the host: 4 channels of 8 32-bit
//registers, each copying data between the engine's DMEM and system
//memory in bursts (Ref the APARA hardware's dma/control.aa).
//
//Registers of a channel (byte offset 4*index in its 32-byte block):
//  R0 control: [31:24] operation (1 load: system memory to DMEM, 2 store:
//     DMEM to system memory), [23:20] and [19:16] the top 4 bits of the
//     36-bit source and destination addresses, [15:8] sequence number,
//     flags [4] error, [3] interrupt enable, [2] completed, [1] started,
//     [0] scheduled
//  R1 source base address     R2 destination base address
//  R3 total bytes (informational)
//  R4 burst count             R5 gap: the distance between bursts
//  R6 bytes per burst; the stop cycle once completed
//  R7 the start cycle
//
//A channel starts when its R0 has scheduled set and started, completed
//and error clear. A load gathers: burst i comes from source + i*gap and
//goes to destination + i*(bytes per burst); a store scatters, the
//reverse. The DMEM side's address is taken modulo the DMEM size.
//On completion: started clear, completed set, and the DMA interrupt if
//interrupt enable is set. Writing R0 with interrupt enable clear clears
//the interrupt.
//
//(control.aa uses flag bit 3 as interrupt enable, as the error flag on
//completion, and as "clear the interrupt" when written, and never starts
//a command with it set; the layout above is our choice, Ref
//docs/source/apara/deviations.md.)
//
//The class keeps the registers and the copy's progress; moving the data
//is the caller's, a piece at a time (nextPiece(), pieceDone()), so the
//timing model can give each piece its bus transaction.

#ifndef APARA_DMA_CORE_H
#define APARA_DMA_CORE_H

#include <stdint.h>

namespace apara
{
	class AparaDmaCore
	{
		public:
		static const unsigned int CHANNELS  = 4;
		static const unsigned int REGISTERS = 8;

		static const uint8_t  LOAD  = 1;
		static const uint8_t  STORE = 2;
		static const uint32_t FLAG_SCHEDULED        = 1u << 0;
		static const uint32_t FLAG_STARTED          = 1u << 1;
		static const uint32_t FLAG_COMPLETED        = 1u << 2;
		static const uint32_t FLAG_INTERRUPT_ENABLE = 1u << 3;
		static const uint32_t FLAG_ERROR            = 1u << 4;

		//One piece of a copy: at most 8 bytes, within one 64-bit word on
		//each side. For a load, read `bytes` from system memory at
		//`systemAddress` and write them to DMEM at `dmemAddress`; for a
		//store, the other way.
		struct Piece
		{
			unsigned int channel;
			bool         toDmem;
			uint64_t     systemAddress;
			uint32_t     dmemAddress;
			unsigned int bytes;
		};

		AparaDmaCore() { reset(); }
		void reset();

		uint32_t readRegister(unsigned int channel, unsigned int index) const;
		void     writeRegister(unsigned int channel, unsigned int index, uint32_t value, uint8_t laneMask, uint64_t now);

		//The next piece to move (channels in round-robin order, a piece at
		//a time). False if no channel is copying.
		bool nextPiece(Piece& p);
		//The piece from nextPiece() is done; `now` stamps a completion.
		void pieceDone(const Piece& p, uint64_t now);

		bool busy() const;
		bool interrupt() const { return interrupt_; }

		private:
		struct Progress
		{
			bool     active;
			uint32_t burst;     //index of the current burst
			uint32_t offset;    //bytes done in it
		};
		uint32_t reg_[CHANNELS][REGISTERS];
		Progress progress_[CHANNELS];
		unsigned int nextChannel_;
		bool     interrupt_;

		void start(unsigned int c, uint64_t now);
		void finish(unsigned int c, uint64_t now, bool error);
	};
}

#endif
