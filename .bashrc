#!/bin/bash

#######################################################
#		EXPORTS
#######################################################

# Setting environment variables
if [ -z "$XDG_CONFIG_HOME" ] ; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi
if [ -z "$XDG_DATA_HOME" ] ; then
    export XDG_DATA_HOME="$HOME/.local/share"
fi
if [ -z "$XDG_CACHE_HOME" ] ; then
    export XDG_CACHE_HOME="$HOME/.cache"
fi

# Disable the bell
if [[ $iatest -gt 0 ]]; then
    bind "set bell-style visible"
fi

# Configure Bash to ignore case during auto-completion
# Note: Using 'bind' instead of adding to .inputrc directly
# Check if $iatest is greater than 0
if [[ $iatest -gt 0 ]]; then
    # Enable case-insensitive auto-completion
    bind "set completion-ignore-case on"
fi

# Configure Bash to automatically show auto-completion list without double tab
# Note: Using 'bind' instead of adding to .inputrc directly
# Check if $iatest is greater than 0
if [[ $iatest -gt 0 ]]; then
    # Enable automatic display of auto-completion list when ambiguous
    bind "set show-all-if-ambiguous On"
fi

# Sends a request to the ipinfo.io API to get the public IP address
get_pip() {
    local ip
    ip=$(curl -sS ipinfo.io/ip)
    echo "$ip"
}

# Extracts any archive(s)
extract () {
    for archive in "$@"; do
        if [ -f "$archive" ] ; then
                case $archive in
                *.tar.bz2)   tar xvjf $archive    ;;
                *.tar.gz)    tar xvzf $archive    ;;
                *.bz2)       bunzip2 $archive     ;;
                *.rar)       rar x $archive       ;;
                *.gz)        gunzip $archive      ;;
                *.tar)       tar xvf $archive     ;;
                *.tbz2)      tar xvjf $archive    ;;
                *.tgz)       tar xvzf $archive    ;;
                *.zip)       unzip $archive       ;;
                *.Z)         uncompress $archive  ;;
                *.7z)        7z x $archive        ;;
                *)           echo "don't know how to extract '$archive'..." ;;
                esac
        else
                echo "'$archive' is not a valid file!"
        fi
    done
}

# Sum the number of files and sub-directories at the current prompt
lsfiledirsum() {
    local total_count=$(find . -maxdepth 1 -mindepth 1 -exec echo x \; | wc -l)
    local file_count=$(find . -maxdepth 1 -type f | wc -l)
    local dir_count=$(($total_count - $file_count))
    echo "$dir_count folder(s) $file_count file(s)"
}

# Sum the number of bytes in the current directory
lsbytesum() {
    local totalBytes=0

    # Use find to get a list of regular files in the current directory
    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            size=$(stat -c %s "$file" 2>/dev/null)
            ((totalBytes += size))
        fi
    done < <(find . -maxdepth 1 -type f -print0)

    # Check if bc is available before using it
    if command -v bc &>/dev/null; then
        totalMegabytes=$(echo "scale=3; $totalBytes/1048576" | bc)
        printf "%.3f\n" "$totalMegabytes"
    else
        echo "bc is not available, unable to convert bytes to megabytes."
    fi
}

#######################################################
#		ALIASES
#######################################################

alias ls='ls -phalANXgs --color=auto --time-style=iso --no-group --group-directories-first'
alias sudo='sudo '
alias nf='neofetch'
alias update='nala update && nala full-upgrade'
alias vbrc='vim ~/.bashrc'

#######################################################
#		PROMPT
#######################################################

# Color Variables
c1='\[\033[0;30m\]' # Non-bold color black
C1='\[\033[1;30m\]' # Bold color
c2='\[\033[0;31m\]' # Non-bold color red
C2='\[\033[1;31m\]' # Bold color
c3='\[\033[0;32m\]' # Non-bold color green
C3='\[\033[1;32m\]' # Bold color
c4='\[\033[0;33m\]' # Non-bold color yellow
C4='\[\033[1;33m\]' # Bold color
c5='\[\033[0;34m\]' # Non-bold color blue
C5='\[\033[1;34m\]' # Bold color
c6='\[\033[0;35m\]' # Non-bold color purple
C6='\[\033[1;35m\]' # Bold color
c7='\[\033[0;36m\]' # Non-bold color cyan
C7='\[\033[1;36m\]' # Bold color
c8='\[\033[0;37m\]' # Non-bold color white
C8='\[\033[1;37m\]' # Bold color
NC='\[\033[0m\]'    # Back to default color

# Define line characters
LINE_BOTTOM="\342\224\200"
LINE_BOTTOM_CORNER="\342\224\224"
LINE_STRAIGHT="\342\224\200"
LINE_UPPER_CORNER="\342\224\214"

export PS1="$c8\$(tput sc)\[\033[1;\$(echo -n \$((\$COLUMNS-45)))H\]\d \174 \$(get_pip) \174 \l \s v\v\$(tput rc)\n$LINE_UPPER_CORNER$LINE_STRAIGHT$LINE_STRAIGHT\174\t\174$LINE_STRAIGHT\174$C8\u$c8\100\h\174$LINE_STRAIGHT\174$C8\$(pwd)$c8: \$(lsfiledirsum) \$(lsbytesum)Mb\174\n$LINE_BOTTOM_CORNER$LINE_STRAIGHT$LINE_BOTTOM\174\[$(tput sgr0)\] "


#######################################################
#		TESTING ONLY
#######################################################

export PS1="\e[s\e[0;0H\e[0;32m\l \s v\v \t\n\e[;0m\e[u\n$C8\u$c8@$c8\h - \$(pwd):$C8 \$(lsfilesum) files \$(lsbytesum)Mb\n> "

export PS1="\e[s\e[0;0H\e[1;37m\l \s v\v \t\n\e[;0m\e[u\u@\h: \$(pwd)\n> "

export PS1="$C8\u$c8@$c8\h - \$(pwd): \$(lsfilesum)files \$(lsbytesum)Mb\n$c3> $C8"


