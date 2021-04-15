#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# make C-s i-search, i.e. search forward
[[ $- == *i* ]] && stty -ixon

############## HISTORY OPTIONS ################

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# Append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=200000
HISTFILESIZE=200000

# Save and reload history after each command finishes
if [[ ${PROMPT_COMMAND} != *"history -a"* ]]; then
    export PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"
fi

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

# -------------------- simplify ssh --------------------
# openssh7.3p1+ needed
alias ssh='TERM=xterm-256color ssh'
svr1="server1_name"
svr1_port="server1_port"
remote_port="remote_port"
myname=$(whoami)
c () {
    # usage: c "host"
    # change the variables above and the command below as needed
    ssh -A -p $remote_port -J ${myname}@${svr1}:$svr1_port ${myname}@$1
}

scpo () {
    scp -r -P $remote_port -oProxyJump=${myname}@${svr1}:${svr1_port} $1 ${myname}@$2
}
scpi () {
    scp -r -P $remote_port -oProxyJump=${myname}@${svr1}:${svr1_port} ${myname}@$1 $2
}

# kill qemu-system-i386 myos
k () {
    qospid=$(ps x | grep [q]emu.*myos | awk '{print $1}')
    kill $qospid
}

# -------------------- remove bash history duplicates and keep order --------------------
his () {
    nl ~/.bash_history | sort -k 2  -k 1,1nr| uniq -f 1 | sort -n | cut -f 2 > ~/.tmp_history
    mv ~/.tmp_history ~/.bash_history
}

# ---------- ediff-files command line, better than vimdiff without vimrc config ----------
edf () {
    emacs -nw -q --eval \
          "(progn (menu-bar-mode 0) (global-display-line-numbers-mode) (load-theme 'tango) (setq ediff-split-window-function 'split-window-horizontally) (ediff-files \"$1\" \"$2\"))"
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

alias rf='rm -rf'

if [ -e /etc/os-release ]; then
    if [ -n "$(grep -i arch /etc/os-release)" ]; then
        alias S='sudo pacman -S '
        alias Ss='sudo pacman -Ss '
        alias Qo='sudo pacman -Qo '
        alias Qi='sudo pacman -Qi '
        alias Fl='sudo pacman -Fl '
        alias Fy='sudo pacman -Fy '
        alias Syu='sudo pacman -Syu '
    fi
    if [ -n "$(grep -i centos /etc/os-release)" ]; then
        alias S='sudo yum install '
        alias Ss='sudo yum search '
        alias Qo='sudo yum whatprovides '
        alias Qi='sudo yum deplist '
        alias Fl='sudo repoquery -l '
        alias Fy='sudo yum makecache '
        alias Syu='sudo yum update '
    fi
    if [ -n "$(grep -i ubuntu /etc/os-release)" ]; then
        alias S='sudo apt-get install '
        alias Ss='sudo apt-cache search '
        alias Qo='sudo apt-file search '
        alias Qi='sudo apt-cache show '
        alias Fl='sudo apt-file list '
        alias Fy='sudo apt-get update && sudo apt-file update '
        alias Syu='sudo apt-get upgrade '
    fi
fi

if [ -e /usr/bin/nvim ]; then
    alias vi=nvim
elif [ -e /usr/bin/vim ]; then
    alias vi=vim
fi

alias emacsd='\emacs -nw --daemon'
alias emacs='emacsclient -nw '
alias mpv='mpv --hwdec=yes '

########## END ALIASes ############

export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland-egl
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland

GO_WORKING_DIR=~/godir
GO_OTHER_PKG_DIR=
export GO_PLAYGROUND_BASE_DIR="$GO_WORKING_DIR/src/goplayground"
export GOPATH=$GO_WORKING_DIR:$GO_OTHER_PKG_DIR
export PATH=$GO_WORKING_DIR/bin:$PATH
# export TERM=xterm-256color
export TERM=xterm-24bit         # true color support, refer to terminal-truecolor-setup

########## Config color for less used by manpages as a pager ##########
# https://github.com/jeaye/stdman
# Colors
default=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
purple=$(tput setaf 5)
orange=$(tput setaf 9)

# Less colors for man pages
export PAGER=less
# Begin blinking
export LESS_TERMCAP_mb=$red
# Begin bold
export LESS_TERMCAP_md=$orange
# End mode
export LESS_TERMCAP_me=$default
# End standout-mode
export LESS_TERMCAP_se=$default
# Begin standout-mode - info box
export LESS_TERMCAP_so=$purple
# End underline
export LESS_TERMCAP_ue=$default
# Begin underline
export LESS_TERMCAP_us=$green

########## END Config color for less ##########

# keychain ssh agent, Funtoo keychain needed
if [ -f ~/.ssh/id_dsa ]; then
    eval `keychain --eval --agents ssh id_dsa`
fi
if [ -f ~/.ssh/id_rsa ]; then
    eval `keychain --eval --agents ssh id_rsa`
fi

export PS1="\[\e[0m\]\n\[\e[1;36m\][\d \t] \[\e[1;33m\]\u@\h \[\e[1;31m\]\w \n\[\e[1;31m\]⌘ \$ \[\e[0m\]"
