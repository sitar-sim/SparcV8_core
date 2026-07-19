//Registers.h

//Implements all registers, aliases, constants and 
//internal signals in the Sparc Core

#ifndef REGISTERS_H
#define REGISTERS_H

#include"BitManipulation.h" //describes functions for bit manipulations in registers
#include"ImplementationDependent.h"
#include<cassert>
#include<stdint.h>


//Number of window registers in the implementation of Sparc V8
//(NWIMDOWS) is defined in implementationDependent.h

class Registers
{
	public:
	//Instruction Unit(IU) General Purpose Registers
	uint32_t G[8]; 			//Global Registers
	uint32_t R[16*NWINDOWS]; 	//Windowed Registers


	//Instruction Register - holds the current instruction
	uint32_t instruction;

	//Instruction Unit(IU) Status/Control registers
	uint32_t PSR; //Program Status Register
	uint32_t TBR; //Trap Base Register
	uint32_t WIM; //Window Invalid Mask Register
	uint32_t Y;   //Y Register
	uint32_t PC;  //Program Counter
	uint32_t nPC; //next Program Counter


	//Ancillary
	uint32_t ASR[32]; //Ancillary State Register
	//***********************************************
	//NOTE: in multiprocessor configuration, 
	//	ASR[31] is hardwired to store core ID and
	//	ASR[30] is hardwired to store processor ID 
	//***********************************************
	
	
	//Floating Point (FU) registers
	uint32_t FSR; //Floating point state Register
	uint32_t f[32]; //general purpose Floating point registers 


	//Floating point operation status indicators:
	// single, double and quad results:
	uint32_t sresult;
	uint32_t dresult[2];
	uint32_t qresult[4];
	bool     fpu_single_result;
	bool     fpu_double_result;
	bool     fpu_quad_result;
	bool     fpu_compare;


	uint32_t texc; //5 bit
	uint32_t tfcc; //2 bit
	uint32_t fpu_c; //completion status bit




	//Coprocessor register
	uint32_t CSR;



	//Interface signals
	uint32_t bp_IRL; 		
	uint32_t bp_reset_in;		
	uint32_t bp_FPU_present;	
	uint32_t bp_FPU_exception; 	
	uint32_t bp_FPU_cc; 		
	uint32_t bp_CP_present ; 	
	uint32_t bp_CP_exception; 	
	uint32_t bp_CP_cc;		

	uint32_t pb_block_ldst_word;	
	uint32_t pb_error;		
	uint32_t pb_block_ldst_byte;	




	public:

	//Constants
	static const uint32_t r0=0;
	static const uint32_t IEEE_754_exception = 1; //{ Floating-point trap types }
	static const uint32_t unfinished_FPop = 2;
	static const uint32_t unimplemented_FPop = 3;
	static const uint32_t sequence_error = 4;
	static const uint32_t hardware_error = 5;
	static const uint32_t invalid_fp_register = 6;







	public:	

	//Register Fields and methods to read/write to them



	//General purpose r(n) Windowed Registers
	inline uint32_t R_r(uint32_t n)
	{
		assert(n<32);
		if(n==0)
			return r0;
		else if(n>=1 && n<=7)
			return G[n];
		else
			return R[((n-8)+(R_CWP()*16))%(16*NWINDOWS)];
	};

	inline void W_r(uint32_t n, uint32_t value)
	{
		assert(n<32);
		if(n==0)
			return;
		else 
			if(n>=1 && n<=7)
				G[n]=value;
			else
				R[((n-8)+(R_CWP()*16))%(16*NWINDOWS)]=value;
	};

	//ASR registers
	inline uint32_t R_ASR(uint32_t n) { assert(n<32); return ASR[n]; };
	inline void W_ASR(uint32_t n, uint32_t value) { if (n<32) ASR[n]=value; else assert(0);};


	//CSR registers
	inline uint32_t R_CSR() 	{return CSR;};
	inline void W_CSR(uint32_t val)	{ CSR=val;};



