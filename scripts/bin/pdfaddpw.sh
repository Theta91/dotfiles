#!/usr/bin/env sh

# Quickly add a password to a pdf.

pdftk "$1" output "pw_${1}" user_pw "$2"
