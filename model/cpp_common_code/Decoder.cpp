//Decoder.cpp

//Decodes the 32 bit instruction to return an Opcode
//The instruction Register and its bit fields are described in Registers.h
//The Opcodes are enumerated in Opcodes.h


#include"Decoder.h"
#include"Opcodes.h"
#include"Registers.h"
#include<cassert>



//Decoding Scheme:(Refer to Appendix F of Sparc V8 manual)
//
//op Encoding (All Formats)
//	op  Format      Instructions
//	 0  2	        Bicc, FBfcc, CBccc, SETHI
//	 1  1	        CALL
//	 2  3	        arithmetic, logical, shift, and remaining
//	 3  3	        memory instructions


//op2 Encoding(Format 2 , when op==0)
//0 UNIMP
//1 unimplemented
//2 Bicc
//3 unimplemented
//4 SETHI
//5 unimplemented
//6 FBfcc
//7 CBccc



Opcode Decoder::decode(Registers * reg) //Table F-1 and F-2
{
	assert(reg!=NULL);
	switch(reg->R_op())
	{
		case 0: //Bicc, FBfcc, CBccc, SETHI
			{
				switch(reg->R_op2())
				{

					case 0:
						return UNIMP;
					case 1:
						return unimplemented;
					case 2:// Bicc : branch on Integer Condition codes
						return Decoder::decodeBicc(reg);
					case 3:// unimplemented
						return unimplemented;
					case 4:// SETHI or NOP
						{
							if (reg->R_rd()==0 && reg->R_imm22()==0)
								return NOP;
							else
								return SETHI;
						}
					case 5:// unimplemented
						return unimplemented;
					case 6:// FBfcc
						return Decoder::decodeFBfcc(reg);
					case 7:// CBccc
						return CBccc; //Decoder::decodeCBccc(reg);
				};
				break;
			}
		case 1:	//CALL
			{ return CALL; break; }
		case 2://arithmetic, logical, shift, and remaining
			{ return Decoder::decodeArith(reg); break; }
		case 3://memory instructions
			{ return Decoder::decodeLoadStore(reg); break; }
		default:
			{ assert(0); return UNIMP ; }
	};
	assert(0);
	return unassigned;
};







