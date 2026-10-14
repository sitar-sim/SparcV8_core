//sparc_sim.cpp
//Author: Neha Karanjkar
//
//The core_l1cache_mmu_devices configuration's Sitar entry point. The
//same as core_mmu_devices' own, plus the split L1 caches inside Core,
//between SparcThread and the MMU (TOP->system.core.caches). Below the
//MMU sits a SystemBridge, which routes each physical access to main
//memory or to the peripheral devices. TOP->system.core is the SPARC core plus MMU,
//TOP->system.mainMemory the physical memory, TOP->system.devices the
//shared Timer, Serial, and Interrupt Controller, all siblings.
//
//MEM checks in the expected-results file read straight from
//MainMemory's own plain readWord(), not through the MMU, since they're
//checking physical memory state directly, what a test setting up page
//tables needs.
//
//Usage: sparc_sim_sitar <hex_file> [expected_file] [max_cycles] [--stats]
//                       [--serial-in <file>] [--serial-out <file>] [--serial-pty]
//                       [--timer-tick-divider <n>]
//                       [--icache-lines <n>] [--icache-ways <n>] [--dcache-lines <n>] [--dcache-ways <n>]
//                       [--always-cacheable]
//
//The serial and timer options mean exactly what they mean for this
//configuration's cpp_model (Ref ../../cpp_model/src/sparc_sim.cpp).
//--timer-tick-divider, when given, overrides the value set in
//System.sitar's knob block.
//
//--stats prints the core's instruction-mix counters, the MMU's
//statistics, and physical memory's own access counters (see
//SparcCoreStats.h, MmuStats.h, MainMemoryStats.h), layered
//innermost-to-outermost, once the run finishes, to stdout, ahead of
//the state/PASS-FAIL report below. Off by default. Can appear anywhere
//among the arguments.

#include "Top.h"
#include "Registers.h"
#include "sitar_logger.h"
#include "SerialBackend.h"
#include "AsiValues.h"
#include "CacheConfig.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <cctype>
#include <cstdlib>

#ifdef SITAR_ENABLE_LOGGING
//Recursively points every submodule/procedure's log stream at `stream`.
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

//<hex_file> with .hex replaced by .serial_in, if that file exists, else "".
static std::string defaultSerialInputFile(const std::string& hexFile)
{
	const std::string suffix = ".hex";
	if (hexFile.size() < suffix.size() ||
	    hexFile.compare(hexFile.size() - suffix.size(), suffix.size(), suffix) != 0)
		return "";
	std::string candidate = hexFile.substr(0, hexFile.size() - suffix.size()) + ".serial_in";
	std::ifstream probe(candidate.c_str());
	return probe.good() ? candidate : "";
}

//Maps a RESULTS-block register mnemonic to its value in the current window.
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
	SerialBackendConfig serialConfig;
	bool serialInputGiven = false;
	uint32_t timerTickDivider = 0; //0: keep System.sitar's value
	unsigned int icacheLines = DEFAULT_ICACHE_LINES, icacheWays = DEFAULT_ICACHE_WAYS;
	unsigned int dcacheLines = DEFAULT_DCACHE_LINES, dcacheWays = DEFAULT_DCACHE_WAYS;
	bool alwaysCacheable = false;
	std::vector<std::string> args;
	for (int i = 1; i < argc; i++)
	{
		std::string arg = argv[i];
		bool hasValue = (i + 1 < argc);
		if (arg == "--stats")
			printStats = true;
		else if (arg == "--serial-in" && hasValue)
		{
			serialConfig.inputFile = argv[++i];
			serialInputGiven = true;
		}
		else if (arg == "--serial-out" && hasValue)
		{
			serialConfig.outputFile = argv[++i];
			serialConfig.kind = SerialBackendConfig::Kind::FILES;
		}
		else if (arg == "--serial-pty")
			serialConfig.kind = SerialBackendConfig::Kind::PTY;
		else if (arg == "--timer-tick-divider" && hasValue)
			timerTickDivider = (uint32_t) std::strtoul(argv[++i], NULL, 10);
		else if (arg == "--icache-lines" && hasValue)
			icacheLines = (unsigned int) std::strtoul(argv[++i], NULL, 10);
		else if (arg == "--icache-ways" && hasValue)
			icacheWays = (unsigned int) std::strtoul(argv[++i], NULL, 10);
		else if (arg == "--dcache-lines" && hasValue)
			dcacheLines = (unsigned int) std::strtoul(argv[++i], NULL, 10);
		else if (arg == "--dcache-ways" && hasValue)
			dcacheWays = (unsigned int) std::strtoul(argv[++i], NULL, 10);
		else if (arg == "--always-cacheable")
			alwaysCacheable = true;
		else
			args.push_back(arg);
	}

	if (args.empty())
	{
		std::cerr << "Usage: " << argv[0] << " <hex_file> [expected_file] [max_cycles] [--stats]"
		          << " [--serial-in <file>] [--serial-out <file>] [--serial-pty] [--timer-tick-divider <n>]"
		          << " [--icache-lines <n>] [--icache-ways <n>] [--dcache-lines <n>] [--dcache-ways <n>] [--always-cacheable]\n";
		return 1;
	}

	std::string   hexFile      = args[0];
	std::string   expectedFile = (args.size() >= 2) ? args[1] : "";
	unsigned long maxCycles    = (args.size() >= 3) ? std::strtoul(args[2].c_str(), NULL, 10) : 1000000UL;

	using namespace sitar;

	Top* TOP = new Top;
	TOP->setInstanceId("TOP");
	TOP->setHierarchicalId("");

