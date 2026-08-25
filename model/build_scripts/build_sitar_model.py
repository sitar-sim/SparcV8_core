#!/usr/bin/env python3
"""
build_sitar_model.py <config_folder> [--logging] [--debug] [--debug-o0]

Shared build logic for every sitar_model configuration under
model/system_models/*/sitar_model/. Takes the path to that configuration's
own sitar_model/ folder and builds entirely relative to it: translates and
compiles every *.sitar file found both in model/sitar_component_models/
(the reusable procedures every configuration shares -- SparcThread,
MemoryInterface, MainMemory today) and in <config_folder>/src/ (that
configuration's own Top/Core composition, the part that actually differs
per configuration), against cpp_common_code/ and
sitar_component_models/cpp_code/, and writes the executable into
<config_folder>/executable/.

No configuration is named or special-cased here -- a new configuration
folder needs no change to this script, only its own src/ files (plus any
new shared component .sitar files it needs, added to
sitar_component_models/) and a one-line build.sh wrapper (see
model/system_models/core_only/sitar_model/build.sh for the pattern).
Translating every shared component unconditionally, even ones a given
configuration's Core.sitar doesn't instantiate, is harmless dead code at
this scale -- simpler than tracking per-configuration dependencies, worth
revisiting only if the shared-component library grows large enough for
that to matter.

The executable name is derived from <config_folder>'s own parent
directory name (the configuration's name), e.g. sparc_sim_sitar_core_only,
with variant suffixes appended for --logging/--debug so multiple builds
can coexist in the same executable/ folder.

Requires the `sitar` CLI on PATH (see the separate sitar repo).

Links against libquadmath, needed by cpp_common_code/FloatingPointFunctions.h
for quad-precision (128-bit) floating point support, via `sitar compile`'s
`-l`/`--libs` option.
"""
import argparse
import glob
import os
import shutil
import subprocess
import sys

SCRIPT_DIR              = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR                = os.path.dirname(SCRIPT_DIR)
CPP_COMMON_CODE_DIR      = os.path.join(MODEL_DIR, 'cpp_common_code')
SITAR_COMPONENT_DIR      = os.path.join(MODEL_DIR, 'sitar_component_models')
SITAR_COMPONENT_CODE_DIR = os.path.join(SITAR_COMPONENT_DIR, 'cpp_code')


