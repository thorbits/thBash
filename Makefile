SHELL := bash

.PHONY: install
install: ## Installs the dotfiles.
	@for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github"); do \
	    f=$$(basename $$file); \
	    cp $$file ${HOME}/$$f; \
	done
	@echo
	@printf '    '
	@for item in \\ \| / - \\ \| / - \\ \| / - \\ \| / - \\ \| / - \\ \| / -; do echo -ne "$item \r"; sleep .2; done
	@echo -e "\r    \r"  # Clear the spinner
	@seq -s '*' 60 | tr -dc '[*\n]'
	@echo "    Dotfiles installed. Press ENTER to restart the shell."
	@seq -s '*' 60 | tr -dc '[*\n]'
	@read -p ""
	@clear
	@exec ${SHELL}  # Restart the shell
	@exit 0
