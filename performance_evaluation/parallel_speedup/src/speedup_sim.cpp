//speedup_sim.cpp
//Author: Neha Karanjkar
//
//Entry point of the parallel speedup demo. TOP->systems[s] is one
//multicore System (Ref ../../../model/system_models/multicore/), and
//every system runs the same program, loaded into its own memory, on all
//4 of its cores.
//
//Usage: speedup_sim <program.hex> [--threads <n>] [--max-cycles <n>]
//
//--threads n (or OMP_NUM_THREADS) sets the number of host threads,
//default 1, at most NUM_SYSTEMS. The mapping is static and whole systems
//go to each thread, in contiguous blocks (16 systems on 4 threads:
//systems 0-3 on thread 0, and so on). A system's cores, bus, memory and
//devices all stay on one thread, and Top goes with thread 0.
//
//Caching is always on (the MMU's "always cacheable" bit, as
//sparc_sim's --always-cacheable), so the cores run mostly from their own
//caches, and each system's bus is lightly used.
//
//At the end it prints the cycles simulated, the time the simulation loop
//took, and whether every core of every system reported success with the
//same result as system 0's.

#include "Top.h"
#include "AsiValues.h"
#include "CacheConfig.h"
#include <iostream>
#include <string>
#include <vector>
#include <cstdlib>
#include <chrono>
#include <algorithm>

#ifdef _OPENMP
#include <omp.h>
#endif

//Each core's checksum, written by the program (Ref program/private_matmul.c).
static const uint32_t RESULTS_BASE = 0x00100000;

int main(int argc, char** argv)
{
	std::string   hexFile;
	unsigned int  numThreads = 0; //0: OMP_NUM_THREADS, else 1
	unsigned long maxCycles  = 1000000000UL;
	for (int i = 1; i < argc; i++)
	{
		std::string arg = argv[i];
		bool hasValue = (i + 1 < argc);
		if (arg == "--threads" && hasValue)
			numThreads = (unsigned int) std::strtoul(argv[++i], NULL, 10);
		else if (arg == "--max-cycles" && hasValue)
			maxCycles = std::strtoul(argv[++i], NULL, 10);
		else
			hexFile = arg;
	}
	if (hexFile.empty())
	{
		std::cerr << "Usage: " << argv[0] << " <program.hex> [--threads <n>] [--max-cycles <n>]\n";
		return 1;
	}

	using namespace sitar;
	Top* TOP = new Top;
	TOP->setInstanceId("TOP");
	TOP->setHierarchicalId("");

	const unsigned int numSystems = sizeof(TOP->systems) / sizeof(TOP->systems[0]);
	const unsigned int numCores   = sizeof(TOP->systems[0].cores) / sizeof(TOP->systems[0].cores[0]);

	if (numThreads == 0)
	{
	#ifdef _OPENMP
		numThreads = std::getenv("OMP_NUM_THREADS") ? (unsigned int) omp_get_max_threads() : 1;
	#else
		numThreads = 1;
	#endif
	}
	numThreads = std::max(1u, std::min(numThreads, numSystems));
	#ifndef _OPENMP
	if (numThreads > 1)
	{
		std::cerr << "ERROR: --threads needs an executable built with OpenMP (build.sh does this)\n";
		return 1;
	}
	#endif

	//Thread t runs systems in a contiguous block, the earlier threads
	//taking one more when they don't divide evenly. Each system's own
	//modules (its cores, bridge, mainMemory, devices, and the System
	//module itself) all go with it. Top goes with thread 0.
	std::vector<std::vector<sitar::module*>> threadModules(numThreads);
	std::vector<unsigned int> firstSystem(numThreads + 1, 0);
	for (unsigned int t = 0; t < numThreads; t++)
		firstSystem[t + 1] = firstSystem[t] + numSystems / numThreads + (t < numSystems % numThreads ? 1 : 0);
	for (unsigned int t = 0; t < numThreads; t++)
		for (unsigned int s = firstSystem[t]; s < firstSystem[t + 1]; s++)
		{
			auto& sys = TOP->systems[s];
			for (unsigned int i = 0; i < numCores; i++)
				threadModules[t].push_back(&sys.cores[i]);
			threadModules[t].push_back(&sys.bridge);
			threadModules[t].push_back(&sys.mainMemory);
			threadModules[t].push_back(&sys.devices);
			threadModules[t].push_back(&sys);
		}
	threadModules[0].push_back(TOP);

	VirtualMemoryRequest alwaysCacheable{true, MemAccessType::STORE, 0x000, ASI_MMU_REGISTER, 0x100, 0, 0x0F};
	VirtualMemoryResponse ignored{};
	for (unsigned int s = 0; s < numSystems; s++)
	{
		auto& sys = TOP->systems[s];
		sys.mainMemory.mem.initializeMemory(hexFile);
		for (unsigned int i = 0; i < numCores; i++)
		{
			sys.cores[i].caches.caches.instructionCache.configure(DEFAULT_ICACHE_LINES, DEFAULT_ICACHE_WAYS);
			sys.cores[i].caches.caches.dataCache.configure(DEFAULT_DCACHE_LINES, DEFAULT_DCACHE_WAYS);
			sys.cores[i].mmu.mmu.access(alwaysCacheable, ignored);
		}
	}

	std::cout << "\n" << numSystems << " systems of " << numCores << " cores each, "
	          << numThreads << " thread(s)" << std::endl;

	//The same loop as the multicore configuration's sparc_sim.cpp (Ref its
	//comment): one phase, a barrier, then the stop check for that phase.
	uint64_t simulation_time = 0;
	const uint64_t phaseLimit = (uint64_t)maxCycles * 2;
	auto start = std::chrono::steady_clock::now();
	#ifdef _OPENMP
	if (numThreads > 1)
	{
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
	double seconds = std::chrono::duration<double>(std::chrono::steady_clock::now() - start).count();

	//Every core must have halted with %o0 == 1, and written the same
	//checksum as the same core of system 0.
	bool pass = true;
	for (unsigned int s = 0; s < numSystems; s++)
		for (unsigned int i = 0; i < numCores; i++)
		{
			auto& thread = TOP->systems[s].cores[i].sparcThread;
			uint32_t sum0 = TOP->systems[0].mainMemory.mem.readWord(RESULTS_BASE + 4 * i);
			uint32_t sum  = TOP->systems[s].mainMemory.mem.readWord(RESULTS_BASE + 4 * i);
			if (!thread.HALT.VALUE || thread.core.reg.R_r(8) != 1 || sum != sum0)
			{
				std::cout << "system " << s << " core " << i << ": FAIL\n";
				pass = false;
			}
		}

	std::cout << "cycles   : " << simulation_time / 2 << "\n"
	          << "time     : " << seconds << " s\n"
	          << "result   : " << (pass ? "PASS" : "FAIL") << std::endl;
	return pass ? 0 : 1;
}