def run(cmd, **kwargs):
    print('+ ' + ' '.join(cmd))
    return subprocess.run(cmd, **kwargs)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('config_folder', help="path to a configuration's sitar_model/ folder, e.g. model/system_models/core_only/sitar_model")
    ap.add_argument('--logging', action='store_true',
                     help="build with Sitar's own per-cycle logging enabled (off by default -- "
                          "noisy and slower; useful for debugging timing, e.g. delay parameters), "
                          "and with SparcCore::logger's CoreLogger methods doing real work instead "
                          "of compiling to no-op stubs (see cpp_common_code/CoreLogger.h) -- both "
                          "controlled by this one flag, same as build_cpp_model.sh's --logging")
    ap.add_argument('--debug', action='store_true',
                     help="build for examination under a debugger: -g (debug symbols) and "
                          "-DSPARC_DEBUG_HOOKS_ENABLED (real, noinline debug_hook_*() functions "
                          "instead of empty stubs -- see cpp_common_code/DebugHooks.h). Stays at "
                          "-O3 -- same reasoning as build_cpp_model.sh's --debug.")
    ap.add_argument('--debug-o0', action='store_true',
                     help="like --debug, but the whole binary at -O0 -- for debugging something "
                          "that isn't one of the hook points or pinned functions above (arbitrary "
                          "breakpoints/single-stepping/local-variable inspection elsewhere).")
    args = ap.parse_args()
    if args.debug_o0:
        args.debug = True

    config_dir = os.path.abspath(args.config_folder)
    # config_dir is .../system_models/<config_name>/sitar_model -- the
    # configuration's own name is its grandparent's basename, not
    # config_dir's own ("sitar_model" for every configuration alike).
    config_name = os.path.basename(os.path.dirname(config_dir))
    src_dir = os.path.join(config_dir, 'src')
    build_dir = os.path.join(config_dir, 'build')          # scratch, gitignored
    output_dir = os.path.join(build_dir, 'Output')          # translated .sitar -> .cpp/.h
    executable_dir = os.path.join(config_dir, 'executable')
    main_file = os.path.join(src_dir, 'sparc_sim.cpp')

    executable_name = 'sparc_sim_sitar_%s' % config_name
    if args.logging:
        executable_name += '_logging'
    if args.debug:
        executable_name += '_debug'
    if args.debug_o0:
        executable_name += 'o0'
    executable = os.path.join(executable_dir, executable_name)

    if not shutil.which('sitar'):
        print("error: `sitar` not found on PATH -- see the separate sitar repo")
        sys.exit(1)

    if os.path.isdir(output_dir):
        shutil.rmtree(output_dir)
    os.makedirs(output_dir)
    os.makedirs(executable_dir, exist_ok=True)
    stale_objects = (glob.glob(os.path.join(SITAR_COMPONENT_CODE_DIR, '*.o'))
                     + glob.glob(os.path.join(CPP_COMMON_CODE_DIR, '*.o'))
                     + glob.glob(main_file[:-4] + '.o'))
    for stale_o in stale_objects:
        os.remove(stale_o)

    sitar_files = sorted(glob.glob(os.path.join(SITAR_COMPONENT_DIR, '*.sitar'))) + \
                  sorted(glob.glob(os.path.join(src_dir, '*.sitar')))

    print("Translating .sitar files...")
    for f in sitar_files:
        r = run(['sitar', 'translate', f, '-o', output_dir])
        if r.returncode != 0:
            print("error: translating %s failed" % f)
            sys.exit(1)

    print("Compiling...")
    cmd = ['sitar', 'compile',
           '-o', executable,
           '-d', output_dir,
           '-d', SITAR_COMPONENT_CODE_DIR,
           '-d', CPP_COMMON_CODE_DIR,
           '-m', main_file,
           '-l', 'quadmath',
           '--logging' if args.logging else '--no-logging']
    cflags = []
    if args.logging:
        # CoreLogger.h/.cpp (cpp_common_code/, compiled in via -d above)
        # needs this to do real work rather than compile to no-op stubs --
        # see cpp_common_code/CoreLogger.h. Independent of Sitar's own
        # --logging above, which only affects Sitar's own logger.
        cflags.append('-DSPARC_LOGGING_ENABLED')
    if args.debug:
        # DebugHooks.h/.cpp needs this to compile in real, noinline hook
        # functions instead of empty stubs. The -O level here overrides
        # sitar compile's own default -O2 (gcc takes the last -O flag on
        # the command line, and this one is appended after it) -- see
        # --debug/--debug-o0's help above.
        opt = '-O0' if args.debug_o0 else '-O3'
        cflags.append('-DSPARC_DEBUG_HOOKS_ENABLED -g ' + opt)
    # A handful of locals/parameters in cpp_common_code (e.g. some decoded
    # register-address fields in execute_FPop()) are computed but not read
    # on every code path, benign, not a sign of a real bug, but sitar
    # compile's own warning flags flag them and alarm a first-time
    # builder. Silenced here rather than in the source.
    cflags.append('-Wno-unused-variable -Wno-unused-but-set-variable -Wno-unused-parameter')
    # sitar compile's own SConstruct always adds -W (aka -Wextra), on top
    # of -Wall, unlike build_cpp_model.sh which only uses -Wall. -Wno-extra
    # cancels that back off, so both build scripts warn at the same level.
    cflags.append('-Wno-extra')
    # FloatingPointFunctions.h's #pragma STDC FENV_ACCESS ON is standard
    # C99/C11, but GCC doesn't implement it, silently ignoring it rather
    # than acting on it. -Wall flags that as an unknown pragma, benign,
    # not a sign of a real bug, so silenced here rather than in the
    # source.
    cflags.append('-Wno-unknown-pragmas')
    if cflags:
        cmd += ['--cflags=' + ' '.join(cflags)]
    r = run(cmd, cwd=config_dir)
    if r.returncode != 0:
        print("error: compile/link failed")
        sys.exit(1)

    print("Built %s" % executable)


if __name__ == '__main__':
    main()
