#!/bin/zsh

tostow=( */(N) )
tostow=(${tostow#uncolorized/})

for dir in $tostow; do
  stow $dir
done
