#!/bin/bash
#
#  _______
#  \_   _|
#    |_|horbits 
#
# My bash config


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

for file in ~/.{bash_prompt,aliases,exports,functions}; do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		# shellcheck source=/dev/null
		source "$file"
	fi
done

unset file
