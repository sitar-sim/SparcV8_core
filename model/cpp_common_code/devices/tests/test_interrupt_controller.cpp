//test_interrupt_controller.cpp
//
//Standalone unit test for InterruptControllerCore. Exercises the class
//directly, with no dependency on the rest of the model, to check its
//per-slot register format and state machine, masking, priority, and the
//IPI block against
//https://sitar-sim.github.io/SparcV8_core/peripheral_devices_interrupt_controller.html
//and AJIT's multi-thread interrupt controller (Ref
//InterruptControllerCore.h's header comment).
//
//Lives in devices/tests/, one level below the device source files, so
//that model/build_scripts/build_cpp_model.sh's cpp_common_code/*/*.cpp
//glob (one directory level only) doesn't pick it up and try to link
//its main() into every model configuration's build.
//
//Build:
//  g++ -std=c++11 -I.. -I../.. -o test_interrupt_controller test_interrupt_controller.cpp ../InterruptControllerCore.cpp ../../BitManipulation.cpp
//Run:
//  ./test_interrupt_controller

#include "../InterruptControllerCore.h"
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

typedef InterruptControllerCore Irc;

static uint32_t slotAddress(int slot) { return DeviceAddress::INTERRUPT_CONTROLLER_MIN + 4 * slot; }
static uint32_t ipiAddress(int word)  { return DeviceAddress::IPI_BASE + 4 * word; }

//Enable bit plus a mask enabling the given levels.
static uint32_t controlWord(bool enable, uint32_t levelBits)
{
	return levelBits | (enable ? 1u : 0u);
}

static uint32_t levelBit(uint32_t irl) { return 1u << irl; }

static void testResetState()
{
	Irc irc;
	bool allClear = true;
	for (int s = 0; s < Irc::NUM_SLOTS; s++)
		allClear = allClear && irc.slots[s].state == Irc::State::DISABLED
		                    && irc.interruptLevel(s) == 0
		                    && irc.readRegister(slotAddress(s), 0xF) == 0;
	check(allClear, "every slot starts DISABLED, level 0, Control reads 0");
	check(Irc::slotIndex(1, 1) == 3 && Irc::slotIndex(3, 0) == 6, "slot index is 2*core + thread");
}

static void testDisabledIgnoresInputs()
{
	Irc irc;
	irc.timerIn = true;
	irc.tick();
	check(irc.interruptLevel(0) == 0, "a DISABLED slot delivers nothing");
}

static void testTimerDelivery()
{
	Irc irc;
	irc.writeRegister(slotAddress(0), 0xF, controlWord(true, levelBit(InterruptLevel::TIMER)));
	check(irc.slots[0].state == Irc::State::ENABLED, "enable write moves the slot to ENABLED");

	irc.tick();
	check(irc.interruptLevel(0) == 0, "no input active: still ENABLED, level 0");

	irc.timerIn = true;
	irc.tick();
	check(irc.interruptLevel(0) == InterruptLevel::TIMER, "timer input delivers IRL 10");
	check(irc.slots[0].state == Irc::State::INTERRUPTING, "slot moves to INTERRUPTING");

	irc.timerIn = false;
	irc.tick();
	check(irc.interruptLevel(0) == InterruptLevel::TIMER, "level is held while INTERRUPTING, even once the source drops");

	irc.writeRegister(slotAddress(0), 0xF, controlWord(false, levelBit(InterruptLevel::TIMER)));
	check(irc.slots[0].state == Irc::State::DISABLED && irc.interruptLevel(0) == 0,
	      "clearing the enable bit drops the level and returns to DISABLED");
}

static void testMasking()
{
	Irc irc;
	irc.writeRegister(slotAddress(0), 0xF, controlWord(true, levelBit(InterruptLevel::SERIAL)));
	irc.timerIn = true;
	irc.tick();
	check(irc.interruptLevel(0) == 0, "a level not enabled in the mask is not delivered");

	irc.serialIn = true;
	irc.tick();
	check(irc.interruptLevel(0) == InterruptLevel::SERIAL, "an enabled level is delivered");
}

static void testPriority()
{
	Irc irc;
	uint32_t all = levelBit(InterruptLevel::TIMER) | levelBit(InterruptLevel::SERIAL) | levelBit(InterruptLevel::EXTERNAL);
	irc.writeRegister(slotAddress(0), 0xF, controlWord(true, all));
	irc.serialIn = irc.externalIn = irc.timerIn = true;
	irc.tick();
	check(irc.interruptLevel(0) == InterruptLevel::TIMER, "with several active, the lowest IRL wins (timer)");

	Irc irc2;
	irc2.writeRegister(slotAddress(0), 0xF, controlWord(true, all));
	irc2.serialIn = irc2.externalIn = true;
	irc2.tick();
	check(irc2.interruptLevel(0) == InterruptLevel::SERIAL, "serial (12) beats external (14)");
}

