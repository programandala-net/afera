# Afera

## Description

Afera stands for “Abersoft Forth Extensions, Resources and Addons”. It’s
a library for Abersoft Forth, a fig-Forth system for ZX Spectrum from
1983. I wrote Afera in 2015, in order to make the development of [Tron
0xF](http://en.program.tron_0xf.html) (an improved remake of an old game
of mine) easier, but improving an old tape-based fig-Forth and making it
more powerful was such a nice programming challenge that the library
soon grew beyond the requirements of the game.

Some of the main features of Afera are the following:

- Many common words and tools found in modern Forth systems.

- Improved tape support.

- 1 KiB of additional free memory on Spectrum 48K.

- 11 KiB of additional free memory on Spectrum 128K.

- Two 16-KiB RAM-disks on Spectrum 128K.

- Improved blocks handling.

- Full screen mode.

- Faster color commands.

- G+DOS support.

- Fixes some bugs of the original system.

## About this file

This file is not intended to teach about the Forth language, the
fig-Forth model, the Abersoft Forth system, what a TAP file is, what a
Makefile is…​ You are supposed to know all that and much more.

The build instructions are for a GNU/Linux system or similar, but the
library is ready to be used on any ZX Spectrum emulator on any platform.

The sources in \<src/\> are the main documentation. They are fully
commented. Also the \<Makefile\> is useful, as an example of building
customized TAP files to use the library with your own Forth programs.

Contact: <http://programandala.net/en.contact.html>

## Files

ACKNOWLEDGMENTS.adoc  
The credits.

Makefile  
The instructions for `make` to build the TAP files from the sources.

README.adoc  
This file.

TO-DO.adoc  
The to-do tasks (abandoned, kept only for reference).

VERSIONS.adoc  
Main changes in latest versions.

benchmarks/  
Some benchmarks used during the development.

src/  
The source of all modules.

sys/  
Abersoft Forth binaries, BASIC loader, DOS and ROM used to build the
library or during the development.

tap/  
The TAP files of all modules.

tests/  
TAP files and launchers for the Fuse emulator, with selected groups of
modules, used to test the library during the development.

## How to build the library files

If you modify the sources, you must create updated TAP files. If you
just want to use the library, skip this section.

A \<Makefile\> contains the instructions required to convert the
fsb-format sources (in the \<scr/\> directory) to TAP files (in the
\<tap/\>) directory and an MGT file (a disk image for G+DOS).

Requirements: read the section "Requirements" of the file \<Makefile\>
and install them.

Then simply use the `make` command.

## How to run Abersoft Forth with Afera

### Tape (manually)

Two bundled files are ready to be used:

- sys/abersoft_forth_afera.tap

- sys/abersoft_forth_afera_tools.tap

The first one contains only the main module of Afera. The second one
contains also some tools usually required during development.

Open any of them with a ZX Spectrum emulator. Abersoft Forth will run.
Then use the following Forth command: `LOADT 1 LOAD`. This will load and
compile the first RAM-disk from tape (containing the loader module) and
then all following modules in the TAP file.

In order to load another library module, open its TAP file from the
\<tap/\> directory using the correspondent command of your ZX Spectrum
emulator. Then use the Forth word `RUNT` (already defined by Afera) to
load and compile the next RAM-disk from the tape.

Some modules need other modules. The word `NEEDS` (defined in
\<src/afera.fsb\>) is used for that. When using tapes, `NEEDS` stops
with an error. When using disks (see below) `NEEDS` loads the required
module from disk.

### A customized tape

In order to use Afera with your own program you must create a TAP file
with first a copy of Abersoft Forth, then the required modules and
finally you application. The first Afera module in the TAP file must be
\<loader.tap\>, the second one \<afera.tap\>, then the rest, ordered by
their own requirements.

Examples:

- See how the Afera’s \<Makefile\> creates the TAP files in the
  \<tests/\> directory.

- See how [Tron 0xF](http://programandala.net/en.program.tron_0xf.html)
  creates its TAP file.

After creating your TAP file, you can run your program as usual:

1.  Open the TAP file with a ZX Spectrum emulator.

2.  Load Abersoft Forth with `LOAD ""`.

3.  Give the following Forth command: `LOADT 1 LOAD`. This will load all
    Afera modules and your program.

### Disk

Afera provides support for G+DOS (the disk operating system of the Plus
D interface), but the first time the library itself must be loaded from
tape. Then a modified system, with compiled support for G+DOS, could be
saved to disk. See \<src/afera.fsb\> and the G+DOS modules
\<scr/gplusdos\_\*.fsb\> for reference on how to save a modified
system).

The \<tests/\> directory contains two files ready to try the G+DOS
support, for 48K and 128K:

- tests/gplusdos_128k_test.tap

- tests/gplusdos_test.tap

For convenience, launchers for the Fuse emulator are provided:

- tests/gplusdos_test.sh

- tests/gplusdos_128k_test.sh

In \<Makefile\> you can see the modules used by each version. Both
versions use \<tests/afera.mgt\>, a disk image that contains a selection
of Afera modules.

Steps to run Abersoft Forth with Afera and disk support:

1.  If you have the Fuse emulator installed, you can execute the
    provided launchers. Otherwise you must run your ZX Spectrum emulator
    manually with Plus D interface, associate the correspondent TAP file
    (\<tests/gplusdos_128k_test.tap\> or \<tests/gplusdos_test.tap\>) as
    input tape and \<tests/afera.mgt\> as drive 1.

2.  Give the BASIC command `RUN`. This will load G+DOS and Abersoft
    Forth from disk.

3.  Load the main Afera modules from tape, with the following Forth
    command: `LOADT 1 LOAD`.

4.  When all modules have been loaded, you are ready to use the disk.
    Examples: `S" *" CAT`, `S" modulename" LOADD`…​
