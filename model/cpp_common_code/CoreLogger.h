//CoreLogger.h
//
//Formats one SparcCore instance's state into a trace of architectural
//events (fetch, trap, memory access, ...), one line per event, in the
//tab-separated format the browser-based viewer in model/log_viewer/
//understands. Owned by SparcCore itself (see SparcCore::logger), so any
//driver holding a SparcCore -- SparcStateMachine (cpp_model) or the
//SparcThread sitar procedure (sitar_model) -- gets one for free, with no
//extra wiring, the same way SparcCore::printSparcState() already did.
//
//Two ways to consume a logged row, chosen via do_print:
//  - do_print == true:  the row is written directly to *out (see init())
//    and the call returns "" (the cpp model's main.cpp works this way).
//  - do_print == false: nothing is written here at all; the formatted
//    row is just returned, for the caller to forward wherever it likes
//    (the sitar model forwards it into its own per-module `log` object,
//    so logging keeps splitting by hierarchy the way Sitar already does
//    in parallel simulation).
//
//Every log_* method does real work only when built with
//-DSPARC_LOGGING_ENABLED (see build.sh); otherwise each is a one-line
//stub that touches nothing and returns "". That's a compile-time
//distinction, not a runtime one: with the macro undefined, none of the
//state-collection/formatting code exists in the compiled log_* bodies at
//all. print_state() and init() are the exception -- they're plain
//formatting/setup utilities, not part of the per-cycle trace, so they
//always do real work regardless of that macro.

#ifndef CORE_LOGGER_H
#define CORE_LOGGER_H

#include <string>
#include <cstdint>
#include <iosfwd>
#include "Opcodes.h" //for the Opcode enum -- lightweight, no circular include risk

class SparcCore; //forward declaration only: SparcCore.h includes this
                  //header to embed a CoreLogger member by value, so this
                  //header must not include SparcCore.h back -- that's
                  //done in CoreLogger.cpp instead, where core state is
                  //actually read.

class CoreLogger
{
	public:
		CoreLogger();

		//Must be called once (SparcCore's own constructor does this
		//automatically, passing itself, so core_ is always valid --
		//see SparcCore.cpp). A driver that wants rows written directly
		//to a stream calls this again afterwards with out/doPrint set;
		//the core reference is harmless to pass again, it's just
		//re-stored. No method below ever takes a core reference itself
		//-- this is the only place it's ever supplied.
		void init(SparcCore& core, std::ostream* out = 0, bool doPrint = false);

		//The column-name header line matching every row below (tab
		//separated, in the same order). Written automatically ahead of
		//the first row when do_print is on; a caller that instead
		//collects rows itself (do_print off -- e.g. the sitar model,
		//writing its own file -- see sitar_check_test.cpp) needs to
		//write this once, itself, before the first row it writes.
		std::string header();

		//If true, every log_* call writes its formatted row to *out
		//(see init()) and returns "" (the return value is redundant in
		//that case). If false, rows are only ever returned, never
		//written here -- e.g. the sitar model forwards them into its
		//own log instead.
		bool do_print;

		//The current window's entire state (PSR fields named and
		//binary, general registers in hex), nicely formatted for a
		//human to read -- e.g. for a one-off dump at the end of a run.
		//Always does real work, regardless of SPARC_LOGGING_ENABLED:
		//unlike log_*, this isn't part of the per-cycle trace, so there
		//is no hot-loop cost here to guard against.
		std::string print_state();

		//One fetched-and-decoded instruction. op is passed in because
		//it's decoded locally by the driver and never stored on
		//SparcCore itself; everything else this needs (the raw
		//instruction word, PC) is read directly off the core.
		std::string log_fetch(unsigned long time, Opcode op);

		//A trap has just been detected (core.trap became true) but not
		//yet serviced. Read core.printTrap() immediately, before
		//anything else runs: SparcCore::selectTrap() (called from
		//executeTraps()) is the only place trap-cause flags get
		//cleared, and that happens the next time this trap is
		//serviced -- never within the same cycle it was raised in, but
		//always by the time the *following* one starts.
		std::string log_trap_raised(unsigned long time);

		//A previously-raised trap has just been serviced by jumping to
		//its handler (as opposed to going straight to error_mode --
		//that's a HALT event, via log_generic(), not this).
		std::string log_trap_enter(unsigned long time);

		//A load (including its double/half/byte variants) has just
		//completed. address/word0/word1/isDouble/mae are all local to
		//the driver's own memory-access step -- not reliably mirrored
		//onto SparcCore's own members across every driver -- so they're
		//passed in explicitly rather than read back off core. mae
		//(memory access exception) is always false in this flat-memory
		//model today, but is logged anyway: it'll matter once a
		//cache/MMU model can actually raise it.
		std::string log_mem_read(unsigned long time, uint32_t address, uint32_t word0, uint32_t word1, bool isDouble, bool mae);

		//A store has just completed; byteMask reflects exactly which
		//bytes of word0/word1 were actually written (partial-word
		//stores included). See log_mem_read() for why these are all
		//passed in explicitly rather than read off core.
		std::string log_mem_write(unsigned long time, uint32_t address, uint32_t word0, uint32_t word1, uint32_t byteMask, bool mae);

		//An atomic load-store (SWAP/LDSTUB) has just completed.
		//oldWord is the value read before the write, newWord what was
		//actually written.
		std::string log_atomic(unsigned long time, uint32_t address, uint32_t oldWord, uint32_t newWord, bool mae);

		//Catch-all for any event that doesn't need a typed signature of
		//its own above -- RESET, ANNUL, HALT, FLUSH, or anything added
		//later -- just an event name and a short free-text status.
		std::string log_generic(unsigned long time, const std::string& event, const std::string& status);

	private:
		SparcCore*    core_;
		std::ostream* out_;
		unsigned long seq_;
		bool          headerWritten_;

		//Builds one full tab-separated row (seq/time/pc/event/detail
		//followed by the entire current-window state) and passes it to
		//emit(). Shared by every log_* method above.
		std::string row(unsigned long time, const std::string& event, const std::string& detail);

		//If do_print: writes s (plus the header line first, if this is
		//the first row) to *out and returns ""; otherwise just returns
		//s unchanged.
		std::string emit(const std::string& s);
};

#endif
