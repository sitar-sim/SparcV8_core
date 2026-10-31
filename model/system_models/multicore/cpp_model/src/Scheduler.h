//Scheduler.h
//Original Author: Neha Karanjkar
//Model Author: Claude Opus 5.5 (high)
//The model code was adapted from a Sparc v8 core simulation model written
//by the first author in C++ and Sitar (2015-2017).
//
//How the cpp_model interleaves its cores. The cpp_model has no clock and
//runs on one host thread, so the cores take turns. Execution proceeds in
//rounds. In each round every running core gets one turn, in an order
//the scheduler picks, and executes a number of instructions in a row
//(one per SparcStateMachine::step()). The cores are thought of as
//running side by side during a round, so a round lasts as many model
//cycles as its longest turn, and the peripheral devices tick that many
//times at the end of it. With one core and rr:1 this is exactly the
//single-core configurations' loop: one instruction, then one device
//tick.
//
//Strategies, chosen at run time with --schedule <spec>:
//  rr:K           round-robin, K instructions per turn. The core that
//                 goes first moves on by one every round, so no core is
//                 always first. Default rr:1.
//  rr-fixed:K     round-robin, K instructions per turn, core 0 always
//                 first.
//  random:S[:M]   each round, a random order of the running cores, and a
//                 random turn length from 1 to M (default 8), from a
//                 generator seeded with S. The same seed always gives
//                 the same interleaving.
//A data-race-free program gives the same results under every strategy.
//A racy one need not, which is what the random strategy is for.

#ifndef SCHEDULER_H
#define SCHEDULER_H

#include <stdint.h>
#include <memory>
#include <string>
#include <vector>

struct Turn
{
	unsigned int  core;
	unsigned long instructions;
};

class Scheduler
{
	public:
		virtual ~Scheduler() {}

		//Fill `turns` with this round's turns, in execution order, one for
		//each core i with running[i] true.
		virtual void nextRound(const std::vector<bool>& running, std::vector<Turn>& turns) = 0;

		//Build a scheduler from a --schedule spec. Returns null and sets
		//`error` if the spec is malformed.
		static std::unique_ptr<Scheduler> fromSpec(const std::string& spec, std::string& error);
};

#endif
