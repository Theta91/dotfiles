#!/usr/bin/env sh

# Attempts to remove the password from a pdf

gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=unencrypted.pdf -c .setpdfwrite -f !$
