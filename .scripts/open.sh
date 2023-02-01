#!/bin/bash

# MacOS-like open command for Linux

for i in $*; do
    setsid xdg-open $i > /dev/null 2>&1
done
