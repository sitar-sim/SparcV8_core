#!/bin/bash
# run_speedup.sh [threads ...]
#
# Runs the demo once for each thread count given (default: 1 2 4), and
# prints each run's time and its speedup over the first run. Pass 1
# first so the speedups are relative to a serial run. Every run must
# PASS, and every run simulates the same number of cycles.
#
# Set OMP_PROC_BIND=true OMP_PLACES=cores in the environment to bind each
# thread to a host core of its own.
HERE="$(cd "$(dirname "$0")" && pwd)"
SIM="$HERE/executable/speedup_sim_openmp"
HEX="$HERE/program/private_matmul.hex"
[ -x "$SIM" ] || { echo "build first: $HERE/build.sh"; exit 1; }
[ $# -gt 0 ] || set -- 1 2 4

base=""
printf "%-8s %-12s %-10s %-8s %s\n" threads cycles time speedup result
for t in "$@"; do
	out=$("$SIM" "$HEX" --threads "$t")
	cycles=$(echo "$out" | awk '/^cycles/ {print $3}')
	time=$(echo "$out" | awk '/^time/ {print $3}')
	result=$(echo "$out" | awk '/^result/ {print $3}')
	[ -n "$base" ] || base=$time
	printf "%-8s %-12s %-10s %-8s %s\n" "$t" "$cycles" "${time}s" "$(echo "$base / $time" | bc -l | xargs printf "%.2f")" "$result"
done