//(op== 2):arithmetic, logical, shift, and remaining
Opcode Decoder::decodeArith(Registers * reg) //Table F-3
{

	//SCHEME:

	//op3<5:4>->0	  1	  2			3
	//op3<3:0>
	//0	  ADD	  ADDcc	  TADDcc		  WRASR† WRY‡
	//1       AND     ANDcc   TSUBcc                  WRPSR
	//2       OR      ORcc    TADDccTV                WRWIM
	//3       XOR     XORcc   TSUBccTV                WRTBR
	//4       SUB     SUBcc   MULScc                  FPop1 See Table F-5 
	//5       ANDN    ANDNcc  SLL                     FPop2 See Table F-6 
	//6       ORN     ORNcc   SRL                     CPop1 
	//7       XNOR    XNORcc  SRA                     CPop2 
	//8       ADDX    ADDXcc  RDASR* RDY** STBAR***   JMPL
	//9                       RDPSR                   RETT 
	//A       UMUL    UMULcc  RDWIM                   Ticc See Table F-7 
	//B       SMUL    SMULcc  RDTBR                   FLUSH 
	//C       SUBX    SUBXcc                          SAVE
	//D                                               RESTORE
	//E       UDIV    UDIVcc
	//F       SDIV    SDIVcc
	//
	//† rd != 0
	//‡ rd = 0
	//* rs1 != 0
	//** rs1 = 0
	//*** rs1 = 15, rd = 0


	switch(reg->R_op3())
	{

		case 0x00: return    ADD ;
		case 0x01: return    AND ;
		case 0x02: return    OR  ;
		case 0x03: return    XOR ;
		case 0x04: return    SUB ;
		case 0x05: return    ANDN;
		case 0x06: return    ORN ;
		case 0x07: return    XNOR;
		case 0x08: return    ADDX;
		case 0x09: return    unassigned;
		case 0x0A: return    UMUL;
		case 0x0B: return    SMUL;
		case 0x0C: return    SUBX;
		case 0x0D: return    unassigned;
		case 0x0E: return    UDIV;
		case 0x0F: return    SDIV;

		case 0x10: return    ADDcc ;
		case 0x11: return    ANDcc ;
		case 0x12: return    ORcc  ;
		case 0x13: return    XORcc ;
		case 0x14: return    SUBcc ;
		case 0x15: return    ANDNcc;
		case 0x16: return    ORNcc ;
		case 0x17: return    XNORcc;
		case 0x18: return    ADDXcc;
		case 0x19: return    unassigned;
		case 0x1A: return    UMULcc;
		case 0x1B: return    SMULcc;
		case 0x1C: return    SUBXcc;
		case 0x1D: return    unassigned;
		case 0x1E: return    UDIVcc;
		case 0x1F: return    SDIVcc;

		case 0x20: return    TADDcc ;
		case 0x21: return    TSUBcc;
		case 0x22: return    TADDccTV;
		case 0x23: return    TSUBccTV ;
		case 0x24: return    MULScc;          
		case 0x25: return    SLL;                  
		case 0x26: return    SRL;                  
		case 0x27: return    SRA;                  
		case 0x28: {
				   if(reg->R_rs1()==15 && reg->R_rd()==0) return STBAR;
				   else if(reg->R_rs1()==0) return RDY;
				   else return    RDASR;
			   };
		case 0x29: return    RDPSR;                
		case 0x2A: return    RDWIM;                
		case 0x2B: return    RDTBR;                
		case 0x2C: return    unassigned;                     
		case 0x2D: return    unassigned;                     
		case 0x2E: return    unassigned; 
		case 0x2F: return    unassigned;

		case 0x30: {
				   if(reg->R_rd()==0) return WRY;
				   else return WRASR; 
			   };
		case 0x31: return    WRPSR;
		case 0x32: return    WRWIM; 
		case 0x33: return    WRTBR; 
		case 0x34: return    Decoder::decodeFPop1(reg); //See Table F-5 
		case 0x35: return    Decoder::decodeFPop2(reg); //See Table F-6 
		case 0x36: return    CPop1; 
		case 0x37: return    CPop2; 
		case 0x38: return    JMPL;
		case 0x39: return    RETT; 
		case 0x3A: return    Decoder::decodeTicc(reg); //See Table F-7 
		case 0x3B: return    FLUSH; 
		case 0x3C: return    SAVE;
		case 0x3D: return    RESTORE;
		case 0x3E: return    unassigned;
		case 0x3F: return    unassigned;
		default : assert(0); return   unassigned;

	}

};


Opcode Decoder::decodeFPop1(Registers * reg) //Table F-5
{
	switch(reg->R_opf())  //opf is 9 bits
	{

		case 0x01 : return FMOVs	;	
		case 0x05 : return FNEGs        ;
		case 0x09 : return FABSs        ;
		case 0x29 : return FSQRTs       ;
		case 0x2A : return FSQRTd       ;
		case 0x2B : return FSQRTq       ;
		case 0x41 : return FADDs        ;
		case 0x42 : return FADDd        ;
		case 0x43 : return FADDq        ;
		case 0x45 : return FSUBs        ;
		case 0x46 : return FSUBd        ;
		case 0x47 : return FSUBq        ;
		case 0x49 : return FMULs        ;
		case 0x4A : return FMULd        ;
		case 0x4B : return FMULq        ;
		case 0x4D : return FDIVs        ;
		case 0x4E : return FDIVd        ;
		case 0x4F : return FDIVq        ;
		case 0x69 : return FsMULd       ;
		case 0x6E : return FdMULq       ;
		case 0xC4 : return FiTOs        ;
		case 0xC6 : return FdTOs        ;
		case 0xC7 : return FqTOs        ;
		case 0xC8 : return FiTOd        ;
		case 0xC9 : return FsTOd        ;
		case 0xCB : return FqTOd        ;
		case 0xCC : return FiTOq        ;
		case 0xCD : return FsTOq        ;
		case 0xCE : return FdTOq        ;
		case 0xD1 : return FsTOi        ;
		case 0xD2 : return FdTOi        ;
		case 0xD3 : return FqTOi        ;
		default: return unimplemented	;
	};
};



