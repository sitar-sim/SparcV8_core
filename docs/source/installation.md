# Installation

The tools to install depend on how the models will be used. Steps 1 and
2 are required for every use, and they are sufficient to build and run
the C++ models. Each later step is optional and independent of the
others. A step can be skipped until the tool it installs is needed.

| Goal | Steps |
|---|---|
| Build and run the C++ models, and run the validation suite | 1, 2 |
| Also build and run the Sitar timing models | 1, 2, 3 |
| Write new SPARC programs in assembly or C, and run them | 1, 2, 4 |
| Examine a running model with gdb | 1, 2, 5 |
| Modify the models and rebuild them | 1, 2, and 3 for the Sitar models |
| Edit and rebuild this documentation | 1, 2, 6 |

These steps assume Linux on an x86_64 machine, and use the package names
of Debian and Ubuntu. Other distributions provide the same tools through
their own package managers.

---

## 1. Check the basic tools

The models need `git`, a C++ compiler with C++11 support (`g++`), and
Python 3. The following commands check that each of them is installed:

```sh
git --version
g++ --version
python3 --version
```

A missing tool can be installed with the following command:

```sh
sudo apt install git g++ python3
```

The models also use `libquadmath` for quad-precision floating point.
Most Linux distributions include it with `g++`, so it rarely needs a
separate installation.

---

## 2. Get the code

The following commands clone the repository and enter its folder:

```sh
git clone https://github.com/sitar-sim/SparcV8_core.git
cd SparcV8_core
```

Each command block in these pages begins with a `cd` into the folder
where it runs. These folders are written relative to `$SPARC_HOME`,
which is the repository's folder. The following command sets this
variable, and must be run from inside the repository's folder:

```sh
export SPARC_HOME=$(pwd)
```

A variable set in this way lasts only for the current terminal. The
following command adds it to `~/.bashrc`, so that every new terminal
has it:

```sh
echo "export SPARC_HOME=$SPARC_HOME" >> ~/.bashrc
```

The C++ models need nothing more. This documentation is also part of
the repository, and can be read offline by opening
`docs/generated_site/index.html` in a browser.

---

## 3. (Optional) Install Sitar

This step is needed only for the Sitar timing models. These models
describe the same core as the C++ models, with cycle-level timing added.
They are built with the [Sitar](https://sitar-sim.github.io/sitar/)
simulation framework.

Sitar's [installation
instructions](https://sitar-sim.github.io/sitar/getting_started.html)
describe how to install it and put the `sitar` command on the `PATH`.
After the installation, the following command should run from any
folder:

```sh
sitar -h
```

---

## 4. (Optional) Install the SPARC cross-toolchain

This step is needed only to compile new programs. The simulator runs a
program from its memory image, which is a `.hex` file. The programs in
this repository come with their memory images, so they run without this
step.

A cross-toolchain is a compiler, assembler and linker that run on the
host machine but produce code for SPARC. The repository includes a
prebuilt toolchain. The following commands unpack it and add it to the
`PATH`:

```sh
cd $SPARC_HOME
compiler/install_toolchain.sh
source compiler/toolchain_env.sh
```

The first command unpacks the toolchain into `compiler/toolchain/`. It
needs the `unzip` tool, which is installed with `sudo apt install unzip`.
The second command adds the toolchain to the `PATH` for the current
terminal only. The following commands check that the toolchain runs:

```sh
sparc-elf-as --version
sparc-elf-gcc --version
```

The following command adds the second command to `~/.bashrc`, so that
every new terminal has the toolchain on its `PATH`:

```sh
echo "source $SPARC_HOME/compiler/toolchain_env.sh" >> ~/.bashrc
```

!!! note "If the toolchain doesn't run"
    The bundled toolchain is built for 32-bit x86 (i386). On a 64-bit
    Debian or Ubuntu machine, it needs the 32-bit C library, which the
    following commands install:

    ```sh
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install libc6-i386 zlib1g:i386
    ```

    The toolchain cannot run on a machine that is not x86, such as an
    Apple Silicon Mac. On such a machine, a Linux x86_64 virtual machine
    can be used instead. Another option is to build a new toolchain with
    Buildroot, as described in [Cross Compiler](cross_compiler.md).

---

## 5. (Optional) Install gdb

This step is needed only to examine a running model with
[gdb](https://en.wikipedia.org/wiki/GNU_Debugger), the GNU debugger.
With gdb, a model can be stopped at a chosen instruction, and its
registers and memory can be examined. The models are ordinary programs
on the host machine, so the host's own `gdb` is sufficient. The
following commands install it and check its version:

```sh
sudo apt install gdb
gdb --version
```

---

## 6. (Optional) Install MkDocs

This step is needed only to edit this documentation and rebuild the
site. Reading the documentation needs nothing more than a browser, by
opening `docs/generated_site/index.html`.

The site is built with [MkDocs](https://www.mkdocs.org/). The following
commands install MkDocs and the packages it uses into a Python virtual
environment in `docs/`. They need to be run only once:

```sh
cd $SPARC_HOME/docs
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

The pages are the Markdown files in `docs/source/`. After they are
edited, the following commands rebuild the site, with the virtual
environment active:

```sh
cd $SPARC_HOME/docs
source .venv/bin/activate
mkdocs build
```

The site is written to `docs/generated_site/`. The command `mkdocs
serve` can be used instead of `mkdocs build` to preview edits in a
browser as they are made. It prints the address to open.

---

## Next

The next page, [Getting Started](getting_started.md), builds the C++
model, runs a first program on it, and continues from there.
