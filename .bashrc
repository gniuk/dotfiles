# ~/.bashrc: executed by bash(1) for non-login shells (i.e. interactive shells)
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
# [[ $- != *i* ]] && return
case $- in
    *i*) ;;
      *) return;;
esac

############## HISTORY OPTIONS ################

# make C-s i-search, i.e. search forward
[[ $- == *i* ]] && stty -ixon

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
## This is horrible! Makes disaster when deleting files
# shopt -s nocaseglob

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

########## END OTHER SHELL OPTIONS ############

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

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
    # ssh -o ConnectTimeout=1 -o ConnectionAttempts=1 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -A -p $remote_port -J ${myname}@$svr1:$svr1_port ${myname}@$1 $2
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
    nl ~/.bash_history | sort -k 2 -k 1,1nr| uniq -f 1 | sort -n | cut -f 2 > ~/.tmp_history
    mv ~/.tmp_history ~/.bash_history
}

# ---------- ediff-files command line, better than vimdiff without vimrc config ----------
edf () {
    emacs -nw -q --eval \
          "(progn (menu-bar-mode 0) (global-display-line-numbers-mode) (load-theme 'tango) (setq ediff-split-window-function 'split-window-horizontally) (ediff-files \"$1\" \"$2\"))"
}

alias gdf='export GDF_FAST=no; git difftool -t meld '
alias gdff='export GDF_FAST=yes; git difftool -t meld '

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
# alias speed='speedtest-cli --server 2406 --simple'
alias speed='speedtest-cli --simple'

if [ -e /etc/os-release ]; then
    if [ -n "$(grep -i arch /etc/os-release)" ]; then
        alias S='sudo pacman -S '
        alias Ss='sudo pacman -Ss '
        alias Qo='sudo pacman -Qo '
        alias Qi='sudo pacman -Qi '
        alias Ql='sudo yay -Ql '
        alias Fl='sudo pacman -Fl '
        alias Fy='sudo pacman -Fy '
        alias Syu='sudo pacman -Syu '
    elif [ -n "$(grep -i centos /etc/os-release)" ]; then
        alias S='sudo yum install '
        alias Ss='sudo yum search '
        alias Qo='sudo yum whatprovides '
        alias Qi='sudo yum deplist '
        alias Fl='sudo repoquery -l '
        alias Fy='sudo yum makecache '
        alias Syu='sudo yum update '
    elif [ -n "$(grep -i -e debian -e ubuntu /etc/os-release)" ]; then
        alias S='sudo apt install '
#        alias Ss='sudo apt-cache search '
# use original apt to search; mint has a wrapper for apt, infomation is mess
# add --names-only option if search keyword in package's name only
        alias Ss='sudo /usr/bin/apt search '
        alias Qo='sudo apt-file search '
        alias Qi='sudo apt-cache show '
        alias Fl='sudo apt-file list '
        alias Fy='sudo apt update && sudo apt-file update '
        alias Syu='sudo apt upgrade '
    fi
fi

if [ -e /usr/bin/nvim ]; then
    alias vi=nvim
elif [ -e /usr/bin/vim ]; then
    alias vi=vim
fi

alias em='emacs --nw'
alias emacsd='\emacs -nw --daemon'
alias emc='emacsclient -nw'
alias mpv='mpv --hwdec=yes'
# alias x='sway'
alias x='startx'

########## END ALIASes ############

## for sway
if [[ -n "$(tty | grep pts)" && -n "$(ps x | grep [s]way)" ]]; then
    export GDK_BACKEND=wayland
    export QT_QPA_PLATFORM=wayland-egl
    export QT_WAYLAND_FORCE_DPI=physical
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export CLUTTER_BACKEND=wayland
    export SDL_VIDEODRIVER=wayland
    export ECORE_EVAS_ENGINE=wayland_egl
    export ELM_ENGINE=wayland_egl
    export _JAVA_AWT_WM_NONREPARENTING=1
fi

GO_WORKING_DIR=$HOME/go
# GO_OTHER_PKG_DIR=
export GO_PLAYGROUND_BASE_DIR="$GO_WORKING_DIR/src/goplayground"
# export GOPATH=$GO_WORKING_DIR:$GO_OTHER_PKG_DIR
export GOPATH=$GO_WORKING_DIR
export PATH=/usr/local/go/bin:$GOPATH/bin:$PATH
# export GOPROXY="https://mirrors.aliyun.com/goproxy,https://goproxy.cn,https://goproxy.io"
export GOPROXY="https://goproxy.cn,https://goproxy.io,direct"

if [ -d "$HOME/.terminfo" ]; then
    export TERM=xterm-24bit         # true color support, refer to terminal-truecolor-setup
    export COLORTERM=truecolor
else
    export TERM=xterm-256color
fi

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

# autojump settings
# git://github.com/wting/autojump.git
if [ -s ~/.autojump/etc/profile.d/autojump.sh ]; then
    source ~/.autojump/etc/profile.d/autojump.sh
elif [ -s /usr/share/autojump/autojump.sh ]; then
    . /usr/share/autojump/autojump.sh
fi

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PS1="\[\e[0m\]\n\[\e[1;36m\][\d \t] \[\e[1;33m\]\u@\h \[\e[1;31m\]\w \n\[\e[1;31m\]⌘ \$ \[\e[0m\]"