Opcode Decoder::decodeFPop2(Registers * reg) //Table F-6
{
	switch(reg->R_opf())  //opf is 9 bits
	{

		case 0x51 : return FCMPs        ;	
		case 0x52 : return FCMPd        ;
		case 0x53 : return FCMPq        ;
		case 0x55 : return FCMPEs       ;
		case 0x56 : return FCMPEd       ;
		case 0x57 : return FCMPEq       ;
		default: return unimplemented	;
	};
};







//(op== 2):arithmetic, logical, shift, and remaining
Opcode Decoder::decodeLoadStore(Registers * reg) //Table F-4
{

	//SCHEME:

	//op<5:4>->0	  1	  2		3
	//op<3:0>
	 //0	  LD         LDA    LDF        LDC
	//1       LDUB       LDUBA  LDFSR      LDCSR
	//2       LDUH       LDUHA             
	//3       LDD        LDDA   LDDF       LDDC 
	//4       ST         STA    STF        STC 
	//5       STB        STBA   STFSR      STCSR
	//6       STH        STHA   STDFQ      STDCQ
	//7       STD        STDA   STDF       STDC
	//8                                    
	//9       LDSB       LDSBA             
	//A       LDSH       LDSHA             
	//B                                    
	//C                                    
	//D       LDSTUB     LDSTUBA           
	//E                         
	//F       SWAP       SWAPA  

	switch(reg->R_op3())
	{

		case 0x00: return    LD				;
		case 0x01: return    LDUB			;
		case 0x02: return    LDUH			;
		case 0x03: return    LDD			;
		case 0x04: return    ST				;
		case 0x05: return    STB			;
		case 0x06: return    STH			;
		case 0x07: return    STD			;
		case 0x08: return    unassigned			;
		case 0x09: return    LDSB			;
		case 0x0A: return    LDSH			;
		case 0x0B: return    unassigned			;
		case 0x0C: return    unassigned			;
		case 0x0D: return    LDSTUB			;
		case 0x0E: return    unassigned			;
		case 0x0F: return    SWAP			;

		case 0x10: return    LDA			;
		case 0x11: return    LDUBA			;
		case 0x12: return    LDUHA			;
		case 0x13: return    LDDA			;
		case 0x14: return    STA			;
		case 0x15: return    STBA			;
		case 0x16: return    STHA			;
		case 0x17: return    STDA			;
		case 0x18: return    unassigned			;
		case 0x19: return    LDSBA			;
		case 0x1A: return    LDSHA			;
		case 0x1B: return    unassigned			;
		case 0x1C: return    unassigned			;
		case 0x1D: return    LDSTUBA			;
		case 0x1E: return    unassigned			;
		case 0x1F: return    SWAPA			;

		case 0x20: return    LDF			;
		case 0x21: return    LDFSR			;
		case 0x22: return    unassigned			;
		case 0x23: return    LDDF			;
		case 0x24: return    STF			;
		case 0x25: return    STFSR			;
		case 0x26: return    STDFQ			;
		case 0x27: return    STDF			;
		case 0x28: return    unassigned			;
		case 0x29: return    unassigned			;
		case 0x2A: return    unassigned			;
		case 0x2B: return    unassigned			;
		case 0x2C: return    unassigned			;
		case 0x2D: return    unassigned			;
		case 0x2E: return    unassigned			;
		case 0x2F: return    unassigned			;

		case 0x30: return 	LDC			;
		case 0x31: return       LDCSR			;
		case 0x32: return    unassigned			;
		case 0x33: return       LDDC			;
		case 0x34: return       STC			;
		case 0x35: return       STCSR			;
		case 0x36: return       STDCQ			;
		case 0x37: return       STDC			;
		case 0x38: return    unassigned			;
		case 0x39: return    unassigned			;
		case 0x3A: return    unassigned			;
		case 0x3B: return    unassigned			;
		case 0x3C: return    unassigned			;
		case 0x3D: return    unassigned			;
		case 0x3E: return    unassigned			;
		case 0x3F: return    unassigned			;
		default : assert (0);
	};

	return unassigned ;
};


