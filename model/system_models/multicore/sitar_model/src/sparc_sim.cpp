//sparc_sim.cpp
//Author: Neha Karanjkar
//
//The multicore configuration's Sitar entry point. TOP->system.cores[i]
//is core i (SPARC core, L1 caches, MMU), TOP->system.bridge the
//CoherentBridge below the MMUs, TOP->system.mainMemory the physical
//memory, TOP->system.devices the shared Timer, Serial, Interrupt
//Controller and scratch-pad, all siblings. The two compile-time knobs,
//NUM_CORES and COHERENT, are System.sitar's parameters.
//
//Every core runs in parallel with the others, one instruction per cycle
//at most, and they meet only at the bridge. The run ends when every
//running core has halted (System.sitar stops the simulation), or after
//max_cycles cycles.
//
//Expected-results lines may name a core: `REG core2.o0 ...` checks core
//2's %o0. A line with no core prefix checks core 0, so every
//single-core test's expected results work unchanged. MEM checks read
//straight from MainMemory's own plain readWord(), not through any MMU.
//
//Usage: sparc_sim_sitar_multicore <hex_file> [expected_file] [max_cycles] [--stats]
//                       [--run-cores <m>]
//                       [--serial-in <file>] [--serial-out <file>] [--serial-pty]
//                       [--timer-tick-divider <n>]
//                       [--icache-lines <n>] [--icache-ways <n>] [--dcache-lines <n>] [--dcache-ways <n>]
//                       [--always-cacheable]
//                       [--threads <n>] [--thread-map <t0,t1,...>]
//
//--run-cores m runs only cores 0 to m-1. The others are held in reset
//(their RESET pin stays high) and count as halted. SPARC_RUN_CORES in
//the environment does the same. Default NUM_CORES. The other options
//mean exactly what they mean for this configuration's cpp_model (Ref
//../../cpp_model/src/sparc_sim.cpp), and apply to every core's caches.
//--timer-tick-divider, when given, overrides System.sitar's value.
//
//--stats prints each core's counters, then the bridge's per-core
//transaction counts and the shared memory's and devices' counters.
//
//Parallel simulation (an executable built with build.sh --openmp only):
//the top-level modules (each core, the bridge, main memory, the devices,
//System itself) are split among host threads, which run one phase at a
//time and meet at a barrier after it. Sitar's two-phase rule makes the
//result identical to the serial run's, cycle for cycle.
//--threads n (or OMP_NUM_THREADS) sets the number of threads, default 1,
//at most NUM_CORES. The mapping is static: thread t always runs the
//same modules, so each core's state stays in one host CPU's caches. By
//default each thread gets a contiguous block of cores (16 cores on 4
//threads: cores 0-3 on thread 0, and so on), and the four light modules
//go with the last thread with the fewest cores, never on a thread of
//their own. --thread-map gives the thread of every module instead, in
//the order --stats prints them: cores[0] .. cores[NUM_CORES-1], bridge,
//mainMemory, devices, system, e.g. --thread-map 0,0,1,1,1,1,1,1 (the
//number of threads is then the largest one named, plus 1). Logging
//builds give each thread its own Sitar log, sitar.thread<t>.log, when
//n > 1, since a shared stream written from several threads would
//interleave. (No module draws random numbers, so there is no generator
//to give each thread.)

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
#include <memory>
#include <algorithm>

#ifdef _OPENMP
#include <omp.h>
#endif

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

#ifdef SITAR_ENABLE_LOGGING
//Derives the trace filename from the hex file's own name. (Identical to
//cpp_model's sparc_sim.cpp copy, see that one's own comment for why.)
//Core 0's trace keeps the single-core name, <base>.log. Core i's is
//<base>.core<i>.log.
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

