//test_scratch_pad.cpp
//
//Standalone unit test for ScratchPadCore, and for its decoding inside
//PeripheralDevicesCore. Checks the behavior described in
//ScratchPadCore.h's header comment: 32 zeroed words, aliasing every 128
//bytes across the 1 KB range, byte-lane merging on writes.
//
//Lives in devices/tests/, one level below the device source files, so
//that model/build_scripts/build_cpp_model.sh's cpp_common_code/*/*.cpp
//glob (one directory level only) doesn't pick up its main().
//
//Build:
//  g++ -std=c++11 -I.. -I../.. -o test_scratch_pad test_scratch_pad.cpp ../ScratchPadCore.cpp ../PeripheralDevicesCore.cpp ../TimerCore.cpp ../SerialCore.cpp ../SerialBackend.cpp ../InterruptControllerCore.cpp ../../BitManipulation.cpp ../../MemCore.cpp
//Run:
//  ./test_scratch_pad

#include "../ScratchPadCore.h"
#include "../PeripheralDevicesCore.h"
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

static const uint32_t BASE = DeviceAddress::SCRATCH_PAD_MIN;

static void testResetState()
{
	ScratchPadCore sp;
	bool allZero = true;
	for (uint32_t a = BASE; a < BASE + 128; a += 4)
		allZero = allZero && (sp.readRegister(a, 0xF) == 0);
	check(allZero, "all 32 words read 0 after reset");
}

static void testReadWrite()
{
	ScratchPadCore sp;
	sp.writeRegister(BASE,     0xF, 0x11111111);
	sp.writeRegister(BASE + 4, 0xF, 0x22222222);
	sp.writeRegister(BASE + 124, 0xF, 0xDEADBEEF);
	check(sp.readRegister(BASE, 0xF)     == 0x11111111, "word 0 reads back");
	check(sp.readRegister(BASE + 4, 0xF) == 0x22222222, "word 1 reads back, independent of word 0");
	check(sp.readRegister(BASE + 124, 0xF) == 0xDEADBEEF, "word 31 reads back");
}

static void testAliasing()
{
	ScratchPadCore sp;
	sp.writeRegister(BASE + 8, 0xF, 0xCAFEF00D);
	check(sp.readRegister(BASE + 128 + 8, 0xF) == 0xCAFEF00D, "word 2 repeats 128 bytes later");
	check(sp.readRegister(BASE + 0x380 + 12, 0xF) == 0, "word 3 in the last 128-byte block is untouched");
	sp.writeRegister(DeviceAddress::SCRATCH_PAD_MAX - 3, 0xF, 0x31313131);
	check(sp.readRegister(BASE + 124, 0xF) == 0x31313131, "the last word of the range aliases word 31");
}

static void testByteLanes()
{
	ScratchPadCore sp;
	sp.writeRegister(BASE, 0xF, 0x11223344);
	sp.writeRegister(BASE, 0x8, 0xAA000000); //byte store to the lowest address
	check(sp.readRegister(BASE, 0xF) == 0xAA223344, "a byte store changes only its lane");
	sp.writeRegister(BASE, 0x3, 0x0000BBCC); //halfword store to address +2
	check(sp.readRegister(BASE, 0xF) == 0xAA22BBCC, "a halfword store changes only its two lanes");
}

static void testThroughPeripheralDevices()
{
	PeripheralDevicesCore devices;
	PhysicalMemoryRequest  request;
	PhysicalMemoryResponse response;
	request.valid = true;
	request.lock  = false;

	//Doubleword store to words 0 and 1 (word 0 in the low 32 bits).
	request.accessType      = PhysicalAccessType::WRITE;
	request.physicalAddress = BASE;
	request.byteMask        = 0xFF;
	request.data            = (((uint64_t) 0x00000001) << 32) | 0x00000002;
	devices.access(request, response);
	check(devices.scratchPad.words[0] == 0x00000002 && devices.scratchPad.words[1] == 0x00000001,
	      "a doubleword store through the bus writes words 0 and 1");

	request.accessType      = PhysicalAccessType::READ;
	request.physicalAddress = BASE + 4;
	request.byteMask        = 0xF0;
	request.data            = 0;
	devices.access(request, response);
	check((uint32_t) (response.readData >> 32) == 0x00000001, "a word load through the bus reads word 1");
	check(devices.stats.scratchPadAccesses == 3 && devices.stats.unmappedAccesses == 0,
	      "scratch-pad accesses are counted, none unmapped");
}

int main()
{
	testResetState();
	testReadWrite();
	testAliasing();
	testByteLanes();
	testThroughPeripheralDevices();

	std::cout << "\n" << (numChecks - numFailed) << "/" << numChecks << " checks passed\n";
	return numFailed == 0 ? 0 : 1;
}
