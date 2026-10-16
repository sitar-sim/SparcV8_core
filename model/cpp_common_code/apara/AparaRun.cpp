//AparaRun.cpp
//Original author: Madhav Desai, IITB
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the APARA engine specification and
//reference C implementation developed by Prof. Madhav Desai, IITB

#include "AparaRun.h"
#include "AparaFiles.h"
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cstdio>

namespace apara
{

namespace
{
	std::string hex(uint64_t v)
	{
		char b[32];
		std::snprintf(b, sizeof(b), "0x%llx", (unsigned long long) v);
		return b;
	}

	void usage(bool sitar)
	{
		std::cerr << "Usage: " << (sitar ? "apara_sim_sitar" : "apara_sim_cpp")
		          << " (-p <pc>)... -i <object-file> [-d <data-file>] [-a <register-file>]\n"
		             "       [-r <results-file>] [--dump-results <file>] [--stats] [--trace]\n"
		          << (sitar ? "       [--max-cycles <n>] [--latency-file <file>]\n"
		                    : "       [--max-bundles <n>]\n");
	}

	void reportStop(unsigned int t, const ThreadState& ts, std::ostream& os)
	{
		if (ts.error & ERROR_RAS)
			os << "thread " << t << ": stopped at " << hex(ts.pc) << ", return-address stack error\n";
		if (!(ts.error & ERROR_EXCEPTION))
			return;
		os << "thread " << t << ": stopped at " << hex(ts.pc) << " by an exception:";
		for (unsigned int s = 0; s < BUNDLE_MAX_SLOTS; s++)
		{
			ExceptionCode c = (ExceptionCode) ((ts.error >> (3 * s)) & 7);
			if (c != ExceptionCode::NONE)
				os << " slot " << s << " " << exceptionName(c) << ";";
		}
		os << "\n";
	}
}

int parseRunOptions(int argc, char* argv[], bool sitar, RunOptions& o)
{
	for (int i = 1; i < argc; i++)
	{
		std::string a = argv[i];
		auto value = [&]() -> std::string {
			if (i + 1 >= argc) { std::cerr << "error: " << a << " needs a value\n"; usage(sitar); std::exit(2); }
			return argv[++i];
		};
		if (a == "-p")
		{
			if (o.startPcs.size() == THREADS_PER_ENGINE) { std::cerr << "error: at most 4 threads\n"; return 2; }
			o.startPcs.push_back((uint32_t) std::strtoul(value().c_str(), nullptr, 16));
		}
		else if (a == "-i") o.objectFile = value();
		else if (a == "-d") o.dataFile = value();
		else if (a == "-a") o.registerFile = value();
		else if (a == "-r") o.resultsFile = value();
		else if (a == "--dump-results") o.dumpFile = value();
		else if (a == "--stats") o.stats = true;
		else if (a == "--trace" || a == "-v") o.trace = true;
		else if (!sitar && a == "--max-bundles") o.limit = std::strtoull(value().c_str(), nullptr, 0);
		else if (sitar && a == "--max-cycles") o.limit = std::strtoull(value().c_str(), nullptr, 0);
		else if (sitar && a == "--latency-file") o.latencyFile = value();
		else if (a == "-h" || a == "--help") { usage(sitar); return 0; }
		else { std::cerr << "error: unknown option " << a << "\n"; usage(sitar); return 2; }
	}
	if (o.objectFile.empty()) { std::cerr << "error: no object file (-i)\n"; usage(sitar); return 2; }
	if (o.startPcs.empty()) o.startPcs.push_back(0);
	return -1;
}

bool loadRun(AparaCore& core, const RunOptions& o, std::vector<uint64_t>& initialDmem, std::string& error)
{
	if (loadObjectFile(core, o.objectFile, error) < 0) return false;
	if (!o.dataFile.empty() && loadDataFile(core, o.dataFile, error) < 0) return false;
	if (!o.registerFile.empty() && loadRegisterFile(core, o.registerFile, error) < 0) return false;
	initialDmem.resize(DMEM_DWORDS);
	for (uint32_t i = 0; i < DMEM_DWORDS; i++)
		initialDmem[i] = core.dmemDword(i);
	return true;
}

int finishRun(const AparaCore& core, const RunOptions& o, const std::vector<uint64_t>& initialDmem,
              bool stillRunning, std::ostream& os)
{
	bool exceptions = false;
	for (unsigned int t = 0; t < THREADS_PER_ENGINE; t++)
	{
		const ThreadState& ts = core.thread(t);
		if (!ts.active) continue;
		reportStop(t, ts, os);
		exceptions = exceptions || (ts.error & (ERROR_EXCEPTION | ERROR_RAS));
	}
	if (stillRunning)
		os << "stopped at the run limit, threads still running\n";

	if (!o.dumpFile.empty())
	{
		if (o.dumpFile == "-")
			writeResults(core, initialDmem, os);
		else
		{
			std::ofstream f(o.dumpFile.c_str());
			if (!f) { std::cerr << "error: cannot write " << o.dumpFile << "\n"; return 2; }
			writeResults(core, initialDmem, f);
		}
	}
	if (o.resultsFile.empty())
		return (exceptions || stillRunning) ? 1 : 0;
	std::string error;
	int mismatches = checkResultsFile(core, o.resultsFile, os, error);
	if (mismatches < 0) { std::cerr << "error: " << error << "\n"; return 2; }
	os << (mismatches == 0 && !stillRunning ? "PASS" : "FAIL") << "\n";
	return mismatches == 0 && !stillRunning ? 0 : 1;
}

}
