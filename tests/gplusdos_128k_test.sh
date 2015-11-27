#!/bin/sh
# 2015-05-17: Created.
# 2015-10-23: Updated.
fuse \
	--machine 128 \
	--no-divide \
	--plusd \
	--tape  gplusdos_128k_test.tap \
	--plusddisk afera.mgt \
  --speed 200 \
	&
	

