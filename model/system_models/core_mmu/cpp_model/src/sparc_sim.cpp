//sparc_sim.cpp
//
//The core_mmu configuration's entry point. Identical to core_only's own
//sparc_sim.cpp, except SparcStateMachine drives SparcCore through an
//MmuCore instance instead of talking to MemCore directly. The MMU's
//downstream target is a MainMemory, which wraps a MemCore for the
//actual backing storage.
//
//MEM checks in the expected-results file read straight from
//MainMemory's own plain readWord(), not through the MMU, since they're
//checking physical memory state directly, what a test setting up page
//tables needs.
//
//Usage: sparc_sim_cpp <hex_file> [expected_file] [max_cycles] [--stats]
//
//--stats prints the core's instruction-mix counters, the MMU's
//statistics, and physical memory's own access counters (see
//SparcCoreStats.h, MmuStats.h, MainMemoryStats.h), layered
//innermost-to-outermost, once the run finishes, to stdout, ahead of
//the state/PASS-FAIL report below. Off by default. Can appear anywhere
//among the arguments.

#include "SparcCore.h"
#include "MainMemory.h"
#include "SparcStateMachine.h"
#include "MmuCore.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <cctype>
#include <cstdlib>

static std::string traceFileName(const std::string& hexFile)
{
	std::string base = hexFile;
	std::string::size_type slash = base.find_last_of("/\\");
	if (slash != std::string::npos)
		base = base.substr(slash + 1);

	const std::string suffix = ".hex";
	if (base.size() >= suffix.size() &&
	    base.compare(base.size() - suffix.size(), suffix.size(), suffix) == 0)
		base = base.substr(0, base.size() - suffix.size());

	return base + ".log";
}

static bool getRegisterValue(Registers& reg, const std::string& name, uint32_t& value)
{
	if (name.size() >= 2 && (name[0] == 'g' || name[0] == 'o' || name[0] == 'l' || name[0] == 'i')
	    && isdigit((unsigned char)name[1]))
	{
		int n = std::atoi(name.c_str() + 1);
		if (n < 0 || n > 7)
			return false;
		int base = (name[0] == 'g') ? 0 : (name[0] == 'o') ? 8 : (name[0] == 'l') ? 16 : 24;
		value = reg.R_r(base + n);
		return true;
	}
	if (name.size() >= 2 && name[0] == 'f' && isdigit((unsigned char)name[1]))
	{
		int n = std::atoi(name.c_str() + 1);
		if (n < 0 || n > 31)
			return false;
		value = reg.R_f(n);
		return true;
	}
	if (name.size() > 3 && name.compare(0, 3, "asr") == 0 && isdigit((unsigned char)name[3]))
	{
		int n = std::atoi(name.c_str() + 3);
		if (n < 0 || n > 31)
			return false;
		value = reg.R_ASR(n);
		return true;
	}
	if (name == "psr")  { value = reg.R_PSR();  return true; }
	if (name == "fpsr" || name == "fsr") { value = reg.R_FSR(); return true; }
	if (name == "y")    { value = reg.R_Y();    return true; }
	if (name == "wim")  { value = reg.R_WIM();  return true; }
	if (name == "tbr")  { value = reg.R_TBR();  return true; }
	if (name == "pc")   { value = reg.R_PC();   return true; }
	if (name == "npc")  { value = reg.R_nPC();  return true; }
	return false;
}

