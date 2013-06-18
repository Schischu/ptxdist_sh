#!/bin/bash

if [ ! -f ".ptxdist/series.quilt" ]; then
	echo "No quilt series found, exit"
	exit 1
fi

# Assuming each comment belongs to patch below it
cat ".ptxdist/series.quilt" \
     |gawk 'BEGIN {FS="/"} \
/^(#|\s*$)/ {x = x $0 "\n"; next} \
            /^patches\//{f=".ptxdist/patches/series"} \
            /^patches_platform\//{f=".ptxdist/patches_platform/series"} \
{print x $2 > f; x="";}'

# debug
# echo "==========="
# cat patches/series
# echo "-----------"
# cat patches_platform/series
