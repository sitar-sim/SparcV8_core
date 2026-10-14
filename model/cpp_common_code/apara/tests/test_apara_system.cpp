//test_apara_system.cpp
//
//Standalone unit test for AparaSystemCore and the units it joins
//(AparaControlCore, AparaDmaCore, AparaCore in SYSTEM_BUS mode), driven
//only through bus accesses, as SPARC software drives the engine: CCU
//commands (IMEM, registers, run, completion with and without the
//interrupt, reset), DMA gather loads and scatter stores, the host's DMEM
//window, and the engine's off-island loads and stores, against a fake
//system memory.
//
//Lives in apara/tests/ so that the build scripts' cpp_common_code/*/*.cpp
//glob does not pick up its main().
//
//Build (from this folder):
//  g++ -std=c++11 -I.. -I../.. -o test_apara_system test_apara_system.cpp ../*.cpp
//Run:
//  ./test_apara_system

#include "../AparaSystemCore.h"
#include <iostream>
#include <map>

using namespace apara;

static int numChecks = 0, numFailed = 0;

static void check(bool condition, const std::string& description)
{
	numChecks++;
	std::cout << (condition ? "PASS: " : "FAIL: ") << description << "\n";
	if (!condition) numFailed++;
}

//A flat system memory of bus doublewords (byteMask bit i: bits [8i+7:8i]).
class FakeSystem : public PhysicalMemoryInterface
{
	public:
	std::map<uint64_t, uint64_t> dword;
	void access(const PhysicalMemoryRequest& q, PhysicalMemoryResponse& r) override
	{
		r.valid = true; r.mae = false;
		uint64_t& d = dword[q.physicalAddress & ~7ULL];
		if (q.accessType == PhysicalAccessType::READ) { r.readData = d; return; }
		uint64_t m = 0;
		for (int i = 0; i < 8; i++) if (q.byteMask & (1 << i)) m |= 0xFFULL << (8 * i);
		d = (d & ~m) | (q.data & m);
	}
	//32-bit big-endian word at a byte address (multiple of 4).
	uint32_t word(uint64_t a) { return (uint32_t) (dword[a & ~7ULL] >> ((a & 4) ? 32 : 0)); }
	void setWord(uint64_t a, uint32_t v)
	{
		uint64_t& d = dword[a & ~7ULL];
		int sh = (a & 4) ? 32 : 0;
		d = (d & ~(0xFFFFFFFFULL << sh)) | ((uint64_t) v << sh);
	}
};

static AparaSystemCore* E;

static void hostWrite(uint64_t a, uint32_t v)
{
	int half = (a & 4) ? 1 : 0;
	PhysicalMemoryRequest q{true, PhysicalAccessType::WRITE, false, a & ~7ULL, (uint64_t) v << (32 * half), (uint8_t) (0xF << (4 * half))};
	PhysicalMemoryResponse r;
	E->access(q, r);
}

static uint32_t hostRead(uint64_t a)
{
	int half = (a & 4) ? 1 : 0;
	PhysicalMemoryRequest q{true, PhysicalAccessType::READ, false, a & ~7ULL, 0, (uint8_t) (0xF << (4 * half))};
	PhysicalMemoryResponse r;
	E->access(q, r);
	return (uint32_t) (r.readData >> (32 * half));
}

static uint64_t ccu(unsigned int t, unsigned int reg) { return E->ccuBase + 32 * t + 4 * reg; }
static uint64_t dmaReg(unsigned int c, unsigned int reg) { return E->dmaBase + 32 * c + 4 * reg; }

//Start command `cmd` on thread t (with extra R0 flags), tick until it completes.
static bool command(unsigned int t, unsigned int cmd, uint32_t flags = 0, int maxTicks = 1000)
{
	hostWrite(ccu(t, 0), (cmd << 8) | AparaControlCore::FLAG_START | AparaControlCore::FLAG_RUN_INTERPRETER | flags);
	for (int i = 0; i < maxTicks; i++)
	{
		E->tick();
		if (hostRead(ccu(t, 0)) & AparaControlCore::FLAG_COMPLETED)
			return true;
	}
	return false;
}

static void loadProgram(unsigned int t, const uint32_t* words, unsigned int n)
{
	for (unsigned int i = 0; i < n; i++)
	{
		hostWrite(ccu(t, 2), i);
		hostWrite(ccu(t, 3), words[i]);
		command(t, AparaControlCore::WRITE_IMEM);
	}
}

