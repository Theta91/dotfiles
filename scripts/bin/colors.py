#! /usr/bin/env python3.4

import csv
import fileinput
import os
import re
import shutil
import subprocess
import sys

#print("""\
#Usage: colors.py [OPTIONS]
#       -h                        Display this usage message
#""")

def retrieveColors():
    xrdb = subprocess.check_output(['xrdb', '-query']).decode('utf-8')
    xrdb = xrdb.replace('\t', '')
    xrdb = re.sub(r'\*\.', '', xrdb)
    xrdb = re.findall(r'(?:background|color[\d]+|foreground):#[\da-z]{6}', xrdb)
    xrdb = [x.split(':') for x in xrdb]

    i = iter(xrdb)
    colors = dict(i)

    return colors

def retrieveFilePaths():
    with open(sys.argv[1]) as f:
        parentDir, whoCares = os.path.split(sys.argv[1])
        fileList = dict(x.strip().split('=', 1) for x in f if x.strip())
        source = []
        dest = []
        for k, v in fileList.items():
            source.append(os.path.join(parentDir, k))
            dest.append(v)

    return source, dest

def colorSubstitution(colors, contents):
    contents = contents.replace('$fg', colors['foreground'])
    contents = contents.replace('$bg', colors['background'])
    contents = contents.replace('$black', colors['color0'])
    contents = contents.replace('$red', colors['color1'])
    contents = contents.replace('$green', colors['color2'])
    contents = contents.replace('$yellow', colors['color3'])
    contents = contents.replace('$blue', colors['color4'])
    contents = contents.replace('$magenta', colors['color5'])
    contents = contents.replace('$cyan', colors['color6'])
    contents = contents.replace('$white', colors['color7'])
    contents = contents.replace('$bblack', colors['color8'])
    contents = contents.replace('$bred', colors['color9'])
    contents = contents.replace('$bgreen', colors['color10'])
    contents = contents.replace('$byellow', colors['color11'])
    contents = contents.replace('$bblue', colors['color12'])
    contents = contents.replace('$bmagenta', colors['color13'])
    contents = contents.replace('$bcyan', colors['color14'])
    contents = contents.replace('$bwhite', colors['color15'])
    return contents

colors = retrieveColors()
source, dest = retrieveFilePaths()
for i in range(len(source)):
    with open(source[i], 'r') as f:
        sourceContents = f.read()
    destContents = colorSubstitution(colors, sourceContents)
    with open(dest[i], 'w') as f:
        f.write(destContents)
