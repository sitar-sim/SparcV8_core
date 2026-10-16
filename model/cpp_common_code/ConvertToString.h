//ConvertToString.h
//Original Author: Neha Karanjkar
//Model Author: Claude Opus 5.5 (high)
//The model code was adapted from a Sparc v8 core simulation model written
//by the first author in C++ and Sitar (2015-2017).
//
//Small helper functions for converting between data types.

#ifndef CONVERT_TO_STRING_H
#define CONVERT_TO_STRING_H

#include<sstream>
#include<string>

template <typename T> std::string ToString ( T Number )
{
	std::stringstream ss;
	ss << Number;
	return ss.str();
}

template <typename T> 
T FromString ( const std::string &Text )
{
	std::stringstream ss(Text);
	T result;
	ss >> result;
	return result;
}
#endif
