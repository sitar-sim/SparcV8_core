//MemAccessInterface.h
//Author: Neha Karanjkar
//
//Shared request/response object connecting a MemoryInterface (the
//requester, one per ifetch/load/store/atomic/flush thread inside
//SparcThread) to whatever persistent procedure is servicing it on the
//other end -- MainMemory today, or later a cache. See MainMemory.sitar
//and MemoryInterface.sitar for the two sides of the handshake protocol
//this struct implements, and Core.sitar for how the pointers are wired:
//the parent module owns one MemAccessInterface instance per connection
//and points both sides at it (same pattern as PipelinedProcessor's
//stage_inputs[] in the sitar repo's examples).
//
//Handshake protocol (exactly one requester and one responder per
//instance of this struct):
//  1. Requester waits until request_valid==false (responder idle), fills
//     in the request fields, then sets request_valid=true.
//  2. Responder waits until request_valid==true, performs the access,
//     fills in the response fields, then sets response_valid=true.
//  3. Requester waits until response_valid==true and access_type matches
//     its own (a cheap consistency check), reads the response fields,
//     then clears both request_valid and response_valid together --
//     this is the single point where the transaction closes, freeing the
//     responder to service the next request and the requester (or
//     another requester sharing the same responder) to issue one.
//  4. Responder waits until response_valid==false before going back to
//     step 2, so it never re-services an already-completed request.

#ifndef MEM_ACCESS_INTERFACE_H
#define MEM_ACCESS_INTERFACE_H

#include <cstdint>
#include <string>

//`enum class` (scoped), not a plain enum: SPARC's own Opcode enum (see
//Opcodes.h) already has a FLUSH enumerator, and a plain enum here would
//collide with it as soon as both headers are included in the same
//translation unit (as Core.cpp does). Every use needs the
//MemAccessType:: qualifier as a result -- see MemoryInterface.sitar,
//MainMemory.sitar and SparcThread.sitar.
enum class MemAccessType : uint32_t
{
	NO_ACCESS = 0,
	LOAD      = 1,
	STORE     = 2,
	IFETCH    = 3,
	ATOMIC_LS = 4,
	FLUSH     = 5
};

inline std::string accessTypeToString(MemAccessType accessType)
{
	switch(accessType)
	{
		case MemAccessType::NO_ACCESS: return "NO_ACCESS";
		case MemAccessType::LOAD:      return "LOAD";
		case MemAccessType::STORE:     return "STORE";
		case MemAccessType::IFETCH:    return "IFETCH";
		case MemAccessType::ATOMIC_LS: return "ATOMIC_LS";
		case MemAccessType::FLUSH:     return "FLUSH";
		default:                       return "INVALID";
	}
}

struct MemAccessInterface
{
	//-------- request: written by the requester, read by the responder --------
	bool          request_valid;
	MemAccessType access_type;
	uint32_t      address;
	uint32_t      addr_space;   //currently ignored; reserved for virtual memory
	uint32_t      writeWord0;
	uint32_t      writeWord1;
	uint32_t      byte_mask;

	//-------- response: written by the responder, read by the requester -------
	bool          response_valid;
	uint32_t      readWord0;
	uint32_t      readWord1;
	uint32_t      instruction;
	bool          MAE;
};

#endif
