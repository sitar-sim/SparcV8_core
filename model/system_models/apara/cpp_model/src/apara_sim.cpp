//apara_sim.cpp
//
//The apara configuration's entry point: one standalone APARA engine
//(AparaCore), functional model. The program and its data are placed
//directly in the engine's IMEM and DMEM before the run, and the run
//ends when no thread is left running. Every data address aliases into
//DMEM (OffIslandMode::ALIAS_TO_LOCAL), as in the reference model.
//
//The options follow the reference simulator, mcode_run, so the same
//test files run on both:
//
//Usage: apara_sim_cpp (-p <pc>)... -i <object-file> [-d <data-file>]
//                     [-a <register-file>] [-r <results-file>]
//                     [--dump-results <file>] [--max-bundles <n>]
//                     [--trace] [--stats]
//
//  -p <pc>             start a thread at <pc> (hex, in instruction words);
//                      the first -p starts thread 0, the next thread 1, ...
//  -i <object-file>    the program (mcode_assemble's .obj format)
//  -d <data-file>      initial DMEM contents (data.map format)
//  -a <register-file>  initial register values
//  -r <results-file>   expected final state; the run PASSes if it matches
//  --dump-results <f>  write the final state as a results file ("-" for
//                      standard output)
//  --max-bundles <n>   stop after <n> bundles (default 100000000)
//  --trace             print every bundle executed
//  --stats             print per-thread bundle and instruction counts
//
//File formats: Ref AparaFiles.h. Exit status: 0 PASS (or no -r given
//and no thread stopped by an exception), 1 FAIL, 2 bad usage or input.

#include "AparaCore.h"
#include "AparaRun.h"
#include <iostream>
#include <cstdio>

using namespace apara;

static void printBundle(const StepResult& r)
{
	std::printf("t%u 0x%x:", r.thread, r.pc);
	if (!r.bundle->valid)
		std::cout << " (" << r.bundle->problem << ")";
	else
		for (unsigned int s = 0; s < r.bundle->size; s++)
		{
			const Instruction& in = r.bundle->slot[s];
			if (in.opcode == Opcode::NULL_OP && in.valid)
				continue;
			std::cout << "  " << in.toString() << ";";
		}
	if (r.exception) std::cout << "  -> exception";
	else if (r.halted) std::cout << "  -> halt";
	else if (r.redirect) std::printf("  -> 0x%x", r.nextPc);
	std::cout << "\n";
}

int main(int argc, char* argv[])
{
	RunOptions o;
	int status = parseRunOptions(argc, argv, false, o);
	if (status >= 0)
		return status;

	AparaCore core;
	std::vector<uint64_t> initialDmem;
	std::string error;
	if (!loadRun(core, o, initialDmem, error)) { std::cerr << "error: " << error << "\n"; return 2; }
	for (unsigned int t = 0; t < o.startPcs.size(); t++)
		core.startThread(t, o.startPcs[t]);

	uint64_t bundles = 0;
	uint64_t instructions[THREADS_PER_ENGINE] = {0, 0, 0, 0};
	while (core.anyRunnable() && bundles < o.limit)
	{
		StepResult r = core.tick();
		bundles++;
		if (r.bundle && r.bundle->valid && !r.exception)
			for (unsigned int s = 0; s < r.bundle->size; s++)
				if (r.bundle->slot[s].opcode != Opcode::NULL_OP && r.bundle->slot[s].opcode != Opcode::NOP)
					instructions[r.thread]++;
		if (o.trace)
			printBundle(r);
	}
	std::cout << "ran " << bundles << " bundles\n";
	if (o.stats)
		for (unsigned int t = 0; t < THREADS_PER_ENGINE; t++)
			if (core.thread(t).active)
				std::cout << "thread " << t << ": " << core.thread(t).bundlesExecuted << " bundles, "
				          << instructions[t] << " instructions (excluding $null/$nop)\n";
	return finishRun(core, o, initialDmem, core.anyRunnable(), std::cout);
}
