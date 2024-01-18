#!/bin/bash

#  _______
#  \_   _|
#    |_|horbits 
#
# My bash config, the following packages are required: autojump bc curl eza figlet lolcat lm-sensors nala man-db neofetch neovim pv rsync sudo vim


#######################################################
#		EXPORTS
#######################################################

iatest=$(expr index "$-" i)

# Disable the bell
if [[ $iatest > 0 ]]; then bind "set bell-style visible"; fi

export HISTFILESIZE=10000
export HISTSIZE=500
# Avoid duplicate entries
export HISTCONTROL=erasedups:ignoredups:ignorespace
# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"

# "nvim" as manpager
export MANPAGER="nvim +Man!"

# Change title of terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|alacritty|st|konsole*)
	  PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
	  ;;
	screen*)
	  PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
	  ;;
esac

# SHOPT
shopt -s autocd # change to named directory
shopt -s cdspell # autocorrects cd misspellings
shopt -s cmdhist # save multi-line commands as single line
shopt -s histappend # do not overwrite history
shopt -s expand_aliases # expand aliases
shopt -s checkwinsize # checks term size when bash regains control

# Record each line as it gets issued
PROMPT_COMMAND='history -a'

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest > 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest > 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# Enable incremental history search with up/down arrows (also Readline goodness)
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\e[C": forward-char'
bind '"\e[D": backward-char'

# Prepend cd to directory names automatically
shopt -s autocd 2> /dev/null
# Correct spelling errors during tab-completion
shopt -s dirspell 2> /dev/null
# Correct spelling errors in arguments supplied to cd
shopt -s cdspell 2> /dev/null

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
# alias lt='eza -aT --color=always --group-directories-first' # tree listing
alias l.='eza -a | egrep "^\."'

alias lt="ls -R | grep ':$' | sed -e 's/:$//' -e 's/[^-][^/]*\//-- /g' -e 's/^/   /' -e 's/--/|/'"
alias ld='du -S | sort -n -r | more'
alias lf='du -h --max-depth=1 | more'

# 10 most used commands with their counts
alias h10="history | awk '{print \$2}' | sort | uniq -c | sort -nr | head"
# Generate a random 32 characters password
alias rpwd="tr -dc 'a-zA-Z0-9~!@#$%^&*_()+}{?></\";.,[]=-' < /dev/urandom | fold -w 32 | head -n 1"

# System commands
alias sudo='sudo '
alias reboot='if [ $(id -u) -eq 0 ]; then reboot; else sudo reboot; fi'
alias nf='neofetch'
alias vbrc='vim ~/.bashrc'

# Packages management
alias debupd="if [ $(id -u) -eq 0 ]; then nala update && nala full-upgrade; else sudo -s <<< 'nala update && nala full-upgrade'; fi"
#alias debupd='if [ $(id -u) -eq 0 ]; then nala update && nala full-upgrade; else sudo nala update && sudo nala full-upgrade; fi'
alias archupd='if [ $(id -u) -eq 0 ]; then pacman -Syyu --needed; else sudo pacman -Syyu --needed; fi'

# Github commands
alias gitcred='git config --global credential.helper store' # verify status with: git config --get-all --global credential.helper
alias pushbash='cp ~/.bashrc ~/mybashrc/.bashrc && cd ~/mybashrc && git add . && git commit -m "$(w3m whatthecommit.com | head -n 1)" .bashrc && git push -u -f origin main'

#######################################################
#		GENERAL FUNCTIONS
#######################################################

# Automatically do an ls after each cd
# cd()
# {
# 	if [ -n "$1" ]; then
# 		builtin cd "$@" && ls
# 	else
# 		builtin cd ~ && ls
# 	fi
# }

# Extracts any archive(s) to a specified directory, usage: extract -d /path/to/destination archive1.tar.gz archive2.zip
extract() { 
	local dest_dir="."  # default destination directory
	while getopts ":d:" opt; do
		case $opt in
			d)
				dest_dir="$OPTARG"
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				return 1
				;;
		esac
	done

	shift $((OPTIND - 1))

	for archive in "$@"; do
		if [ -f "$archive" ]; then
			echo "Extracting '$archive' to '$dest_dir'..."
			case $archive in
				*.tar.bz2)   tar xjf "$archive" -C "$dest_dir" ;;
				*.tar.gz)    tar xzf "$archive" -C "$dest_dir" ;;
				*.bz2)       bunzip2 "$archive" ;;
				*.rar)       unrar x "$archive" "$dest_dir" ;;
				*.gz)        gunzip "$archive" ;;
				*.tar)       tar xvf "$archive" -C "$dest_dir" ;;
				*.tbz2)      tar xjf "$archive" -C "$dest_dir" ;;
				*.tgz)       tar xzf "$archive" -C "$dest_dir" ;;
				*.zip)       unzip "$archive" -d "$dest_dir" ;;
				*.Z)         uncompress "$archive" ;;
				*.7z)        7z x "$archive" -o"$dest_dir" ;;
				*.deb)       ar x "$archive" -C "$dest_dir" ;;
				*.tar.xz)    tar xf "$archive" -C "$dest_dir" ;;
				*.tar.zst)   unzstd "$archive" -d "$dest_dir" ;;
				*)
					echo "Unsupported archive format: '$archive'" >&2
					continue
					;;
			esac
			echo "Extraction of '$archive' completed successfully."
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

