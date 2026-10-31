//Scheduler.cpp
//Original Author: Neha Karanjkar
//Model Author: Claude Opus 5.5 (high)
//The model code was adapted from a Sparc v8 core simulation model written
//by the first author in C++ and Sitar (2015-2017).

#include "Scheduler.h"
#include <cstdlib>
#include <random>
#include <sstream>

namespace
{
	class RoundRobinScheduler : public Scheduler
	{
		public:
			RoundRobinScheduler(unsigned long k, bool rotate) : k_(k), rotate_(rotate), first_(0) {}

			void nextRound(const std::vector<bool>& running, std::vector<Turn>& turns) override
			{
				turns.clear();
				unsigned int n = (unsigned int) running.size();
				for (unsigned int i = 0; i < n; i++)
				{
					unsigned int core = (first_ + i) % n;
					if (running[core])
						turns.push_back(Turn{core, k_});
				}
				if (rotate_ && n > 0)
					first_ = (first_ + 1) % n;
			}

		private:
			unsigned long k_;
			bool          rotate_;
			unsigned int  first_;
	};

	class RandomScheduler : public Scheduler
	{
		public:
			RandomScheduler(uint32_t seed, unsigned long maxTurn) : rng_(seed), maxTurn_(maxTurn) {}

			void nextRound(const std::vector<bool>& running, std::vector<Turn>& turns) override
			{
				turns.clear();
				for (unsigned int core = 0; core < running.size(); core++)
					if (running[core])
						turns.push_back(Turn{core, 0});

				//Fisher-Yates with the generator's raw output (std::mt19937's
				//sequence is fixed by the C++ standard, std::shuffle's use of
				//it is not), so a seed gives the same run on any host.
				for (size_t i = turns.size(); i > 1; i--)
				{
					size_t j = rng_() % i;
					std::swap(turns[i - 1], turns[j]);
				}
				for (Turn& t : turns)
					t.instructions = 1 + rng_() % maxTurn_;
			}

		private:
			std::mt19937  rng_;
			unsigned long maxTurn_;
	};

	//Splits "a:b:c" into its fields.
	std::vector<std::string> fields(const std::string& spec)
	{
		std::vector<std::string> out;
		std::stringstream ss(spec);
		std::string f;
		while (std::getline(ss, f, ':'))
			out.push_back(f);
		return out;
	}

	bool positiveNumber(const std::string& s, unsigned long& value)
	{
		if (s.empty())
			return false;
		char* end = NULL;
		value = std::strtoul(s.c_str(), &end, 0);
		return *end == '\0' && value > 0;
	}
}

std::unique_ptr<Scheduler> Scheduler::fromSpec(const std::string& spec, std::string& error)
{
	std::vector<std::string> f = fields(spec);
	unsigned long a = 0, b = 0;

	if (f.size() == 2 && (f[0] == "rr" || f[0] == "rr-fixed") && positiveNumber(f[1], a))
		return std::unique_ptr<Scheduler>(new RoundRobinScheduler(a, f[0] == "rr"));

	if ((f.size() == 2 || f.size() == 3) && f[0] == "random")
	{
		char* end = NULL;
		unsigned long seed = std::strtoul(f[1].c_str(), &end, 0);
		bool seedOk = !f[1].empty() && *end == '\0';
		b = 8;
		if (seedOk && (f.size() == 2 || positiveNumber(f[2], b)))
			return std::unique_ptr<Scheduler>(new RandomScheduler((uint32_t) seed, b));
	}

	error = "bad --schedule '" + spec + "' (expected rr:K, rr-fixed:K, or random:SEED[:MAXTURN])";
	return nullptr;
}
