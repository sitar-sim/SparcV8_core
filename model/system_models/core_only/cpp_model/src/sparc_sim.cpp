//sparc_sim.cpp
//
//Builds sparc_sim_cpp: loads a memory image, runs it via
//SparcStateMachine until it halts (or a cycle limit is reached), then
//either just reports the final state, or -- if an expected-results file
//is given -- checks final register/memory state against it and prints
//PASS/FAIL per check plus an overall verdict for the test as a whole.
//
//expected_file is optional: pass "" (or omit it, along with max_cycles)
//to skip validation entirely and just run the program, printing the
//final processor state instead of PASS/FAIL/OVERALL. Useful for ad hoc
//runs of a .hex file that has no paired expected-results file at all.
//This is validation/run_tests.py's own default checker binary (see its
//--sitar flag for the Sitar-driven counterpart, model/sitar_model's
//sparc_sim_sitar).
//
//The expected-results file, when given, is a normalized format produced
//by validation/run_tests.py from a test's .vprj RESULTS block:
//
//    REG <name> <hex_value>
//    MEM <hex_addr> <hex_value> <hex_mask>
//
//Register names: g1-g7, o0-o7, l0-l7, i0-i7 (windowed integer registers),
//f0-f31 (floating point), psr, fpsr, y, wim, tbr, pc, npc, asr0-asr31.
//MEM checks read a whole word at <hex_addr> (word-aligned) and compare
//(word & mask) against (value & mask) -- this is how partial-word
//store/atomic checks (byte/halfword masks) are expressed.
//
//Exit code: 0 if the core halted (and, when validating, every check
//passed too), 1 otherwise.
//
//Usage: sparc_sim_cpp <hex_file> [expected_file] [max_cycles]

#include "SparcCore.h"
#include "MemCore.h"
#include "SparcStateMachine.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <cctype>
#include <cstdlib>

//Derives the trace filename from the hex file's own name: the same
//basename, with a trailing ".hex" replaced by ".log" (or just ".log"
//appended, if for some reason it doesn't end in ".hex"). Lets multiple
//tests be run one after another from the same directory without each
//one overwriting the last one's trace, unlike a single fixed filename.
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

//Maps a RESULTS-block register mnemonic to its value in the current window.
//Returns false if the name isn't recognized.
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
	if (argc < 2)
	{
		std::cerr << "Usage: " << argv[0] << " <hex_file> [expected_file] [max_cycles]\n";
		return 1;
	}

	std::string   hexFile      = argv[1];
	std::string   expectedFile = (argc >= 3) ? argv[2] : "";
	unsigned long maxCycles    = (argc >= 4) ? std::strtoul(argv[3], NULL, 10) : 1000000UL;

	MemCore mem;
	mem.initializeMemory(hexFile);

	SparcCore core;
	core.memCore = &mem;

	SparcStateMachine runner(core, mem);

#ifdef SPARC_LOGGING_ENABLED
	//Only present in a --logging build (see build.sh). Named after
	//hexFile (see traceFileName()), written into the current directory.
	std::string traceFile = traceFileName(hexFile);
	std::ofstream logFile(traceFile.c_str());
	if (logFile.is_open())
	{
		core.logger.init(core, &logFile, true);
		std::cout << "Logging instruction trace to " << traceFile << "\n";
	}
	else
	{
		std::cerr << "warning: could not open " << traceFile << " for writing; continuing without logging\n";
	}
#endif

	runner.run(maxCycles);

	//No expected-results file: just run the program and report the
	//final state. Nothing here is a pass/fail check, so PASS/FAIL/OVERALL
	//don't apply.
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
			continue; //blank line
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