# Display CPU temperature (lm-Sensors)
get_temp() { 
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

# Display a progress bar
pbar() { 
	local duration
	local columns
	local space_available
	local fit_to_screen
	local space_reserved

	space_reserved=6   # reserved for % value
	duration=${1}
	columns=$(tput cols)
	space_available=$(( columns-space_reserved ))

	if (( duration < space_available )); then 
		fit_to_screen=1;
	else 
		fit_to_screen=$(( duration / space_available ));
		fit_to_screen=$((fit_to_screen+1));
	fi

	already_done() { for ((done=0; done<(elapsed / fit_to_screen) ; done=done+1 )); do printf ">" | lolcat; done }
	remaining() { for (( remain=(elapsed/fit_to_screen) ; remain<(duration/fit_to_screen) ; remain=remain+1 )); do printf " "; done }
	percentage() { printf "| %s%%" $(( ((elapsed)*100)/(duration)*100/100 )) | lolcat; }
	clean_line() { printf "\r"; }

	for (( elapsed=1; elapsed<=duration; elapsed=elapsed+1 )); do
		already_done; remaining; percentage
		sleep 1
		clean_line
	done
	clean_line
}

# Colored countdown (figlet lolcat)
cdown() { 
    N=$1 # Capture the argument as N
  # Start a while loop that continues until N is greater than 0
    while ((N-- > 0)); do
    # Display the current countdown number using figlet for ASCII art
    # and lolcat for colored output, then sleep for 1 second
        echo "$N" | figlet -c | lolcat && sleep 1
    done
}

# Copy file with a progress bar (rsync)
cppb() { 
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

# Copy file with a progress bar (pv)
cppv() { 
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
cpg() {
    local source="$1"
    local destination="$2"

    if [ -d "$destination" ]; then
        cp "$source" "$destination" && cd "$destination" || return 1
    else
        cp "$source" "$destination" || return 1
    fi
}

# Move and go to the directory
mvg() {
    local source="$1"
    local destination="$2"

    if [ -d "$destination" ]; then
        mv "$source" "$destination" && cd "$destination" || return 1
    else
        mv "$source" "$destination" || return 1
    fi
}

# Create and go to the directory
mkcd(){ NAME=$1; mkdir -p "$NAME"; cd "$NAME"; }

# Start a script depending on the installed distro (autojump)
autojump() { 
	distro=$(lsb_release -si 2>/dev/null || cat /etc/os-release | grep '^ID=' | cut -d= -f2)
	case $distro in
		"Debian")
			if [ -f "/usr/share/autojump/autojump.sh" ]; then
				. /usr/share/autojump/autojump.sh
			elif [ -f "/usr/share/autojump/autojump.bash" ]; then
				. /usr/share/autojump/autojump.bash
			else
				echo "Can't find the autojump script."
			fi
			;;
		"arch")
			;;
		"fedora")
			;;
		*)
			echo "Unsupported distribution: $distro"
			;;
	esac
}


