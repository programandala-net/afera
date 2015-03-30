# Makefile

# This Makefile converts the Abersoft Forth extensions, <extend.fsb> to
# <extend.tap>, ready to be loaded into ZX Spectrum's Abersoft Forth.

# ##############################################################
# History

# 2015-03-12: First version.
# 2015-03-27: Updated with fsb2abersoft
# 2015-03-28: Implicite recipe.

# ##############################################################
# Requirements

# fsb
# 	<~/comp/vim/fsb/>

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

