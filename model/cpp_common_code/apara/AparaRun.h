//AparaRun.h
//
//What the apara configuration's two simulators (cpp_model and
//sitar_model) share: their command line, loading the test files into an
//AparaCore, and the end-of-run report and results check.
//
//Command line (the reference simulator mcode_run's options, plus ours):
//  (-p <pc>)... -i <object-file> [-d <data-file>] [-a <register-file>]
//  [-r <results-file>] [--dump-results <file>] [--stats] [--trace]
//  [--max-bundles <n>]            (cpp_model)
//  [--max-cycles <n>] [--latency-file <file>]   (sitar_model)
//File formats: Ref AparaFiles.h.

#ifndef APARA_RUN_H
#define APARA_RUN_H

#include <string>
#include <vector>
#include <ostream>
#include "AparaCore.h"

namespace apara
{
	struct RunOptions
	{
		std::vector<uint32_t> startPcs;
		std::string objectFile, dataFile, registerFile, resultsFile, dumpFile, latencyFile;
		uint64_t limit = 100000000ULL; //bundles (cpp_model) or cycles (sitar_model)
		bool trace = false;
		bool stats = false;
	};

	//Returns -1 to go on, else the exit status (help, or a usage error).
	int parseRunOptions(int argc, char* argv[], bool sitar, RunOptions& o);

	//Loads the files and records the initial DMEM. Returns false (with
	//`error` set) if a file cannot be loaded.
	bool loadRun(AparaCore& core, const RunOptions& o, std::vector<uint64_t>& initialDmem, std::string& error);

	//Prints how each started thread stopped, writes the dump, checks the
	//results file. Returns the exit status: 0 PASS (or no results file
	//and no thread stopped by an exception), 1 FAIL, 2 bad input.
	int finishRun(const AparaCore& core, const RunOptions& o, const std::vector<uint64_t>& initialDmem,
	              bool stillRunning, std::ostream& os);
}

#endif
