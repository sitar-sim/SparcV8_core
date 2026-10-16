//AparaControlCore.h
//Original author: Madhav Desai, IITB
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the APARA engine specification and
//reference C implementation developed by Prof. Madhav Desai, IITB
//
//The APARA engine's control unit (CCU) as seen by the host: per thread,
//8 32-bit registers and a command interpreter (Ref the APARA hardware's
//ccu.aa and CCU.TXT, in Aa_model/Apara_source/SOURCES/ENGINE/cpu/ccu).
//
//Registers of a thread (byte offset 4*index in the thread's 32-byte block):
//  R0 control/status: [31:16] sequence number, [15:14] thread (for command
//     9), [11:8] command, flags [7] init done, [6:5] cpu mode, [4] run
//     the command interpreter, [3] interrupt enable, [2] command
//     completed, [1] command started, [0] start the command
//  R1 PC              R2 IMEM index / register index
//  R3 IMEM write data / timer high    R4 IMEM read data / timer low
//  R5 completion: [31] valid, [26] RAS error, [25] halt, [24] exception,
//     [23:0] exception codes (the thread's ERROR)
//  R6 register high / stop PC / RAS depth    R7 register low / next PC / RAS top
//
//Commands (R0[11:8]): 1 read IMEM (R4 := IMEM[R2]), 2 write IMEM
//(IMEM[R2] := R3), 3 reset the thread, 4 run it from R1, 5 read register
//R2 into R6:R7 (high:low), 6 write register R2 from R6:R7, 7 completion
//(below), 8 step one bundle at R1 (R7 := the next PC), 9 RAS state of
//thread R0[15:14] (R6 := depth, R7 := top), 10 timer (R3:R4 := cycles).
//
//A command runs when R0 has start set and started and completed clear,
//and the interpreter is on (R0 bit 4, as last written by the host): the
//interpreter sets started, has the command carried out, then writes the
//results and sets completed.
//
//Command 7 reports the thread's stop: once the thread has stopped since
//it was last run, R5 := valid | ERROR and R6 := its PC; each stop is
//reported once. Without interrupt enable the command completes at once
//(R5 = 0 if the thread has not stopped). With interrupt enable it
//completes when the thread stops, and raises the engine interrupt. (A
//choice between the sources: CCU.TXT calls the command "wait-on-
//complete", ccu.aa polls; Ref docs/source/apara/deviations.md.) Writing
//R0 with interrupt enable clear clears the interrupt.
//
//The class sequences commands; carrying them out (IMEM, registers,
//running threads) is the caller's, through beginCommand() and
//finishCommand(), so the functional model can do it at once and the
//timing model over its pipeline's channels.

#ifndef APARA_CONTROL_CORE_H
#define APARA_CONTROL_CORE_H

#include <stdint.h>
#include "AparaCore.h"

namespace apara
{
	class AparaControlCore
	{
		public:
		static const unsigned int REGISTERS = 8;

		enum Command : uint8_t
		{
			READ_IMEM = 1, WRITE_IMEM = 2, RESET_THREAD = 3, RUN_THREAD = 4,
			READ_REGISTER = 5, WRITE_REGISTER = 6, COMPLETION = 7, STEP = 8,
			READ_RAS_STATE = 9, READ_TIMER = 10
		};

		static const uint32_t FLAG_START            = 1u << 0;
		static const uint32_t FLAG_STARTED          = 1u << 1;
		static const uint32_t FLAG_COMPLETED        = 1u << 2;
		static const uint32_t FLAG_INTERRUPT_ENABLE = 1u << 3;
		static const uint32_t FLAG_RUN_INTERPRETER  = 1u << 4;
		static const uint32_t COMPLETION_VALID      = 1u << 31;

		//A command, as beginCommand() hands it to the caller.
		struct Request
		{
			unsigned int thread;
			uint8_t      command;
			uint32_t     r1, r2, r3, r6, r7;
			unsigned int rasThread; //command 9
		};

		//The caller's results. Fields matter only for the commands that set them.
		struct Result
		{
			uint32_t imemWord     = 0;       //1
			uint64_t registerValue = 0;      //5
			uint32_t nextPc       = 0;       //8
			uint32_t rasDepth     = 0;       //9
			uint32_t rasTop       = 0;       //9
			uint64_t cycles       = 0;       //10
		};

		AparaControlCore() { reset(); }
		void reset();

		//Host access (index 0..7).
		uint32_t readRegister(unsigned int thread, unsigned int index) const;
		void     writeRegister(unsigned int thread, unsigned int index, uint32_t value, uint8_t laneMask = 0xF);

		//The next thread with a command to run, or -1.
		int  commandReady() const;
		//Sets started and returns the command.
		Request beginCommand(unsigned int thread);
		//Writes the results and sets completed. For COMPLETION: call only
		//when completionReady() (or at once when the command does not wait).
		void finishCommand(unsigned int thread, const Result& result);

		//A thread's stop, from the engine: its ERROR and PC.
		void threadStopped(unsigned int thread, uint32_t error, uint32_t pc);
		//Whether a COMPLETION command of `thread` can finish now.
		bool completionReady(unsigned int thread) const;
		//Whether the COMPLETION command begun for `thread` waits for the stop.
		bool completionWaits(unsigned int thread) const { return waiting_[thread & 3]; }

		bool interrupt() const { return interrupt_; }

		private:
		uint32_t reg_[THREADS_PER_ENGINE][REGISTERS];
		bool     interpreterOn_[THREADS_PER_ENGINE];
		bool     waiting_[THREADS_PER_ENGINE];
		bool     stopPending_[THREADS_PER_ENGINE]; //a stop not yet reported
		uint32_t stopError_[THREADS_PER_ENGINE];
		uint32_t stopPc_[THREADS_PER_ENGINE];
		bool     interrupt_;
	};
}

#endif
