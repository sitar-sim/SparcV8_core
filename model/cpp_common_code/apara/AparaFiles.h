//AparaFiles.h
//
//The APARA engine's file formats, as the reference tools (mcode_assemble,
//mcode_run) write and read them. Text after '!' is a comment, blank
//lines are ignored, numbers are hexadecimal.
//
//  object file (.obj)      <word index>: <instruction word>
//                          e.g. "8: 80000000"
//  data file (data.map)    <dword index>: <64-bit value>, the index taken
//                          modulo the DMEM size
//                          e.g. "10: 0x0102030405060708"
//  register file           <thread> <register> <64-bit value>
//                          e.g. "0 3 0x10"
//  results file            one expected value per line, with an optional
//                          mask (only the mask's bits are compared):
//                            <thread> pc  <pc> [mask]
//                            <thread> reg <register> <value> [mask]
//                            <thread> mem <dword index> <value> [mask]
//                          and, an extension of ours,
//                            <thread> error <ERROR register> [mask]
//                          ("mem" lines ignore the thread; DMEM is shared).

#ifndef APARA_FILES_H
#define APARA_FILES_H

#include <string>
#include <ostream>
#include <vector>
#include "AparaCore.h"

namespace apara
{
	//Each returns the number of entries loaded, or -1 (with `error` set)
	//if the file cannot be read or has a malformed line.
	int loadObjectFile(AparaCore& core, const std::string& path, std::string& error);
	int loadDataFile(AparaCore& core, const std::string& path, std::string& error);
	int loadRegisterFile(AparaCore& core, const std::string& path, std::string& error);

	//Checks every line of a results file against the engine's state,
	//writing one line per mismatch to `report`. Returns the number of
	//mismatches, or -1 (with `error` set) if the file cannot be read or
	//has a malformed line.
	int checkResultsFile(const AparaCore& core, const std::string& path, std::ostream& report, std::string& error);

	//Writes the engine's state as a results file: PC, ERROR and all
	//registers of every started thread, and every DMEM dword that is
	//non-zero now or was non-zero in `initialDmem` (DMEM_DWORDS values).
	void writeResults(const AparaCore& core, const std::vector<uint64_t>& initialDmem, std::ostream& os);
}

#endif
