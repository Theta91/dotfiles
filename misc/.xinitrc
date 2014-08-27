#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Path stuff
PATH=$HOME/bin:$HOME/.cabal/bin:$PATH
xset +fp /usr/share/fonts/misc
xset fp rehash

# Various X settings
xsetroot -cursor_name left_ptr
xrdb -merge ~voighta/.Xresources

unclutter -root &

autocutsel -fork &
autocutsel -selection PRIMARY -fork &

urxvtd -q -o -f

dropbox start &

$HOME/bin/set-wallpaper &

syndaemon -t -k -i 2 -d &
redshift -l 37.5486691564197:-77.4678126287814 -t 5500:3700 &

/usr/bin/start-pulseaudio-x11

urxvtc &
urxvtc &

exec xmonad