	//General purpose f(n) Floating point Registers
	inline uint32_t R_f(unsigned int n)
	{
		assert(n<32);
		return f[n];
	};

	inline void W_f(unsigned int n, uint32_t value)
	{
		assert(n<32);
		f[n]=value;
	};



	//1. PSR and its bit fields	
	//Read methods
	inline uint32_t R_PSR()  {return PSR;}; static const int size_PSR=32;
	inline uint32_t R_impl() {return readBits(PSR, 31,28); };  static const int size_impl=4;
	inline uint32_t R_ver()  {return readBits(PSR, 27,24); };  static const int size_ver=4;
	inline uint32_t R_icc()  {return readBits(PSR, 23,20); };  static const int size_icc=4;
	inline uint32_t R_N()    {return readBits(PSR, 23,23); };  static const int size_N=1;
	inline uint32_t R_Z()    {return readBits(PSR, 22,22); };  static const int size_Z=1;
	inline uint32_t R_V()    {return readBits(PSR, 21,21); };  static const int size_V=1;
	inline uint32_t R_C()    {return readBits(PSR, 20,20); };  static const int size_C=1;
	inline uint32_t R_reserved_PSR()    {return readBits(PSR, 19,14); }; 	static const int size_reserved_PSR=5;
	inline uint32_t R_EC()  {return readBits(PSR, 13,13); };  static const int size_EC =1;
	inline uint32_t R_EF()  {return readBits(PSR, 12,12); };  static const int size_EF =1;
	inline uint32_t R_PIL() {return readBits(PSR, 11,8 ); };  static const int size_PIL=4;
	inline uint32_t R_S()   {return readBits(PSR, 7 ,7 ); };  static const int size_S  =1;
	inline uint32_t R_PS()  {return readBits(PSR, 6 ,6 ); };  static const int size_PS =1;
	inline uint32_t R_ET()  {return readBits(PSR, 5 ,5 ); };  static const int size_ET =1;
	inline uint32_t R_CWP() {return readBits(PSR, 4 ,0 ); };  static const int size_CWP=5;
	//Write methods
	inline void W_PSR( uint32_t val) { PSR=val; };      
	inline void W_impl(uint32_t val) { writeBits(PSR, 31,28, val); };
	inline void W_ver (uint32_t val) { writeBits(PSR, 27,24, val); };
	inline void W_icc (uint32_t val) { writeBits(PSR, 23,20, val); };
	inline void W_N   (uint32_t val) { writeBits(PSR, 23,23, val); };
	inline void W_Z   (uint32_t val) { writeBits(PSR, 22,22, val); };
	inline void W_V   (uint32_t val) { writeBits(PSR, 21,21, val); };
	inline void W_C   (uint32_t val) { writeBits(PSR, 20,20, val); };
	inline void W_reserved_PSR (uint32_t val) { writeBits(PSR, 19,14, val); };
	inline void W_EC  (uint32_t val) { writeBits(PSR, 13,13 , val); };
	inline void W_EF  (uint32_t val) { writeBits(PSR, 12,12 , val); };
	inline void W_PIL (uint32_t val) { writeBits(PSR, 11,8  , val); };
	inline void W_S   (uint32_t val) { writeBits(PSR, 7 ,7  , val); };
	inline void W_PS  (uint32_t val) { writeBits(PSR, 6 ,6  , val); };
	inline void W_ET  (uint32_t val) { writeBits(PSR, 5 ,5  , val); };
	inline void W_CWP (uint32_t val) { writeBits(PSR, 4 ,0  , val); };

	//2. TBR and its fields
	//Read methods
	inline uint32_t R_TBR()  {return TBR;}; static const int size_TBR=32;
	inline uint32_t R_TBA()  {return readBits(TBR, 31,12); };  static const int size_TBA=20;
	inline uint32_t R_tt()   {return readBits(TBR, 11,4 ); };  static const int size_tt=8;  
	inline uint32_t R_zero() {return readBits(TBR, 3 ,0 ); };  static const int size_zero=4;
	//Write methods
	inline void W_TBR	 (uint32_t val) { TBR=val; };
	inline void W_TBA	 (uint32_t val) { writeBits(TBR, 31,12, val); };
	inline void W_tt     (uint32_t val) { writeBits(TBR, 11,4 , val); };
	inline void W_zero 	 (uint32_t val) { writeBits(TBR, 3 ,0 , val); };




