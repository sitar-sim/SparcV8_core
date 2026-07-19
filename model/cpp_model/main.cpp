//main.cpp
//
//Standalone entry point for functional testing of the SparcCore
//model. Loads a hex-dump memory image (see MemCore::initializeMemory) into a
//flat MemCore, runs it to completion (or until a cycle limit is reached) via
//SparcStateMachine, then prints a register dump and how/whether it halted.
//
//This tool does not decide pass/fail -- it just runs a memory image and
//shows you the final state, for quick ad hoc use. A real test's pass/fail
//verdict comes from comparing final register/memory state against that
//test's expected results (see check_test.cpp and validation/run_tests.py).
//
//Usage: sparc_cpp_sim <hex_dump_file> [max_cycles]

#include "SparcCore.h"
#include "MemCore.h"
#include "SparcStateMachine.h"
#include <iostream>
#include <cstdlib>
#include <string>

int main(int argc, char** argv)
{
	if (argc < 2)
	{
		std::cerr << "Usage: " << argv[0] << " <hex_dump_file> [max_cycles]\n";
		return EXIT_FAILURE;
	}

	std::string  hexDumpFile = argv[1];
	unsigned long maxCycles  = (argc >= 3) ? std::strtoul(argv[2], NULL, 10) : 1000000UL;

	MemCore mem;
	mem.initializeMemory(hexDumpFile);

	SparcCore core;
	core.memCore = &mem; //used by SparcCore::instructionFetch()

	SparcStateMachine runner(core, mem);
	runner.run(maxCycles);

	std::cout << "\n" << core.printSparcRegisters() << "\n";

	if (runner.halted)
		std::cout << "\nSimulation halted (error_mode) after " << runner.cyclesExecuted << " cycles.\n";
	else
		std::cout << "\nSimulation stopped: cycle limit (" << maxCycles
		          << ") reached without halting\n";

	return runner.halted ? EXIT_SUCCESS : EXIT_FAILURE;
}
