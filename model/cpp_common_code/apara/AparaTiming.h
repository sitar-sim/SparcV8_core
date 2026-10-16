//AparaTiming.h
//Original author: Madhav Desai, IITB
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the APARA engine specification and
//reference C implementation developed by Prof. Madhav Desai, IITB
//
//Plain C++ pieces of the APARA engine's timing model (the Sitar modules
//AparaFetch .. AparaWriteback embed these): the tokens that travel
//between the pipeline stages, the per-instruction latency table, the
//branch target buffer, and the data memory bank timing.
//
//The microarchitecture and its numbers follow "APARA Engine:
//Microarchitecture and Timing" (engine_isp/docs/microarch in the APARA
//repository); docs/source/apara/timing_model.md describes our model of it.

#ifndef APARA_TIMING_H
#define APARA_TIMING_H

#include <stdint.h>
#include <string>
#include <map>
#include "AparaCore.h"

namespace apara
{
	//------------------------------------------------------------------
	//Tokens (all plain structs, sent by value over Sitar nets)
	//------------------------------------------------------------------

	//Bundle flags (Ref the microarch doc's stream ids): the first bundle
	//of a newly started thread carries NEW_THREAD, the first bundle after
	//a PC correction carries NEW_STREAM. EXEC uses them to decide which
	//bundles to skip.
	const uint8_t BUNDLE_NEW_THREAD = 1;
	const uint8_t BUNDLE_NEW_STREAM = 2;

	//One bundle on its way from FETCH to EXEC. FETCH fills the words and
	//the prediction, DECODE the register masks and the latency.
	struct BundleToken
	{
		uint32_t pc;
		uint32_t predictedNextPc;
		uint32_t word[BUNDLE_MAX_SLOTS]; //the bundle's words, the rest 0
		uint32_t readMask;               //registers read (bit i: $ri)
		uint32_t writeMask;              //registers written
		uint8_t  thread;
		uint8_t  size;                   //slots
		uint8_t  flags;                  //BUNDLE_NEW_THREAD, BUNDLE_NEW_STREAM
		uint8_t  latency;                //EXEC cycles without memory and divider effects
		uint8_t  usesDivider;            //holds a DIV or FSQRT
		uint8_t  padding[3];
	};
	#define APARA_BUNDLE_TOKEN_BYTES 56

	//Result flags.
	const uint8_t RESULT_SKIPPED     = 1; //not executed (wrong path, or its thread had stopped)
	const uint8_t RESULT_MISPREDICT  = 2; //the next PC differs from FETCH's prediction
	const uint8_t RESULT_HALT        = 4; //the thread stopped at this bundle ($halt or an exception)
	const uint8_t RESULT_CONTROL     = 8; //holds a control transfer

	//A bundle's outcome, from EXEC back to REGFILE and on to WRITEBACK.
	struct ResultToken
	{
		uint32_t pc;
		uint32_t nextPc;
		uint32_t writeMask;
		uint8_t  thread;
		uint8_t  flags;
		uint8_t  size;
		uint8_t  padding;
	};
	#define APARA_RESULT_TOKEN_BYTES 16

	//WRITEBACK to FETCH: a PC correction (also trains the BTB).
	struct CorrectionToken
	{
		uint32_t bundlePc;
		uint32_t correctPc;
		uint8_t  thread;
		uint8_t  taken;   //correctPc is not the next sequential bundle
		uint8_t  padding[2];
	};
	#define APARA_CORRECTION_TOKEN_BYTES 12

	//WRITEBACK to FETCH: a thread has stopped.
	struct HaltToken
	{
		uint8_t thread;
		uint8_t padding[3];
	};
	#define APARA_HALT_TOKEN_BYTES 4

	//------------------------------------------------------------------
	//Tokens between the engine and its host-side units (AparaHost), in a
	//system: EXEC owns the engine's state, so everything else reaches
	//it through EXEC's service port.
	//------------------------------------------------------------------

	enum class ServiceKind : uint8_t
	{
		DMEM_READ, DMEM_WRITE,          //a DMEM word (address: byte offset; lanes, data: DMEM format)
		REGISTER_READ, REGISTER_WRITE,  //thread register `index`
		IMEM_READ, IMEM_WRITE,          //IMEM word `index`
		START_THREAD, RESET_THREAD,     //start at `index` (the PC); reset
		STEP,                           //one bundle at `index`; response: the next PC
		RAS_STATE                       //response: data = depth, extra = top
	};

	struct ServiceRequest
	{
		uint64_t    data;
		uint32_t    index;   //byte offset, register, IMEM index or PC
		ServiceKind kind;
		uint8_t     thread;
		uint8_t     lanes;
		uint8_t     tag;     //the requester's, returned in the response
	};
	#define APARA_SERVICE_REQUEST_BYTES 16

	struct ServiceResponse
	{
		uint64_t data;
		uint32_t extra;
		uint8_t  tag;
		uint8_t  padding[3];
	};
	#define APARA_SERVICE_RESPONSE_BYTES 16

