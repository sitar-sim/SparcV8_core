//CoreLogger.cpp

#include "CoreLogger.h"
#include "SparcCore.h"
#include "BitManipulation.h"
#include <sstream>
#include <ostream>

//Returns the low `width` bits of getBitString(value) (which is always
//32 characters, left-padded with zeros -- see BitManipulation.cpp), i.e.
//value's binary representation at its own field width.
static std::string binField(uint32_t value, int width)
{
	return getBitString(value).substr(32 - width, width);
}

static std::string hexField(uint32_t value)
{
	std::stringstream ss;
	ss << "0x" << std::hex << value;
	return ss.str();
}

CoreLogger::CoreLogger()
	: do_print(false), core_(0), out_(0), seq_(0), headerWritten_(false)
{}

void CoreLogger::init(SparcCore& core, std::ostream* out, bool doPrint)
{
	core_     = &core;
	out_      = out;
	do_print  = doPrint;
}

__attribute__((optimize("O0")))
std::string CoreLogger::print_state()
{
	Registers& reg = core_->reg;
	std::stringstream ss;

	ss << "PROCESSOR STATE: " << core_->printSparcState() << "\n";
	ss << "PSR.impl 0b" << binField(reg.R_impl(), Registers::size_impl) << "\n";
	ss << "PSR.ver  0b" << binField(reg.R_ver(),  Registers::size_ver)  << "\n";
	ss << "PSR.N    0b" << binField(reg.R_N(),    Registers::size_N)    << "\n";
	ss << "PSR.Z    0b" << binField(reg.R_Z(),    Registers::size_Z)    << "\n";
	ss << "PSR.V    0b" << binField(reg.R_V(),    Registers::size_V)    << "\n";
	ss << "PSR.C    0b" << binField(reg.R_C(),    Registers::size_C)    << "\n";
	ss << "PSR.EC   0b" << binField(reg.R_EC(),   Registers::size_EC)   << "\n";
	ss << "PSR.EF   0b" << binField(reg.R_EF(),   Registers::size_EF)   << "\n";
	ss << "PSR.PIL  0b" << binField(reg.R_PIL(),  Registers::size_PIL)  << "\n";
	ss << "PSR.S    0b" << binField(reg.R_S(),    Registers::size_S)    << "\n";
	ss << "PSR.PS   0b" << binField(reg.R_PS(),   Registers::size_PS)   << "\n";
	ss << "PSR.ET   0b" << binField(reg.R_ET(),   Registers::size_ET)   << "\n";
	ss << "PSR.CWP  0b" << binField(reg.R_CWP(),  Registers::size_CWP)  << "\n";

	ss << "PC  " << hexField(reg.R_PC())  << "\n";
	ss << "nPC " << hexField(reg.R_nPC()) << "\n";
	ss << "WIM " << hexField(reg.R_WIM()) << "\n";
	ss << "Y   " << hexField(reg.R_Y())   << "\n";
	ss << "TBR " << hexField(reg.R_TBR()) << "\n";

	static const char* g[8] = {"g0","g1","g2","g3","g4","g5","g6","g7"};
	static const char* o[8] = {"o0","o1","o2","o3","o4","o5","o6","o7"};
	static const char* l[8] = {"l0","l1","l2","l3","l4","l5","l6","l7"};
	static const char* i[8] = {"i0","i1","i2","i3","i4","i5","i6","i7"};
	for (int n=0; n<8; n++) ss << g[n] << " " << hexField(reg.R_r(n))     << "\n";
	for (int n=0; n<8; n++) ss << o[n] << " " << hexField(reg.R_r(8+n))   << "\n";
	for (int n=0; n<8; n++) ss << l[n] << " " << hexField(reg.R_r(16+n))  << "\n";
	for (int n=0; n<8; n++) ss << i[n] << " " << hexField(reg.R_r(24+n))  << "\n";

	return ss.str();
}

#ifdef SPARC_LOGGING_ENABLED

//Column order fixed here matches model/log_viewer/'s expectations exactly
//-- see that directory's README once it exists. Any change here needs a
//matching change to the viewer.
static const char* TRACE_HEADER =
	"seq\ttime\tpc\tevent\tdetail\t"
	"mode\twim\ty\ttbr\tnpc\t"
	"psr_impl\tpsr_ver\tpsr_n\tpsr_z\tpsr_v\tpsr_c\tpsr_ec\tpsr_ef\tpsr_pil\tpsr_s\tpsr_ps\tpsr_et\tpsr_cwp\t"
	"g0\tg1\tg2\tg3\tg4\tg5\tg6\tg7\t"
	"o0\to1\to2\to3\to4\to5\to6\to7\t"
	"l0\tl1\tl2\tl3\tl4\tl5\tl6\tl7\t"
	"i0\ti1\ti2\ti3\ti4\ti5\ti6\ti7";

