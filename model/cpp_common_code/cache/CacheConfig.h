//CacheConfig.h
//Original Authors: Madhav Desai, Neha Karanjkar, Aniket Deshmukh
//Model Author: Claude Opus 5.5 (high)
//This model code was adapted from the VIVT L1 cache model developed by
//the original authors.
//
//Default L1 cache organization, the same as AJIT's own defaults: 512
//lines of 64 bytes (32 KB) per cache, direct mapped. Both are run-time
//settings in every configuration with caches (--icache-lines,
//--icache-ways, --dcache-lines, --dcache-ways), these are just the
//defaults. The line size is fixed, Ref MemoryInterfaces.h's
//CACHE_LINE_BYTES.

#ifndef CACHE_CONFIG_H
#define CACHE_CONFIG_H

const unsigned int DEFAULT_ICACHE_LINES = 512;
const unsigned int DEFAULT_ICACHE_WAYS  = 1;
const unsigned int DEFAULT_DCACHE_LINES = 512;
const unsigned int DEFAULT_DCACHE_WAYS  = 1;

#endif
