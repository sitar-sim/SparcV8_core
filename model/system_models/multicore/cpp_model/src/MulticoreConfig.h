//MulticoreConfig.h
//Original Author: Neha Karanjkar
//Model Author: Claude Opus 5.5 (high)
//The model code was adapted from a Sparc v8 core simulation model written
//by the first author in C++ and Sitar (2015-2017).
//
//The multicore configuration's compile-time knobs, for the cpp_model.
//The sitar_model has the same two knobs as parameters of its System
//module. Change them here and rebuild.

#ifndef MULTICORE_CONFIG_H
#define MULTICORE_CONFIG_H

namespace MulticoreConfig
{
	//Number of cores, each with its own L1 I/D caches and MMU, sharing
	//one main memory and one set of peripheral devices. At most 4, the
	//number of cores the Interrupt Controller has thread slots for
	//(2 slots per core, Ref InterruptControllerCore.h).
	const unsigned int NUM_CORES = 4;
}

#endif
