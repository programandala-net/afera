# Makefile

# This file is part of Afera
# (Abersoft Forth Extensions, Resources and Addons)

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
test_files=$(wildcard _tests/*_test.tap)

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

# On Debian i486, with make 3.86, sh fails wit error
# "@make not found"; removing the at sign works.

.PHONY : tapes
tapes:
	for source in $$(ls -1 src/*.fsb) ; do \
		make tap/$$(basename $${source} .fsb).tap ; \
	done

# XXX TODO

# _tests/gplusdos_test.tap: tapes afera.mgt
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
# 		> _tests/abersoft_forth_afera_gplusdos_install.tap

# _tests/gplusdos_128k_test.tap: tapes afera.mgt
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
# 		> _tests/gplusdos_128k_test.tap

afera.mgt: tapes sys/abersoft_forth_gplusdos.bas.tap
	mkmgt \
		--quiet afera.mgt \
		sys/gplusdos-sys-2a.tap \
		sys/abersoft_forth_gplusdos.bas.tap \
		sys/abersoft_forth.bin.tap \
		--tap-filename \
		mgt/*.tap


# ##############################################################
# Backups

backup:
	tar -czf backups/$$(date +%Y%m%d%H%M)_afera.tgz \
		Makefile \
		src/*.fsb \
		sys/*.bas \
		_drafts/* \
		_tests/*.fsb \
		_ex/*

# ##############################################################
# Files grouped for disk

# XXX TODO This is experimental. Not used yet.
# 
# The goal is to create an MGT disk with less files. The files of the
# library are small, and an MGT disk can have only 80 files. As as
# result, soon the disk is full of files, but mostly empty.
#
# The approach is to pack the files into wordsets, but something has to
# be done about the source headers, maybe convert them to metacomments.
#
# If RAM-disks are used, the grouped files can not be larger than 16
# KiB, and word `NEEDS`, that currently only gets the file into the
# RAM-disk and interprets it, must be improved to search the file and
# load the required word a word. A draft is already started in
# <_drafts/require.fsb>.
#
# The second approach is to implement actual disk support. Then files
# could be of any length.

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

#	_tests/512bbuf_test.tap \

.PHONY: tests
tests: $(test_files)

_tests/lowersys_test.tap: tapes
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
		> _tests/lowersys_test.tap

_tests/512bbuf_test.tap: \
	tapes \
	sys/abersoft_forth_afera_tools_inc.tap
	cat \
		sys/abersoft_forth_afera_tools_inc.tap \
		tap/512bbuf.tap \
		> _tests/512bbuf_test.tap

_tests/bank_test.tap: tapes
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
		> _tests/bank_test.tap

_tests/gplusdos_test.tap: tapes afera.mgt
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
		> _tests/gplusdos_test.tap

_tests/gplusdos_128k_test.tap: tapes afera.mgt
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
		> _tests/gplusdos_128k_test.tap

_tests/transient_test.tap: tapes
	cat \
		sys/abersoft_forth.tap \
		tap/loader.tap \
		tap/afera.tap \
		tap/transient.tap \
		tap/recurse.tap \
		tap/decode.tap \
		tap/loaded.tap \
		> _tests/transient_test.tap

_tests/plus3dos_test.tap: tapes
	cat \
		tap/loader.tap \
		tap/afera.tap \
		tap/assembler.tap \
		tap/plus3dos.tap \
		tap/loaded.tap \
		> _tests/plus3dos_test.tap

_tests/bracket-if.tap: tapes
	cat \
		sys/abersoft_forth.tap \
		tap/loader.tap \
		tap/afera.tap \
		tap/flags.tap \
		tap/pick.tap \
		tap/2r.tap \
		tap/strings.tap \
		tap/csb.tap \
		tap/csb-256.tap \
		tap/bracket-if.tap \
		tap/loaded.tap \
		> _tests/bracket-if.tap

_tests/16kramdisks_test.tap: tapes
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
		> _tests/16kramdisks_test.tap

_tests/deasm_test.tap: tapes
	cat \
		sys/abersoft_forth.tap \
		tap/loader.tap \
		tap/afera.tap \
		tap/lowersys.tap \
		tap/bank.tap \
		tap/16kramdisks.tap \
		tap/upperc.tap \
		tap/uppers.tap \
		tap/caseins.tap \
		tap/move.tap \
		tap/flags.tap \
		tap/pick.tap \
		tap/strings.tap \
		tap/recurse.tap \
		tap/decode.tap \
		tap/deasm.tap \
		tap/loaded.tap \
		> _tests/deasm_test.tap