	//3. Instruction Register and its bit fields
	//Read methods
	inline uint32_t R_instruction() {return instruction;}; static const int size_instruction=32;
	inline uint32_t R_op()   	{return readBits(instruction, 31,30); };  static const int size_op=2;
	inline uint32_t R_op2()  	{return readBits(instruction, 24,22); };  static const int size_op2=3;
	inline uint32_t R_op3()  	{return readBits(instruction, 24,19); };  static const int size_op3=6;
	inline uint32_t R_opf()  	{return readBits(instruction, 13,5 ); };  static const int size_opf    =9;
	inline uint32_t R_opc()  	{return readBits(instruction, 13,5 ); };  static const int size_opc    =9;
	inline uint32_t R_asi()  	{return readBits(instruction, 12,5 ); };  static const int size_asi    =8;
	inline uint32_t R_i()  		{return readBits(instruction, 13,13); };  static const int size_i      =1;
	inline uint32_t R_rd()  	{return readBits(instruction, 29,25); };  static const int size_rd     =5;
	inline uint32_t R_a()  		{return readBits(instruction, 29,29); };  static const int size_a      =1;
	inline uint32_t R_cond()  	{return readBits(instruction, 28,25); };  static const int size_cond   =4;
	inline uint32_t R_rs1()  	{return readBits(instruction, 18,14); };  static const int size_rs1    =5;
	inline uint32_t R_rs2()  	{return readBits(instruction, 4 ,0 ); };  static const int size_rs2    =5;
	inline uint32_t R_simm13()  	{return readBits(instruction, 12,0 ); };  static const int size_simm13 =13;
	inline uint32_t R_shcnt()  	{return readBits(instruction, 4 ,0 ); };  static const int size_shcnt  =5;
	inline uint32_t R_disp30()  	{return readBits(instruction, 29,0 ); };  static const int size_disp30 =30;
	inline uint32_t R_disp22()  	{return readBits(instruction, 21,0 ); };  static const int size_disp22 =22;
	inline uint32_t R_imm22()   	{return readBits(instruction, 21,0 ); };  static const int size_imm22  =22;
	inline uint32_t R_software_trap() {return readBits(instruction, 6,0  ); };  static const int size_software_trap=7;
	//Write methods
	inline void W_instruction ( uint32_t val) { instruction=val; };      
	inline void W_op (uint32_t val) 	{ writeBits(instruction, 31,30, val); };
	inline void W_op2(uint32_t val)  	{ writeBits(instruction, 24,22, val); };  
	inline void W_op3(uint32_t val)  	{ writeBits(instruction, 24,19, val); };  
	inline void W_opf(uint32_t val)  	{ writeBits(instruction, 13,5 , val); };  
	inline void W_opc(uint32_t val)  	{ writeBits(instruction, 13,5 , val); };  
	inline void W_asi(uint32_t val)  	{ writeBits(instruction, 12,5 , val); };  
	inline void W_i(uint32_t val)  	{ writeBits(instruction, 13,13, val); };  
	inline void W_rd(uint32_t val)  	{ writeBits(instruction, 29,25, val); };  
	inline void W_a(uint32_t val)  	{ writeBits(instruction, 29,29, val); };  
	inline void W_cond(uint32_t val)  	{ writeBits(instruction, 28,25, val); };  
	inline void W_rs1(uint32_t val)  	{ writeBits(instruction, 18,14, val); };  
	inline void W_rs2(uint32_t val)  	{ writeBits(instruction, 4 ,0 , val); };  
	inline void W_simm13(uint32_t val)  { writeBits(instruction, 12,0 , val); };  
	inline void W_shcnt(uint32_t val)  	{ writeBits(instruction, 4 ,0 , val); };  
	inline void W_disp30(uint32_t val)  { writeBits(instruction, 29,0 , val); };  
	inline void W_disp22(uint32_t val)  { writeBits(instruction, 21,0 , val); };  
	inline void W_imm22 (uint32_t val)  { writeBits(instruction, 21,0 , val); };  
	inline void W_software_trap(uint32_t val) { writeBits(instruction, 6,0  , val); };  



