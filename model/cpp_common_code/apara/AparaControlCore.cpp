//AparaControlCore.cpp
//Original author: Madhav Desai, IITB
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the APARA engine specification and
//reference C implementation developed by Prof. Madhav Desai, IITB

#include "AparaControlCore.h"
#include <cstring>

namespace apara
{

void AparaControlCore::reset()
{
	std::memset(reg_, 0, sizeof(reg_));
	for (unsigned int t = 0; t < THREADS_PER_ENGINE; t++)
	{
		interpreterOn_[t] = false;
		waiting_[t] = false;
		stopPending_[t] = false;
		stopError_[t] = 0;
		stopPc_[t] = 0;
	}
	interrupt_ = false;
}

uint32_t AparaControlCore::readRegister(unsigned int thread, unsigned int index) const
{
	return reg_[thread & 3][index & 7];
}

void AparaControlCore::writeRegister(unsigned int thread, unsigned int index, uint32_t value, uint8_t laneMask)
{
	unsigned int t = thread & 3, i = index & 7;
	uint32_t mask = 0;
	for (unsigned int b = 0; b < 4; b++)
		if (laneMask & (1u << b))
			mask |= 0xFFu << (8 * b);
	reg_[t][i] = (reg_[t][i] & ~mask) | (value & mask);
	if (i == 0)
	{
		interpreterOn_[t] = (reg_[t][0] & FLAG_RUN_INTERPRETER) != 0;
		if (!(reg_[t][0] & FLAG_INTERRUPT_ENABLE))
			interrupt_ = false;
	}
}

int AparaControlCore::commandReady() const
{
	for (unsigned int t = 0; t < THREADS_PER_ENGINE; t++)
	{
		uint32_t r0 = reg_[t][0];
		if (interpreterOn_[t] && (r0 & FLAG_START) && !(r0 & (FLAG_STARTED | FLAG_COMPLETED)))
			return (int) t;
	}
	return -1;
}

AparaControlCore::Request AparaControlCore::beginCommand(unsigned int thread)
{
	unsigned int t = thread & 3;
	uint32_t& r0 = reg_[t][0];
	r0 = (r0 & ~FLAG_START) | FLAG_STARTED; //as the hardware: start cleared, started set
	Request q;
	q.thread = t;
	q.command = (uint8_t) ((r0 >> 8) & 0xF);
	q.r1 = reg_[t][1];
	q.r2 = reg_[t][2];
	q.r3 = reg_[t][3];
	q.r6 = reg_[t][6];
	q.r7 = reg_[t][7];
	q.rasThread = (r0 >> 14) & 3;
	waiting_[t] = q.command == COMPLETION && (r0 & FLAG_INTERRUPT_ENABLE);
	if (q.command == RUN_THREAD || q.command == RESET_THREAD)
		stopPending_[t] = false; //a new run: its stop is reported afresh
	return q;
}

void AparaControlCore::finishCommand(unsigned int thread, const Result& r)
{
	unsigned int t = thread & 3;
	uint32_t* R = reg_[t];
	switch ((R[0] >> 8) & 0xF)
	{
		case READ_IMEM:      R[4] = r.imemWord; break;
		case READ_REGISTER:  R[6] = (uint32_t) (r.registerValue >> 32); R[7] = (uint32_t) r.registerValue; break;
		case STEP:           R[7] = r.nextPc; break;
		case READ_RAS_STATE: R[6] = r.rasDepth; R[7] = r.rasTop; break;
		case READ_TIMER:     R[3] = (uint32_t) (r.cycles >> 32); R[4] = (uint32_t) r.cycles; break;
		case COMPLETION:
			if (stopPending_[t])
			{
				R[5] = COMPLETION_VALID | (stopError_[t] & 0x07FFFFFF);
				R[6] = stopPc_[t];
				stopPending_[t] = false;
				if (R[0] & FLAG_INTERRUPT_ENABLE)
					interrupt_ = true;
			}
			else
				R[5] = 0;
			waiting_[t] = false;
			break;
		default: break; //the others write no register
	}
	R[0] = (R[0] & ~FLAG_STARTED) | FLAG_COMPLETED;
}

void AparaControlCore::threadStopped(unsigned int thread, uint32_t error, uint32_t pc)
{
	unsigned int t = thread & 3;
	stopPending_[t] = true;
	stopError_[t] = error;
	stopPc_[t] = pc;
}

bool AparaControlCore::completionReady(unsigned int thread) const
{
	return stopPending_[thread & 3];
}

}
