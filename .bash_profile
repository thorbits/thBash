#!/bin/bash
#
#  _______
#  \_   _|
#    |_|horbits 
#
# My bash config

# Load .bashrc, which loads: ~/.{bash_prompt,aliases,functions,path,extra,exports}
if [[ -r "${HOME}/.bashrc" ]]; then
	source "${HOME}/.bashrc"
fi
