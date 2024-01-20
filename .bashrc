#!/bin/bash
#
#  _______
#  \_   _|
#    |_|horbits 
#
# My bash config, the following packages are required: 
# autojump bc curl eza feh figlet iftop lolcat lm-sensors nala man-db neofetch neovim pv rsync sudo vim


# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Enable bash programmable completion features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	.  /etc/bash_completion
fi

for file in ~/.{bash_prompt,aliases,functions,exports}; do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		# shellcheck source=/dev/null
		source "$file"
	fi
done

unset file