//The modules a parallel run maps onto threads, in --thread-map order.
//Every other module (Top) has no behavior of its own and goes with
//`system`.
static std::vector<sitar::module*> mappedModules(sitar::Top* TOP, unsigned int numCores,
                                                 std::vector<std::string>& names)
{
	std::vector<sitar::module*> list;
	for (unsigned int i = 0; i < numCores; i++)
	{
		list.push_back(&TOP->system.cores[i]);
		names.push_back("cores[" + std::to_string(i) + "]");
	}
	list.push_back(&TOP->system.bridge);     names.push_back("bridge");
	list.push_back(&TOP->system.mainMemory); names.push_back("mainMemory");
	list.push_back(&TOP->system.devices);    names.push_back("devices");
	list.push_back(&TOP->system);            names.push_back("system");
	return list;
}

//The default thread of every mapped module, for numThreads threads
//(1 to numCores): contiguous blocks of cores, the earlier threads taking
//one more core when they don't divide evenly, and the light modules on
//the last thread with the fewest cores.
static std::vector<unsigned int> defaultThreadMap(unsigned int numCores, unsigned int numThreads)
{
	std::vector<unsigned int> map;
	std::vector<unsigned int> coresOnThread(numThreads, 0);
	for (unsigned int t = 0; t < numThreads; t++)
		coresOnThread[t] = numCores / numThreads + (t < numCores % numThreads ? 1 : 0);
	for (unsigned int t = 0; t < numThreads; t++)
		for (unsigned int k = 0; k < coresOnThread[t]; k++)
			map.push_back(t);
	unsigned int light = 0;
	for (unsigned int t = 0; t < numThreads; t++)
		if (coresOnThread[t] <= coresOnThread[light])
			light = t;
	for (int k = 0; k < 4; k++)
		map.push_back(light);
	return map;
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
	unsigned long runCores = 0; //0: all cores
	unsigned int numThreads = 0; //0: OMP_NUM_THREADS, else 1
	std::string threadMapSpec;
	if (const char* env = std::getenv("SPARC_RUN_CORES"))
		runCores = std::strtoul(env, NULL, 10);
	std::vector<std::string> args;
	for (int i = 1; i < argc; i++)
	{
		std::string arg = argv[i];
		bool hasValue = (i + 1 < argc);
		if (arg == "--stats")
			printStats = true;
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
		else if (arg == "--threads" && hasValue)
			numThreads = (unsigned int) std::strtoul(argv[++i], NULL, 10);
		else if (arg == "--thread-map" && hasValue)
			threadMapSpec = argv[++i];
		else
			args.push_back(arg);
	}

	if (args.empty())
	{
		std::cerr << "Usage: " << argv[0] << " <hex_file> [expected_file] [max_cycles] [--stats] [--run-cores <m>]"
		          << " [--serial-in <file>] [--serial-out <file>] [--serial-pty] [--timer-tick-divider <n>]"
		          << " [--icache-lines <n>] [--icache-ways <n>] [--dcache-lines <n>] [--dcache-ways <n>] [--always-cacheable]"
		          << " [--threads <n>] [--thread-map <t0,t1,...>]\n";
		return 1;
	}

	std::string   hexFile      = args[0];
	std::string   expectedFile = (args.size() >= 2) ? args[1] : "";
	unsigned long maxCycles    = (args.size() >= 3) ? std::strtoul(args[2].c_str(), NULL, 10) : 1000000UL;

	using namespace sitar;

	Top* TOP = new Top;
	TOP->setInstanceId("TOP");
	TOP->setHierarchicalId("");

	const unsigned int numCores = sizeof(TOP->system.cores) / sizeof(TOP->system.cores[0]);
	if (runCores == 0)
		runCores = numCores;
	if (runCores > numCores)
	{
		std::cerr << "ERROR: --run-cores must be 1 to " << numCores << "\n";
		return 1;
	}

	//Which thread runs which module (one thread: a plain serial run).
	std::vector<std::string> moduleNames;
	std::vector<sitar::module*> modules = mappedModules(TOP, numCores, moduleNames);
	std::vector<unsigned int> threadMap;
	if (!threadMapSpec.empty())
	{
		std::stringstream spec(threadMapSpec);
		std::string item;
		while (std::getline(spec, item, ','))
			threadMap.push_back((unsigned int) std::strtoul(item.c_str(), NULL, 10));
		if (threadMap.size() != modules.size())
		{
			std::cerr << "ERROR: --thread-map needs " << modules.size() << " thread numbers, one each for";
			for (const std::string& n : moduleNames)
				std::cerr << " " << n;
			std::cerr << "\n";
			return 1;
		}
		numThreads = *std::max_element(threadMap.begin(), threadMap.end()) + 1;
	}
	else
	{
		if (numThreads == 0)
		{
	#ifdef _OPENMP
			//omp_get_max_threads() is OMP_NUM_THREADS when that is set,
			//else the host's CPU count. Only an explicit request runs in
			//parallel, since a small system runs slower in parallel.
			numThreads = std::getenv("OMP_NUM_THREADS") ? (unsigned int) omp_get_max_threads() : 1;
	#else
			numThreads = 1;
	#endif
		}
		//A thread with no core of its own would only add a barrier.
		numThreads = std::max(1u, std::min(numThreads, numCores));
		threadMap = defaultThreadMap(numCores, numThreads);
	}
	#ifndef _OPENMP
	if (numThreads > 1)
	{
		std::cerr << "ERROR: --threads/--thread-map need an executable built with build.sh --openmp\n";
		return 1;
	}
	#endif
	std::vector<std::vector<sitar::module*>> threadModules(numThreads);
	for (size_t k = 0; k < modules.size(); k++)
		threadModules[threadMap[k]].push_back(modules[k]);

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

	//Several threads: one Sitar log per thread, shared by every module
	//that thread runs (and their procedures). `system` and Top are set
	//alone, not hierarchically, since their children may run elsewhere.
	std::vector<std::unique_ptr<std::ofstream>> threadLogFiles;
	if (numThreads > 1)
	{
		for (unsigned int t = 0; t < numThreads; t++)
			threadLogFiles.emplace_back(new std::ofstream(("sitar.thread" + std::to_string(t) + ".log").c_str()));
		for (size_t k = 0; k < modules.size(); k++)
		{
			std::ofstream* stream = threadLogFiles[threadMap[k]].get();
			if (modules[k] == &TOP->system)
			{
				TOP->system.log.setOstream(stream);
				TOP->log.setOstream(stream);
			}
			else
				setHierarchicalOstream(modules[k], stream);
		}
	}

	std::vector<std::unique_ptr<std::ofstream>> sparcTraceFiles;
	for (unsigned int i = 0; i < runCores; i++)
	{
		auto& thread = TOP->system.cores[i].sparcThread;
		std::string traceFile = traceFileName(hexFile, i);
		sparcTraceFiles.emplace_back(new std::ofstream(traceFile.c_str()));
		if (sparcTraceFiles.back()->is_open())
		{
			thread.log.setOstream(sparcTraceFiles.back().get());
			thread.log.useDefaultPrefix = false;
			thread.log.setPrefix("");
			*sparcTraceFiles.back() << thread.core.logger.header() << "\n";
		}
		else
		{
			std::cerr << "warning: could not open " << traceFile << " for writing; core " << i << "'s trace will go to stderr instead\n";
		}
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

	for (unsigned int i = 0; i < numCores; i++)
	{
		TOP->system.cores[i].caches.caches.instructionCache.configure(icacheLines, icacheWays);
		TOP->system.cores[i].caches.caches.dataCache.configure(dcacheLines, dcacheWays);
	}

	//Cores beyond --run-cores never leave reset.
	TOP->system.runCores = runCores;
	for (unsigned int i = runCores; i < numCores; i++)
		TOP->system.cores[i].sparcThread.RESET_pin = 1;

	//Same as the cpp_model: --always-cacheable or SPARC_ALWAYS_CACHEABLE=1
	//sets the MMU Control Register's "always cacheable" bit before the run.
	if (const char* env = std::getenv("SPARC_ALWAYS_CACHEABLE"))
		alwaysCacheable = alwaysCacheable || (std::string(env) == "1");
	if (alwaysCacheable)
	{
		VirtualMemoryRequest set{true, MemAccessType::STORE, 0x000, ASI_MMU_REGISTER, 0x100, 0, 0x0F};
		VirtualMemoryResponse ignored{};
		for (unsigned int i = 0; i < numCores; i++)
			TOP->system.cores[i].mmu.mmu.access(set, ignored);
	}

	//run for up to maxCycles cycles (Sitar counts phases, 2 per cycle),
	//or until the model itself calls `stop simulation` (System.sitar does
	//this once every running core has halted).
	uint64_t simulation_time = 0;
	const uint64_t phaseLimit = (uint64_t)maxCycles * 2;
	#ifdef _OPENMP
	if (numThreads > 1)
	{
		//Sitar's own parallel loop (as in its sitar_default_main.cpp),
		//with each thread running its own, fixed list of modules: one
		//phase, a barrier, then the stop check. Two barriers per cycle.
		//
		//The stop check asks whether `stop simulation` was called in phase t
		//or earlier, not merely whether it has been called. A thread that has
		//already moved on into phase t+1 may stop the run there while a
		//slower thread is still checking phase t. With a plain flag, the
		//slower thread would leave the loop a phase early, and the two would
		//wait at different barriers for ever. Sitar records the phase of the
		//stop, so every thread leaves after the same phase, and the run ends
		//on the same cycle as a serial run.
		uint64_t finalTime = 0;
		omp_set_dynamic(0);
		#pragma omp parallel num_threads(numThreads)
		{
			const std::vector<sitar::module*>& mine = threadModules[omp_get_thread_num()];
			uint64_t t;
			for (t = 0; t < phaseLimit; t++)
			{
				for (sitar::module* m : mine)
					m->run(t);
				#pragma omp barrier
				if (sitar::simulation_stopped_by(t))
					break;
			}
			#pragma omp single
			{ finalTime = t; }
		}
		simulation_time = finalTime;
	}
	else
	#endif
	{
		for (simulation_time = 0; simulation_time < phaseLimit; simulation_time++)
		{
			TOP->runHierarchical(simulation_time);
			if (sitar::simulation_stopped())
				break;
		}
	}

	bool allHalted = true;
	for (unsigned int i = 0; i < runCores; i++)
		allHalted = allHalted && TOP->system.cores[i].sparcThread.HALT.VALUE;
	unsigned long cyclesExecuted = (unsigned long)(simulation_time / 2);

	if (printStats)
	{
		std::cout << "\n=== threads ===\n " << numThreads << " thread(s):";
		for (unsigned int t = 0; t < numThreads; t++)
		{
			std::cout << "\n\t thread " << t << " =";
			for (size_t k = 0; k < modules.size(); k++)
				if (threadMap[k] == t)
					std::cout << " " << moduleNames[k];
		}
		std::cout << "\n";
		for (unsigned int i = 0; i < runCores; i++)
			std::cout << "\n=== core " << i << " ===\n"
			          << TOP->system.cores[i].sparcThread.core.stats.toString()
			          << TOP->system.cores[i].caches.caches.statsToString()
			          << TOP->system.cores[i].mmu.mmu.stats.toString();
		std::cout << "\n=== shared ===\n Bridge transactions per core:";
		for (unsigned int i = 0; i < numCores; i++)
			std::cout << "\n\t core " << i << " = " << TOP->system.bridge.transactionsPerCore[i];
		std::cout << "\n" << TOP->system.mainMemory.mem.stats.toString()
		          << TOP->system.devices.devices.stats.toString();
	}

	if (expectedFile.empty())
	{
		for (unsigned int i = 0; i < runCores; i++)
			std::cout << "\n=== core " << i << " ===\n" << TOP->system.cores[i].sparcThread.core.logger.print_state() << "\n";
		if (allHalted)
			std::cout << "Simulation halted after " << cyclesExecuted << " cycles (all " << runCores << " cores halted).\n";
		else
			std::cout << "Simulation stopped: cycle limit (" << maxCycles
			          << ") reached without every core halting.\n";
		return allHalted ? 0 : 1;
	}

	if (!allHalted)
	{
		std::cout << "FAIL: not every core halted within " << maxCycles << " cycles (still running:";
		for (unsigned int i = 0; i < runCores; i++)
			if (!TOP->system.cores[i].sparcThread.HALT.VALUE)
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
			continue; //blank line
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
			if (!getRegisterValue(TOP->system.cores[coreId].sparcThread.core.reg, regName, actual))
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