int main()
{
	FakeSystem sys;
	AparaSystemCore engine;
	engine.setSystem(&sys);
	E = &engine;

	//---- IMEM through the CCU
	hostWrite(ccu(0, 2), 5);
	hostWrite(ccu(0, 3), 0x12345678);
	check(command(0, AparaControlCore::WRITE_IMEM), "write IMEM completes");
	check(engine.engine.imemWord(5) == 0x12345678, "write IMEM writes IMEM[R2]");
	hostWrite(ccu(1, 2), 5);
	command(1, AparaControlCore::READ_IMEM);
	check(hostRead(ccu(1, 4)) == 0x12345678, "read IMEM (another thread's CCU) into R4");

	//---- thread registers
	hostWrite(ccu(2, 2), 7);
	hostWrite(ccu(2, 6), 0xAABBCCDD);
	hostWrite(ccu(2, 7), 0x11223344);
	command(2, AparaControlCore::WRITE_REGISTER);
	check(engine.engine.readRegister(2, 7) == 0xAABBCCDD11223344ULL, "write register from R6:R7");
	hostWrite(ccu(2, 6), 0);
	hostWrite(ccu(2, 7), 0);
	command(2, AparaControlCore::READ_REGISTER);
	check(hostRead(ccu(2, 6)) == 0xAABBCCDD && hostRead(ccu(2, 7)) == 0x11223344, "read register into R6:R7");

	//---- run to $halt, completion polled
	const uint32_t addHalt[] = {0x90810c05, 0xec000000}; //+ $r1 ($i64) $r1 5 ; $halt
	loadProgram(0, addHalt, 2);
	hostWrite(ccu(0, 1), 0);
	command(0, AparaControlCore::RUN_THREAD);
	check(engine.engine.thread(0).active, "run starts the thread");
	for (int i = 0; i < 10; i++) engine.tick();
	command(0, AparaControlCore::COMPLETION);
	uint32_t r5 = hostRead(ccu(0, 5));
	check(r5 == (AparaControlCore::COMPLETION_VALID | ERROR_HALT), "completion: R5 = valid | halt");
	check(hostRead(ccu(0, 6)) == 2, "completion: R6 = the stop PC");
	check(engine.engine.readRegister(0, 1) == 5, "the program ran");
	command(0, AparaControlCore::COMPLETION);
	check(hostRead(ccu(0, 5)) == 0, "a stop is reported once");
	check(!engine.interrupt(), "no interrupt without interrupt enable");

	//---- run with the completion interrupt
	hostWrite(ccu(0, 1), 0);
	command(0, AparaControlCore::RUN_THREAD);
	hostWrite(ccu(0, 0), (AparaControlCore::COMPLETION << 8) | AparaControlCore::FLAG_START
	          | AparaControlCore::FLAG_RUN_INTERPRETER | AparaControlCore::FLAG_INTERRUPT_ENABLE);
	engine.tick();
	bool interruptAtOnce = engine.interrupt();
	for (int i = 0; i < 10 && !engine.interrupt(); i++) engine.tick();
	check(!interruptAtOnce && engine.interrupt(), "completion with interrupt enable waits, then interrupts");
	check(hostRead(ccu(0, 5)) == (AparaControlCore::COMPLETION_VALID | ERROR_HALT) && (hostRead(ccu(0, 0)) & AparaControlCore::FLAG_COMPLETED),
	      "  and completes with R5 valid");
	hostWrite(ccu(0, 0), AparaControlCore::FLAG_RUN_INTERPRETER);
	check(!engine.interrupt(), "writing R0 without interrupt enable clears the interrupt");

	//---- reset
	command(0, AparaControlCore::RESET_THREAD);
	check(!engine.engine.thread(0).active && engine.engine.thread(0).error == 0 && engine.engine.readRegister(0, 1) == 10,
	      "reset stops the thread and clears ERROR, keeps registers");

	//---- timer and RAS state
	command(3, AparaControlCore::READ_TIMER);
	uint64_t t = ((uint64_t) hostRead(ccu(3, 3)) << 32) | hostRead(ccu(3, 4));
	check(t > 0 && t <= engine.cycle, "timer: R3:R4 = the cycle count");

	//---- the host's DMEM window, and its byte order
	hostWrite(engine.dmemBase + 0, 0x11223344);
	hostWrite(engine.dmemBase + 4, 0x55667788);
	check(engine.engine.dmemDword(0) == 0x1122334455667788ULL, "host words land big-endian in DMEM");
	engine.engine.writeDmemDword(1, 0x0102030405060708ULL);
	check(hostRead(engine.dmemBase + 8) == 0x01020304 && hostRead(engine.dmemBase + 12) == 0x05060708, "host reads DMEM words back");

	//---- engine off-island load and store, and a DMEM load of the host's word
	const uint64_t SYS = 0x20000; //above the DMEM's 64 KB: off island
	sys.setWord(SYS + 0, 0xCAFEF00D);
	sys.setWord(SYS + 4, 0x0BADBEEF);
	//$ld ($i64) $r4 [$r2 + 0]  $st ($i32) [$r2 + 12] $r3 ; $ld ($u32) $r5 [$r6 + 0] ; $halt
	//($r6: the DMEM window: in a system the engine reaches its DMEM by that address)
	const uint32_t off[] = {0xe8000000, 0x68000000, 0x68000000, 0x68000000, 0x4c841400, 0x5063140c, 0x68000000, 0x68000000,
	                        0xe8000000, 0x68000000, 0x68000000, 0x68000000, 0x4d053400, 0x68000000, 0x68000000, 0x68000000, 0xec000000};
	loadProgram(1, off, 17);
	engine.engine.writeRegister(1, 2, SYS);
	engine.engine.writeRegister(1, 3, 0x76543210);
	engine.engine.writeRegister(1, 6, engine.dmemBase);
	hostWrite(ccu(1, 1), 0);
	command(1, AparaControlCore::RUN_THREAD);
	for (int i = 0; i < 10; i++) engine.tick();
	check(engine.engine.readRegister(1, 4) == 0xCAFEF00D0BADBEEFULL, "engine off-island 64-bit load");
	check(sys.word(SYS + 12) == 0x76543210, "engine off-island 32-bit store");
	check(engine.engine.readRegister(1, 5) == 0x11223344, "engine loads the host's DMEM word, by its window address");

	//---- DMA gather load: 3 bursts of 6 bytes, 16 apart, from an odd address
	for (unsigned int i = 0; i < 64; i += 4)
		sys.setWord(0x30000 + i, 0x10203040 + i * 0x01010101);
	auto sysByte = [&](uint64_t a) { return (sys.word(a & ~3ULL) >> (8 * (3 - (a & 3)))) & 0xFF; };
	hostWrite(dmaReg(0, 1), 0x30001);       //source
	hostWrite(dmaReg(0, 2), 0x100);         //destination (DMEM offset)
	hostWrite(dmaReg(0, 3), 18);
	hostWrite(dmaReg(0, 4), 3);             //bursts
	hostWrite(dmaReg(0, 5), 16);            //gap
	hostWrite(dmaReg(0, 6), 6);             //bytes per burst
	hostWrite(dmaReg(0, 0), (AparaDmaCore::LOAD << 24) | AparaDmaCore::FLAG_SCHEDULED | AparaDmaCore::FLAG_INTERRUPT_ENABLE);
	for (int i = 0; i < 100 && engine.dma.busy(); i++) engine.tick();
	bool gathered = true;
	for (unsigned int b = 0; b < 3; b++)
		for (unsigned int k = 0; k < 6; k++)
		{
			uint32_t d = 0x100 + 6 * b + k;
			uint64_t got = (engine.engine.dmemDword(d >> 3) >> (56 - 8 * (d & 7))) & 0xFF;
			gathered = gathered && got == sysByte(0x30001 + 16 * b + k);
		}
	check(gathered, "DMA load gathers 3 bursts into contiguous DMEM");
	uint32_t c0 = hostRead(dmaReg(0, 0));
	check((c0 & AparaDmaCore::FLAG_COMPLETED) && !(c0 & AparaDmaCore::FLAG_STARTED) && !(c0 & AparaDmaCore::FLAG_ERROR), "DMA control: completed");
	check(hostRead(dmaReg(0, 6)) > hostRead(dmaReg(0, 7)), "DMA R6 (stop cycle) after R7 (start cycle)");
	check(engine.interrupt(), "DMA interrupt on completion");
	hostWrite(dmaReg(0, 0), 0);
	check(!engine.interrupt(), "writing the control word without interrupt enable clears it");

	//---- DMA scatter store: 2 bursts of 5 bytes, 32 apart
	engine.engine.writeDmemDword(0x40, 0x0A0B0C0D0E0F1011ULL);
	engine.engine.writeDmemDword(0x41, 0x1213141516171819ULL);
	hostWrite(dmaReg(2, 1), 0x200);
	hostWrite(dmaReg(2, 2), 0x40003);
	hostWrite(dmaReg(2, 4), 2);
	hostWrite(dmaReg(2, 5), 32);
	hostWrite(dmaReg(2, 6), 5);
	hostWrite(dmaReg(2, 0), (AparaDmaCore::STORE << 24) | AparaDmaCore::FLAG_SCHEDULED);
	for (int i = 0; i < 100 && engine.dma.busy(); i++) engine.tick();
	const uint8_t want[10] = {0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13};
	bool scattered = true;
	for (unsigned int b = 0; b < 2; b++)
		for (unsigned int k = 0; k < 5; k++)
			scattered = scattered && sysByte(0x40003 + 32 * b + k) == want[5 * b + k];
	check(scattered && sysByte(0x40002) == 0 && sysByte(0x40008) == 0, "DMA store scatters 2 bursts, touching only their bytes");
	hostWrite(dmaReg(3, 0), (7u << 24) | AparaDmaCore::FLAG_SCHEDULED);
	check(hostRead(dmaReg(3, 0)) & AparaDmaCore::FLAG_ERROR, "an unknown DMA operation completes with the error flag");

	std::cout << "\n" << numChecks - numFailed << "/" << numChecks << " checks passed\n";
	return numFailed == 0 ? 0 : 1;
}
