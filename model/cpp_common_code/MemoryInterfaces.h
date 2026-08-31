//MemoryInterfaces.h
//
//Plain data structs describing a memory request and response, shared
//verbatim between the cpp_model and the sitar_model. No methods here.
//See VirtualMemoryInterface/PhysicalMemoryInterface below for the thin
//abstract classes the cpp side uses to stay config-invariant.
//
//VirtualMemoryRequest/Response is what SparcCore and SparcStateMachine
//depend on: a 32-bit virtual address, the ASI the access was made with,
//and an accessType tag (IFETCH, LOAD, STORE, ATOMIC_LS, FLUSH,
//NO_ACCESS). Whatever sits downstream, MemCore, an MMU, or later a
//cache, implements VirtualMemoryInterface the same way, so SparcCore
//and SparcStateMachine stay unchanged as that downstream target
//changes. mae (Memory Access Exception) matters once an MMU is present,
//since a translation can fail. isInstructionFetch selects which MMU
//fault class a page fault is recorded under. A LOAD or IFETCH response
//is carried entirely in readWord0, since the two never occur on the
//same request.
//
//PhysicalMemoryRequest/Response is what the interface below an MMU
//speaks instead: a 64-bit physical address (36 bits meaningful), no
//ASI, no isInstructionFetch. Every transaction moves a full 64-bit
//doubleword, even a single 32-bit load, with an 8-bit byteMask (one bit
//per byte) selecting which bytes actually matter. No ATOMIC_LS on the
//physical side: atomicity is already resolved above this interface, by
//the time a translation succeeds. `lock` marks an atomic access's
//locked read half, and is reserved for multi-core arbitration, unused
//until that exists.

#ifndef MEMORY_INTERFACES_H
#define MEMORY_INTERFACES_H

#include <stdint.h>
#include <string>

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
	switch (accessType)
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

struct VirtualMemoryRequest
{
	bool          valid;
	MemAccessType accessType;
	uint32_t      address;
	uint32_t      asi;
	uint32_t      word0;
	uint32_t      word1;
	uint32_t      byteMask;
};

struct VirtualMemoryResponse
{
	bool     valid;
	uint32_t readWord0;
	uint32_t readWord1;
	bool     mae;
};

enum class PhysicalAccessType : uint32_t
{
	READ  = 0,
	WRITE = 1
};

struct PhysicalMemoryRequest
{
	bool               valid;
	PhysicalAccessType accessType;
	bool               lock;             //reserved, unused until multi-island arbitration exists
	uint64_t           physicalAddress;  //36 bits meaningful, zero-padded
	uint64_t           data;             //WRITE only
	uint8_t            byteMask;         //WRITE only, one bit per byte of data
};

struct PhysicalMemoryResponse
{
	bool     valid;
	uint64_t readData;
	bool     mae;
};

//Wire-format token widths for the two structs above, used by the Sitar
//net/port/token declarations that carry them packed (Ref
//sitar::pack/unpack) once the MMU-to-memory link is nets, not a plain
//procedure handshake (Ref core_mmu/sitar_model/src/System.sitar). `valid`
//is deliberately excluded from both -- a token's mere presence on a net
//already is the valid signal.
//accessType(4)+lock(1)+physicalAddress(8)+data(8)+byteMask(1).
#define TOKEN_REQ_WIDTH  22
//readData(8)+mae(1).
#define TOKEN_RESP_WIDTH 9

//Abstract interfaces the cpp_model side uses to stay config-invariant --
//one virtual method each, taking/filling the structs above, instead of
//a differently-shaped method per operation. The sitar_model side has no
//equivalent class -- procedures just hold VirtualMemoryRequest/Response
//(or PhysicalMemoryRequest/Response) instances/pointers directly.

class VirtualMemoryInterface
{
	public:
		virtual ~VirtualMemoryInterface() {}
		virtual void access(const VirtualMemoryRequest& request, VirtualMemoryResponse& response) = 0;
};

class PhysicalMemoryInterface
{
	public:
		virtual ~PhysicalMemoryInterface() {}
		virtual void access(const PhysicalMemoryRequest& request, PhysicalMemoryResponse& response) = 0;
};

#endif
