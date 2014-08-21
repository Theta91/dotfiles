#!/bin/bash

play -t sl - synth 10:00:00 pinknoise band -n 1200 200 tremolo 20 .1 < /dev/zero

#sox -n --rate 48000 -b 16 35-70pinknoise.wav synth 00:00:30 pinknoise sinc 35-70 gain -n -3
#sox -n --rate 48000 -b 16 500-1000pinknoise.flac synth 00:00:30 pinknoise sinc 500-1000 gain -n -3
