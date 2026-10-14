//SerialBackend.h
//
//Host-side I/O for the Serial device's serial_out/serial_in pins: where
//transmitted bytes go, and where received bytes come from. SerialCore
//talks to whichever backend it is given through the small abstract
//interface below, and never knows which one it is.
//
//The serial device's purpose in this model is to let a program display
//output and accept input, so three backends are provided, chosen at run
//time (Ref SerialBackendConfig below):
//
//  - CONSOLE (the default): transmitted bytes are written straight to
//    the simulator's own standard output. Received bytes come from an
//    optional input file. With no input file, nothing is ever received.
//  - FILES: transmitted bytes are appended to an output file, received
//    bytes come from an input file. Deterministic, for automated tests.
//  - PTY: a pseudo-terminal. Any terminal emulator can attach to the
//    slave device it prints, for interactive use in both directions.
//
//Input files are read one byte at a time from where the previous read
//stopped. Reaching the end of the file just means "no byte yet": bytes
//appended to the file later are still picked up.

#ifndef SERIAL_BACKEND_H
#define SERIAL_BACKEND_H

#include <stdint.h>
#include <fstream>
#include <memory>
#include <ostream>
#include <string>

class SerialBackend
{
	public:
		virtual ~SerialBackend() {}

		//Sends one byte out on serial_out.
		virtual void writeByte(uint8_t byte) = 0;

		//Non-blocking. Returns false if no byte is available right now.
		virtual bool tryReadByte(uint8_t& byte) = 0;
};

//Which backend to construct, and with what files. Built from the
//simulator's command line by whichever driver is running.
struct SerialBackendConfig
{
	enum class Kind { CONSOLE, FILES, PTY };

	Kind        kind = Kind::CONSOLE;
	std::string inputFile;  //CONSOLE (optional) and FILES: received bytes
	std::string outputFile; //FILES only: transmitted bytes
};

std::unique_ptr<SerialBackend> makeSerialBackend(const SerialBackendConfig& config);

//Transmits to an output stream (standard output, or a file it opens and
//owns), receives from an optional input file. Implements both CONSOLE
//and FILES.
class StreamSerialBackend : public SerialBackend
{
	public:
		//Transmits to the given stream, which must outlive this object
		//(e.g. std::cout).
		StreamSerialBackend(std::ostream& out, const std::string& inputFile);

		//Transmits to outputFile, truncated first so a test can check
		//exactly what this run wrote.
		StreamSerialBackend(const std::string& outputFile, const std::string& inputFile);

		void writeByte(uint8_t byte) override;
		bool tryReadByte(uint8_t& byte) override;

	private:
		void openInput(const std::string& inputFile);

		std::ofstream ownedOut_; //used only by the file constructor
		std::ostream* out_;
		std::ifstream in_;
		bool          hasInput_;
};

//Wraps another backend, passing every byte through unchanged, and also
//keeps a copy of every byte transmitted, so a driver can check a
//program's serial output after the run (Ref a .vprj's serial_out line).
class RecordingSerialBackend : public SerialBackend
{
	public:
		explicit RecordingSerialBackend(std::unique_ptr<SerialBackend> inner) : inner_(std::move(inner)) {}

		void writeByte(uint8_t byte) override { transmitted_.push_back((char) byte); inner_->writeByte(byte); }
		bool tryReadByte(uint8_t& byte) override { return inner_->tryReadByte(byte); }

		const std::string& transmitted() const { return transmitted_; }

	private:
		std::unique_ptr<SerialBackend> inner_;
		std::string                    transmitted_;
};

//A pseudo-terminal pair (posix_openpt). slavePath() names the device a
//terminal emulator attaches to, and is printed once at construction.
class PtySerialBackend : public SerialBackend
{
	public:
		PtySerialBackend();
		~PtySerialBackend() override;

		const std::string& slavePath() const { return slavePath_; }

		void writeByte(uint8_t byte) override;
		bool tryReadByte(uint8_t& byte) override;

	private:
		int         masterFd_;
		std::string slavePath_;
};

#endif