#ifdef SITAR_ENABLE_LOGGING
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

	std::string traceFile = traceFileName(hexFile);
	std::ofstream sparcTraceFile(traceFile.c_str());
	if (sparcTraceFile.is_open())
	{
		TOP->system.core.sparcThread.log.setOstream(&sparcTraceFile);
		TOP->system.core.sparcThread.log.useDefaultPrefix = false;
		TOP->system.core.sparcThread.log.setPrefix("");
		sparcTraceFile << TOP->system.core.sparcThread.core.logger.header() << "\n";
	}
	else
	{
		std::cerr << "warning: could not open " << traceFile << " for writing; sparcThread's trace will go to stderr instead\n";
	}
#endif

	TOP->system.mainMemory.mem.initializeMemory(hexFile);

	if (!serialInputGiven)
		serialConfig.inputFile = defaultSerialInputFile(hexFile);
	//Keep a copy of everything transmitted, for serial_out checks below.
	RecordingSerialBackend* serialRecorder = new RecordingSerialBackend(makeSerialBackend(serialConfig));
	TOP->system.devices.devices.serial.setBackend(std::unique_ptr<SerialBackend>(serialRecorder));
	if (timerTickDivider != 0)
		TOP->system.devices.devices.timerTickDivider = timerTickDivider;

	TOP->system.core.caches.caches.instructionCache.configure(icacheLines, icacheWays);
	TOP->system.core.caches.caches.dataCache.configure(dcacheLines, dcacheWays);

	//Same as the cpp_model: --always-cacheable or SPARC_ALWAYS_CACHEABLE=1
	//sets the MMU Control Register's "always cacheable" bit before the run.
	if (const char* env = std::getenv("SPARC_ALWAYS_CACHEABLE"))
		alwaysCacheable = alwaysCacheable || (std::string(env) == "1");
	if (alwaysCacheable)
	{
		VirtualMemoryRequest set{true, MemAccessType::STORE, 0x000, ASI_MMU_REGISTER, 0x100, 0, 0x0F};
		VirtualMemoryResponse ignored{};
		TOP->system.core.mmu.mmu.access(set, ignored);
	}

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

	bool          halted        = TOP->system.core.sparcThread.HALT.VALUE;
	unsigned long cyclesExecuted = (unsigned long)(simulation_time / 2);

	if (printStats)
		std::cout << TOP->system.core.sparcThread.core.stats.toString()
		           << TOP->system.core.caches.caches.statsToString()
		           << TOP->system.core.mmu.mmu.stats.toString()
		           << TOP->system.mainMemory.mem.stats.toString()
		           << TOP->system.devices.devices.stats.toString();

	if (expectedFile.empty())
	{
		std::cout << "\n" << TOP->system.core.sparcThread.core.logger.print_state() << "\n";
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

	Registers& reg = TOP->system.core.sparcThread.core.reg;

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
		else if (kind == "SERIAL_OUT")
		{
			//The exact bytes transmitted, as hex ("-" for none).
			std::string expectedHex;
			ss >> expectedHex;
			if (expectedHex == "-")
				expectedHex.clear();
			std::string actualHex;
			static const char* digits = "0123456789abcdef";
			for (unsigned char c : serialRecorder->transmitted())
			{
				actualHex.push_back(digits[c >> 4]);
				actualHex.push_back(digits[c & 0xF]);
			}
			numChecks++;
			if (actualHex == expectedHex)
				std::cout << "PASS: serial output (" << serialRecorder->transmitted().size() << " bytes)\n";
			else
			{
				std::cout << "FAIL: serial output expected hex '" << expectedHex
				          << "' got '" << actualHex << "'\n";
				allPass = false;
			}
		}
		else if (kind == "MEM")
		{
			uint32_t addr, expected, mask;
			ss >> std::hex >> addr >> expected >> mask;

			uint32_t alignedAddr = addr & (~0x3u);
			uint32_t word        = TOP->system.mainMemory.mem.readWord(alignedAddr);
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
