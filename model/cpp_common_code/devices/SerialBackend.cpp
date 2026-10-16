//SerialBackend.cpp
//Original Author: Neha Karanjkar
//Model Author: Claude Opus 5.5 (high)
//The model code was adapted from a Sparc v8 core simulation model written
//by the first author in C++ and Sitar (2015-2017).

#include "SerialBackend.h"
#include <cstdlib>
#include <fcntl.h>
#include <iostream>
#include <unistd.h>

std::unique_ptr<SerialBackend> makeSerialBackend(const SerialBackendConfig& config)
{
	switch (config.kind)
	{
		case SerialBackendConfig::Kind::FILES:
			return std::unique_ptr<SerialBackend>(
				new StreamSerialBackend(config.outputFile, config.inputFile));
		case SerialBackendConfig::Kind::PTY:
			return std::unique_ptr<SerialBackend>(new PtySerialBackend());
		case SerialBackendConfig::Kind::CONSOLE:
		default:
			return std::unique_ptr<SerialBackend>(
				new StreamSerialBackend(std::cout, config.inputFile));
	}
}

//----------------------------------------------------------------------
//StreamSerialBackend
//----------------------------------------------------------------------

StreamSerialBackend::StreamSerialBackend(std::ostream& out, const std::string& inputFile) :
	out_(&out), hasInput_(false)
{
	openInput(inputFile);
}

StreamSerialBackend::StreamSerialBackend(const std::string& outputFile, const std::string& inputFile) :
	ownedOut_(outputFile.c_str(), std::ios::binary | std::ios::trunc),
	out_(&ownedOut_),
	hasInput_(false)
{
	if (!ownedOut_.is_open())
		std::cerr << "\nWarning: SerialBackend: could not open output file " << outputFile;
	openInput(inputFile);
}

void StreamSerialBackend::openInput(const std::string& inputFile)
{
	if (inputFile.empty())
		return;
	in_.open(inputFile.c_str(), std::ios::binary);
	hasInput_ = in_.is_open();
	if (!hasInput_)
		std::cerr << "\nWarning: SerialBackend: could not open input file " << inputFile
		          << ", nothing will be received";
}

void StreamSerialBackend::writeByte(uint8_t byte)
{
	out_->put((char) byte);
	out_->flush(); //so output appears as the program produces it
}

bool StreamSerialBackend::tryReadByte(uint8_t& byte)
{
	if (!hasInput_)
		return false;

	char c;
	if (in_.get(c))
	{
		byte = (uint8_t) c;
		return true;
	}
	//End of file for now. Clear the EOF state so bytes appended later
	//are still read on a future call.
	in_.clear();
	return false;
}

//----------------------------------------------------------------------
//PtySerialBackend
//----------------------------------------------------------------------

PtySerialBackend::PtySerialBackend() : masterFd_(-1)
{
	masterFd_ = posix_openpt(O_RDWR | O_NOCTTY);
	bool ok = (masterFd_ >= 0);
	ok = ok && (grantpt(masterFd_) == 0);
	ok = ok && (unlockpt(masterFd_) == 0);
	const char* name = ok ? ptsname(masterFd_) : NULL;
	if (!name)
	{
		std::cerr << "\nError: SerialBackend: could not create a pseudo-terminal";
		std::exit(1);
	}
	slavePath_ = name;

	int flags = fcntl(masterFd_, F_GETFL, 0);
	fcntl(masterFd_, F_SETFL, flags | O_NONBLOCK);

	std::cerr << "\nSerial device: attach a terminal to " << slavePath_ << "\n";
}

PtySerialBackend::~PtySerialBackend()
{
	if (masterFd_ >= 0)
		close(masterFd_);
}

void PtySerialBackend::writeByte(uint8_t byte)
{
	//Best-effort: with nothing attached, the byte is simply dropped, the
	//same as real hardware transmitting with nothing listening.
	ssize_t n = write(masterFd_, &byte, 1);
	(void) n;
}

bool PtySerialBackend::tryReadByte(uint8_t& byte)
{
	return read(masterFd_, &byte, 1) == 1;
}
