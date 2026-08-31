//================================================================
// OpcodeLatencies.h
// Author: Neha Karanjkar
//
// Opcode-wise per-instruction latency for the Sitar timing model.
// Included only from SparcThread.sitar. Not part of cpp_common_code/,
// since SparcCore has no notion of cycles or timing at all.
//
// getOpcodeLatency(op) returns how many cycles SparcThread spends on a
// given opcode via wait(opcode_delay, 0). A compile-time table, not a
// runtime-loaded config file. To change a latency, edit
// OPCODE_LATENCY_OVERRIDES below and rebuild.
//
// This is the latency of executing the opcode itself, charged in
// addition to whatever separate memory-access latency a memory
// instruction incurs on its own. Independent and additive, e.g. a LD
// with an opcode latency of 1 and a memory-access latency of 5 takes 6
// cycles total.
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
