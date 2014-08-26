#!/usr/bin/env sh

# Removes the first page from a pdf.

pdftk "$1" cat 2-end output "$1".1
pdftk "$1".1 output "$1"
rm "$1".1
