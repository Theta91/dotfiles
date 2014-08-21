#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Configure PATH
PATH="$PATH:$HOME/bin:$HOME/.cabal/bin"

# Various X settings
autocutsel -fork &
autocutsel -selection PRIMARY -fork &
xsetroot -cursor_name left_ptr
unclutter -root &
xrdb -merge ~voighta/.Xresources
$HOME/bin/wallpaper.sh

/usr/bin/start-pulseaudio-x11

syndaemon -t -k -i 2 -d &
redshift -l 37.5486691564197:-77.4678126287814 -t 5500:3700 &
dropbox start &

urxvtd -q -o -f

exec xmonad