	//4. Read write methods for other Registers
	//Read methods
	inline uint32_t R_WIM() {return WIM;}; static const int size_WIM=32;
	inline uint32_t R_Y()   {return Y;}; static const int size_Y=32;
	inline uint32_t R_PC()  {return PC;}; static const int size_PC=32;
	inline uint32_t R_nPC() {return nPC;}; static const int size_nPC=32;
	//Write methods
	inline void W_WIM(uint32_t val)	 
	{
		//Note: bits corresponding to unimplemented windows read as 0
		//and writes to these bits is ignored.
		uint32_t n; 		//all ones
		n=(~ ((~0)<<NWINDOWS) );   	//clear low nwindow bits
		val=val&n;
		WIM=val;
	};
	inline void W_Y(uint32_t val)	 {Y  =val;};
	inline void W_PC(uint32_t val)	 {PC =val;};
	inline void W_nPC(uint32_t val)	 {nPC=val;};



	//5. Interface signals
	//Read methods
	inline uint32_t R_bp_IRL()		{return readBits(bp_IRL 	   , 3,0); };  static const int size_bp_IRL=4; //4bit
	inline uint32_t R_bp_reset_in()		{return readBits(bp_reset_in	   , 0,0); };  static const int size_bp_reset_in=1; 
	inline uint32_t R_bp_FPU_present()	{return readBits(bp_FPU_present	   , 0,0); };  static const int size_FPU_present=1;	 
	inline uint32_t R_bp_FPU_exception()	{return readBits(bp_FPU_exception  , 0,0); };  static const int size_FPU_exception=1; 	 
	inline uint32_t R_bp_FPU_cc()		{return readBits(bp_FPU_cc 	   , 1,0); };  static const int size_FPU_cc=2; 	 //2 bit
	inline uint32_t R_bp_CP_present ()	{return readBits(bp_CP_present     , 0,0); };  static const int size_CP_present=1 ; 	 
	inline uint32_t R_bp_CP_exception()	{return readBits(bp_CP_exception   , 0,0); };  static const int size_CP_exception=1; 	 
	inline uint32_t R_bp_CP_cc()		{return readBits(bp_CP_cc	   , 1,0); };  static const int size_CP_cc=2;		  //2 bit
	inline uint32_t R_pb_block_ldst_word()	{return readBits(pb_block_ldst_word, 0,0); };  static const int size_pb_block_ldst_word=1; 
	inline uint32_t R_pb_error()		{return readBits(pb_error	   , 0,0); };  static const int size_pb_error=1; 
	inline uint32_t R_pb_block_ldst_byte()	{return readBits(pb_block_ldst_byte, 0,0); };  static const int size_block_ldst_byte=1;	
	//Write methods
	inline void W_bp_IRL(uint32_t val)		{writeBits(bp_IRL 		, 3,0, val); };  
	inline void W_bp_reset_in(uint32_t val)		{writeBits(bp_reset_in	   	, 0,0, val); };  
	inline void W_bp_FPU_present(uint32_t val)	{writeBits(bp_FPU_present	, 0,0, val); };  
	inline void W_bp_FPU_exception(uint32_t val)	{writeBits(bp_FPU_exception  	, 0,0, val); };  
	inline void W_bp_FPU_cc(uint32_t val)		{writeBits(bp_FPU_cc 	   	, 1,0, val); };  
	inline void W_bp_CP_present (uint32_t val)	{writeBits(bp_CP_present     	, 0,0, val); };  
	inline void W_bp_CP_exception(uint32_t val)	{writeBits(bp_CP_exception   	, 0,0, val); };  
	inline void W_bp_CP_cc(uint32_t val)		{writeBits(bp_CP_cc	   	, 1,0, val); };  
	inline void W_pb_block_ldst_word(uint32_t val)	{writeBits(pb_block_ldst_word	, 0,0, val); };  
	inline void W_pb_error(uint32_t val)		{writeBits(pb_error	   	, 0,0, val); };  
	inline void W_pb_block_ldst_byte(uint32_t val)	{writeBits(pb_block_ldst_byte	, 0,0, val); };  