	//EXEC's off-island 64-bit-word transaction (Ref DwordTransaction), and
	//its answer.
	struct OffIslandRequest
	{
		uint64_t data;
		uint32_t address;
		uint8_t  lanes;    //DMEM format: bit i for bits [8i+7:8i]
		uint8_t  store;
		uint8_t  thread;
		uint8_t  padding;
	};
	#define APARA_OFF_ISLAND_REQUEST_BYTES 16

	struct OffIslandResponse
	{
		uint64_t data;
		uint8_t  thread;
		uint8_t  padding[7];
	};
	#define APARA_OFF_ISLAND_RESPONSE_BYTES 16

	//EXEC to the host side: a thread stopped (its ERROR and PC).
	struct StopNotice
	{
		uint32_t error;
		uint32_t pc;
		uint8_t  thread;
		uint8_t  padding[3];
	};
	#define APARA_STOP_NOTICE_BYTES 12

	//EXEC to FETCH: start a thread at pc, or stop fetching it.
	struct FetchControl
	{
		uint32_t pc;
		uint8_t  thread;
		uint8_t  start;   //1 start, 0 reset
		uint8_t  padding[2];
	};
	#define APARA_FETCH_CONTROL_BYTES 8

	//------------------------------------------------------------------
	//Latency table
	//------------------------------------------------------------------

	//EXEC latency of each instruction, in cycles, keyed by "<class>
	//<operands>" (e.g. "arith int64"). The defaults are the microarch
	//doc's table; a text file can override any entry (Ref load()).
	class LatencyTable
	{
		public:
		LatencyTable();

		//Reads "<class> <operands> <cycles>" lines ('#' starts a comment).
		//Returns false (with `error` set) on an unreadable file, an
		//unknown key or a malformed line.
		bool load(const std::string& path, std::string& error);

		unsigned int cycles(const Instruction& in) const;
		unsigned int bundleCycles(const Instruction* slots, unsigned int count) const;

		//Cycles of a bundle's local memory accesses, added to its
		//latency: the access itself, plus one bank port use per extra
		//access to the same bank (Ref memoryCycles()).
		unsigned int memoryCycles(const StepResult& r) const;
		//The bundle's accesses beyond the first to their bank.
		static unsigned int sameBankExtras(const StepResult& r);

		static std::string key(const Instruction& in);
		const std::map<std::string, unsigned int>& entries() const { return table_; }
		std::string toString() const;

		unsigned int bankConflictCycles = 1; //per extra same-bank access in a bundle

		private:
		std::map<std::string, unsigned int> table_;
	};

	//DMEM bank of a byte address (Ref the microarch doc: bit 15).
	inline unsigned int dmemBank(uint32_t address) { return (address >> 15) & 1; }

	//------------------------------------------------------------------
	//Branch target buffer (Ref the microarch doc's bpbV3)
	//------------------------------------------------------------------

	//256 entries, direct mapped by the low 8 bits of the bundle PC, shared
	//by the threads. Each entry: a 22-bit tag (the PC's upper bits), a
	//2-bit counter (0 strongly taken .. 3 strongly not taken) and a
	//target. A lookup predicts the target when the tag matches and the
	//counter is below 3. Only PC corrections train it.
	class BranchTargetBuffer
	{
		public:
		static const unsigned int ENTRIES = 256;
		static const uint8_t      NOT_TAKEN = 3;

		BranchTargetBuffer() { reset(); }
		void reset();

		//True with the predicted next PC if the entry predicts a jump.
		bool predict(uint32_t pc, uint32_t& target) const;
		//A correction: the bundle at pc went to target (taken) or to the
		//next bundle (not taken).
		void train(uint32_t pc, bool taken, uint32_t target);

		private:
		struct Entry { bool valid; uint32_t tag; uint8_t counter; uint32_t target; };
		Entry entries_[ENTRIES];
	};

	//------------------------------------------------------------------
	//Statistics of a run (filled by the stage modules)
	//------------------------------------------------------------------
	struct AparaTimingStats
	{
		uint64_t bundlesFetched     = 0;
		uint64_t bundlesExecuted    = 0;
		uint64_t bundlesSkipped     = 0;
		uint64_t mispredicts        = 0;
		uint64_t btbPredictions     = 0; //fetches that followed a BTB target
		uint64_t lockStallCycles    = 0; //cycles some ready bundle waited on a register lock
		uint64_t tokenStallCycles   = 0; //cycles a ready bundle waited for a REGFILE token
		uint64_t bankConflicts      = 0; //extra same-bank accesses
		uint64_t dividerStallCycles = 0; //cycles a bundle waited for the shared divider
		uint64_t rawHazards         = 0; //bundles issued while a register they read had an older write
		                                 //still outstanding (0 unless REGFILE's interlock is off)
		uint64_t maskViolations     = 0; //bundles that read or wrote a register outside their lock masks
		bool     interlock          = true; //REGFILE's interlock was on
		uint64_t perThreadExecuted[THREADS_PER_ENGINE] = {0, 0, 0, 0};

		void add(const AparaTimingStats& o);
		std::string toString() const;
	};
}

#endif