#######################################################
#		DRAW BAR
#######################################################

# Show some shell infos
shell_info() { 
	local bash_name=$(ps -p $$ -o comm=)
	local shell_version=$BASH_VERSION
	echo "   | $bash_name v$shell_version"
}

# Sends a request to the ipinfo.io API to get the public IP address
get_pip() { 
	local ip
	ip=$(curl -sS ipinfo.io/ip 2>/dev/null) || { echo "Error fetching public IP address"; return 1; }
	echo "$ip"
}

# Show memory usage
memusage() { 
	# Use the free command to get memory information
	local mem_info=$(free --mega -h | grep "Mem:")
	# Extract used memory and total memory
	local used_memory=$(echo "$mem_info" | awk '{print $3}')
	local total_memory=$(echo "$mem_info" | awk '{print $2}')
	# Display the result
	echo "MEM: $used_memory / $total_memory"
}

# Show current date
get_date() { 
	date "+%a-%d-%b"
}

# Menu style bar on top of screen
draw_bar() { 
	# local menu_height=1
	# local menu_width=$(tput cols)
	# while true; do
		# tput cup 0 0
		printf '\033[K%s' "$(tput sc)$(tput cup 0 0)$(tput rev)$(shell_info)$(printf '%*s' $((COLUMNS-95)) ' ') | $(cpu) | $(memusage) | $(lip) | $(get_date)$(tput sgr0)$(tput rc)"
	# for ((i=1; i<=menu_height; i++)); do
	# 	printf "\n"
	#	done
	# sleep 2
	# done
}


#######################################################
#		PROMPT
#######################################################

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
            # Increment totalBytes by the size of each regular file
            ((totalBytes += $(stat -c %s "$file" 2>/dev/null)))
        fi
    done < <(find . -maxdepth 1 -type f -print0)

    # Check if bc is available before using it
    if command -v bc &>/dev/null; then
        # Calculate totalMegabytes and print the result
        totalMegabytes=$(echo "scale=3; $totalBytes/1048576" | bc)
        printf "%.3f\n" "$totalMegabytes"
    else
        echo "Error: 'bc' is not installed"
    fi
}

alias cpu="echo 'CPU: $(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf("%.1f\n", usage)}')%'"
alias pwd='pwd | sed "s#\(/[^/]\{1,\}/[^/]\{1,\}/[^/]\{1,\}/\).*\(/[^/]\{1,\}/[^/]\{1,\}\)/\{0,1\}#\1_\2#g"'
alias lip="ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1'"
alias dirsize="du -cshx | awk 'END {print $1}'"