	//6. FSR and its bit fields
	//Read methods
	inline uint32_t R_FSR() 	{return FSR;};
	inline uint32_t R_RD()		{return readBits(FSR, 31,30);};
	inline uint32_t R_unused0()	{return readBits(FSR, 29,28);};
	inline uint32_t R_TEM()		{return readBits(FSR, 27,23);};
	inline uint32_t R_NVM()		{return readBits(FSR, 27,27);};
	inline uint32_t R_OFM()		{return readBits(FSR, 26,26);};
	inline uint32_t R_UFM()		{return readBits(FSR, 25,25);};
	inline uint32_t R_DZM()		{return readBits(FSR, 24,24);};
	inline uint32_t R_NXM()		{return readBits(FSR, 23,23);};
	inline uint32_t R_NS()		{return readBits(FSR, 22,22);};
	inline uint32_t R_reserved_FSR(){return readBits(FSR, 21,20);};
	inline uint32_t R_FSRver()	{return readBits(FSR, 19,17);};
	inline uint32_t R_ftt()		{return readBits(FSR, 16,14);};
	inline uint32_t R_qne()		{return readBits(FSR, 13,13);};
	inline uint32_t R_unused1()	{return readBits(FSR, 12,12);};
	inline uint32_t R_fcc()		{return readBits(FSR, 11,10);};
	inline uint32_t R_aexc()	{return readBits(FSR, 9,5);};
	inline uint32_t R_nva()		{return readBits(FSR, 9,9);};
	inline uint32_t R_ofa()		{return readBits(FSR, 8,8);};
	inline uint32_t R_ufa()		{return readBits(FSR, 7,7);};
	inline uint32_t R_dza()		{return readBits(FSR, 6,6);};
	inline uint32_t R_nxa()		{return readBits(FSR, 5,5);};
	inline uint32_t R_cexc()	{return readBits(FSR, 4,0);};
	inline uint32_t R_nvc()		{return readBits(FSR, 4,4);};
	inline uint32_t R_ofc()		{return readBits(FSR, 3,3);};
	inline uint32_t R_ufc()		{return readBits(FSR, 2,2);};
	inline uint32_t R_dzc()		{return readBits(FSR, 1,1);};
	inline uint32_t R_nxc()		{return readBits(FSR, 0,0);};
	//Write methods
	inline void W_FSR(uint32_t val)		{ FSR=val;};
	inline void W_RD(uint32_t val)		{ writeBits(FSR,  31,30,val); };
	inline void W_unused0(uint32_t val)	{ writeBits(FSR,  29,28,val); };
	inline void W_TEM(uint32_t val)		{ writeBits(FSR,  27,23,val); };
	inline void W_NVM(uint32_t val)		{ writeBits(FSR,  27,27,val); };
	inline void W_OFM(uint32_t val)		{ writeBits(FSR,  26,26,val); };
	inline void W_UFM(uint32_t val)		{ writeBits(FSR,  25,25,val); };
	inline void W_DZM(uint32_t val)		{ writeBits(FSR,  24,24,val); };
	inline void W_NXM(uint32_t val)		{ writeBits(FSR,  23,23,val); };
	inline void W_NS (uint32_t val)		{ writeBits(FSR,  22,22,val); };
	inline void W_reserved_FSR(uint32_t val){ writeBits(FSR,  21,20,val); };
	inline void W_FSRver(uint32_t val)	{ writeBits(FSR,  19,17,val); };
	inline void W_ftt(uint32_t val)		{ writeBits(FSR,  16,14,val); };
	inline void W_qne(uint32_t val)		{ writeBits(FSR,  13,13,val); };
	inline void W_unused1(uint32_t val)	{ writeBits(FSR,  12,12,val); };
	inline void W_fcc(uint32_t val)		{ writeBits(FSR,  11,10,val); };
	inline void W_aexc(uint32_t val)	{ writeBits(FSR,  9 ,5 ,val); };
	inline void W_nva(uint32_t val)		{ writeBits(FSR,  9 ,9 ,val); };
	inline void W_ofa(uint32_t val)		{ writeBits(FSR,  8 ,8 ,val); }; 
	inline void W_ufa(uint32_t val)		{ writeBits(FSR,  7 ,7 ,val); }; 
	inline void W_dza(uint32_t val)		{ writeBits(FSR,  6 ,6 ,val); }; 
	inline void W_nxa(uint32_t val)		{ writeBits(FSR,  5 ,5 ,val); }; 
	inline void W_cexc(uint32_t val)	{ writeBits(FSR,  4 ,0 ,val); };
	inline void W_nvc(uint32_t val)		{ writeBits(FSR,  4 ,4 ,val); }; 
	inline void W_ofc(uint32_t val)		{ writeBits(FSR,  3 ,3 ,val); };
	inline void W_ufc(uint32_t val)		{ writeBits(FSR,  2 ,2 ,val); };
	inline void W_dzc(uint32_t val)		{ writeBits(FSR,  1 ,1 ,val); };
	inline void W_nxc(uint32_t val)		{ writeBits(FSR,  0 ,0 ,val); };

