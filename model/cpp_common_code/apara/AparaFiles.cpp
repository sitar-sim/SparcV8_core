//AparaFiles.cpp
//Original author: Madhav Desai, IITB
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the APARA engine specification and
//reference C implementation developed by Prof. Madhav Desai, IITB

#include "AparaFiles.h"
#include <fstream>
#include <sstream>
#include <cstdio>
#include <cstdlib>

namespace apara
{

namespace
{
	//The lines of a file, comments and blank lines removed, with their
	//line numbers.
	bool readLines(const std::string& path, std::vector<std::pair<int, std::string> >& lines, std::string& error)
	{
		std::ifstream in(path.c_str());
		if (!in)
		{
			error = "cannot read " + path;
			return false;
		}
		std::string line;
		int number = 0;
		while (std::getline(in, line))
		{
			number++;
			size_t bang = line.find('!');
			if (bang != std::string::npos)
				line.erase(bang);
			if (line.find_first_not_of(" \t\r") == std::string::npos)
				continue;
			lines.push_back(std::make_pair(number, line));
		}
		return true;
	}

	bool parseHex(const std::string& s, uint64_t& v)
	{
		if (s.empty())
			return false;
		char* end = nullptr;
		v = std::strtoull(s.c_str(), &end, 16); //accepts an optional 0x
		return *end == '\0';
	}

	std::vector<std::string> tokens(const std::string& line)
	{
		std::vector<std::string> t;
		std::istringstream is(line);
		std::string s;
		while (is >> s)
			t.push_back(s);
		return t;
	}

	std::string where(const std::string& path, int line)
	{
		return path + ":" + std::to_string(line) + ": ";
	}

	//"<index>: <value>" lines.
	template <typename Store>
	int loadIndexValueFile(const std::string& path, std::string& error, Store store)
	{
		std::vector<std::pair<int, std::string> > lines;
		if (!readLines(path, lines, error))
			return -1;
		for (auto& l : lines)
		{
			size_t colon = l.second.find(':');
			std::vector<std::string> left, right;
			if (colon != std::string::npos)
			{
				left = tokens(l.second.substr(0, colon));
				right = tokens(l.second.substr(colon + 1));
			}
			uint64_t index, value;
			if (left.size() != 1 || right.size() != 1 || !parseHex(left[0], index) || !parseHex(right[0], value))
			{
				error = where(path, l.first) + "expected \"<index>: <value>\"";
				return -1;
			}
			if (!store(index, value, error))
			{
				error = where(path, l.first) + error;
				return -1;
			}
		}
		return (int) lines.size();
	}

