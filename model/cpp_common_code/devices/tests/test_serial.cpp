//test_serial.cpp
//
//Standalone unit test for SerialCore. Exercises the class directly,
//with no dependency on the rest of the model, to check that its
//register read/write and Tx/Rx behavior match
//https://sitar-sim.github.io/SparcV8_core/peripheral_devices_serial_device.html
//
//Uses the FILES backend (Ref SerialBackend.h) for deterministic,
//non-interactive I/O, in $TMPDIR (or /tmp).
//
//Lives in devices/tests/, one level below the device source files, so
//that model/build_scripts/build_cpp_model.sh's cpp_common_code/*/*.cpp
//glob (one directory level only) doesn't pick it up and try to link
//its main() into every model configuration's build.
//
//Build:
//  g++ -std=c++11 -I.. -I../.. -o test_serial test_serial.cpp ../SerialCore.cpp ../SerialBackend.cpp ../../BitManipulation.cpp
//Run:
//  ./test_serial

#include "../SerialCore.h"
#include "../DeviceAddresses.h"
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <iterator>

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

static std::string tmpPath(const char* name)
{
	const char* dir = std::getenv("TMPDIR");
	return std::string(dir ? dir : "/tmp") + "/" + name;
}

static const std::string RX_FILE = tmpPath("test_serial_rx.bin");
static const std::string TX_FILE = tmpPath("test_serial_tx.bin");

static void writeFile(const std::string& path, const std::string& contents)
{
	std::ofstream out(path.c_str(), std::ios::binary | std::ios::trunc);
	out << contents;
}

static void appendFile(const std::string& path, const std::string& contents)
{
	std::ofstream out(path.c_str(), std::ios::binary | std::ios::app);
	out << contents;
}

static std::string readFile(const std::string& path)
{
	std::ifstream in(path.c_str(), std::ios::binary);
	return std::string(std::istreambuf_iterator<char>(in), std::istreambuf_iterator<char>());
}

//A SerialCore on the FILES backend, with the given bytes waiting to be
//received.
static void attachFiles(SerialCore& serial, const std::string& rxContents)
{
	writeFile(RX_FILE, rxContents);
	SerialBackendConfig config;
	config.kind       = SerialBackendConfig::Kind::FILES;
	config.inputFile  = RX_FILE;
	config.outputFile = TX_FILE;
	serial.setBackend(makeSerialBackend(config));
}

static void writeControl(SerialCore& serial, bool txEn, bool rxEn, bool rxIntEn, bool uartReset = false)
{
	uint32_t data = (txEn ? 1u : 0u)
	              | (rxEn ? (1u << 1) : 0u)
	              | (rxIntEn ? (1u << 2) : 0u)
	              | (uartReset ? (1u << 5) : 0u);
	serial.writeRegister(DeviceAddress::SERIAL_CONTROL, 0xF, data);
}

static uint32_t readControl(SerialCore& serial)
{
	return serial.readRegister(DeviceAddress::SERIAL_CONTROL, 0xF);
}

static bool bit(uint32_t word, uint32_t position) { return (word >> position) & 1u; }

//A `stub` to Tx: the byte at the Tx address is the most significant
//byte of its word (big-endian), so it arrives in lane 3.
static void storeTxByte(SerialCore& serial, uint8_t byte)
{
	serial.writeRegister(DeviceAddress::SERIAL_TX, 0x8, ((uint32_t) byte) << 24);
}

//An `ldub` of Rx: the byte comes back in lane 3.
static uint8_t loadRxByte(SerialCore& serial)
{
	return (uint8_t) (serial.readRegister(DeviceAddress::SERIAL_RX, 0x8) >> 24);
}

static void testResetState()
{
	SerialCore serial;
	attachFiles(serial, "");
	check(serial.txState == SerialCore::TxState::DISABLED, "Tx starts DISABLED");
	check(serial.rxState == SerialCore::RxState::DISABLED, "Rx starts DISABLED");
	check(readControl(serial) == 0 && !serial.intOut,      "Control reads 0 and intOut is low after reset");
}

static void testTransmit()
{
	SerialCore serial;
	attachFiles(serial, "");
	writeControl(serial, true, false, false);
	check(serial.txState == SerialCore::TxState::ENABLED, "Tx_en=1 moves Tx to ENABLED");

	storeTxByte(serial, 'H');
	check(bit(readControl(serial), SerialControlBits::TX_FULL_BIT), "Tx write sets Tx_full");
	check(readFile(TX_FILE).empty(), "byte not sent before the transmit time has passed");

	storeTxByte(serial, 'X');
	serial.tick();
	check(!bit(readControl(serial), SerialControlBits::TX_FULL_BIT), "Tx_full clears after txTicksPerByte ticks");
	check(readFile(TX_FILE) == "H", "the byte reached the output, and a write while TRANSMITTING was dropped");

	storeTxByte(serial, 'i');
	serial.tick();
	check(readFile(TX_FILE) == "Hi", "a second byte follows the first");
}

