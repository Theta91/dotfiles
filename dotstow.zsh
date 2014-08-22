#!/bin/zsh

tostow=( */(N) )

for dir in $tostow; do
  stow $dir
done
