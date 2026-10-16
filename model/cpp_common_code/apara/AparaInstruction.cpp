//AparaInstruction.cpp
//Original author: Madhav Desai, IITB
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the APARA engine specification and
//reference C implementation developed by Prof. Madhav Desai, IITB

#include "AparaInstruction.h"
#include <sstream>

namespace apara
{

namespace
{
	uint32_t field(uint32_t w, unsigned int high, unsigned int low)
	{
		return (w >> low) & (uint32_t) lowMask(high - low + 1);
	}

	int32_t signedField(uint32_t w, unsigned int high, unsigned int low)
	{
		return (int32_t) (int64_t) signExtend(field(w, high, low), high - low + 1);
	}

	bool isAluOpcode(Opcode op) { return op >= Opcode::ADD && op <= Opcode::SHR; }

	//The reference model's inferDestinationType() (McodeUtils.cpp): the
	//result type keeps the source type's flags, only the width changes.
	Type inferDestination(Opcode op, const Type& src)
	{
		Type d = src;
		if (src.isVector)
		{
			if (op == Opcode::DOT || op == Opcode::VREDUCE)
				d.bits = src.isFloat ? 32 : 64;
		}
		else if (isAluOpcode(op) && !src.isFloat)
			d.bits = 64; //integer ALU results are 64-bit
		return d;
	}

	uint32_t bit(unsigned int reg) { return reg == 0 ? 0u : (1u << (reg & 0x1F)); }
	uint32_t range(unsigned int first, unsigned int count)
	{
		uint32_t m = 0;
		for (unsigned int i = 0; i < count; i++)
			m |= bit((first + i) & 0x1F);
		return m;
	}

	//Register counts of a CAST: a vector cast to a wider element reads one
	//register and writes several, to a narrower element reads several
	//and writes one (Ref the reference's Calculate_Register_Counts()).
	void castRegisterCounts(const Instruction& in, unsigned int& inRegs, unsigned int& outRegs)
	{
		inRegs = outRegs = 1;
		if (in.castSource.isVector)
		{
			if (in.type.bits < in.castSource.bits) inRegs  = in.castSource.bits / in.type.bits;
			else if (in.castSource.bits < in.type.bits) outRegs = in.type.bits / in.castSource.bits;
		}
	}

	unsigned int packInputRegisters(const Instruction& in)
	{
		return (in.packedBits + in.wordBits - 1) / in.wordBits;
	}