//Functions to decode sub-types of instructions when op==0

Opcode Decoder::decodeBicc (Registers * reg)//op=0 op2=2
{
	switch(reg->R_cond()) //cond is 4 bits
	{
	case 0x0: return	BN	;
	case 0x1: return	BE      ;
	case 0x2: return	BLE     ;
	case 0x3: return	BL      ;
	case 0x4: return	BLEU    ;
	case 0x5: return	BCS     ;
	case 0x6: return	BNEG    ;
	case 0x7: return	BVS     ;
	case 0x8: return	BA      ;
	case 0x9: return	BNE     ;
	case 0xA: return	BG      ;
	case 0xB: return	BGE     ;
	case 0xC: return	BGU     ;
	case 0xD: return	BCC     ;
	case 0xE: return	BPOS    ;
	case 0xF: return	BVC     ;
	default : assert (0);
	};

	return  unassigned;
};

Opcode Decoder::decodeFBfcc(Registers * reg)//op=0 op2=6
{
	switch(reg->R_cond()) //cond is 4 bits
	{
	case 0x0: return	FBN	;
	case 0x1: return	FBNE    ;
	case 0x2: return	FBLG    ;
	case 0x3: return	FBUL    ;
	case 0x4: return	FBL     ;
	case 0x5: return	FBUG    ;
	case 0x6: return	FBG     ;
	case 0x7: return	FBU     ;
	case 0x8: return	FBA     ;
	case 0x9: return	FBE     ;
	case 0xA: return	FBUE    ;
	case 0xB: return	FBGE    ;
	case 0xC: return	FBUGE   ;
	case 0xD: return	FBLE    ;
	case 0xE: return	FBULE   ;
	case 0xF: return	FBO     ;
	default : assert (0);
	};

	return unassigned;
};

Opcode Decoder::decodeCBccc(Registers * reg)//op=0 op2=7
{
	switch(reg->R_cond()) //cond is 4 bits
	{
	case 0x0: return	CB123	;
	case 0x1: return	CB12	;
	case 0x2: return	CB13	;
	case 0x3: return	CB1	;
	case 0x4: return	CB23	;
	case 0x5: return	CB2	;
	case 0x6: return	CB3	;
	case 0x7: return	CBA	;
	case 0x8: return	CB0	;
	case 0x9: return	CB03	;
	case 0xA: return	CB02	;
	case 0xB: return	CB023	;
	case 0xC: return	CB01	;
	case 0xD: return	CB013	;
	case 0xE: return	CB012	;
	case 0xF: return	CBN	;
	default : assert(0);
	};
	return unassigned;

};

Opcode Decoder::decodeTicc(Registers * reg)//op=2 op3=0x3A
{
	switch(reg->R_cond()) //cond is 4 bits
	{
	case 0x0: return	TN  ;
	case 0x1: return	TE  ;
	case 0x2: return	TLE ;
	case 0x3: return	TL  ;
	case 0x4: return	TLEU;
	case 0x5: return	TCS ;
	case 0x6: return	TNEG;
	case 0x7: return	TVS ;
	case 0x8: return	TA  ;
	case 0x9: return	TNE ;
	case 0xA: return	TG  ;
	case 0xB: return	TGE ;
	case 0xC: return	TGU ;
	case 0xD: return	TCC ;
	case 0xE: return	TPOS;
	case 0xF: return	TVC ;
	default : assert(0); return unassigned;
	};

	return unassigned;
};
		


