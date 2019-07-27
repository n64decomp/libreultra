# libreultra
An open libultra decompilation brought you to by a couple of clever folks.

## What is this?

This is the N64 standard SDK library. It is normally closed source, but recently has been decompiled (with a 1:1 match when recompiled using the original compiler) from the game *Super Mario 64*. Unfortunately, there are a couple of functions that I have deemed useful that were not used in SM64 (and were discarded by the linker) and are thus included from the libultra source code provided from the N64 SDK. ***The Oman archives were not used in any way for this project.***

## Building
Building libreultra is exclusive to Linux and WSL due to the IRIX emulator. Before you build, install the following dependencies (Debian package names):

* ``make``
* ``git``
* ``binutils-mips-linux-gnu`` (>= 2.27) (``mips64-elf`` is also acceptable)
* ``python3``
* ``build-essential``
* ``pkg-config``
* ``zlib1g-dev``
* ``libglib2.0-dev``
* ``libpixman-1-dev``
* ``libcapstone3``

After installing these dependencies, run ``make`` in the root directory.