static void testTransmitLanesAndImmediate()
{
	SerialCore serial;
	attachFiles(serial, "");
	serial.txTicksPerByte = 0;
	writeControl(serial, true, false, false);

	serial.writeRegister(DeviceAddress::SERIAL_TX, 0x1, 'a');
	serial.writeRegister(DeviceAddress::SERIAL_TX, 0xF, ((uint32_t) 'b') << 24 | 'z');
	check(readFile(TX_FILE) == "ab",
	      "txTicksPerByte=0 sends within the write, byte taken from the most significant selected lane");
}

static void testTransmitDisabledDrops()
{
	SerialCore serial;
	attachFiles(serial, "");
	storeTxByte(serial, 'Q');
	serial.tick();
	check(readFile(TX_FILE).empty(), "Tx write while DISABLED is dropped");

	writeControl(serial, true, false, false);
	storeTxByte(serial, 'Z');
	writeControl(serial, false, false, false);
	check(readFile(TX_FILE) == "Z" && serial.txState == SerialCore::TxState::DISABLED,
	      "disabling Tx mid-transmission finishes sending the byte, then disables");
}

static void testReceivePolling()
{
	SerialCore serial;
	attachFiles(serial, "AB");

	serial.tick();
	check(serial.rxState == SerialCore::RxState::DISABLED, "no byte received while Rx is DISABLED");

	writeControl(serial, false, true, false);
	serial.tick();
	check(bit(readControl(serial), SerialControlBits::RX_FULL_BIT), "byte received sets Rx_full");
	check(!serial.intOut, "no interrupt with Rx_interrupt_enable=0");

	serial.tick();
	check(serial.rxByte == 'A', "no further byte consumed while holding an unread one");

	check(loadRxByte(serial) == 'A', "Rx read returns the first byte, in lane 3");
	check(!bit(readControl(serial), SerialControlBits::RX_FULL_BIT), "Rx read clears Rx_full");

	serial.tick();
	check(loadRxByte(serial) == 'B', "next byte received after the first is read");

	serial.tick();
	check(serial.rxState == SerialCore::RxState::ENABLED, "end of input: nothing more received");
	appendFile(RX_FILE, "C");
	serial.tick();
	check(loadRxByte(serial) == 'C', "bytes appended to the input file later are still received");
}

static void testReceiveInterrupt()
{
	SerialCore serial;
	attachFiles(serial, "X");
	writeControl(serial, false, true, true);
	serial.tick();
	check(serial.intOut, "Rx with Rx_interrupt_enable=1 raises the interrupt");
	loadRxByte(serial);
	check(!serial.intOut, "Rx read clears the interrupt");

	SerialCore s2;
	attachFiles(s2, "Y");
	writeControl(s2, false, true, true);
	s2.tick();
	writeControl(s2, false, false, false);
	check(!s2.intOut && s2.rxState == SerialCore::RxState::DISABLED,
	      "Rx_en=0 clears Rx_full and the interrupt, from any state");
}

static void testUartReset()
{
	SerialCore serial;
	attachFiles(serial, "X");
	writeControl(serial, true, true, true);
	serial.tick();
	writeControl(serial, true, true, true, true);
	check(serial.txState == SerialCore::TxState::DISABLED &&
	      serial.rxState == SerialCore::RxState::DISABLED && !serial.intOut,
	      "UART_reset returns both state machines to DISABLED and clears the interrupt");
	check(!bit(readControl(serial), SerialControlBits::UART_RESET_BIT), "UART_reset always reads back as 0");
}

static void testBaudRegisters()
{
	SerialCore serial;
	attachFiles(serial, "");
	serial.writeRegister(DeviceAddress::SERIAL_BAUD_LIMIT,     0xF, 0x1234);
	serial.writeRegister(DeviceAddress::SERIAL_BAUD_FREQUENCY, 0xF, 0x5678);
	check(serial.readRegister(DeviceAddress::SERIAL_BAUD_LIMIT, 0xF) == 0x1234,     "baud limit is plain read/write storage");
	check(serial.readRegister(DeviceAddress::SERIAL_BAUD_FREQUENCY, 0xF) == 0x5678, "baud frequency has its own address");
	check(readFile(TX_FILE).empty(), "a baud-frequency write does not transmit anything");
}

int main()
{
	testResetState();
	testTransmit();
	testTransmitLanesAndImmediate();
	testTransmitDisabledDrops();
	testReceivePolling();
	testReceiveInterrupt();
	testUartReset();
	testBaudRegisters();

	std::cout << "\n" << (numFailed == 0 ? "OVERALL: PASS" : "OVERALL: FAIL")
	          << " (" << numChecks << " checks, " << numFailed << " failed)\n";
	return numFailed == 0 ? 0 : 1;
}
