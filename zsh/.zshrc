HISTFILE=~/.zsh/histfile
HISTSIZE=1000
SAVEHIST=2048
setopt autocd extendedglob
bindkey -v

zstyle :compinstall filename '/home/voighta/.zshrc'
# -----------------------------------------------------------------------------
#                                Autoload stuff
# -----------------------------------------------------------------------------
#  completion
autoload -Uz compinit && compinit
#  colors
autoload -U colors && colors
#  zmv
autoload zmv
alias zmv='zmv -W -n'
alias rzmv='zmv -W'


setopt HIST_IGNORE_DUPS
# -----------------------------------------------------------------------------
#                                  Completion
# -----------------------------------------------------------------------------
#
setopt autolist
# -----------------------------------------------------------------------------
#                                    Prompt
# -----------------------------------------------------------------------------
#  adapted from: http://aperiodic.net/phil/prompt/
precmd() {
  local leftLen=${#${(%):-%*}}
  local rightLen=${#${(%):-%~}}
  local truncate=""
  local padding=""

  [[ "$leftLen + $rightLen" -gt $COLUMNS ]] && (( truncate=$COLUMNS - $leftLen ))
  [[ "$leftLen - $rightLen" -le $COLUMNS ]] && padding="\${(l.(($COLUMNS - $leftLen - $rightLen)).. .)}"
  print -rP "%{$fg[yellow]%}%*%{$fg[green]%}${(e)padding}%${(e)truncate}<...<%~%<<%{$reset_color%}"
}
PROMPT="%{%(!.$fg[red].$fg[cyan])%}%n> %{$reset_color%}"
RPROMPT=""
# -----------------------------------------------------------------------------
#  Persistent dirstack per the Arch Wiki
# -----------------------------------------------------------------------------
DIRSTACKSIZE=10
DIRSTACKFILE=~/.zsh/dirs
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
  [[ -d $dirstack[1] ]] && cd $dirstack[1]
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
