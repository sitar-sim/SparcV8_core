//apara_sim.cpp
//
//The apara configuration's Sitar entry point: one standalone APARA engine
//with its timing model (Top.sitar, AparaEngine.sitar). The same command
//line and files as the cpp_model's apara_sim_cpp (Ref AparaRun.h), plus
//--max-cycles (default 100000000) and --latency-file (Ref AparaTiming.h's
//LatencyTable). Reports the cycles the run took: up to the cycle the
//last thread's halting bundle left WRITEBACK.
//
//--stats prints the pipeline's counters (--trace has no effect here).

#include "Top.h"
#include "AparaRun.h"
#include <iostream>

using namespace sitar;
using namespace apara;

int main(int argc, char* argv[])
{
	RunOptions o;
	int status = parseRunOptions(argc, argv, true, o);
	if (status >= 0)
		return status;

	Top* TOP = new Top;
	TOP->setInstanceId("TOP");
	AparaCore& core = TOP->engine.exec.core;

	std::vector<uint64_t> initialDmem;
	std::string error;
	if (!loadRun(core, o, initialDmem, error)) { std::cerr << "error: " << error << "\n"; return 2; }
	if (!o.latencyFile.empty() && !TOP->engine.exec.latency.load(o.latencyFile, error))
	{
		std::cerr << "error: " << error << "\n";
		return 2;
	}
	for (unsigned int t = 0; t < o.startPcs.size(); t++)
		TOP->engine.startThread(t, o.startPcs[t]);
	TOP->startedThreads = (unsigned int) o.startPcs.size();

	uint64_t time;
	for (time = 0; time < o.limit * 2; time++)
	{
		TOP->runHierarchical(time);
		if (sitar::simulation_stopped())
			break;
	}
	bool stillRunning = !sitar::simulation_stopped();
	uint64_t cycles = TOP->engine.writeback.lastRetireCycle + 1;

	std::cout << "ran " << TOP->engine.writeback.retired << " bundles in " << cycles << " cycles\n";
	if (TOP->engine.exec.pcMismatches)
		std::cout << "internal error: " << TOP->engine.exec.pcMismatches
		          << " executed bundles were not at their thread's PC\n";
	if (o.stats)
		std::cout << TOP->engine.stats().toString();
	return finishRun(core, o, initialDmem, stillRunning, std::cout);
}
