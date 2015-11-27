# Makefile

# Copyright (C) 2015 Marcos Cruz (programandala.net)

# This file is part of Afera
# (Abersoft Forth Extensions, Resources and Addons)
# http://programandala.net/en.program.afera.html

# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice and this notice are
# preserved.  This file is offered as-is, without any
# warranty.

# ##############################################################
# History

# See at the end of the file.

# ##############################################################
# Requirements

# fsb or fsb2
#   <http://programandala.net/en.program.fsb.html>
#   <http://programandala.net/en.program.fsb2.html>
# basename
#   <http://www.gnu.org/software/coreutils/>
# mkmgt
#   <http://programandala.net/en.program.mkmgt.html>

# Note: Dependig on fsb2 or fsb are used, the following
# commands must be replaced in this file:
#
# For fsb2:
#  fsb2-abersoft src/afera.fsb
#  fsb2-abersoft11k $<
# For fsb:
#  fsb-abersoft src/afera.fsb
#  fsb-abersoft11k $<

################################################################
# Config

VPATH = ./:src:tap
MAKEFLAGS = --no-print-directory

.ONESHELL:

# ##############################################################
# Recipes

source_files=$(wildcard src/*.fsb)
tape_files=$(wildcard tap/*.tap)
test_files=$(wildcard tests/*_test.tap)

.PHONY : all
all: \
	sys \
	tests

clean:
	rm -f tap/*.tap
	rm -f tests/afera.mgt

# The main file of the library has to be converted
# to a 11263-byte RAM-disk file,
# required by the unfixed Abersoft Forth.
tap/afera.tap: src/afera.fsb
	fsb2-abersoft src/afera.fsb
	mv src/afera.tap tap/

# The other modules can be 11264-byte RAM-disk files.
tap/%.tap: src/%.fsb
	fsb2-abersoft11k $<
	mv src/$*.tap tap/

# ##############################################################
# System packages

# System packages whose name ends with "_inc.tap" have no <loaded.tap> at the
# end, so its loader will never stop.  They are intended to be used as the
# first part of other packages (see examples below) that add more modules,
# including <loaded.tap> at the end.

sys: \
	sys/abersoft_forth_afera.tap \
	sys/abersoft_forth_afera_inc.tap \
	sys/abersoft_forth_afera_tools.tap \
	sys/abersoft_forth_afera_tools_inc.tap

sys/abersoft_forth_afera_inc.tap: \
	tap/loader.tap \
	tap/afera.tap \
	tap/lowersys.tap \
	tap/bank.tap
	cat \
		sys/abersoft_forth.tap \
		tap/loader.tap \
		tap/afera.tap \
		tap/lowersys.tap \
		tap/bank.tap \
		> sys/abersoft_forth_afera_inc.tap

sys/abersoft_forth_afera.tap: \
	sys/abersoft_forth_afera_inc.tap \
	tap/loaded.tap
	cat \
		sys/abersoft_forth_afera_inc.tap \
		tap/loaded.tap \
		> sys/abersoft_forth_afera.tap

sys/abersoft_forth_afera_tools_inc.tap: \
	tap/loader.tap \
	tap/afera.tap \
	tap/dot-s.tap \
	tap/cswap.tap \
	tap/dump.tap \
	tap/recurse.tap \
	tap/decode.tap
	cat \
		sys/abersoft_forth.tap \
		tap/loader.tap \
		tap/afera.tap \
		tap/dot-s.tap \
		tap/cswap.tap \
		tap/dump.tap \
		tap/recurse.tap \
		tap/decode.tap \
		> sys/abersoft_forth_afera_tools_inc.tap

sys/abersoft_forth_afera_tools.tap: \
	sys/abersoft_forth_afera_tools_inc.tap \
	tap/loaded.tap
	cat \
		sys/abersoft_forth_afera_tools_inc.tap \
		tap/loaded.tap \
		> sys/abersoft_forth_afera_tools.tap

# ##############################################################
# G+DOS

sys/abersoft_forth_gplusdos.bas.tap: sys/abersoft_forth_gplusdos.bas
	bas2tap -q -n -sAutoload -a1 \
		sys/abersoft_forth_gplusdos.bas  \
		sys/abersoft_forth_gplusdos.bas.tap

# XXX
# On Debian i486, with make 3.86, sh fails with error
# "@make not found"; removing the "@" sign works.
# On Raspbian with make 4.0 it works without modification.

.PHONY : tapes
tapes:
	for source in $$(ls -1 src/*.fsb) ; do \
		make tap/$$(basename $${source} .fsb).tap ; \
	done

# XXX TODO

# tests/gplusdos_test.tap: tapes test/afera.mgt
# 	cat \
# 		tap/loader.tap \
# 		tap/afera.tap \
# 		tap/buffercol.tap \
# 		tap/flags.tap \
# 		tap/pick.tap \
# 		tap/move.tap \
# 		tap/2r.tap \
# 		tap/strings.tap \
#			tap/at-fetch.tap \
# 		tap/plusscreen.tap \
# 		tap/dot-s.tap \
# 		tap/assembler.tap \
# 		tap/gplusdos_1.tap \
# 		tap/gplusdos_2.tap \
# 		tap/gplusdos_vars.tap \
# 		tap/loaded.tap \
# 		> tests/abersoft_forth_afera_gplusdos_install.tap

# tests/gplusdos_128k_test.tap: tapes tests/afera.mgt
# 	cat \
# 		tap/loader.tap \
# 		tap/afera.tap \
# 		tap/lowersys.tap \
# 		tap/bank.tap \
# 		tap/16kramdisks.tap \
# 		tap/buffercol.tap \
# 		tap/flags.tap \
# 		tap/pick.tap \
# 		tap/move.tap \
# 		tap/2r.tap \
# 		tap/strings.tap \
#			tap/at-fetch.tap \
# 		tap/plusscreen.tap \
# 		tap/dot-s.tap \
# 		tap/assembler.tap \
# 		tap/gplusdos_1.tap \
# 		tap/gplusdos_2.tap \
# 		tap/gplusdos_vars.tap \
# 		tap/loaded.tap \
# 		> tests/gplusdos_128k_test.tap

# The afera.mgt disk image for +D is created with the G+DOS
# system file, Abersoft Forth with a customized loader, and
# a selection of Afera modules, regarded as useful optional
# extensions after the G+DOS version of Abersoft Forth has
# been created and saved to the disk by the user.

tests/afera.mgt: tapes sys/abersoft_forth_gplusdos.bas.tap
	mkmgt --quiet tests/afera.mgt \
		sys/gplusdos-sys-2a.tap \
		sys/abersoft_forth_gplusdos.bas.tap \
		sys/abersoft_forth.bin.tap \
		--tap-filename \
		tap/16kramdisks.tap \
		tap/2nip.tap \
		tap/2rdrop.tap \
		tap/2r.tap \
		tap/2slash.tap \
		tap/afera.tap \
		tap/akey.tap \
		tap/alias.tap \
		tap/assembler.tap \
		tap/at-fetch.tap \
		tap/bank.tap \
		tap/bracket-flags.tap \
		tap/bracket-if.tap \
		tap/buffercol.tap \
		tap/caseins.tap \
		tap/cell.tap \
		tap/color.tap \
		tap/continued.tap \
		tap/csb-256.tap \
		tap/csb.tap \
		tap/cswap.tap \
		tap/decode.tap \
		tap/defer.tap \
		tap/dminus.tap \
		tap/dot-rs.tap \
		tap/dot-s.tap \
		tap/dump.tap \
		tap/flags.tap \
		tap/graphics.tap \
		tap/inkeyq.tap \
		tap/keyboard.tap \
		tap/logo.tap \
		tap/lowerc.tap \
		tap/lowers.tap \
		tap/lowersys.tap \
		tap/minus-rot.tap \
		tap/move.tap \
		tap/noname.tap \
		tap/notequals.tap \
		tap/pick.tap \
		tap/plot.tap \
		tap/plusscreen.tap \
		tap/point.tap \
		tap/prefixes.tap \
		tap/qexit.tap \
		tap/qrstack.tap \
		tap/random.tap \
		tap/rdepth.tap \
		tap/rdrop.tap \
		tap/recurse.tap \
		tap/renamings.tap \
		tap/roll.tap \
		tap/scroll.tap \
		tap/sgn.tap \
		tap/s-plus.tap \
		tap/sqrt.tap \
		tap/strings.tap \
		tap/time.tap \
		tap/transient.tap \
		tap/traverse.tap \
		tap/udg-store.tap \
		tap/unloop.tap \
		tap/upperc.tap \
		tap/uppers.tap \
		tap/value.tap

# ##############################################################
# Backups

backup:
	tar -cJf backups/$$(date +%Y%m%d%H%M)_afera.tar.xz \
		Makefile \
		src/*.fsb \
		sys/*.bas \
		tests/*.fsb \
		benchmarks/*.fsb \
		_drafts/* \
		_ex/*

################################################################
# ZIP archive for distribution

.PHONY: zip
zip:
	rm -f afera.zip && \
	cd .. && \
	zip -9 afera/afera.zip \
		afera/Makefile \
		afera/ACKNOWLEDGMENTS.adoc \
		afera/LICENSE.txt \
		afera/README.adoc \
		afera/TO-DO.adoc \
		afera/src/*.fsb \
		afera/sys/* \
		afera/tap/*.tap \
		afera/tests/* \
		afera/benchmarks/*
	cd -

# ##############################################################
# Files grouped for disk

# XXX TODO This is experimental. Not used yet.
#
# The goal is to create an MGT disk with less files, because
# the files of the library are small, and a G+DOS disk can
# hold only 80 files.
#
# The approach is to pack the files into wordsets, but
# something has to be done about the source headers, maybe
# convert them to metacomments.
#
# If RAM-disks are used, the grouped files can not be larger
# than 16 KiB, and word `NEEDS`, that currently only gets
# the file into the RAM-disk and interprets it, must be
# improved to search the file and load the required word. A
# draft is already started in <_drafts/require.fsb>.
#
# An alternative is actual disk support.  Then files could
# be of any length.
#
# Another alternative is to use Beta DOS instead of G+DOS,
# and reserve more tracks for the disk directory.

groups_for_disk:
	cat \
		src/2nip.fsb \
		src/2slash.fsb \
		src/cswap.fsb \
		src/dminus.fsb \
		src/sqrt.fsb \
		src/sgn.fsb \
		src/notequals.fsb \
		> src.grouped_for_disk/operators.fsb ; \
	cat \
		src/2rdrop.fsb \
		src/2r.fsb \
		src/qrstack.fsb \
		src/rdepth.fsb \
		src/rdrop.fsb \
		> src.grouped_for_disk/rstack.fsb ; \
	cat \
		src/roll.fsb \
		src/pick.fsb \
		src/minus-rot.fsb \
		> src.grouped_for_disk/stack.fsb ; \
	cp src/assembler.fsb src.grouped_for_disk/ ; \
	cp src/afera.fsb src.grouped_for_disk/ ; \
	cat \
		src/akey.fsb \
		src/inkeyq.fsb \
		src/keyboard.fsb \
		src/key_identifiers.fsb \
		> src.grouped_for_disk/keyboard.fsb ; \
	cat \
		src/color.fsb \
		src/plot.fsb \
		src/plusscreen.fsb \
		src/point.fsb \
		src/scroll.fsb \
		src/graphics.fsb \
		src/logo.fsb \
		src/udg-store.fsb \
		src/at-fetch.fsb \
		> src.grouped_for_disk/graphics.fsb ; \
	cat \
		src/bracket-if.fsb \
		src/dot-s.fsb \
		src/dot-rs.fsb \
		src/dot-vocs.fsb \
		src/dump.fsb \
		src/decode.fsb \
		src/ms.fsb \
		src/time.fsb \
		> src.grouped_for_disk/tools.fsb ; \
	cat \
		src/strings.fsb \
		src/csb.fsb \
		src/upperc.fsb \
		src/uppers.fsb \
		src/lowerc.fsb \
		src/lowers.fsb \
		src/lengths.fsb \
		src/s-plus.fsb \
		src/s-equals.fsb \
		src/move.fsb \
		> src.grouped_for_disk/strings.fsb ; \
	cat \
		src/gplusdos_1.fsb \
		src/gplusdos_2.fsb \
		src/gplusdos_3.fsb \
		src/gplusdos_cat.fsb \
		src/gplusdos_mem.fsb \
		src/gplusdos_vars.fsb \
		> src.grouped_for_disk/gplusdos.fsb ; \
	cat \
		src/slash-load-t.fsb \
		src/slash-save-t.fsb \
		src/tape.fsb \
		> src.grouped_for_disk/tape.fsb ; \
	cat \
		src/alias.fsb \
		src/bracket-flags.fsb \
		src/buffercol.fsb \
		src/caseins.fsb \
		src/cell.fsb \
		src/continued.fsb \
		src/defer.fsb \
		src/flags.fsb \
		src/lowersys.fsb \
		src/noname.fsb \
		src/prefixes.fsb \
		src/qexit.fsb \
		src/random.fsb \
		src/recurse.fsb \
		src/renamings.fsb \
		src/transient.fsb \
		src/traverse.fsb \
		src/unloop.fsb \
		src/value.fsb \
		> src.grouped_for_disk/to-do.fsb


# ##############################################################
# Temporary for development

# XXX FIXME The test files are not updated if they don't
# exist.

.PHONY: tests
tests: $(test_files)

tests/lowersys_test.tap: tapes
	cat \
		sys/abersoft_forth.tap \
		tap/loader.tap \
		tap/afera.tap \
		tap/cswap.tap \
		tap/dump.tap \
		tap/dot-rs.tap \
		tap/dot-s.tap \
		tap/lowersys.tap \
		tap/loaded.tap \
		> tests/lowersys_test.tap

tests/512bbuf_test.tap: \
	tapes \
	sys/abersoft_forth_afera_tools_inc.tap
	cat \
		sys/abersoft_forth_afera_tools_inc.tap \
		tap/512bbuf.tap \
		> tests/512bbuf_test.tap

tests/bank_test.tap: tapes
	cat \
		sys/abersoft_forth.tap \
		tap/loader.tap \
		tap/afera.tap \
		tap/recurse.tap \
		tap/decode.tap \
		tap/cswap.tap \
		tap/dump.tap \
		tap/lowersys.tap \
		tap/bank.tap \
		tap/16kramdisks.tap \
		tap/loaded.tap \
		> tests/bank_test.tap

tests/gplusdos_test.tap: tapes tests/afera.mgt
	cat \
		tap/loader.tap \
		tap/afera.tap \
		tap/buffercol.tap \
		tap/flags.tap \
		tap/pick.tap \
		tap/move.tap \
		tap/2r.tap \
		tap/strings.tap \
		tap/csb.tap \
		tap/csb-256.tap \
		tap/at-fetch.tap \
		tap/plusscreen.tap \
		tap/cswap.tap \
		tap/dump.tap \
		tap/dot-s.tap \
		tap/dot-vocs.tap \
		tap/transient.tap \
		tap/transient-start-4096.tap \
		tap/assembler.tap \
		tap/transient-end.tap \
		tap/gplusdos_1.tap \
		tap/gplusdos_2.tap \
		tap/gplusdos_3.tap \
		tap/gplusdos_vars.tap \
		tap/gplusdos_mem.tap \
		tap/transient-remove.tap \
		tap/loaded.tap \
		> tests/gplusdos_test.tap

tests/gplusdos_128k_test.tap: tapes tests/afera.mgt
	cat \
		tap/loader.tap \
		tap/afera.tap \
		tap/lowersys.tap \
		tap/bank.tap \
		tap/16kramdisks.tap \
		tap/buffercol.tap \
		tap/flags.tap \
		tap/pick.tap \
		tap/move.tap \
		tap/2r.tap \
		tap/strings.tap \
		tap/csb.tap \
		tap/csb-256.tap \
		tap/at-fetch.tap \
		tap/plusscreen.tap \
		tap/dot-s.tap \
		tap/dot-vocs.tap \
		tap/transient.tap \
		tap/transient-start-4096.tap \
		tap/assembler.tap \
		tap/transient-end.tap \
		tap/gplusdos_1.tap \
		tap/gplusdos_2.tap \
		tap/gplusdos_3.tap \
		tap/gplusdos_cat.tap \
		tap/gplusdos_vars.tap \
		tap/gplusdos_mem.tap \
		tap/transient-remove.tap \
		tap/loaded.tap \
		> tests/gplusdos_128k_test.tap

tests/transient_test.tap: tapes
	cat \
		sys/abersoft_forth.tap \
		tap/loader.tap \
		tap/afera.tap \
		tap/transient.tap \
		tap/recurse.tap \
		tap/decode.tap \
		tap/loaded.tap \
		> tests/transient_test.tap

# tests/plus3dos_test.tap: tapes
# 	cat \
# 		tap/loader.tap \
# 		tap/afera.tap \
# 		tap/assembler.tap \
# 		tap/plus3dos.tap \
# 		tap/loaded.tap \
# 		> tests/plus3dos_test.tap

tests/bracket-if_test.tap: tapes
	cat \
		sys/abersoft_forth.tap \
		tap/loader.tap \
		tap/afera.tap \
		tap/flags.tap \
		tap/pick.tap \
		tap/2r.tap \
		tap/move.tap \
		tap/strings.tap \
		tap/csb.tap \
		tap/csb-256.tap \
		tap/bracket-if.tap \
		tap/loaded.tap \
		> tests/bracket-if.tap

tests/16kramdisks_test.tap: tapes
	cat \
		sys/abersoft_forth.tap \
		tap/loader.tap \
		tap/afera.tap \
		tap/lowersys.tap \
		tap/bank.tap \
		tap/time.tap \
		tap/recurse.tap \
		tap/decode.tap \
		tap/16kramdisks.tap \
		tap/loaded.tap \
		> tests/16kramdisks_test.tap

tests/rdrop_test.tap: tapes
	cat \
		sys/abersoft_forth_afera_tools_inc.tap \
		tap/rdrop.tap \
		tap/2rdrop.tap \
		tap/loaded.tap \
		> tests/rdrop_test.tap

tests/defer_test.tap: tapes
	cat \
		sys/abersoft_forth_afera_tools_inc.tap \
		tap/defer.tap \
		tap/noname.tap \
		tap/loaded.tap \
		> tests/defer_test.tap

tests/hi-to_test.tap: tapes
	cat \
		sys/abersoft_forth.tap \
		tap/loader.tap \
		tap/afera.tap \
		tap/cswap.tap \
		tap/dump.tap \
		tap/dot-rs.tap \
		tap/dot-s.tap \
		tap/lowersys.tap \
		tap/hi-to-top.tap \
		tap/hi-to.tap \
		tap/time.tap \
		tap/loaded.tap \
		> tests/hi-to_test.tap

# ##############################################################
# History

# 2015-03-12: First version.
#
# 2015-03-27: Updated with fsb2abersoft
#
# 2015-03-28: Implicite recipe.
#
# 2015-04-06: Improved recipes.
#
# 2015-04-15: Updated. New: MGT image.
#
# 2015-05-06: New: 'test' recipe for development TAP files.
#
# 2015-05-07: New: <sys/abersoft_forth_and_tools.tap>, for development.
#
# 2015-05-08: Recipes updated with the <loader.tap> and <loaded.tap> modules,
# that make it possible to compile the files with one command, no matter the
# number of modules included.
#
# 2015-05-11: Updated.
#
# 2015-05-14: Updated with the fsb2abersoft11k converter.
#
# 2015-05-15: New: backup recipe; tapes recipe, factored from afera.mgt.
#
# 2015-06-06: Updated.
#
# 2015-07-05: Updated.
#
# 2015-07-06: `tests/defer_test.tap`.
#
# 2015-07-16: Updated.
#
# 2015-07-17: Added 'tests/hi-to_test.tap' recipe for
# debugging the module <hi-to.fsb>.
#
# 2015-09-04: Added the zip recipe.
#
# 2015-10-23: Updated the names of fsb converters.
#
# 2015-10-26: Updated two names of modules. fsb2 is used by default instead of fsb.
#
# 2015-10-30: Updated the zip recipe with the licenses.
