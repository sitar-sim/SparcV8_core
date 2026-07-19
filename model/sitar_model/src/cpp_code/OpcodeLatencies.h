//================================================================
// OpcodeLatencies.h
// Author: Neha Karanjkar
//
// Opcode-wise per-instruction latency, for the Sitar timing model.
//
// This is deliberately NOT part of model/cpp_common_code/ -- the C++ core
// (SparcCore) has no notion of cycles or timing at all, by design (see
// model/README.md); timing lives entirely in the Sitar layer that
// drives it. This file is included only from SparcThread.sitar.
//
// getOpcodeLatency(op) returns how many cycles SparcThread should spend
// executing a given opcode, on top of the 1 cycle a `do`/`wait until
// this_phase==1` loop iteration already takes structurally. This is a
// compile-time table, not a runtime-loaded config file: to change a
// latency, edit OPCODE_LATENCY_OVERRIDES below and rebuild.
//
// IMPORTANT: this is the latency of *executing* the opcode itself
// (decode/ALU/etc.), and is charged IN ADDITION TO whatever separate
// memory-access latency a load/store/ifetch/atomic/flush instruction
// incurs via MemoryInterface.delay and/or MainMemory.delay (see
// MemoryInterface.sitar and MainMemory.sitar -- two independent knobs on
// either side of that connection). All three are independent and
// additive, e.g. a LD with an opcode latency of 1, a MemoryInterface
// delay of 2, and a MainMemory delay of 3 takes 6 cycles total, not 3.
//================================================================

#ifndef OPCODE_LATENCIES_H
#define OPCODE_LATENCIES_H

#include "Opcodes.h"
#include <unordered_map>

// Latency (in cycles) charged to every opcode that is NOT listed in
// OPCODE_LATENCY_OVERRIDES below.
#define DEFAULT_PER_OPCODE_DELAY 1

// Opcodes whose latency differs from DEFAULT_PER_OPCODE_DELAY above.
// List only the exceptions here -- every opcode not mentioned uses the
// default. Values are in cycles, and (as above) are on top of any
// separate memory-access latency for memory instructions.
//
// This table is intentionally empty by default (this model currently
// treats every opcode as equally 1 cycle); add entries as needed, e.g.
// to approximate a multi-cycle multiplier/divider:
//
//   static const std::unordered_map<Opcode, uint32_t> OPCODE_LATENCY_OVERRIDES = {
//       {UMUL, 4}, {SMUL, 4}, {UMULcc, 4}, {SMULcc, 4},
//       {UDIV, 8}, {SDIV, 8}, {UDIVcc, 8}, {SDIVcc, 8},
//   };
static const std::unordered_map<Opcode, uint32_t> OPCODE_LATENCY_OVERRIDES = {
};

inline uint32_t getOpcodeLatency(Opcode op)
{
	auto it = OPCODE_LATENCY_OVERRIDES.find(op);
	if (it != OPCODE_LATENCY_OVERRIDES.end())
		return it->second;
	return DEFAULT_PER_OPCODE_DELAY;
}

#endif
