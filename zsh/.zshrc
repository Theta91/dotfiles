# -----------------------------------------------------------------------------
#                                   History
# -----------------------------------------------------------------------------
HISTFILE=~/.zsh/histfile
HISTSIZE=1000
SAVEHIST=2048
setopt extendedhistory
setopt histignorealldups
setopt histignorespace
# -----------------------------------------------------------------------------
# Don't send SIGHUP to background processes when the shell exits.
setopt nohup

# avoid "beep"ing
setopt nobeep

# * shouldn't match dotfiles. ever.
setopt noglobdots

setopt autocd
setopt extendedglob
# Stick with emacs keybindings
bindkey -e
# -----------------------------------------------------------------------------
#                zkbd compatible keybindings, per the Arch Wiki
# -----------------------------------------------------------------------------
typeset -A key

key[Home]=${terminfo[khome]}

key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' "${terminfo[smkx]}"
    }
    function zle-line-finish () {
        printf '%s' "${terminfo[rmkx]}"
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi
# -----------------------------------------------------------------------------
#                                     zmv
# -----------------------------------------------------------------------------
#  zmv
autoload zmv
alias zmv='zmv -W -n'
alias rzmv='zmv -W'
# -----------------------------------------------------------------------------
#                                  Completion
#                          much copied from grml-zsh
# -----------------------------------------------------------------------------
#  completion
autoload -Uz compinit && compinit
_comp_options+=(globdots)
setopt autolist
# start menu completion only if it could find no unambiguous initial string
zstyle ':completion:*:correct:*'       insert-unambiguous true
zstyle ':completion:*:corrections'     format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*:correct:*'       original true
# activate color-completion
zstyle ':completion:*:default'         list-colors ${(s.:.)LS_COLORS}
# set format for warnings
zstyle ':completion:*:warnings'        format $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'
# Provide more processes in completion of programs like killall:
zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'
# run rehash on completion so new installed program are found automatically:
_force_rehash() {
  (( CURRENT == 1 )) && rehash
  return 1
}
# try to be smart about when to use what completer...
setopt correct
zstyle -e ':completion:*' completer '
  if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]] ; then
      _last_try="$HISTNO$BUFFER$CURSOR"
      reply=(_complete _match _ignored _prefix _files)
  else
      if [[ $words[1] == (rm|mv) ]] ; then
          reply=(_complete _files)
      else
          reply=(_oldlist _expand _force_rehash _complete _ignored _correct _approximate _files)
      fi
  fi'
# -----------------------------------------------------------------------------
#                                 Colored less
# -----------------------------------------------------------------------------
export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
export LESS=" -R "
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
# -----------------------------------------------------------------------------
#                                    Prompt
# -----------------------------------------------------------------------------
#  colors
autoload -U colors && colors
PROMPT="%{$fg_bold[cyan]%}%~%{$reset_color%}
%{%(!.$fg_bold[red].$fg_bold[green])%}%n%(!.#.$)%{$reset_color%} "
RPROMPT=""
# -----------------------------------------------------------------------------
#  Persistent dirstack per the Arch Wiki
# -----------------------------------------------------------------------------
DIRSTACKSIZE=10
DIRSTACKFILE=~/.zsh/dirs
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
fi
chpwd() {
  print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}
setopt autopushd pushdsilent pushdtohome
setopt pushdignoredups
setopt pushdminus
# -----------------------------------------------------------------------------
#                                   Sources
# -----------------------------------------------------------------------------
sources=( ~/.zsh/aliases
          ~/.zsh/functions
        )
#  Fish-like syntax highlighting per the Arch Wiki
sources+=( /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh )
sources+=( /usr/share/doc/pkgfile/command-not-found.zsh )
for i ($^sources(.N)) source $i
# -----------------------------------------------------------------------------