int main(int argc, char** argv)
{
	//Pull --stats out of the argument list wherever it appears, leaving
	//the rest to be parsed positionally exactly as before.
	bool printStats = false;
	std::vector<std::string> args;
	for (int i = 1; i < argc; i++)
	{
		std::string arg = argv[i];
		if (arg == "--stats")
			printStats = true;
		else
			args.push_back(arg);
	}

	if (args.empty())
	{
		std::cerr << "Usage: " << argv[0] << " <hex_file> [expected_file] [max_cycles] [--stats]\n";
		return 1;
	}

	std::string   hexFile      = args[0];
	std::string   expectedFile = (args.size() >= 2) ? args[1] : "";
	unsigned long maxCycles    = (args.size() >= 3) ? std::strtoul(args[2].c_str(), NULL, 10) : 1000000UL;

	MainMemory mem;
	mem.initializeMemory(hexFile);

	MmuCore mmu(mem);

	//Manual/debug knob for exercising MmuCore::tlbEnabled -- not part of the
	//documented CLI (argv parsing above is untouched, so run_tests.py's
	//fixed <hex> [expected] [max_cycles] invocation is unaffected).
	//MMU_TLB_ENABLED=0 forces the TLB off for this run; unset or any
	//other value leaves it at its MMU_TLB_PRESENT-derived default.
	if (const char* tlbEnabledEnv = std::getenv("MMU_TLB_ENABLED"))
		mmu.tlbEnabled = (std::string(tlbEnabledEnv) != "0");

	SparcCore core;
	core.memCore = &mmu;

	SparcStateMachine runner(core, mmu);

#ifdef SPARC_LOGGING_ENABLED
	std::string traceFile = traceFileName(hexFile);
	std::ofstream logFile(traceFile.c_str());
	if (logFile.is_open())
	{
		core.logger.init(core, &logFile, true);
		mmu.setLogger(&core.logger, &runner.cyclesExecuted);
		std::cout << "Logging instruction trace to " << traceFile << "\n";
	}
	else
	{
		std::cerr << "warning: could not open " << traceFile << " for writing; continuing without logging\n";
	}
#endif

	runner.run(maxCycles);

	if (printStats)
		std::cout << core.stats.toString() << mmu.stats.toString() << mem.stats.toString();

	if (expectedFile.empty())
	{
		std::cout << "\n" << core.logger.print_state() << "\n";
		if (runner.halted)
			std::cout << "Simulation halted after " << runner.cyclesExecuted << " cycles.\n";
		else
			std::cout << "Simulation stopped: cycle limit (" << maxCycles
			          << ") reached without halting.\n";
		return runner.halted ? 0 : 1;
	}

	if (!runner.halted)
	{
		std::cout << "FAIL: core did not halt within " << maxCycles << " cycles\n";
		std::cout << "OVERALL: FAIL (0 checks)\n";
		return 1;
	}

	std::cout << "\n";

	std::ifstream in(expectedFile.c_str());
	if (!in.is_open())
	{
		std::cerr << "ERROR: could not open expected-results file: " << expectedFile << "\n";
		return 1;
	}

	bool allPass    = true;
	int  numChecks  = 0;
	std::string line;
	while (std::getline(in, line))
	{
		std::istringstream ss(line);
		std::string kind;
		ss >> kind;

		if (kind.empty())
		{
			continue;
		}
		else if (kind == "REG")
		{
			std::string name;
			uint32_t    expected, mask;
			ss >> name >> std::hex >> expected >> mask;

			uint32_t actual;
			if (!getRegisterValue(core.reg, name, actual))
			{
				std::cout << "FAIL: unrecognized register '" << name << "'\n";
				allPass = false;
				continue;
			}
			numChecks++;
			if ((actual & mask) == (expected & mask))
			{
				std::cout << "PASS: " << name << " = 0x" << std::hex << actual << std::dec << "\n";
			}
			else
			{
				std::cout << "FAIL: " << name << " expected 0x" << std::hex << expected
				           << " (mask 0x" << mask << ") got 0x" << actual << std::dec << "\n";
				allPass = false;
			}
		}
		else if (kind == "MEM")
		{
			uint32_t addr, expected, mask;
			ss >> std::hex >> addr >> expected >> mask;

			uint32_t alignedAddr = addr & (~0x3u);
			uint32_t word        = mem.readWord(alignedAddr);
			numChecks++;
			if ((word & mask) == (expected & mask))
			{
				std::cout << "PASS: m[0x" << std::hex << addr << "] = 0x" << word << std::dec << "\n";
			}
			else
			{
				std::cout << "FAIL: m[0x" << std::hex << addr << "] expected 0x" << expected
				           << " (mask 0x" << mask << ") got 0x" << word << std::dec << "\n";
				allPass = false;
			}
		}
		else
		{
			std::cout << "FAIL: unrecognized expected-results line: '" << line << "'\n";
			allPass = false;
		}
	}

	std::cout << (allPass ? "OVERALL: PASS" : "OVERALL: FAIL") << " (" << numChecks << " checks)\n";
	return allPass ? 0 : 1;
}
