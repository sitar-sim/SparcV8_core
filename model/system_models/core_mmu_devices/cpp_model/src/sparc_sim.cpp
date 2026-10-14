//sparc_sim.cpp
//
//The core_mmu_devices configuration's entry point. The same as
//core_mmu's own sparc_sim.cpp, except that the MMU's downstream target
//is a SystemBus instead of a plain MainMemory. The bus routes each
//physical address either to main memory or to the shared set of
//peripheral devices (PeripheralDevicesCore: Timer, Serial, Interrupt
//Controller). After every core cycle the devices tick once, and the
//Interrupt Controller's level for this core's thread slot is driven
//onto the core's IRL input pins (bp_IRL), sampled on the next cycle.
//
//MEM checks in the expected-results file read straight from
//MainMemory's own plain readWord(), not through the MMU, since they're
//checking physical memory state directly, what a test setting up page
//tables needs.
//
//Usage: sparc_sim_cpp <hex_file> [expected_file] [max_cycles] [--stats]
//                     [--serial-in <file>] [--serial-out <file>] [--serial-pty]
//                     [--timer-tick-divider <n>]
//
//Serial device I/O (Ref SerialBackend.h): by default, transmitted bytes
//go to this program's standard output. Received bytes come from
//--serial-in's file, or, if that is not given, from <hex_file> with
//.hex replaced by .serial_in, if such a file exists (so a validation
//test can carry its own input). --serial-out sends transmitted bytes
//to a file instead. --serial-pty uses a pseudo-terminal for both.
//
//--timer-tick-divider sets how many core cycles make one timer tick
//(default 1).
//
//--stats prints the core's instruction-mix counters, the MMU's
//statistics, and physical memory's own access counters (see
//SparcCoreStats.h, MmuStats.h, MainMemoryStats.h), layered
//innermost-to-outermost, once the run finishes, to stdout, ahead of
//the state/PASS-FAIL report below. Off by default. Can appear anywhere
//among the arguments.

#include "SparcCore.h"
#include "MainMemory.h"
#include "SparcStateMachine.h"
#include "MmuCore.h"
#include "SystemBus.h"
#include "PeripheralDevicesCore.h"
#include "SerialBackend.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <cctype>
#include <cstdlib>

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
	//Pull the --options out of the argument list wherever they appear,
	//leaving the rest to be parsed positionally exactly as core_mmu does.
	bool printStats = false;
	SerialBackendConfig serialConfig;
	bool serialInputGiven = false;
	uint32_t timerTickDivider = 1;
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
		else
			args.push_back(arg);
	}

	if (args.empty())
	{
		std::cerr << "Usage: " << argv[0] << " <hex_file> [expected_file] [max_cycles] [--stats]"
		          << " [--serial-in <file>] [--serial-out <file>] [--serial-pty] [--timer-tick-divider <n>]\n";
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

	SystemBus bus(mem, devices);
	MmuCore mmu(bus);

	//Manual/debug knob for exercising MmuCore::tlbEnabled -- not part of the
	//documented CLI (argv parsing above is untouched, so run_tests.py's
	//fixed <hex> [expected] [max_cycles] invocation is unaffected).
	//MMU_TLB_ENABLED=0 forces the TLB off for this run; unset or any
	//other value leaves it at its MMU_TLB_PRESENT-derived default.
	if (const char* tlbEnabledEnv = std::getenv("MMU_TLB_ENABLED"))
		mmu.tlbEnabled = (std::string(tlbEnabledEnv) != "0");

	SparcCore core;
	core.memCore = &mmu;

	SparcStateMachine runner(core, mmu);

	//This single core is core 0, thread 0 (Ref SparcCore::coreThreadIdWord()).
	const int interruptSlot = InterruptControllerCore::slotIndex(core.getCoreID(), core.getThreadID());
	runner.afterEachCycle = [&]()
	{
		devices.tick();
		core.reg.W_bp_IRL(devices.interruptLevel(interruptSlot)); //the core's IRL input pins
	};

#ifdef SPARC_LOGGING_ENABLED
	std::string traceFile = traceFileName(hexFile);
	std::ofstream logFile(traceFile.c_str());
	if (logFile.is_open())
	{
		core.logger.init(core, &logFile, true);
		mmu.setLogger(&core.logger, &runner.cyclesExecuted);
		std::cout << "Logging instruction trace to " << traceFile << "\n";
	}
	else
	{
		std::cerr << "warning: could not open " << traceFile << " for writing; continuing without logging\n";
	}
#endif

	runner.run(maxCycles);

	if (printStats)
		std::cout << core.stats.toString() << mmu.stats.toString() << mem.stats.toString()
		          << devices.stats.toString();

	if (expectedFile.empty())
	{
		std::cout << "\n" << core.logger.print_state() << "\n";
		if (runner.halted)
			std::cout << "Simulation halted after " << runner.cyclesExecuted << " cycles.\n";
		else
			std::cout << "Simulation stopped: cycle limit (" << maxCycles
			          << ") reached without halting.\n";
		return runner.halted ? 0 : 1;
	}

	if (!runner.halted)
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

			uint32_t actual;
			if (!getRegisterValue(core.reg, name, actual))
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
