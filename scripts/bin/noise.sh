#!/usr/bin/env sh

# Generates pink noise for the specified number of hours. Requires sox.

play -c 2 -r 48k -t s32 - synth ${1}:00:00 pinknoise band -n 1200 200 tremolo 20 .1 < /dev/zero
