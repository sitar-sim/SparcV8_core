//AparaSystemCore.h
//
//One APARA engine attached to a system, for the functional (cpp) model:
//the engine (AparaCore), its control unit (AparaControlCore) and DMA unit
//(AparaDmaCore), joined as the hardware joins them.
//
//Host side: a PhysicalMemoryInterface for the system bus, decoding the
//engine's three windows in the system's physical address space (Ref
//SystemAddressMap.h's AJIT_APARA layout for their addresses):
//  DMEM window    64 KB  dmemBase:  the engine's DMEM
//  CCU registers  128 B  ccuBase:   thread addr[6:5], register addr[4:2]
//  DMA registers  128 B  dmaBase:   channel addr[6:5], register addr[4:2]
//Bus data is a doubleword of two big-endian 32-bit words, the lower
//address in the low half; DMEM holds big-endian doublewords. The two
//differ by a swap of the halves (Ref busToDmem()).
//
//System side: the engine's off-island loads and stores, and the DMA's
//transfers, go to `system` (the bus), as physical accesses.
//
//tick() advances everything by one cycle: the CCU runs the commands the
//host has started, the engine runs one bundle (its threads in turn), the
//DMA moves one piece (up to 8 bytes). interrupt() is the engine's
//interrupt pin: the CCU's or the DMA's.

#ifndef APARA_SYSTEM_CORE_H
#define APARA_SYSTEM_CORE_H

#include <stdint.h>
#include "AparaCore.h"
#include "AparaControlCore.h"
#include "AparaDmaCore.h"
#include "MemoryInterfaces.h"
#include "SystemAddressMap.h"

namespace apara
{
	//Bus doubleword <-> DMEM doubleword, and their byte masks.
	inline uint64_t busToDmem(uint64_t d) { return (d << 32) | (d >> 32); }
	inline uint8_t  busMaskToDmemLanes(uint8_t m) { return (uint8_t) ((m << 4) | (m >> 4)); }

	class AparaSystemCore : public PhysicalMemoryInterface, private OffIslandPort
	{
		public:
		AparaSystemCore(unsigned int cluster = 0, unsigned int engine = 0);

		void setSystem(PhysicalMemoryInterface* system) { system_ = system; }

		//Host access to the windows.
		void access(const PhysicalMemoryRequest& request, PhysicalMemoryResponse& response) override;
		bool contains(uint64_t physicalAddress) const;

		void tick();
		bool interrupt() const { return control.interrupt() || dma.interrupt(); }

		AparaCore        engine;
		AparaControlCore control;
		AparaDmaCore     dma;

		uint64_t cycle = 0;
		uint64_t bundles = 0;

		const uint64_t dmemBase, ccuBase, dmaBase;

		private:
		PhysicalMemoryInterface* system_ = nullptr;
		//A COMPLETION command waiting for its thread to stop, per thread.
		bool completionWaiting_[THREADS_PER_ENGINE] = {false, false, false, false};

		void runCommands();
		void movePiece();

		//OffIslandPort: the engine's off-island accesses, to the bus.
		uint64_t readDword(uint32_t address, uint8_t laneMask) override;
		void     writeDword(uint32_t address, uint8_t laneMask, uint64_t data) override;
		uint64_t systemRead(uint64_t address, uint8_t busMask);
		void     systemWrite(uint64_t address, uint8_t busMask, uint64_t busData);
	};
}

#endif