static void testReadBackFormat()
{
	Irc irc;
	uint32_t mask = levelBit(InterruptLevel::TIMER) | levelBit(InterruptLevel::SERIAL);
	irc.writeRegister(slotAddress(2), 0xF, controlWord(true, mask));
	irc.serialIn = true;
	uint32_t before = irc.readRegister(slotAddress(2), 0xF);
	check((before & 0xFFFFu) == controlWord(true, mask), "bits [15:0] read back as written");
	check(((before >> (15 + InterruptLevel::SERIAL)) & 1u) == 1u, "active serial shows at bit 15+12 of the vector");
	check(((before >> 31) & 1u) == 0u, "bit 31 clear before the slot is INTERRUPTING");

	irc.tick();
	uint32_t after = irc.readRegister(slotAddress(2), 0xF);
	check(((after >> 31) & 1u) == 1u, "bit 31 set while INTERRUPTING");

	irc.writeRegister(slotAddress(2), 0xF, 0xFFFF0000u | controlWord(true, mask));
	check((irc.readRegister(slotAddress(2), 0xF) & 0x7FFF0000u) == ((irc.incomingVector(2) >> 1) << 16),
	      "writes to the read-only vector bits do not show on read-back");
}

static void testSlotsAreIndependent()
{
	Irc irc;
	irc.writeRegister(slotAddress(0), 0xF, controlWord(true, levelBit(InterruptLevel::TIMER)));
	irc.writeRegister(slotAddress(1), 0xF, controlWord(true, levelBit(InterruptLevel::SERIAL)));
	irc.timerIn = true;
	irc.tick();
	check(irc.interruptLevel(0) == InterruptLevel::TIMER && irc.interruptLevel(1) == 0,
	      "the broadcast timer reaches only the slot whose mask enables it");
	check(irc.interruptLevel(5) == 0, "untouched slots stay idle");
}

static void testIpi()
{
	Irc irc;
	irc.writeRegister(slotAddress(3), 0xF, controlWord(true, levelBit(InterruptLevel::IPI)));
	irc.writeRegister(ipiAddress(1), 0xF, 1u << 3); //value bit for slot 3
	irc.tick();
	check(irc.interruptLevel(3) == 0, "IPI value without the mask bit is not delivered");

	irc.writeRegister(ipiAddress(0), 0xF, 1u << 3); //mask bit for slot 3
	irc.tick();
	check(irc.interruptLevel(3) == InterruptLevel::IPI, "IPI mask and value both set: slot 3 gets IRL 11");
	check(irc.interruptLevel(2) == 0, "other slots do not see slot 3's IPI");

	irc.writeRegister(ipiAddress(18), 0xF, 0xCAFEu);
	irc.writeRegister(ipiAddress(2),  0xF, 0x1234u);
	check(irc.readRegister(ipiAddress(18), 0xF) == 0xCAFEu && irc.readRegister(ipiAddress(2), 0xF) == 0x1234u,
	      "lock word and message words are separate storage (no aliasing)");
	check(irc.ipiWords[0] == (1u << 3), "writing the lock word does not disturb the IPI mask");
}

static void testByteLaneWrite()
{
	Irc irc;
	//Lane 1 (bits [15:8]) carries the timer mask bit (bit 10), lane 0 the enable bit.
	irc.writeRegister(slotAddress(0), 0x2, levelBit(InterruptLevel::TIMER));
	check(irc.slots[0].state == Irc::State::DISABLED, "mask-only byte write leaves the slot DISABLED");
	irc.writeRegister(slotAddress(0), 0x1, 0x1u);
	irc.timerIn = true;
	irc.tick();
	check(irc.interruptLevel(0) == InterruptLevel::TIMER, "byte-lane writes merge into one Control word");
}

int main()
{
	testResetState();
	testDisabledIgnoresInputs();
	testTimerDelivery();
	testMasking();
	testPriority();
	testReadBackFormat();
	testSlotsAreIndependent();
	testIpi();
	testByteLaneWrite();

	std::cout << "\n" << (numFailed == 0 ? "OVERALL: PASS" : "OVERALL: FAIL")
	          << " (" << numChecks << " checks, " << numFailed << " failed)\n";
	return numFailed == 0 ? 0 : 1;
}
