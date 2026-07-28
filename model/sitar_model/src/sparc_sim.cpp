//sparc_sim.cpp
//Author: Neha Karanjkar
//
//Builds sparc_sim_sitar: the Sitar-driven counterpart to
//model/cpp_model's sparc_sim_cpp -- same job (load a hex-dump memory
//image, run to halt or a cycle limit, either just report the final state
//or, if given an expected-results file, check it and print PASS/FAIL per
//check and an OVERALL verdict), but drives the actual Sitar
//Top/Core/SparcThread model instead of the standalone C++
//SparcStateMachine. This is the `-m` custom main file for `sitar compile`
//-- see build.py.
//
//Kept as a near-duplicate of sparc_sim_cpp's source (same CLI, same
//expected-file format, same output format) rather than a shared library,
//so that validation/run_tests.py can point at either binary
//interchangeably (see its --sitar flag) with zero changes to the
//test-comparison logic itself.
//
//expected_file is optional, exactly as in sparc_sim_cpp: pass "" (or
//omit it, along with max_cycles) to skip validation and just run the
//program, printing the final processor state instead of
//PASS/FAIL/OVERALL.
//
//Usage: sparc_sim_sitar <hex_file> [expected_file] [max_cycles]

#include "Top.h"
#include "Registers.h"
#include "sitar_logger.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <cctype>
#include <cstdlib>

#ifdef SITAR_ENABLE_LOGGING
//Recursively points every submodule/procedure's log stream at `stream`.
//Only needed when build.py is run with --logging (off by default, since
//a normal run doesn't want per-cycle trace noise).
static void setHierarchicalOstream(sitar::module* m, std::ostream* stream)
{
	m->log.setOstream(stream);
	for (auto it = m->_submodules.begin(); it != m->_submodules.end(); ++it)
		setHierarchicalOstream(it->second, stream);
	for (auto it = m->_procedures.begin(); it != m->_procedures.end(); ++it)
		setHierarchicalOstream(it->second, stream);
}
#endif

//Derives the trace filename from the hex file's own name. (Identical to
//cpp_model's sparc_sim.cpp copy, see that one's own comment for why.)
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
//Returns false if the name isn't recognized. (Identical to cpp_model's
//sparc_sim.cpp copy -- Registers.h is the same shared cpp_common_code
//either way.)
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

	using namespace sitar;

	Top* TOP = new Top;
	TOP->setInstanceId("TOP");
	TOP->setHierarchicalId("");

#ifdef SITAR_ENABLE_LOGGING
	//Sitar's own per-request/response log (mainMemory, ifetchThread and
	//the other MemoryInterface instances) -- everything except
	//sparcThread's own CoreLogger trace, which gets its own dedicated
	//file below.
	std::ofstream sitarLogFile("sitar.log");
	if (sitarLogFile.is_open())
	{
		logger::default_logstream = &sitarLogFile;
	}
	else
	{
		std::cerr << "warning: could not open sitar.log for writing; logging to stderr instead\n";
		logger::default_logstream = &std::cerr;
	}
	setHierarchicalOstream(TOP, logger::default_logstream);

	//sparcThread's own log carries nothing but SparcCore::logger's
	//CoreLogger trace rows (see SparcThread.sitar) -- give it a
	//dedicated file, with the "(time)hierarchicalId:" prefix every
	//other module gets (see sitar_module.cpp's setLogPrefix()) turned
	//off, so the result is directly loadable into log_viewer/ with no
	//extraction/stripping needed first. Same filename convention as
	//the cpp model's --logging build -- see model/cpp_model/sparc_sim.cpp.
	std::string traceFile = traceFileName(hexFile);
	std::ofstream sparcTraceFile(traceFile.c_str());
	if (sparcTraceFile.is_open())
	{
		TOP->core.sparcThread.log.setOstream(&sparcTraceFile);
		TOP->core.sparcThread.log.useDefaultPrefix = false;
		TOP->core.sparcThread.log.setPrefix("");

		//CoreLogger only writes this itself when do_print is on (see
		//CoreLogger.h) -- we're not using that here (each row still
		//goes through sparcThread's own log<<, so it's forwarded like
		//everything else Sitar logs), so write it ourselves, once.
		sparcTraceFile << TOP->core.sparcThread.core.logger.header() << "\n";
	}
	else
	{
		std::cerr << "warning: could not open " << traceFile << " for writing; sparcThread's trace will go to stderr instead\n";
	}
#endif

	TOP->core.mainMemory.mem.initializeMemory(hexFile);

	//run for up to maxCycles cycles (Sitar counts phases, 2 per cycle),
	//or until the model itself calls `stop simulation` (Core.sitar does
	//this once sparcThread halts).
	uint64_t simulation_time;
	for (simulation_time = 0; simulation_time < (uint64_t)maxCycles * 2; simulation_time++)
	{
		TOP->runHierarchical(simulation_time);
		if (sitar::simulation_stopped())
			break;
	}

	bool          halted        = TOP->core.sparcThread.HALT.VALUE;
	unsigned long cyclesExecuted = (unsigned long)(simulation_time / 2);

	//No expected-results file: just run the program and report the
	//final state, the same idea as cpp_model's sparc_sim_cpp. Nothing
	//here is a pass/fail check, so PASS/FAIL/OVERALL don't apply.
	if (expectedFile.empty())
	{
		std::cout << "\n" << TOP->core.sparcThread.core.logger.print_state() << "\n";
		if (halted)
			std::cout << "Simulation halted after " << cyclesExecuted << " cycles.\n";
		else
			std::cout << "Simulation stopped: cycle limit (" << maxCycles
			          << ") reached without halting.\n";
		return halted ? 0 : 1;
	}

	if (!halted)
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

	Registers& reg = TOP->core.sparcThread.core.reg;

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
			if (!getRegisterValue(reg, name, actual))
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
			uint32_t word        = TOP->core.mainMemory.mem.readWord(alignedAddr);
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
