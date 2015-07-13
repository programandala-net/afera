# Makefile

# This file is part of Afera
# (Abersoft Forth Extensions, Resources and Addons)
# http://programandala.net/en.program.afera.html

# ##############################################################
# History

# See at the end of the file.

# ##############################################################
# Requirements

# XXX TODO

# fsb
# 	<~/comp/vim/fsb/>
# basename
#   <http://www.gnu.org/software/coreutils/>
# mkmgt
#   <~/forth/mkmgt/>

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
	rm -f afera.mgt

# The main file of the library has to be converted
# to a 11263-byte RAM-disk file,
# required by the unfixed Abersoft Forth.
tap/afera.tap: src/afera.fsb
	fsb2abersoft src/afera.fsb
	mv src/afera.tap tap/

# The other modules can be 11264-byte RAM-disk files.
tap/%.tap: src/%.fsb
	fsb2abersoft11k $<
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

# On Debian i486, with make 3.86, sh fails with error
# "@make not found"; removing the "@" sign works.
# On Raspbian with make 4.0 it works without modification.

.PHONY : tapes
tapes:
	for source in $$(ls -1 src/*.fsb) ; do \
		make tap/$$(basename $${source} .fsb).tap ; \
	done

# XXX TODO

# tests/gplusdos_test.tap: tapes afera.mgt
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

# tests/gplusdos_128k_test.tap: tapes afera.mgt
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

afera.mgt: tapes sys/abersoft_forth_gplusdos.bas.tap
	mkmgt --quiet afera.mgt \
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

# ##############################################################
# Tarballs

# XXX TODO

tarball:
	tar -czf afera_$$(date +%Y%m%d%H%M).tgz \
		Makefile \
		src/ \
		sys/ \
		tap/ \
		tests/ \
		benchmarks/

# ##############################################################
# Files grouped for disk

# XXX TODO This is experimental. Not used yet.
# 
# The goal is to create an MGT disk with less files. The
# files of the library are small, and an MGT disk can have
# only 80 files. As as result, soon the disk is full of
# files, but mostly empty.
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
		src/time.fsb \
		> src.grouped_for_disk/tools.fsb ; \
	cat \
		src/strings.fsb \
		src/csb.fsb \
		src/upperc.fsb \
		src/uppers.fsb \
		src/lowerc.fsb \
		src/lowers.fsb \
		src/s-plus.fsb \
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
		src/slash-loadt.fsb \
		src/slash-savet.fsb \
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

tests/gplusdos_test.tap: tapes afera.mgt
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

tests/gplusdos_128k_test.tap: tapes afera.mgt
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