	unsigned int packOutputRegisters(const Instruction& in)
	{
		return in.packedBits < 64 ? 1 : in.packedBits / 64;
	}
}

Instruction Instruction::decode(uint32_t w)
{
	Instruction in;
	in.word        = w;
	in.bundleStart = (w >> 31) & 1;
	in.opcode      = (Opcode) field(w, 30, 26);
	in.valid       = true;
	in.rd  = (uint8_t) field(w, 20, 16);
	in.rs1 = (uint8_t) field(w, 15, 11);
	in.rs2 = (uint8_t) field(w, 4, 0);

	switch (in.opcode)
	{
		case Opcode::NOP:
		case Opcode::NULL_OP:
			in.klass = InstructionClass::NONE;
			break;

		case Opcode::HALT:
			in.klass = InstructionClass::HALT;
			break;

		case Opcode::CALL:
			in.klass     = InstructionClass::CONTROL;
			in.immediate = field(w, 25, 25);
			in.jump      = signedField(w, 24, 0);
			break;

		case Opcode::RETURN:
			in.klass = InstructionClass::CONTROL;
			break;

		case Opcode::BRANCH:
			in.klass     = InstructionClass::CONTROL;
			in.type      = Type::fromCode(field(w, 25, 22));
			in.condition = (Condition) field(w, 21, 19);
			in.increment = signedField(w, 18, 17);
			in.jump      = signedField(w, 16, 5);
			if (in.type.isFloat || in.type.isVector)
				in.increment = 0; //as the reference: no auto-increment on a float or vector test
			break;

		case Opcode::FSQRT:
			in.klass    = InstructionClass::DIVIDE;
			in.type     = Type::fromCode(field(w, 25, 21));
			in.destType = in.type;
			break;

		case Opcode::DOT:
			in.klass    = InstructionClass::DOT;
			in.type     = Type::fromCode(field(w, 25, 21));
			in.flag     = field(w, 10, 10);
			in.destType = inferDestination(in.opcode, in.type);
			break;

		case Opcode::VREDUCE:
			in.klass     = InstructionClass::VECTOR;
			in.type      = Type::fromCode(field(w, 25, 21));
			in.subOpcode = (Opcode) field(w, 10, 6);
			in.destType  = inferDestination(in.opcode, in.type);
			break;

		case Opcode::CAST:
			in.klass      = InstructionClass::CAST;
			in.type       = Type::fromCode(field(w, 25, 21));
			in.castSource = Type::fromCode(field(w, 14, 10));
			in.type.isVector = in.castSource.isVector; //the destination's vector-ness comes from the source
			in.destType   = in.type;
			break;

		case Opcode::CMOV:
			in.klass     = InstructionClass::ALU;
			in.type      = Type::fromCode(field(w, 25, 21));
			in.condition = (Condition) field(w, 10, 8);
			in.increment = signedField(w, 7, 6);
			if (in.type.isFloat || in.type.isVector)
				in.increment = 0;
			break;

		case Opcode::PACK:
			in.klass      = InstructionClass::ALU;
			in.packedBits = (uint16_t) (1u << field(w, 15, 12));
			in.wordBits   = (uint16_t) (1u << field(w, 11, 9));
			break;

		case Opcode::SET:
			in.klass        = InstructionClass::ALU;
			in.setByteIndex = (uint8_t) field(w, 23, 21);
			in.setValue     = (uint16_t) field(w, 15, 0);
			break;

		case Opcode::SLICE:
			in.klass     = InstructionClass::ALU;
			in.sliceHigh = (uint8_t) ((field(w, 25, 21) << 1) | field(w, 15, 15));
			in.sliceLow  = (uint8_t) field(w, 14, 9);
			break;

		case Opcode::LOAD:
		case Opcode::STORE:
			in.klass     = InstructionClass::MEMORY;
			in.type      = Type::fromCode(field(w, 25, 21));
			in.immediate = field(w, 10, 10);
			in.increment = signedField(w, 9, 5);
			in.immValue  = signedField(w, 9, 0);
			break;

		default:
			if (isAluOpcode(in.opcode))
			{
				in.type     = Type::fromCode(field(w, 25, 21));
				in.isVector = in.type.isVector;
				in.destType = inferDestination(in.opcode, in.type);
				in.klass    = in.isVector ? InstructionClass::VECTOR
				            : (in.opcode == Opcode::DIV ? InstructionClass::DIVIDE : InstructionClass::ALU);
				if (in.isVector)
					in.flag = field(w, 10, 10); //replicate
				else
				{
					in.immediate = field(w, 10, 10);
					in.immValue  = signedField(w, 9, 0);
				}
			}
			else
				in.valid = false; //opcodes 0x1C..0x1F
			break;
	}
	if (in.valid)
		in.valid = in.checkValidity();
	return in;
}

//Encodings the engine does not execute: undefined type codes, operand
//widths an instruction cannot handle, and register groups that would run
//past $r31 (Ref docs/source/apara/isa.md for the rules).
bool Instruction::checkValidity() const
{
	switch (opcode)
	{
		case Opcode::NOP: case Opcode::NULL_OP: case Opcode::HALT:
		case Opcode::RETURN: case Opcode::CALL:
		case Opcode::SET:
			return true;
		case Opcode::BRANCH:
		case Opcode::CMOV:
			return type.valid && !type.isVector && type.bits <= 64;
		case Opcode::PACK:
			return wordBits <= 64 && wordBits <= packedBits && packedBits <= 256
			       && packInputRegisters(*this) <= 32;
		case Opcode::SLICE:
			return sliceLow <= sliceHigh;
		case Opcode::LOAD:
		case Opcode::STORE:
			return type.valid && type.bits >= 8 && rd + transferRegisters() <= 32;
		case Opcode::CAST:
		{
			if (!type.valid || !castSource.valid || type.bits > 64 || castSource.bits > 64)
				return false;
			unsigned int i, o;
			castRegisterCounts(*this, i, o);
			return i <= 2 && o <= 2; //vector casts go one width step at a time
		}
		case Opcode::DOT:
			return type.valid && type.bits <= 64;
		case Opcode::VREDUCE:
			if (!type.valid || type.bits > 64)
				return false;
			if (type.isFloat)
				return subOpcode == Opcode::ADD || subOpcode == Opcode::MUL;
			return subOpcode == Opcode::ADD || subOpcode == Opcode::MUL || subOpcode == Opcode::OR
			       || subOpcode == Opcode::AND || subOpcode == Opcode::XOR || subOpcode == Opcode::XNOR;
		case Opcode::FSQRT: //f32 and f64 only (Ref the ISA, isa.txt)
			return type.valid && type.isFloat && !type.isVector && (type.bits == 32 || type.bits == 64);
		default:
			if (!isAluOpcode(opcode) || !type.valid)
				return false;
			if (isVector) //VALU: element-wise add, subtract, multiply
				return opcode == Opcode::ADD || opcode == Opcode::SUB || opcode == Opcode::MUL;
			if (type.isFloat) //scalar float: the four arithmetic operations
				return opcode == Opcode::ADD || opcode == Opcode::SUB || opcode == Opcode::MUL || opcode == Opcode::DIV;
			return true;
	}
}

uint32_t Instruction::readMask() const
{
	switch (opcode)
	{
		case Opcode::CALL:    return immediate ? 0 : bit(rs2);
		case Opcode::BRANCH:  return bit(rs2);
		case Opcode::FSQRT:
		case Opcode::VREDUCE: return bit(rs1);
		case Opcode::DOT:     return bit(rs1) | bit(rs2) | bit(rd);
		case Opcode::CAST:    { unsigned int i, o; castRegisterCounts(*this, i, o); return range(rs2, i); }
		case Opcode::CMOV:    return bit(rs1) | bit(rs2) | bit(rd);
		case Opcode::PACK:    return range(rs2, packInputRegisters(*this));
		case Opcode::SLICE:   return bit(rs2);
		case Opcode::LOAD:    return bit(rs1) | (immediate ? 0 : bit(rs2));
		case Opcode::STORE:   return bit(rs1) | (immediate ? 0 : bit(rs2)) | range(rd, transferRegisters());
		default:
			if (isAluOpcode(opcode))
				return bit(rs1) | ((immediate && !isVector) ? 0 : bit(rs2));
			return 0;
	}
}

uint32_t Instruction::writeMask() const
{
	switch (opcode)
	{
		case Opcode::BRANCH:  return increment ? bit(rs2) : 0;
		case Opcode::FSQRT:
		case Opcode::VREDUCE:
		case Opcode::DOT:
		case Opcode::SET:
		case Opcode::SLICE:   return bit(rd);
		case Opcode::CAST:    { unsigned int i, o; castRegisterCounts(*this, i, o); return range(rd, o); }
		case Opcode::CMOV:    return bit(rd) | (increment ? bit(rs2) : 0);
		case Opcode::PACK:    return range(rd, packOutputRegisters(*this));
		case Opcode::LOAD:    return range(rd, transferRegisters()) | ((!immediate && increment) ? bit(rs2) : 0);
		case Opcode::STORE:   return (!immediate && increment) ? bit(rs2) : 0;
		default:
			if (isAluOpcode(opcode))
				return bit(rd);
			return 0;
	}
}

std::string opcodeName(Opcode op)
{
	switch (op)
	{
		case Opcode::NOP:     return "$nop";
		case Opcode::CALL:    return "$call";
		case Opcode::BRANCH:  return "?";
		case Opcode::RETURN:  return "$return";
		case Opcode::ADD:     return "+";
		case Opcode::SUB:     return "-";
		case Opcode::MUL:     return "*";
		case Opcode::DIV:     return "/";
		case Opcode::OR:      return "|";
		case Opcode::AND:     return "&";
		case Opcode::XOR:     return "^";
		case Opcode::NOR:     return "~|";
		case Opcode::NAND:    return "~&";
		case Opcode::XNOR:    return "~^";
		case Opcode::SHL:     return "<<";
		case Opcode::SHR:     return ">>";
		case Opcode::FSQRT:   return "$fsqrt";
		case Opcode::DOT:     return "$dot";
		case Opcode::CAST:    return "$cast";
		case Opcode::LOAD:    return "$ld";
		case Opcode::STORE:   return "$st";
		case Opcode::SET:     return "$set";
		case Opcode::VREDUCE: return "$vreduce";
		case Opcode::CMOV:    return "$cmov";
		case Opcode::PACK:    return "$pack";
		case Opcode::SLICE:   return "$slice";
		case Opcode::NULL_OP: return "$null";
		case Opcode::HALT:    return "$halt";
		default:              return "$illegal";
	}
}

std::string Instruction::toString() const
{
	static const char* cond[8] = {"(always)", "==", ">", "<", ">=", "<=", "!=", "(never)"};
	std::ostringstream s;
	auto r = [](unsigned int n) { return "$r" + std::to_string(n); };
	auto incr = [](int32_t i) { return i == 0 ? std::string() : (i > 0 ? " ++" + std::to_string(i) : " --" + std::to_string(-i)); };
	if (!valid) { s << "$illegal 0x" << std::hex << word; return s.str(); }
	switch (opcode)
	{
		case Opcode::NOP: case Opcode::NULL_OP: case Opcode::HALT: case Opcode::RETURN:
			s << opcodeName(opcode); break;
		case Opcode::CALL:
			s << "$call " << (immediate ? ("pc" + std::string(jump >= 0 ? "+" : "") + std::to_string(jump)) : r(rs2)); break;
		case Opcode::BRANCH:
			s << "? (" << type.name() << ") " << r(rs2) << " " << cond[(int) condition] << incr(increment)
			  << " $goto pc" << (jump >= 0 ? "+" : "") << jump; break;
		case Opcode::FSQRT:
			s << "$fsqrt " << r(rd) << " (" << type.name() << ") " << r(rs1); break;
		case Opcode::DOT:
			s << "$dot " << (flag ? "$accumulate " : "") << r(rd) << " (" << type.name() << ") " << r(rs1) << " " << r(rs2); break;
		case Opcode::VREDUCE:
			s << "$vreduce " << opcodeName(subOpcode) << " " << r(rd) << " (" << type.name() << ") " << r(rs1); break;
		case Opcode::CAST:
			s << "$cast (" << destType.name() << ") " << r(rd) << " (" << castSource.name() << ") " << r(rs2); break;
		case Opcode::CMOV:
			s << "$cmov (" << type.name() << ") " << r(rs1) << " " << cond[(int) condition] << incr(increment)
			  << " " << r(rd) << " " << r(rs2); break;
		case Opcode::PACK:
			s << "$pack " << packedBits << " " << r(rd) << " " << wordBits << " " << r(rs2); break;
		case Opcode::SET:
			s << "$set " << r(rd) << " " << (int) setByteIndex << " " << setValue; break;
		case Opcode::SLICE:
			s << "$slice " << r(rd) << " " << (int) sliceHigh << " " << (int) sliceLow << " " << r(rs2); break;
		case Opcode::LOAD:
			s << "$ld (" << type.name() << ") " << r(rd) << " [" << r(rs1) << " + "
			  << (immediate ? std::to_string(immValue) : r(rs2) + incr(increment)) << "]"; break;
		case Opcode::STORE:
			s << "$st (" << type.name() << ") [" << r(rs1) << " + "
			  << (immediate ? std::to_string(immValue) : r(rs2) + incr(increment)) << "] " << r(rd); break;
		default:
			if (isVector)
				s << "$v " << opcodeName(opcode) << " " << r(rd) << " (" << type.name() << ") " << r(rs1) << " " << r(rs2)
				  << (flag ? " $replicate" : "");
			else
				s << opcodeName(opcode) << " " << r(rd) << " (" << type.name() << ") " << r(rs1) << " "
				  << (immediate ? std::to_string(immValue) : r(rs2));
			break;
	}
	return s.str();
}

}
