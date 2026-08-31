//ConvertToString.h
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
