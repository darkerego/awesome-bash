# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
	#export PS1="\u@\h:\W\[\e[31m\]\\$\[$(tput sgr0)\] "
        export PS1="\u@\h:\w\[\e[31m\]\\$\[\e[m\] "
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -A'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p -v'
alias df='df -h'
alias du='du -h -c'
alias reload='source ~/.bashrc'
alias biggest='BLOCKSIZE=1048576; du -x | sort -nr | head -10'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

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

# Base 64 En/Decode
decode () {
  echo "$1" | base64 -d ; echo
}

encode () {
  echo "$1" | base64 ; echo
}

# Easy extract
extract () {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       rar x $1       ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)           echo "don't know how to extract '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}
# gzip directory
alias compress=cgz $@
# Makes directory then moves into it

genpass() {
        local l=$1
        [ "$l" == "" ] && l=16
        tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs | tee -a .pass
}

encrypt(){
  case $1 in
  -e) echo $2 | openssl enc -base64 -aes-128-cbc -a -salt -pass pass:$3
  ;;
  -f) cat $2 | openssl enc -base64 -aes-128-cbc -a -salt -pass pass:$3
  ;;
  -h|--help) echo "Encrypt a file/string with AES-128-CBC w/ Base64 "
             echo "                   encrypt -e <string> <password>"
             echo "                   encrypt -f <file> <password>  "
  ;;
  esac
}


decrypt(){
  case $1 in
  -e) echo $2 | openssl enc -d -base64 -aes-128-cbc -a -salt -pass pass:$3
  ;;
  -f) cat $2 | openssl enc -d -base64 -aes-128-cbc -a -salt -pass pass:$3
  ;;
  -h|--help) echo  "Decrypt a file/string with AES-128-CBC w/ Base64 "
             echo   "                  decrypt -e <string> <password>"
             echo   "                  decrypt -f <file> <password>"
  ;;
  esac
}




function mkcd() {
  mkdir -p -v $1
  cd $1
}

function cpserver(){

case $1 in
-w|--web)
scp $2 "$3"://var/www/html/$1
;;
-n|--new|-home)
scp $2 "$3"://home/ghost/new
;;
-h|--help|*)
echo -e "USAGE: cpserver -w|-n file server
-w Put in web srv dir. 
-n Put in ~/new.
-h Show this shelp"
;;
esac

}

# Creates an archive from given directory
mktar() { tar cvf  "${1%%/}.tar"     "${1%%/}/"; }
mktgz() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }
mktbz() { tar cvjf "${1%%/}.tar.bz2" "${1%%/}/"; }

### ALIASES

## Keeping things organized


## Moving around & all that jazz
alias back='cd $OLDPWD'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

## Dir shortcuts
#alias home='cd ~/'
alias docs='cd ~/Documents'
alias dls='cd ~/Downloads'
#alias books='cd ~/eBooks'
#alias images='cd ~/Images'
#alias packages='cd ~/Packages'
#alias aruby='cd ~/Ruby'
#alias torrents='cd ~/Torrents'
#alias videos='cd ~/Videos'
#alias webdesign='cd ~/Web\ Design'
#alias localhost='cd /var/www'

# Development Aliases
#
alias bin='cd ~/bin'
alias ccmips='export PATH=$PATH:$toolchain'
alias mips-gcc='/home/$USER/Source/cross-compiler-mips/bin/mips-gcc'

make_mips(){
export PATH=$PATH:/home/$USE/Source/cross-compiler-mips/bin
make CC=mips-gcc LD=mips-ld RANLIB=mips-ranlib STRIP="mips-strip --strip-all"
}



weather(){ curl -s "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=${@:-<YOURZIPORLOCATION>}"|perl -ne '/<title>([^<]+)/&&printf "%s: ",$1;/<fcttext>([^<]+)/&&print $1,"\n"';}


alias urle='python -c "import urllib, sys; print urllib.quote(  sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read()[0:-1])"'

alias urld='python -c "import urllib, sys; print urllib.unquote(sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read()[0:-1])"'

urlencode() {
    # urlencode <string>
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c"
        esac
    done
}

urldecode() {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

subnets(){
cat $1 | sort -u | cut -d "." -f -3 | sed 's/$/.*/'
}

getIp(){
curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'
}

proxup(){
ssh -D 1080 "$@"
echo "Status: $?"
}

sprunge(){
cat "$@" |proxychains curl -F 'sprunge=<-' http://sprunge.us 
}
alias spr="curl -F 'sprunge=<-' http://sprunge.us"