//Tab-joined values for every column after "detail" in TRACE_HEADER above,
//in the same order. Deliberately excludes pc (already supplied by row(),
//since it's also this row's identity column, not just state).
static std::string collectStateTSV(SparcCore& core)
{
	Registers& reg = core.reg;
	std::stringstream ss;
	ss << core.printSparcState()                      << "\t"
	   << hexField(reg.R_WIM())                        << "\t"
	   << hexField(reg.R_Y())                          << "\t"
	   << hexField(reg.R_TBR())                        << "\t"
	   << hexField(reg.R_nPC())                        << "\t"
	   << binField(reg.R_impl(), Registers::size_impl) << "\t"
	   << binField(reg.R_ver(),  Registers::size_ver)  << "\t"
	   << binField(reg.R_N(),    Registers::size_N)    << "\t"
	   << binField(reg.R_Z(),    Registers::size_Z)    << "\t"
	   << binField(reg.R_V(),    Registers::size_V)    << "\t"
	   << binField(reg.R_C(),    Registers::size_C)    << "\t"
	   << binField(reg.R_EC(),   Registers::size_EC)   << "\t"
	   << binField(reg.R_EF(),   Registers::size_EF)   << "\t"
	   << binField(reg.R_PIL(),  Registers::size_PIL)  << "\t"
	   << binField(reg.R_S(),    Registers::size_S)    << "\t"
	   << binField(reg.R_PS(),   Registers::size_PS)   << "\t"
	   << binField(reg.R_ET(),   Registers::size_ET)   << "\t"
	   << binField(reg.R_CWP(),  Registers::size_CWP);
	for (int n=0; n<8; n++) ss << "\t" << hexField(reg.R_r(n));
	for (int n=0; n<8; n++) ss << "\t" << hexField(reg.R_r(8+n));
	for (int n=0; n<8; n++) ss << "\t" << hexField(reg.R_r(16+n));
	for (int n=0; n<8; n++) ss << "\t" << hexField(reg.R_r(24+n));
	return ss.str();
}

std::string CoreLogger::row(unsigned long time, const std::string& event, const std::string& detail)
{
	std::stringstream ss;
	ss << seq_++ << "\t" << time << "\t" << hexField(core_->reg.R_PC()) << "\t"
	   << event << "\t" << detail << "\t" << collectStateTSV(*core_);
	return ss.str();
}

std::string CoreLogger::header()
{
	return TRACE_HEADER;
}

std::string CoreLogger::emit(const std::string& s)
{
	if (!do_print)
		return s;
	if (out_)
	{
		if (!headerWritten_)
		{
			*out_ << header() << "\n";
			headerWritten_ = true;
		}
		*out_ << s << "\n";
	}
	return "";
}

std::string CoreLogger::log_fetch(unsigned long time, Opcode op)
{
	std::stringstream d;
	d << printOpcode(op) << " word=" << hexField(core_->reg.R_instruction());
	return emit(row(time, "FETCH", d.str()));
}

std::string CoreLogger::log_trap_raised(unsigned long time)
{
	return emit(row(time, "TRAP_RAISED", core_->printTrap()));
}

std::string CoreLogger::log_trap_enter(unsigned long time)
{
	Registers& reg = core_->reg;
	std::stringstream d;
	d << "jumped to trap handler " << SparcCore::trapTypeName(reg.R_tt())
	  << ", addr=" << hexField(reg.R_PC());
	return emit(row(time, "TRAP_ENTER", d.str()));
}

std::string CoreLogger::log_execute(unsigned long time, Opcode op)
{
	return emit(row(time, "EXECUTED", printOpcode(op)));
}

std::string CoreLogger::log_mem_read(unsigned long time, uint32_t address, uint32_t word0, uint32_t word1, bool isDouble, bool mae)
{
	std::stringstream d;
	d << "addr=" << hexField(address) << " word0=" << hexField(word0);
	if (isDouble)
		d << " word1=" << hexField(word1);
	d << " MAE=" << (mae ? 1 : 0);
	return emit(row(time, "MEM_READ", d.str()));
}

std::string CoreLogger::log_mem_write(unsigned long time, uint32_t address, uint32_t word0, uint32_t word1, uint32_t byteMask, bool mae)
{
	std::stringstream d;
	d << "addr=" << hexField(address) << " word0=" << hexField(word0)
	  << " word1=" << hexField(word1) << " mask=" << hexField(byteMask)
	  << " MAE=" << (mae ? 1 : 0);
	return emit(row(time, "MEM_WRITE", d.str()));
}

std::string CoreLogger::log_atomic(unsigned long time, uint32_t address, uint32_t oldWord, uint32_t newWord, bool mae)
{
	std::stringstream d;
	d << "addr=" << hexField(address) << " old=" << hexField(oldWord)
	  << " new=" << hexField(newWord) << " MAE=" << (mae ? 1 : 0);
	return emit(row(time, "ATOMIC", d.str()));
}

std::string CoreLogger::log_generic(unsigned long time, const std::string& event, const std::string& status)
{
	return emit(row(time, event, status));
}

#else //SPARC_LOGGING_ENABLED not defined: every log_* call below is a stub

std::string CoreLogger::header() { return ""; }
std::string CoreLogger::log_fetch(unsigned long, Opcode) { return ""; }
std::string CoreLogger::log_trap_raised(unsigned long) { return ""; }
std::string CoreLogger::log_trap_enter(unsigned long) { return ""; }
std::string CoreLogger::log_execute(unsigned long, Opcode) { return ""; }
std::string CoreLogger::log_mem_read(unsigned long, uint32_t, uint32_t, uint32_t, bool, bool) { return ""; }
std::string CoreLogger::log_mem_write(unsigned long, uint32_t, uint32_t, uint32_t, uint32_t, bool) { return ""; }
std::string CoreLogger::log_atomic(unsigned long, uint32_t, uint32_t, uint32_t, bool) { return ""; }
std::string CoreLogger::log_generic(unsigned long, const std::string&, const std::string&) { return ""; }

#endif