	//Other floating point related signals
	inline uint32_t R_texc()		{return readBits(texc, 4,0);};
	inline uint32_t R_tfcc()		{return readBits(tfcc, 1,0);};
	inline uint32_t R_fpu_c()		{return readBits(fpu_c, 0,0);};
	
	inline void W_texc(uint32_t val)	{ writeBits(texc,  4 ,0 ,val); };
	inline void W_tfcc(uint32_t val)	{ writeBits(tfcc,  1 ,0 ,val); };
	inline void W_fpu_c(uint32_t val)	{ writeBits(fpu_c,  0 ,0 ,val); };
	










	//Constructor
	Registers()
	{
		//Initialize all Registers;
		for(int i=0;i<8;i++) G[i]=0;
		for(int i=0;i<NWINDOWS*16;i++) R[i]=0;
		instruction=0; //Instruction reg
		PSR=0; //Program Status Register
		//set suoervisor mode
		W_S(1);
		//enable traps
		W_ET(1);


		TBR=0; //Trap Base Register
		WIM=0; //Window Invalid Mask Register
		Y=0;   //Y Register
		PC=0;  //Program Counter
		nPC=4; //next Program Counter


		//Floating Point (FU) registers
		FSR=0; //Floating point state Register
		for(int i=0;i<=31;i++) f[i]=0; //general purpose Floating point registers 

		sresult=0;
		for(int i=0;i<2;i++)dresult[i]=0;
		for(int i=0;i<4;i++)qresult[i]=0;
		fpu_single_result =0;
		fpu_double_result =0;
		fpu_quad_result =0;
		fpu_compare=0;
		texc = 0;
		tfcc = 0;
		fpu_c =0;




		//Interface signals
		bp_IRL=0; 		
		bp_reset_in=0;		
		bp_FPU_present=1;	
		bp_FPU_exception=0; 	
		bp_FPU_cc=0; 		
		bp_CP_present =0; 	
		bp_CP_exception=0; 	
		bp_CP_cc=0;		

		pb_block_ldst_word=0;	
		pb_error=0;		
		pb_block_ldst_byte=0;	

		//Ancillary
		for(int i=0;i<=31;i++) ASR[i]=0; //Ancillary State Register



	};


};

#endif

