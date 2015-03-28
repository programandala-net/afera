# Makefile

# This Makefile converts the Abersoft Forth extensions, <extend.fsb> to
# <extend.tap>, ready to be loaded into ZX Spectrum's Abersoft Forth.

# ##############################################################
# History

# 2015-03-12: First version.
# 2015-03-27: Updated with fsb2abersoft.

# ##############################################################
# To-do

# Fix
#
# 'bin2code' always returns exit code 97, but it works.  'ls -l DISC.tap' is
# used after 'bin2code' in order to avoid the exit code to be detected by
# 'make'.
#
# New:
#
# Create generic recipes for converting all .fsb in the directory.

# ##############################################################
# Requirements

# fsb2fb
# 	<~/comp/vim/fsb>
# bin2code
#   <http://metalbrain.speccy.org/link-eng.htm>.

################################################################
# Config

VPATH = ./
MAKEFLAGS = --no-print-directory

.ONESHELL:

# ##############################################################
# Recipes

.PHONY: all
all: $(wildcard *.tap)

%.tap : %.fsb
	fsb2abersoft $<

################################################################
# Old

#################################################################
# <extend.tap> has been created.
#
# Load Abersoft Forth, then open <extend.tap> as the tape file of the
# emulator and execute the following Forth word:
#
#   LOADT
#
# Then the blocks from the TAP file will be ready in the RAM-disc.
# Then you can use the Forth words `INDEX`, `LIST` and `LOAD`.
#################################################################

################################################################
# Notes

# This should work:
	
# invasores.udg.tap : invasores.udg.fb
# 	rm -f DISC && \
# 	ln -s invasores.udg.fb DISC && \
# 	bin2code DISC invasores.udg.tap ; \
# 	rm -f DISC

# But Abersoft Forth saves its 11-block RAM-disc with 11263
# length, not 11264! When a 11264-byte file is loaded with
# 'LOADT', tape loading error happens.
#
# This is the solution:

# invasores.main.tap : invasores.main.fb
# 	head --bytes=-1 invasores.main.fb > DISC ; \
# 	bin2code DISC invasores.main.tap ; \
# 	rm -f DISC