function __setprompt
{
	local LAST_COMMAND=$? # Must come first!

	# Define colors
	local c1='\[\033[0;30m\]' # Color black
	local C1='\[\033[1;30m\]' # Bold color
	local c2='\[\033[0;31m\]' # Color red
	local C2='\[\033[1;31m\]' # Bold color
	local c3='\[\033[0;32m\]' # Color green
	local C3='\[\033[1;32m\]' # Bold color
	local c4='\[\033[0;33m\]' # Color yellow
	local C4='\[\033[1;33m\]' # Bold color
	local c5='\[\033[0;34m\]' # Color blue
	local C5='\[\033[1;34m\]' # Bold color
	local c6='\[\033[0;35m\]' # Color purple
	local C6='\[\033[1;35m\]' # Bold color
	local c7='\[\033[0;36m\]' # Color cyan
	local C7='\[\033[1;36m\]' # Bold color
	local c8='\[\033[0;37m\]' # Color white
	local C8='\[\033[1;37m\]' # Bold color
	local NC='\[\033[0m\]'    # Default color

	# Define line characters
	local LINE_BOTTOM='\342\224\200'
	local LINE_BOTTOM_CORNER='\342\224\224'
	local LINE_STRAIGHT='\342\224\200'
	local LINE_UPPER_CORNER='\342\224\214'

	local t1_bg='\[$(tput setab 31)\]'
	local t1_fg='\[$(tput setaf 31)\]'
	local t2_bg='\[$(tput setab 69)\]'
	local t2_fg='\[$(tput setaf 69)\]'
	local RESET='\[$(tput sgr0)\]'

	local tr1=$(echo -e "${t1_fg}${t2_bg}E0B0${RESET}")
	local tr2=$(echo -e "${t2_fg}E0B0")
	
	# Show error exit code if there is one
	if [[ $LAST_COMMAND != 0 ]]; then
		PS1="   \174Exit Code: $c2${LAST_COMMAND} ("
		if [[ $LAST_COMMAND == 1 ]]; then
			PS1+="General error"
		elif [ $LAST_COMMAND == 2 ]; then
			PS1+="Missing keyword, command, or permission problem"
		elif [ $LAST_COMMAND == 126 ]; then
			PS1+="Permission problem or command is not an executable"
		elif [ $LAST_COMMAND == 127 ]; then
			PS1+="Command not found"
		elif [ $LAST_COMMAND == 128 ]; then
			PS1+="Invalid argument to exit"
		elif [ $LAST_COMMAND == 129 ]; then
			PS1+="Fatal error signal 1"
		elif [ $LAST_COMMAND == 130 ]; then
			PS1+="Script terminated by Control-C"
		elif [ $LAST_COMMAND == 131 ]; then
			PS1+="Fatal error signal 3"
		elif [ $LAST_COMMAND == 132 ]; then
			PS1+="Fatal error signal 4"
		elif [ $LAST_COMMAND == 133 ]; then
			PS1+="Fatal error signal 5"
		elif [ $LAST_COMMAND == 134 ]; then
			PS1+="Fatal error signal 6"
		elif [ $LAST_COMMAND == 135 ]; then
			PS1+="Fatal error signal 7"
		elif [ $LAST_COMMAND == 136 ]; then
			PS1+="Fatal error signal 8"
		elif [ $LAST_COMMAND == 137 ]; then
			PS1+="Fatal error signal 9"
		elif [ $LAST_COMMAND -gt 255 ]; then
			PS1+="Exit status out of range"
		else
			PS1+="Unknown error code"
		fi
		PS1+=")$NC\174\n"
	else
		PS1=""
	fi

	# Menu style bar on top of screen
	# PS1+="$(draw_bar)"
	PS1+="\[$(tput sc)\$(tput cup 0)$(tput rev)$(shell_info)$(printf '%*s' $((COLUMNS-95)) ' ') \174 $(cpu) \174 $(memusage) \174 $(lip) \174 $(get_date) $RESET\$(tput rc)\n"
	
	# Prompt begins
	PS1+="$LINE_UPPER_CORNER$LINE_STRAIGHT$LINE_STRAIGHT\174$(date +'%-I':%M:%S%P)\174$LINE_STRAIGHT"

	# Change username color if normal user or root
	if [[ $EUID -ne 0 ]]; then
		PS1+="\174$C8\u$c8@\h"
	else
		PS1+="\174$c2\u$c8@\h"
	fi

	# Current directory detailed info
	PS1+="\174$LINE_STRAIGHT\174$C8\$(pwd)$c8: $(lsfiledirsum) $(lsbytesum)Mb / $(dirsize) $(autojump)"

	# Change cursor color if normal user or root
	PS1+="\n$LINE_BOTTOM_CORNER$LINE_STRAIGHT$LINE_BOTTOM\174"

	if [[ $EUID -ne 0 ]]; then
		PS1+=$'\u2192 '
	else
		PS1+="$c2>$RESET "
	fi

	# PS2 is used to continue a command using the \ character
	PS2="$C1>$NC "
}
PROMPT_COMMAND="__setprompt; $PROMPT_COMMAND"