	std::string hex(uint64_t v)
	{
		char b[32];
		std::snprintf(b, sizeof(b), "0x%llx", (unsigned long long) v);
		return b;
	}
}

int loadObjectFile(AparaCore& core, const std::string& path, std::string& error)
{
	return loadIndexValueFile(path, error, [&](uint64_t index, uint64_t value, std::string& e) {
		if (index >= IMEM_WORDS) { e = "word index " + hex(index) + " is beyond IMEM"; return false; }
		if (value > 0xFFFFFFFFULL) { e = "instruction word " + hex(value) + " is wider than 32 bits"; return false; }
		core.writeImemWord((uint32_t) index, (uint32_t) value);
		return true;
	});
}

int loadDataFile(AparaCore& core, const std::string& path, std::string& error)
{
	return loadIndexValueFile(path, error, [&](uint64_t index, uint64_t value, std::string&) {
		core.writeDmemDword((uint32_t) (index % DMEM_DWORDS), value);
		return true;
	});
}

int loadRegisterFile(AparaCore& core, const std::string& path, std::string& error)
{
	std::vector<std::pair<int, std::string> > lines;
	if (!readLines(path, lines, error))
		return -1;
	for (auto& l : lines)
	{
		//Some reference tests write "0: 1: 0x1"; the colons are separators.
		std::string line = l.second;
		for (char& c : line)
			if (c == ':') c = ' ';
		std::vector<std::string> t = tokens(line);
		uint64_t thread, reg, value;
		if (t.size() != 3 || !parseHex(t[0], thread) || !parseHex(t[1], reg) || !parseHex(t[2], value)
		    || thread >= THREADS_PER_ENGINE || reg >= REGISTERS)
		{
			error = where(path, l.first) + "expected \"<thread 0-3> <register 0-1f> <value>\"";
			return -1;
		}
		core.writeRegister((unsigned) thread, (unsigned) reg, value);
	}
	return (int) lines.size();
}

int checkResultsFile(const AparaCore& core, const std::string& path, std::ostream& report, std::string& error)
{
	std::vector<std::pair<int, std::string> > lines;
	if (!readLines(path, lines, error))
		return -1;
	int mismatches = 0;
	for (auto& l : lines)
	{
		std::vector<std::string> t = tokens(l.second);
		uint64_t thread = 0, a = 0, b = 0, mask = ~0ULL;
		bool ok = t.size() >= 3 && parseHex(t[0], thread) && thread < THREADS_PER_ENGINE && parseHex(t[2], a);
		std::string kind = t.size() >= 2 ? t[1] : "";
		std::string name;
		uint64_t actual = 0, expected = 0;
		if (ok && (kind == "pc" || kind == "error"))
		{
			ok = t.size() <= 4 && (t.size() < 4 || parseHex(t[3], mask));
			expected = a;
			const ThreadState& ts = core.thread((unsigned) thread);
			actual = kind == "pc" ? ts.pc : ts.error;
			name = "thread " + std::to_string(thread) + " " + kind;
		}
		else if (ok && (kind == "reg" || kind == "mem"))
		{
			ok = t.size() >= 4 && t.size() <= 5 && parseHex(t[3], b) && (t.size() < 5 || parseHex(t[4], mask));
			expected = b;
			if (kind == "reg")
			{
				ok = ok && a < REGISTERS;
				actual = core.readRegister((unsigned) thread, (unsigned) a);
				name = "thread " + std::to_string(thread) + " $r" + std::to_string(a);
			}
			else
			{
				actual = core.dmemDword((uint32_t) (a % DMEM_DWORDS));
				name = "DMEM[" + hex(a % DMEM_DWORDS) + "]";
			}
		}
		else
			ok = false;
		if (!ok)
		{
			error = where(path, l.first) + "expected \"<thread> pc|error <value> [mask]\" or \"<thread> reg|mem <index> <value> [mask]\"";
			return -1;
		}
		if ((actual & mask) != (expected & mask))
		{
			mismatches++;
			report << "mismatch: " << name << " = " << hex(actual) << ", expected " << hex(expected);
			if (mask != ~0ULL)
				report << " (mask " << hex(mask) << ")";
			report << "\n";
		}
	}
	return mismatches;
}

void writeResults(const AparaCore& core, const std::vector<uint64_t>& initialDmem, std::ostream& os)
{
	os << "! APARA engine final state\n";
	for (unsigned int t = 0; t < THREADS_PER_ENGINE; t++)
	{
		const ThreadState& ts = core.thread(t);
		if (!ts.active)
			continue;
		os << "! thread " << t << (ts.halted ? " halted" : " running") << ", ERROR " << hex(ts.error) << "\n";
		os << t << " pc " << hex(ts.pc) << "\n";
		for (unsigned int r = 1; r < REGISTERS; r++)
			os << t << " reg " << hex(r) << " " << hex(ts.r[r]) << "\n";
	}
	for (uint32_t i = 0; i < DMEM_DWORDS; i++)
	{
		uint64_t v = core.dmemDword(i);
		if (v != 0 || (i < initialDmem.size() && initialDmem[i] != 0))
			os << "0 mem " << hex(i) << " " << hex(v) << "\n";
	}
}

}
