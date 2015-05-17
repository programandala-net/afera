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
	tap/bank.tap \
	tap/48kq.tap
	cat \
		sys/abersoft_forth.tap \
		tap/loader.tap \
		tap/afera.tap \
		tap/lowersys.tap \
		tap/bank.tap \
		tap/48kq.tap \
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
# 		tap/plusscreen.tap \
# 		tap/dot-s.tap \
# 		tap/2star.tap \
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
# 		tap/48kq.tap \
# 		tap/16kramdisks.tap \
# 		tap/buffercol.tap \
# 		tap/flags.tap \
# 		tap/pick.tap \
# 		tap/move.tap \
# 		tap/2r.tap \
# 		tap/strings.tap \
# 		tap/plusscreen.tap \
# 		tap/dot-s.tap \
# 		tap/2star.tap \
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
		_ex/*

# ##############################################################
# Temporary for development

#	_tests/512bbuf_test.tap \

tests: \
	_tests/lowersys_test.tap \
	_tests/bank_test.tap \
	_tests/gplusdos_test.tap \
	_tests/gplusdos_128k_test.tap \
	_tests/bracket-if.tap \
	_tests/16kramdisks_test.tap \
	_tests/transient_test.tap

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
		tap/plusscreen.tap \
		tap/cswap.tap \
		tap/dump.tap \
		tap/dot-s.tap \
		tap/2star.tap \
		tap/transient.tap \
		tap/transient-start-4096.tap \
		tap/assembler.tap \
		tap/transient-end.tap \
		tap/gplusdos_1.tap \
		tap/gplusdos_2.tap \
		tap/gplusdos_vars.tap \
		tap/transient-remove.tap \
		tap/loaded.tap \
		> _tests/gplusdos_test.tap

_tests/gplusdos_128k_test.tap: tapes afera.mgt
	cat \
		tap/loader.tap \
		tap/afera.tap \
		tap/lowersys.tap \
		tap/bank.tap \
		tap/48kq.tap \
		tap/16kramdisks.tap \
		tap/buffercol.tap \
		tap/flags.tap \
		tap/pick.tap \
		tap/move.tap \
		tap/2r.tap \
		tap/strings.tap \
		tap/plusscreen.tap \
		tap/dot-s.tap \
		tap/2star.tap \
		tap/transient.tap \
		tap/transient-start-4096.tap \
		tap/assembler.tap \
		tap/transient-end.tap \
		tap/gplusdos_1.tap \
		tap/gplusdos_2.tap \
		tap/gplusdos_vars.tap \
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
