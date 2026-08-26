//MemoryInterfaces.h
//
//Plain data "wire bundle" structs describing a memory request/response,
//one pair for each side of an MMU (or, in a config with no MMU, the one
//pair SparcCore/SparcStateMachine talk to directly) -- shared verbatim
//between the cpp_model (a function takes a request struct, fills in a
//response struct) and the sitar_model (the same struct types are what
//actually sits in a procedure's request/response handshake, `valid`
//fields included). No methods here -- see VirtualMemoryInterface/
//PhysicalMemoryInterface below for the (thin, one-method-each) abstract
//classes the cpp side uses to stay config-invariant.
//
//VirtualMemoryRequest/Response (formerly three separately-shaped
//MemoryAccessProvider methods, and separately AJIT/sitar's own
//MemAccessInterface struct -- unified into one definition both sides
//now share): what SparcCore and SparcStateMachine actually depend on for
//memory access -- a plain 32-bit VA, the ASI the access was made with
//(asi -- see SparcCore::addr_space, computed by execute_PreLoad/PreStore/
//PreAtomicLoadStore/instructionFetch per the manual), and an accessType
//tag distinguishing IFETCH/LOAD/STORE/ATOMIC_LS/FLUSH/NO_ACCESS instead
//of three differently-named methods. Whatever a cpp_model configuration
//connects downstream (MemCore directly in core_only, an Mmu in core_mmu,
//later a cache) implements VirtualMemoryInterface the same way, so
//SparcCore and SparcStateMachine stay unchanged as that downstream
//target changes -- see Plan_SoC_Integration_Roadmap.md's "lego-block
//interface contract". FLUSH computes an address but touches no memory in
//this model (see SparcCore::execute_PreFlush) -- included in the enum
//for parity with the sitar side's own long-standing MemAccessType, not
//because anything currently issues a FLUSH-type request.
//
//mae (Memory Access Exception) matters once an MMU sits downstream: a
//translation can genuinely fail. isInstructionFetch (IFETCH vs LOAD)
//matters for exactly one thing: which MMU fault class (instruction- vs
//data-access) an eventual page fault is recorded under, which in turn
//affects the Fault Status Register's overwrite (OW) priority rules (Ref
//Appendix H.5 -- a data-access fault is never overwritten by an
//instruction-access fault). AJIT's own MMU additionally defers
//committing an instruction-fetch fault's FSR/FAR until the fetch is
//confirmed non-speculative (its core has a pipeline that can squash a
//fetch on a branch misprediction); this driver has no pipeline at all --
//every fetch it makes is for the instruction about to execute, never
//squashed -- so that deferral has nothing to guard against here, and the
//MMU commits an instruction-fetch fault immediately like any other.
//
//A plain LOAD/IFETCH response is carried entirely in readWord0
//(readWord1 unused) -- collapsed this way (rather than a separate
//"instruction" field, which AJIT/sitar's own MemAccessInterface used to
//have) since IFETCH and LOAD never occur on the same request.
//
//PhysicalMemoryRequest/Response: the interface below an MMU (Mmu ->
//MainMemory, and later devices) speaks instead -- a 64-bit physical
//address (36 bits meaningful, Ref Appendix H, zero-padded above that --
//see Notes_multi_core_modeling.md), no ASI (the pass-through-ASI
//encoding from Appendix I is already folded into the PA bits by the
//time anything is downstream of the MMU), no isInstructionFetch
//(permission checking is already done). Modeled directly on AJIT's own
//AJIT Core Bus (ACB) interface -- confirmed against
//docs/processor/ajit_processor_description.pdf (ajit-toolchain repo),
//section 7.1: "A 64-bit data, 36-bit address system memory interface,"
//with request format
//  [109]=lock [108]=read/write_bar [107:100]=byte mask [99:64]=address [63:0]=write-data
//and response format [64]=error [63:0]=read-data. Every transaction --
//even a single 32-bit load -- moves a full 64-bit doubleword; a
//narrower access is realized by the 8-bit byteMask (one bit per byte,
//bit i selecting byte i of data, i.e. data bits [8*i+7:8*i]) selecting
//only the bytes that matter, with the caller extracting/inserting
//whichever 32-bit half it actually wanted (AJIT's own "half-select",
//e.g. readPageTableEntryFromMemory()'s
//getBit64(physical_addr,2)==0 ? high32 : low32 dance in its C model).
//Mmu.cpp implements exactly this half-select adaptation at the boundary
//between its own (32-bit-word-shaped) public interface and this
//64-bit-doubleword-shaped downstream one.
//
//No ATOMIC_LS on the physical side, deliberately: atomicity doesn't
//percolate this far down. Mmu::translate()'s dual load+store permission
//check (Ref docs/compliance/README.md's Issue 4) already resolves the
//part of "atomic" that matters above this interface -- by the time a
//translation succeeds, nothing downstream needs to know the access was
//atomic to preserve that guarantee. AJIT's own actual bus behavior has
//no distinct atomic transaction either (confirmed directly in its C
//model, Mmu.c's sysMemBusRequest() call sites): a locked plain READ,
//then a separate unlocked plain WRITE -- exactly {READ, WRITE} plus the
//`lock` bit here. `lock` is reserved/unused until multi-island
//arbitration exists (Ref Notes_multi_core_modeling.md's "Atomic
//load-store in a multi-core model" section, which also records AJIT's
//own lock enforcement being a single global lock gated by core ID, not
//per memory module -- confirmed directly in AJIT's bridge.c).

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
