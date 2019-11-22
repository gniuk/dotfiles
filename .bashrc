#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

############## HISTORY OPTIONS ################

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=2000000

# Save and reload history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

############ END HISTORY OPTIONS ##############

############ OTHER SHELL OPTIONS ##############

# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
shopt -s cdspell

# Use case-insensitive filename globbing
shopt -s nocaseglob

########## END OTHER SHELL OPTIONS ############

########## CUSTOM FUNCTIONS ##########
# copy from cygwin
cd_func ()
{
  local x2 the_new_dir adir index
  local -i cnt

  if [[ $1 ==  "--" ]]; then
    dirs -v
    return 0
  fi

  the_new_dir=$1
  [[ -z $1 ]] && the_new_dir=$HOME

  if [[ ${the_new_dir:0:1} == '-' ]]; then
    #
    # Extract dir N from dirs
    index=${the_new_dir:1}
    [[ -z $index ]] && index=1
    adir=$(dirs +$index)
    [[ -z $adir ]] && return 1
    the_new_dir=$adir
  fi

  #
  # '~' has to be substituted by ${HOME}
  [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

  #
  # Now change to the new dir and add to the top of the stack
  pushd "${the_new_dir}" > /dev/null
  [[ $? -ne 0 ]] && return 1
  the_new_dir=$(pwd)

  #
  # Trim down everything beyond 11th entry
  popd -n +11 2>/dev/null 1>/dev/null

  #
  # Remove any other occurence of this dir, skipping the top of the stack
  for ((cnt=1; cnt <= 10; cnt++)); do
    x2=$(dirs +${cnt} 2>/dev/null)
    [[ $? -ne 0 ]] && return 0
    [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
    if [[ "${x2}" == "${the_new_dir}" ]]; then
      popd -n +$cnt 2>/dev/null 1>/dev/null
      cnt=cnt-1
    fi
  done

  return 0
}

############ END CUSTOM FUNCTIONS ##############

############ ALIASes ##############
alias ls='ls --color=auto'

alias cd=cd_func
alias l='ls -lh --color=auto'
alias ll='ls -alh --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'

alias S='sudo pacman -S '
alias Ss='sudo pacman -Ss '
alias Fo='sudo pacman -Fo '
alias Fl='sudo pacman -Fl '
alias Fy='sudo pacman -Fy '
alias Syu='sudo pacman -Syu '

alias emacsd='\emacs -nw --daemon'
alias emacs='emacsclient -nw '
alias mpv='mpv --hwdec=yes '

########## END ALIASes ############

export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland-egl
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland

export GOPATH=~/godir
export PATH=$GOPATH/bin:$PATH
export TERM=xterm-256color

export PS1="\[\e[0m\]\n\[\e[1;36m\][\d \t] \[\e[1;33m\]\u@\h \[\e[1;31m\]\w \n\$ \[\e[0m\]"
