#!/bin/bash
iatest=$(expr index "$-" i)

#######################################################
#		EXPORTS
#######################################################

# Disable the bell
if [[ $iatest > 0 ]]; then bind "set bell-style visible"; fi

export HISTFILESIZE=10000
export HISTSIZE=500
export HISTCONTROL=erasedups:ignoredups:ignorespace

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

# SHOPT
shopt -s autocd # change to named directory
shopt -s cdspell # autocorrects cd misspellings
shopt -s cmdhist # save multi-line commands in history as single line
shopt -s histappend # do not overwrite history
shopt -s expand_aliases # expand aliases
shopt -s checkwinsize # checks term size when bash regains control

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest > 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest > 0 ]]; then bind "set show-all-if-ambiguous On"; fi

#######################################################
#		ALIASES
#######################################################

# To temporarily bypass an alias, we precede the command with a \
# EG: the ls command is aliased, but to use the normal ls command you would type \ls
# alias ls='ls -phalANXgs --color=auto --time-style=iso --no-group --group-directories-first'

# Changing "ls" to "eza"
alias ls='eza -al --color=always --group-directories-first' # my preferred listing
alias la='eza -a --color=always --group-directories-first'  # all files and dirs
alias ll='eza -l --color=always --group-directories-first'  # long format
alias lt='eza -aT --color=always --group-directories-first' # tree listing
alias l.='eza -a | egrep "^\."'

alias sudo='sudo '
alias nf='neofetch'
alias update='nala update && nala full-upgrade'
alias vbrc='vim ~/.bashrc'

#######################################################
#		FUNCTIONS
#######################################################

# Automatically do an ls after each cd
# cd ()
# {
# 	if [ -n "$1" ]; then
# 		builtin cd "$@" && ls
# 	else
# 		builtin cd ~ && ls
# 	fi
# }

# Sends a request to the ipinfo.io API to get the public IP address
get_pip () { 
  local ip
  ip=$(curl -sS ipinfo.io/ip 2>/dev/null) || { echo "Error fetching public IP address"; return 1; }
  echo "$ip"
}

# Extracts any archive(s), usage: extract archive1.tar.gz archive2.zip
extract () { 
  for archive in "$@"; do 
  if [ -f "$archive" ]; then case $archive in *.tar.bz2) tar xjf "$archive" ;; *.tar.gz) tar xzf "$archive" ;; *.bz2) bunzip2 "$archive" ;; *.rar) unrar x "$archive" ;; *.gz) gunzip "$archive" ;; *.tar) tar xvf "$archive" ;; *.tbz2) tar xjf "$archive" ;; *.tgz) tar xzf "$archive" ;; *.zip) unzip "$archive" ;; *.Z) uncompress "$archive" ;; *.7z) 7z x "$archive" ;; *.deb) ar x "$archive" ;; *.tar.xz) tar xf "$archive" ;; *.tar.zst) unzstd "$archive" ;; *) echo "'$archive' cannot be extracted" ;; esac else 
  echo "'$archive' is not a valid file!"
  fi
  done
}

# Display CPU temperature (Sensors)
get_temp () { 
	# Check if 'sensors' command is available
	if command -v sensors &>/dev/null; then
	# Extract CPU temperature using 'sensors'
	local cpu_temperature=$(sensors | grep "Core 0" | awk '{print $3}')
        # Check if temperature is not empty
        if [ -n "$cpu_temperature" ]; then
		echo "CPU Temperature: $cpu_temperature"
        else
		echo "Unable to retrieve CPU temperature."
        	fi
	else
        echo "Error: 'lm-sensors' is not installed"
	fi
}

# Colored countdown (Figlet Lolcat)
cdown () { 
    N=$1 # Capture the argument as N
  # Start a while loop that continues until N is greater than 0
    while ((N-- > 0)); do
    # Display the current countdown number using figlet for ASCII art
    # and lolcat for colored output, then sleep for 1 second
        echo "$N" | figlet -c | lolcat && sleep 1
    done
}

