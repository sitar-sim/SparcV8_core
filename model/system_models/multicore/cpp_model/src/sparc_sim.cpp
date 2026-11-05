//sparc_sim.cpp
//
//The multicore configuration's entry point. NUM_CORES copies of
//core_l1cache_mmu_devices' island (SparcStateMachine -> L1CachesCore ->
//MmuCore), all sharing one SystemBus, and through it one main memory and
//one set of peripheral devices (Ref MulticoreConfig.h for the knobs).
//
//Core i has core ID i, so `rd %asr29` tells it apart from the others,
//and its IRL input pins are driven from the Interrupt Controller's slot
//for core i, thread 0. Every core starts at the reset PC (0), as on
//AJIT, and runs the same program, which uses the core ID to decide
//what each core does.
//
//The cores are interleaved on one host thread, in rounds, by a
//Scheduler (Ref Scheduler.h, which also explains what a "model cycle"
//means here). The run ends when every running core has halted, or when
//max_cycles model cycles have passed.
//
//Expected-results lines may name a core: `REG core2.o0 ...` checks core
//2's %o0. A line with no core prefix checks core 0, so every
//single-core test's expected results work unchanged.
//
//Usage: sparc_sim_cpp_multicore <hex_file> [expected_file] [max_cycles] [--stats]
//                     [--schedule <spec>] [--run-cores <m>]
//                     [--serial-in <file>] [--serial-out <file>] [--serial-pty]
//                     [--timer-tick-divider <n>]
//                     [--icache-lines <n>] [--icache-ways <n>] [--dcache-lines <n>] [--dcache-ways <n>]
//                     [--always-cacheable] [--coherent] [--no-coherent] [--snoop-filter]
//
//--schedule picks the interleaving strategy (default rr:1, Ref
//Scheduler.h). SPARC_SCHEDULE in the environment does the same.
//
//--run-cores m runs only cores 0 to m-1. The others never leave reset,
//and count as halted. This lets a single-core program (one that does
//not look at its core ID) run unchanged on a multi-core build.
//SPARC_RUN_CORES in the environment does the same. Default NUM_CORES.
//
//--coherent keeps the caches coherent (Ref CoherentBus.h). It is off by
//default. SPARC_COHERENT=1 in the environment turns it on, and --no-coherent
//turns it off for a test that needs it off whatever the environment says.
//--snoop-filter, or SPARC_SNOOP_FILTER=1, leaves out repeated invalidates.
//
//The other options are core_l1cache_mmu_devices' own, applied to every
//core's caches.

#include "MulticoreConfig.h"
#include "Scheduler.h"
#include "SparcCore.h"
#include "MainMemory.h"
#include "SparcStateMachine.h"
#include "MmuCore.h"
#include "SystemBus.h"
#include "CoherentBus.h"
#include "PeripheralDevicesCore.h"
#include "SerialBackend.h"
#include "L1CachesCore.h"
#include "AsiValues.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <memory>
#include <algorithm>
#include <cctype>
#include <cstdlib>

static_assert(MulticoreConfig::NUM_CORES >= 1 && MulticoreConfig::NUM_CORES <= 4,
              "NUM_CORES must be 1 to 4 (the Interrupt Controller has slots for 4 cores)");

//One core with its own caches and MMU, the unit the system has N of.
struct Island
{
	MmuCore           mmu;
	L1CachesCore      caches;
	SparcCore         core;
	SparcStateMachine runner;

	Island(PhysicalMemoryInterface& bus, unsigned int coreId) :
		mmu(bus), caches(mmu), core(), runner(core, caches)
	{
		core.setCoreID(coreId);
		core.memCore = &caches;
		caches.currentContext = [this]() { return mmu.currentContext(); };
	}
};

#ifdef SPARC_LOGGING_ENABLED
//<hex_file>'s base name with .hex replaced by .log for core 0 (the same
//name as the single-core configurations use), .core<i>.log for the others.
static std::string traceFileName(const std::string& hexFile, unsigned int coreId)
{
	std::string base = hexFile;
	std::string::size_type slash = base.find_last_of("/\\");
	if (slash != std::string::npos)
		base = base.substr(slash + 1);

	const std::string suffix = ".hex";
	if (base.size() >= suffix.size() &&
	    base.compare(base.size() - suffix.size(), suffix.size(), suffix) == 0)
		base = base.substr(0, base.size() - suffix.size());

	if (coreId == 0)
		return base + ".log";
	return base + ".core" + std::to_string(coreId) + ".log";
}
#endif

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

