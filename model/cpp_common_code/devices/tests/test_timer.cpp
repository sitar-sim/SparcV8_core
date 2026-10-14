//test_timer.cpp
//
//Standalone unit test for TimerCore. Exercises the class directly,
//with no dependency on the rest of the model, to check that its
//register read/write and counting behavior match
//https://sitar-sim.github.io/SparcV8_core/peripheral_devices_timer.html
//and AJIT's own timer (Ref TimerCore.h's header comment).
//
//Lives in devices/tests/, one level below the device source files, so
//that model/build_scripts/build_cpp_model.sh's cpp_common_code/*/*.cpp
//glob (one directory level only) doesn't pick it up and try to link
//its main() into every model configuration's build.
//
//Build:
//  g++ -std=c++11 -I.. -I../.. -o test_timer test_timer.cpp ../TimerCore.cpp ../../BitManipulation.cpp
//Run:
//  ./test_timer

#include "../TimerCore.h"
#include "../DeviceAddresses.h"
#include <iostream>

static int numChecks = 0;
static int numFailed = 0;

static void check(bool condition, const std::string& description)
{
	numChecks++;
	if (condition)
		std::cout << "PASS: " << description << "\n";
	else
	{
		std::cout << "FAIL: " << description << "\n";
		numFailed++;
	}
}

static const uint32_t CONTROL = DeviceAddress::TIMER_CONTROL;

static uint32_t controlWord(uint32_t maxCount, bool enable)
{
	return (maxCount << 1) | (enable ? 1u : 0u);
}

static void testResetState()
{
	TimerCore timer;
	check(timer.state == TimerCore::State::DISABLED, "starts in DISABLED");
	check(timer.count == 0,                          "starts with count 0");
	check(timer.intOut == false,                     "starts with intOut low");
	check(timer.readRegister(CONTROL, 0xF) == 0,     "Control reads 0 after reset");
}

static void testCountAndInterrupt()
{
	TimerCore timer;
	timer.writeRegister(CONTROL, 0xF, controlWord(3, true));
	check(timer.state == TimerCore::State::ENABLED, "enable write moves to ENABLED");
	check(timer.count == 0 && timer.maxCount == 3,  "enable write clears count and captures max_count");

	timer.tick();
	timer.tick();
	check(timer.count == 2 && !timer.intOut, "two ticks: count 2, no interrupt yet");

	timer.tick();
	check(timer.intOut, "third tick: count reaches max_count, interrupt asserted");
	check(timer.state == TimerCore::State::INTERRUPTING, "third tick: moves to INTERRUPTING");

	timer.tick();
	check(timer.count == 3 && timer.intOut, "tick while INTERRUPTING changes nothing");
}

static void testZeroAndOneMaxCount()
{
	TimerCore a;
	a.writeRegister(CONTROL, 0xF, controlWord(0, true));
	a.tick();
	check(a.intOut, "max_count 0 interrupts on the first tick (no wrap-around)");

	TimerCore b;
	b.writeRegister(CONTROL, 0xF, controlWord(1, true));
	check(!b.intOut, "max_count 1: no interrupt before the first tick");
	b.tick();
	check(b.intOut, "max_count 1 interrupts on the first tick");
}

static void testDisableClears()
{
	TimerCore timer;
	timer.writeRegister(CONTROL, 0xF, controlWord(1, true));
	timer.tick();
	check(timer.intOut, "setup: interrupt asserted");

	timer.writeRegister(CONTROL, 0xF, controlWord(1, false));
	check(timer.state == TimerCore::State::DISABLED, "disable write moves to DISABLED");
	check(timer.count == 0 && !timer.intOut,         "disable write clears count and intOut");
}

static void testEnableIgnoredUnlessDisabled()
{
	TimerCore timer;
	timer.writeRegister(CONTROL, 0xF, controlWord(5, true));
	timer.tick();
	timer.tick();
	timer.writeRegister(CONTROL, 0xF, controlWord(100, true));
	check(timer.count == 2 && timer.maxCount == 5,
	      "enable write while ENABLED does not restart or reload the timer");

	TimerCore t2;
	t2.writeRegister(CONTROL, 0xF, controlWord(1, true));
	t2.tick();
	t2.writeRegister(CONTROL, 0xF, controlWord(1, true));
	check(t2.state == TimerCore::State::INTERRUPTING && t2.intOut,
	      "enable write while INTERRUPTING keeps the interrupt asserted, state unchanged");
}

static void testReadReturnsControlWord()
{
	TimerCore timer;
	timer.writeRegister(CONTROL, 0xF, controlWord(5, true));
	timer.tick();
	check(timer.readRegister(CONTROL, 0xF) == controlWord(5, true),
	      "read returns the Control word as written, not the live count");
}

static void testByteLaneWrites()
{
	TimerCore timer;
	//Write only the least significant byte (lane 0): max_count bits
	//[7:1] = 4, enable = 1.
	timer.writeRegister(CONTROL, 0x1, controlWord(4, true));
	check(timer.state == TimerCore::State::ENABLED && timer.maxCount == 4,
	      "a byte-lane write is merged into the Control word");

	TimerCore t2;
	t2.writeRegister(CONTROL, 0xF, 0x12345600u);
	t2.writeRegister(CONTROL, 0x1, 0x00000001u);
	check(t2.readRegister(CONTROL, 0xF) == 0x12345601u,
	      "unselected lanes keep their previous value");
}

static void testUnmappedAddress()
{
	TimerCore timer;
	timer.writeRegister(DeviceAddress::TIMER_CONTROL + 4, 0xF, controlWord(3, true));
	check(timer.state == TimerCore::State::DISABLED, "write to an unmapped timer offset is ignored");
	check(timer.readRegister(DeviceAddress::TIMER_CONTROL + 4, 0xF) == 0, "read of an unmapped timer offset returns 0");
}

int main()
{
	testResetState();
	testCountAndInterrupt();
	testZeroAndOneMaxCount();
	testDisableClears();
	testEnableIgnoredUnlessDisabled();
	testReadReturnsControlWord();
	testByteLaneWrites();
	testUnmappedAddress();

	std::cout << "\n" << (numFailed == 0 ? "OVERALL: PASS" : "OVERALL: FAIL")
	          << " (" << numChecks << " checks, " << numFailed << " failed)\n";
	return numFailed == 0 ? 0 : 1;
}
