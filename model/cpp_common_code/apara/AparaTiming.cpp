//AparaTiming.cpp
//Original author: Madhav Desai, IITB
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the APARA engine specification and
//reference C implementation developed by Prof. Madhav Desai, IITB

#include "AparaTiming.h"
#include <fstream>
#include <sstream>
#include <algorithm>

namespace apara
{

static_assert(sizeof(BundleToken)     == APARA_BUNDLE_TOKEN_BYTES,     "BundleToken size");
static_assert(sizeof(ResultToken)     == APARA_RESULT_TOKEN_BYTES,     "ResultToken size");
static_assert(sizeof(CorrectionToken) == APARA_CORRECTION_TOKEN_BYTES, "CorrectionToken size");
static_assert(sizeof(HaltToken)       == APARA_HALT_TOKEN_BYTES,       "HaltToken size");
static_assert(sizeof(ServiceRequest)    == APARA_SERVICE_REQUEST_BYTES,     "ServiceRequest size");
static_assert(sizeof(ServiceResponse)   == APARA_SERVICE_RESPONSE_BYTES,    "ServiceResponse size");
static_assert(sizeof(OffIslandRequest)  == APARA_OFF_ISLAND_REQUEST_BYTES,  "OffIslandRequest size");
static_assert(sizeof(OffIslandResponse) == APARA_OFF_ISLAND_RESPONSE_BYTES, "OffIslandResponse size");
static_assert(sizeof(StopNotice)        == APARA_STOP_NOTICE_BYTES,         "StopNotice size");
static_assert(sizeof(FetchControl)      == APARA_FETCH_CONTROL_BYTES,       "FetchControl size");

//----------------------------------------------------------------------
//Latency table
//----------------------------------------------------------------------

//The defaults: the microarch doc's per-opcode latency table. Entries
//marked "assumed" are not in the hardware's table (open items there).
LatencyTable::LatencyTable()
{
	table_ = {
		{"nop any", 1}, {"control any", 1}, {"halt any", 1}, {"misc any", 1}, {"logic any", 1},
		{"arith int<=32", 1}, {"arith int64", 2}, {"arith fp<=16", 1}, {"arith fp32", 3}, {"arith fp64", 3},
		{"shift int<=32", 1}, {"shift int64", 2},
		{"dot int<=32", 2}, {"dot int64", 3}, {"dot fp<=16", 2}, {"dot fp32", 3}, {"dot fp64", 3},
		{"cast narrow", 1}, {"cast wide", 2},
		{"vreduce any", 2}, //assumed
		{"cmov any", 1},    //assumed
		{"memory local", 3},
		{"divide any", 10}, {"sqrt any", 10}, //the designer's figure, to be confirmed
	};
}

namespace
{
	std::string operandGroup(const Type& t, bool fpWidths)
	{
		if (t.isFloat)
			return t.bits <= 16 ? "fp<=16" : (fpWidths && t.bits == 64 ? "fp64" : "fp32");
		return t.bits <= 32 ? "int<=32" : "int64";
	}
}

std::string LatencyTable::key(const Instruction& in)
{
	switch (in.opcode)
	{
		case Opcode::NOP: case Opcode::NULL_OP:                  return "nop any";
		case Opcode::BRANCH: case Opcode::CALL: case Opcode::RETURN: return "control any";
		case Opcode::HALT:                                       return "halt any";
		case Opcode::SET: case Opcode::SLICE: case Opcode::PACK: return "misc any";
		case Opcode::CMOV:                                       return "cmov any";
		case Opcode::LOAD: case Opcode::STORE:                   return "memory local";
		case Opcode::DIV:                                        return "divide any";
		case Opcode::FSQRT:                                      return "sqrt any";
		case Opcode::VREDUCE:                                    return "vreduce any";
		case Opcode::DOT:                                        return "dot " + operandGroup(in.type, true);
		case Opcode::OR: case Opcode::AND: case Opcode::XOR:
		case Opcode::NOR: case Opcode::NAND: case Opcode::XNOR:  return "logic any";
		case Opcode::SHL: case Opcode::SHR:                      return "shift " + operandGroup(in.type, false);
		case Opcode::ADD: case Opcode::SUB: case Opcode::MUL:    return "arith " + operandGroup(in.type, true);
		case Opcode::CAST:
		{
			const Type& s = in.castSource; const Type& d = in.destType;
			bool narrow = (!s.isFloat && !d.isFloat) || (s.isFloat && !d.isFloat)
			              || (s.isFloat && d.isFloat && s.bits <= 16 && d.bits <= 16);
			return narrow ? "cast narrow" : "cast wide";
		}
	}
	return "nop any";
}

unsigned int LatencyTable::cycles(const Instruction& in) const
{
	if (!in.valid)
		return 1;
	auto i = table_.find(key(in));
	return i == table_.end() ? 1 : i->second;
}

//The slowest instruction of the bundle. Loads and stores count as 1
//here: their time is the bundle's memory phase (memoryCycles()).
unsigned int LatencyTable::bundleCycles(const Instruction* slots, unsigned int count) const
{
	unsigned int c = 1;
	for (unsigned int s = 0; s < count; s++)
		if (slots[s].klass != InstructionClass::MEMORY)
			c = std::max(c, cycles(slots[s]));
	return c;
}

//Each DMEM bank has one 256-bit port: a bundle's accesses to the two
//banks proceed in parallel, accesses to the same bank one after another.
unsigned int LatencyTable::sameBankExtras(const StepResult& r)
{
	unsigned int perBank[2] = {0, 0};
	for (unsigned int k = 0; k < r.memoryAccessCount; k++)
		if (!r.memoryAccess[k].offIsland)
			perBank[dmemBank(r.memoryAccess[k].address)]++;
	unsigned int most = std::max(perBank[0], perBank[1]);
	return most > 1 ? most - 1 : 0;
}

unsigned int LatencyTable::memoryCycles(const StepResult& r) const
{
	if (r.memoryAccessCount == 0)
		return 0;
	return table_.at("memory local") + bankConflictCycles * sameBankExtras(r);
}

bool LatencyTable::load(const std::string& path, std::string& error)
{
	std::ifstream in(path.c_str());
	if (!in) { error = "cannot read " + path; return false; }
	std::string line;
	int n = 0;
	while (std::getline(in, line))
	{
		n++;
		size_t hash = line.find('#');
		if (hash != std::string::npos) line.erase(hash);
		std::istringstream is(line);
		std::string cls, operands, extra;
		long cycles;
		if (!(is >> cls))
			continue;
		if (!(is >> operands >> cycles) || (is >> extra) || cycles < 1 || cycles > 255)
		{
			error = path + ":" + std::to_string(n) + ": expected \"<class> <operands> <cycles 1-255>\"";
			return false;
		}
		std::string k = cls + " " + operands;
		if (table_.find(k) == table_.end())
		{
			error = path + ":" + std::to_string(n) + ": unknown entry \"" + k + "\"";
			return false;
		}
		table_[k] = (unsigned int) cycles;
	}
	return true;
}

std::string LatencyTable::toString() const
{
	std::ostringstream s;
	for (auto& e : table_)
		s << e.first << " " << e.second << "\n";
	return s.str();
}

//----------------------------------------------------------------------
//Branch target buffer
//----------------------------------------------------------------------

void BranchTargetBuffer::reset()
{
	for (unsigned int i = 0; i < ENTRIES; i++)
		entries_[i] = Entry{false, 0, NOT_TAKEN, 0};
}

bool BranchTargetBuffer::predict(uint32_t pc, uint32_t& target) const
{
	const Entry& e = entries_[pc & (ENTRIES - 1)];
	if (e.valid && e.tag == ((pc >> 8) & 0x3FFFFF) && e.counter < NOT_TAKEN)
	{
		target = e.target;
		return true;
	}
	return false;
}

void BranchTargetBuffer::train(uint32_t pc, bool taken, uint32_t target)
{
	Entry& e = entries_[pc & (ENTRIES - 1)];
	uint32_t tag = (pc >> 8) & 0x3FFFFF;
	if (e.valid && e.tag == tag)
	{
		if (taken)
		{
			if (e.counter > 0) e.counter--;
			e.target = target;
		}
		else if (e.counter < NOT_TAKEN)
			e.counter++;
	}
	else
		e = Entry{true, tag, (uint8_t) (taken ? 0 : NOT_TAKEN), taken ? target : 0};
}

//----------------------------------------------------------------------

void AparaTimingStats::add(const AparaTimingStats& o)
{
	bundlesFetched     += o.bundlesFetched;
	bundlesExecuted    += o.bundlesExecuted;
	bundlesSkipped     += o.bundlesSkipped;
	mispredicts        += o.mispredicts;
	btbPredictions     += o.btbPredictions;
	lockStallCycles    += o.lockStallCycles;
	tokenStallCycles   += o.tokenStallCycles;
	bankConflicts      += o.bankConflicts;
	dividerStallCycles += o.dividerStallCycles;
	rawHazards         += o.rawHazards;
	maskViolations     += o.maskViolations;
	interlock          = interlock && o.interlock;
	for (unsigned int t = 0; t < THREADS_PER_ENGINE; t++)
		perThreadExecuted[t] += o.perThreadExecuted[t];
}

std::string AparaTimingStats::toString() const
{
	std::ostringstream s;
	s << "bundles fetched          " << bundlesFetched << "\n"
	  << "bundles executed         " << bundlesExecuted << "\n"
	  << "bundles skipped          " << bundlesSkipped << "  (wrong path or stopped thread)\n"
	  << "mispredicts              " << mispredicts << "\n"
	  << "BTB-predicted fetches    " << btbPredictions << "\n"
	  << "register-lock stalls     " << lockStallCycles << " cycles\n"
	  << "REGFILE token stalls     " << tokenStallCycles << " cycles\n"
	  << "DMEM bank conflicts      " << bankConflicts << "\n"
	  << "divider stalls           " << dividerStallCycles << " cycles\n"
	  << "REGFILE interlock        " << (interlock ? "on" : "off") << "\n"
	  << "RAW hazards              " << rawHazards << "\n"
	  << "lock-mask violations     " << maskViolations << "\n";
	for (unsigned int t = 0; t < THREADS_PER_ENGINE; t++)
		s << "thread " << t << " bundles executed " << perThreadExecuted[t] << "\n";
	return s.str();
}

}