//Splits "core<i>.<reg>" into i and <reg>. A name with no "core<i>."
//prefix is core 0's. Returns false if the core number is malformed.
static bool splitCorePrefix(const std::string& name, unsigned int& coreId, std::string& reg)
{
	coreId = 0;
	reg    = name;
	if (name.compare(0, 4, "core") != 0)
		return true;
	std::string::size_type dot = name.find('.');
	if (dot == std::string::npos || dot == 4)
		return false;
	for (std::string::size_type i = 4; i < dot; i++)
		if (!isdigit((unsigned char)name[i]))
			return false;
	coreId = (unsigned int) std::atoi(name.c_str() + 4);
	reg    = name.substr(dot + 1);
	return true;
}

int main(int argc, char** argv)
{
	const unsigned int numCores = MulticoreConfig::NUM_CORES;

	//Pull the --options out of the argument list wherever they appear,
	//leaving the rest to be parsed positionally.
	bool printStats = false;
	SerialBackendConfig serialConfig;
	bool serialInputGiven = false;
	uint32_t timerTickDivider = 1;
	unsigned int icacheLines = DEFAULT_ICACHE_LINES, icacheWays = DEFAULT_ICACHE_WAYS;
	unsigned int dcacheLines = DEFAULT_DCACHE_LINES, dcacheWays = DEFAULT_DCACHE_WAYS;
	bool alwaysCacheable = false;
	bool coherent        = false;
	bool snoopFilter     = false;
	if (const char* env = std::getenv("SPARC_COHERENT"))
		coherent = (std::string(env) == "1");
	if (const char* env = std::getenv("SPARC_SNOOP_FILTER"))
		snoopFilter = (std::string(env) == "1");
	std::string scheduleSpec = "rr:1";
	unsigned long runCores = numCores;
	if (const char* env = std::getenv("SPARC_SCHEDULE"))
		scheduleSpec = env;
	if (const char* env = std::getenv("SPARC_RUN_CORES"))
		runCores = std::strtoul(env, NULL, 10);

	std::vector<std::string> args;
	for (int i = 1; i < argc; i++)
	{
		std::string arg = argv[i];
		bool hasValue = (i + 1 < argc);
		if (arg == "--stats")
			printStats = true;
		else if (arg == "--schedule" && hasValue)
			scheduleSpec = argv[++i];
		else if (arg == "--run-cores" && hasValue)
			runCores = std::strtoul(argv[++i], NULL, 10);
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
		else if (arg == "--coherent")
			coherent = true;
		else if (arg == "--no-coherent")
			coherent = false;
		else if (arg == "--snoop-filter")
			snoopFilter = true;
		else
			args.push_back(arg);
	}

	if (args.empty())
	{
		std::cerr << "Usage: " << argv[0] << " <hex_file> [expected_file] [max_cycles] [--stats]"
		          << " [--schedule <spec>] [--run-cores <m>]"
		          << " [--serial-in <file>] [--serial-out <file>] [--serial-pty] [--timer-tick-divider <n>]"
		          << " [--icache-lines <n>] [--icache-ways <n>] [--dcache-lines <n>] [--dcache-ways <n>] [--always-cacheable]"
		          << " [--coherent] [--no-coherent] [--snoop-filter]\n";
		return 1;
	}

	std::string scheduleError;
	std::unique_ptr<Scheduler> scheduler = Scheduler::fromSpec(scheduleSpec, scheduleError);
	if (!scheduler)
	{
		std::cerr << "ERROR: " << scheduleError << "\n";
		return 1;
	}
	if (runCores < 1 || runCores > numCores)
	{
		std::cerr << "ERROR: --run-cores must be 1 to " << numCores << "\n";
		return 1;
	}

	std::string   hexFile      = args[0];
	std::string   expectedFile = (args.size() >= 2) ? args[1] : "";
	unsigned long maxCycles    = (args.size() >= 3) ? std::strtoul(args[2].c_str(), NULL, 10) : 1000000UL;

	MainMemory mem;
	mem.initializeMemory(hexFile);

	if (!serialInputGiven)
		serialConfig.inputFile = defaultSerialInputFile(hexFile);

	PeripheralDevicesCore devices;
	//Keep a copy of everything transmitted, for serial_out checks below.
	RecordingSerialBackend* serialRecorder = new RecordingSerialBackend(makeSerialBackend(serialConfig));
	devices.serial.setBackend(std::unique_ptr<SerialBackend>(serialRecorder));
	devices.timerTickDivider = (timerTickDivider == 0) ? 1 : timerTickDivider;

	SystemBus systemBus(mem, devices);
	CoherentBus bus(systemBus, numCores);
	bus.coherent    = coherent;
	bus.snoopFilter = snoopFilter;

	//The same switch as an environment variable, for running whole test
	//suites with caching on (run_tests.py passes no extra options).
	if (const char* env = std::getenv("SPARC_ALWAYS_CACHEABLE"))
		alwaysCacheable = alwaysCacheable || (std::string(env) == "1");

	std::vector<std::unique_ptr<Island>> islands;
	for (unsigned int i = 0; i < numCores; i++)
	{
		islands.emplace_back(new Island(bus.port(i), i));
		Island& island = *islands.back();
		bus.attachCaches(i, &island.caches);

		//Manual/debug knob, as in the single-core configurations.
		if (const char* tlbEnabledEnv = std::getenv("MMU_TLB_ENABLED"))
			island.mmu.tlbEnabled = (std::string(tlbEnabledEnv) != "0");

		island.caches.instructionCache.configure(icacheLines, icacheWays);
		island.caches.dataCache.configure(dcacheLines, dcacheWays);

		if (alwaysCacheable)
		{
			//MMU Control Register (ASI 4, address 0) bit 8, written straight
			//to the MMU before the run, as a program's own `sta` would.
			VirtualMemoryRequest set{true, MemAccessType::STORE, 0x000, ASI_MMU_REGISTER, 0x100, 0, 0x0F};
			VirtualMemoryResponse ignored{};
			island.mmu.access(set, ignored);
		}
	}

#ifdef SPARC_LOGGING_ENABLED
	std::vector<std::unique_ptr<std::ofstream>> logFiles;
	for (unsigned int i = 0; i < runCores; i++)
	{
		Island& island = *islands[i];
		std::string traceFile = traceFileName(hexFile, i);
		logFiles.emplace_back(new std::ofstream(traceFile.c_str()));
		if (logFiles.back()->is_open())
		{
			island.core.logger.init(island.core, logFiles.back().get(), true);
			island.mmu.setLogger(&island.core.logger, &island.runner.cyclesExecuted);
			std::cout << "\nLogging core " << i << "'s instruction trace to " << traceFile << "\n";
		}
		else
			std::cerr << "warning: could not open " << traceFile << " for writing; continuing without logging\n";
	}
#endif

	//running[i]: core i takes part in the next round. Cores beyond
	//--run-cores never leave reset.
	std::vector<bool> running(numCores, false);
	for (unsigned int i = 0; i < runCores; i++)
		running[i] = true;

	unsigned long cycles = 0;
	std::vector<Turn> turns;
	while (cycles < maxCycles && std::find(running.begin(), running.end(), true) != running.end())
	{
		scheduler->nextRound(running, turns);
		unsigned long roundCycles = 0;
		for (const Turn& t : turns)
		{
			SparcStateMachine& runner = islands[t.core]->runner;
			unsigned long n = 0;
			while (n < t.instructions && !runner.step())
				n++;
			if (runner.halted)
			{
				running[t.core] = false;
				n++; //the cycle that found the core halted
			}
			roundCycles = std::max(roundCycles, n);
		}

		//The devices tick once per model cycle of the round, then every
		//core's IRL pins take its slot's level, sampled on its next cycle.
		for (unsigned long c = 0; c < roundCycles; c++)
			devices.tick();
		for (unsigned int i = 0; i < numCores; i++)
		{
			SparcCore& core = islands[i]->core;
			core.reg.W_bp_IRL(devices.interruptLevel(InterruptControllerCore::slotIndex(core.getCoreID(), core.getThreadID())));
		}
		cycles += roundCycles;
	}

	bool allHalted = true;
	for (unsigned int i = 0; i < runCores; i++)
		allHalted = allHalted && islands[i]->runner.halted;

	if (printStats)
	{
		for (unsigned int i = 0; i < runCores; i++)
		{
			Island& island = *islands[i];
			std::cout << "\n=== core " << i << " ===\n"
			          << island.core.stats.toString() << island.caches.statsToString() << island.mmu.stats.toString();
		}
		std::cout << "\n=== shared ===\n Bus invalidates sent = " << bus.invalidatesSent
		          << ", left out by the snoop filter = " << bus.invalidatesFiltered
		          << "\n" << mem.stats.toString() << devices.stats.toString();
	}

	if (expectedFile.empty())
	{
		for (unsigned int i = 0; i < runCores; i++)
			std::cout << "\n=== core " << i << " ===\n" << islands[i]->core.logger.print_state() << "\n";
		if (allHalted)
			std::cout << "Simulation halted after " << cycles << " cycles (all " << runCores << " cores halted).\n";
		else
			std::cout << "Simulation stopped: cycle limit (" << maxCycles
			          << ") reached without every core halting.\n";
		return allHalted ? 0 : 1;
	}

	if (!allHalted)
	{
		std::cout << "FAIL: not every core halted within " << maxCycles << " cycles (still running:";
		for (unsigned int i = 0; i < runCores; i++)
			if (!islands[i]->runner.halted)
				std::cout << " core " << i;
		std::cout << ")\n";
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

			unsigned int coreId;
			std::string  regName;
			uint32_t     actual;
			if (!splitCorePrefix(name, coreId, regName) || coreId >= runCores)
			{
				std::cout << "FAIL: '" << name << "' names a core that is not running\n";
				allPass = false;
				continue;
			}
			if (!getRegisterValue(islands[coreId]->core.reg, regName, actual))
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
