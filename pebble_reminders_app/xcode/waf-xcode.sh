#!/bin/bash
# Expecting arm toolchain + openocd binaries to be in $PATH after sourcing .bash_profile:
source ~/.profile
cd ..
if [ -z $ACTION ]; then
    ACTION=build
fi

./waf $ACTION
