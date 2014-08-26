#!/usr/bin/env sh

# Attempts to shrink a pdf using ghostscript.

gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -sOutputFile="${1%.pdf}-shrunk.pdf" "$1"