# Copy file with a progress bar (Rsync)
cppb () { 
    # Check if rsync is available
     if ! command -v rsync &>/dev/null; then
	     echo "Error: 'rsync' is not installed"
	     return 1
     fi
    # Check the number of arguments
     if [[ "$#" -ne 2 ]]; then
	     echo "Usage: cppb source_file destination_file"
	     return 1
     fi
    # Run rsync with --progress option
    rsync --progress "$1" "$2"
}

# Copy file with a progress bar (Pipe Viewer)
cppv () { 
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: cppv source_file destination"
        return 1
    fi
    # Check if pv is available
    if ! command -v pv > /dev/null; then
        echo "Error: 'pv' is not installed"
        return 1
    fi
    # Use pv to display a progress bar during copy
    pv "$1" > "$2"
}

# Copy and go to the directory
cpg () { 
	if [ -d "$2" ];then
		cp "$1" "$2" && cd "$2"
	else
		cp "$1" "$2"
	fi
}

# Move and go to the directory
mvg () { 
	if [ -d "$2" ];then
		mv "$1" "$2" && cd "$2"
	else
		mv "$1" "$2"
	fi
}

# Create and go to the directory
mkdirg () { 
	mkdir -p "$1"
	cd "$1"
}

# Sum the number of files and sub-directories at the current prompt
lsfiledirsum () { 
	local total_count=$(find . -maxdepth 1 -mindepth 1 -exec echo x \; | wc -l)
	local file_count=$(find . -maxdepth 1 -type f | wc -l)
	local dir_count=$(($total_count - $file_count))
	echo "$dir_count folder(s) $file_count file(s)"
}

# Sum the number of bytes in the current directory
lsbytesum () { 
    local totalBytes=0
    
	# Use find to get a list of regular files in the current directory
	while IFS= read -r -d '' file; do 
		[[ -f "$file" ]] && ((totalBytes += $(stat -c %s "$file" 2>/dev/null)))
		done < <(find . -maxdepth 1 -type f -print0)
	# Check if bc is available before using it
	if command -v bc &>/dev/null; then
		totalMegabytes=$(echo "scale=3; $totalBytes/1048576" | bc)
		printf "%.3f\n" "$totalMegabytes"
	else
		echo "Error: 'bc' is not installed"
	fi
}

# GitHub additions
gitpush () { 
	cp ~/.bashrc ~/mybashrc
	cd ~/mybashrc
	git add .
	git commit -m .bashrc
	git push -u -f origin main
	{ printf 36136807+thorbits@users.noreply.github.com\n; }
}

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

# alias cpu="grep 'cpu ' /proc/stat | awk '{usage=(\$2+\$4)*100/(\$2+\$4+\$5)} END {print usage}' | awk '{printf(\"%.1f\n\", \$1)}'"

export PS1="\$(tput sc)\$(tput rev)\[\033[1;\$(echo -n \$((\$COLUMNS-45)))H\]\d \174 \$(get_pip) \174 \l \s v\v\$(tput sgr0)\$(tput rc)\n$LINE_UPPER_CORNER$LINE_STRAIGHT$LINE_STRAIGHT\174\t\174$LINE_STRAIGHT\174$C8\u$c8\100\h\174$LINE_STRAIGHT\174$C8\$(pwd)$c8: \$(lsfiledirsum) \$(lsbytesum)Mb\174\n$LINE_BOTTOM_CORNER$LINE_STRAIGHT$LINE_BOTTOM\174\[$(tput sgr0)\] "

# export PS1="\$(tput sc)\$(tput rev)\[\033[1;\$(echo -n \$((\$COLUMNS-45)))H\]\d \174 \$(get_pip) \174 \l \s v\v\$(tput sgr0)\$(tput rc)\n$LINE_UPPER_CORNER$LINE_STRAIGHT$LINE_STRAIGHT\174\t\174$LINE_STRAIGHT\174$C8\u$c8\100\h\174$LINE_STRAIGHT\174$C8\$(pwd)$c8: \$(/bin/ls -A -1 | /usr/bin/wc -l) file(s) \$(/bin/ls -lah | /bin/grep -m 1 total | /bin/sed 's/total //')\174\n$LINE_BOTTOM_CORNER$LINE_STRAIGHT$LINE_BOTTOM\174\[$(tput sgr0)\] "
