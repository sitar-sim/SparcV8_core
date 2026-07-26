//MemCore.cpp

#include"MemCore.h"
#include"DebugRegistry.h"
#include<iostream>
#include<stdint.h>
#include<fstream>
#include<cstdlib>
#include<vector>
#include<sstream>


MemCore::MemCore()
{
	core.resize(nwords, 0);
	std::cout<<"\nTotal Main Memory size :0x"<<std::hex<<memSize<<std::dec;

	DebugRegistry::registerMemCore(this); //see DebugRegistry.h -- no-op
	                                       //unless built with --debug
};

//Initialize memory image by reading a text file
//the text file has format (\naddr, word, word, [word], ...)
bool MemCore::initializeMemory(std::string hex_dump_file)
{


	//open a file to read and initialize memory
	using namespace std;
	ifstream infile;
	infile.open(hex_dump_file.c_str(), ifstream::in);
	if(!infile.is_open())
	{
		cerr<<"\nERROR: MemCore.cpp: Could not open file for initializing memory";
		cerr<<"\nExiting Simulation";
		exit(EXIT_FAILURE);
	}
	string line;
	uint32_t addr=0;
	uint32_t word[4];
	unsigned int count=0;  //total number of words stored in memory
	cout<<"\nInitializing memory from hex-dump file...";

	while(infile.good())
	{
		getline(infile,line);
		if(!(line=="" || line ==" "))
		{
			stringstream ss;
			ss<<line;
			ss>>hex>>addr;
			for(int i=0;i<=3;i++)
				ss>>hex>>word[i];

			//write to memory
			for(int i=0;i<=3;i++)
			{
				core[(addr>>2)+i]=word[i];
				count++;
				//If we run out of available memory, stop storing
				//bytes into array
				if(count>=nwords && !infile.eof())
				{
					cerr<<"\nProgram size exceeds memory size of "<<memSize<<" bytes";
					break;
				};
			};
		};

	};
	cout<<"\nLast address written = "<<hex<<addr<<dec;
	infile.close();
	return true;

};


	
