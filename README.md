## dotfiles

A backup of my dotfiles and various other pieces of configuration & scripts that I use regularly. Many will have sections cribbed liberally from various people.

### dotstow.zsh
I manage my dotfiles with GNU stow (credit: Brandon Invergo). Running ./dotstow.zsh from this directory automagically symlinks/updates all the files/folder inside each subdirectory to $HOME.

### Xresources
```
.Xresources:           .Xresources; most options #include'd from .xresources.d
.xresources.d/color-*: color schemes
             /font-*:  URxvt font definition
             /urxvt:   misc. URxvt options
```
### irssi
```
.irssi/weed.theme:                irssi theme
      /solarized-universal.theme: used for log format
      /scripts/*.pl:              various irssi scripts
      /scripts/autorun/*.pl:      symlink'd scripts I actually use
```
### misc
```
.xinitrc: commands to be executed when X is started
```
### scripts
```
bin/dmenu-yeganesh: shortcut for keyboard-driven program launcher for xmonad
   /dt:             manages several common dtach sessions
   /noise.sh:       generates pink noise
   /screenshot:     shortcut for keyboard-driven screenshots for xmonad
   /wallpaper.sh:   manages wallpaper changing
```
### vim
```
.vimrc: vim config
.vim:   all the rest
```
### xmonad
```
.config/xmobar/xmobarrc: xmobar configuration file
.xmonad/xmonad.hs:       xmonad configuration file
```
### zsh
```
.zshenv:        environment variables to be exported
.zshrc:         zsh setup
.zsh/aliases:   custom aliases
    /functions: custom functions
```
