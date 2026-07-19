//sitar_check_test.cpp
//Author: Neha Karanjkar
//
//Sitar-driven counterpart to model/cpp_model/check_test.cpp -- same job
//(load a hex-dump memory image, run to halt or a cycle limit, check final
//register/memory state against an expected-results file, print PASS/FAIL
//per check and an OVERALL verdict), but drives the actual Sitar
//Top/Core/SparcThread model instead of the standalone C++
//SparcStateMachine. This is the `-m` custom main file for `sitar compile`
//-- see build.py.
//
//Kept as a near-duplicate of check_test.cpp (same CLI, same expected-file
//format, same output format) rather than a shared library, so that
//validation/run_tests.py can point at either binary interchangeably (see
//its --sitar flag) with zero changes to the test-comparison logic itself.
//
//Usage: sitar_check_test <hex_file> <expected_file> [max_cycles]

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
//normal check_test runs don't want per-cycle trace noise); identical to
//the helper of the same name in sitar_default_main.cpp.
static void setHierarchicalOstream(sitar::module* m, std::ostream* stream)
{
	m->log.setOstream(stream);
	for (auto it = m->_submodules.begin(); it != m->_submodules.end(); ++it)
		setHierarchicalOstream(it->second, stream);
	for (auto it = m->_procedures.begin(); it != m->_procedures.end(); ++it)
		setHierarchicalOstream(it->second, stream);
}
#endif

//Maps a RESULTS-block register mnemonic to its value in the current window.
//Returns false if the name isn't recognized. (Identical to check_test.cpp's
//copy -- Registers.h is the same shared cpp_common_code either way.)
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
	if (argc < 3)
	{
		std::cerr << "Usage: " << argv[0] << " <hex_file> <expected_file> [max_cycles]\n";
		return 1;
	}

	std::string   hexFile      = argv[1];
	std::string   expectedFile = argv[2];
	unsigned long maxCycles    = (argc >= 4) ? std::strtoul(argv[3], NULL, 10) : 1000000UL;

	using namespace sitar;

	Top* TOP = new Top;
	TOP->setInstanceId("TOP");
	TOP->setHierarchicalId("");

#ifdef SITAR_ENABLE_LOGGING
	logger::default_logstream = &std::cerr;   //stderr: keeps PASS/FAIL/OVERALL on stdout parseable
	setHierarchicalOstream(TOP, logger::default_logstream);
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

	if (!TOP->core.sparcThread.HALT.VALUE)
	{
		std::cout << "FAIL: core did not halt within " << maxCycles << " cycles\n";
		std::cout << "OVERALL: FAIL (0 checks)\n";
		return 1;
	}

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
