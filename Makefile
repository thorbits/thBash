SHELL := bash

.PHONY: install
install: ## Installs the dotfiles.
	@for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github"); do \
	    f=$$(basename $$file); \
	    cp $$file ${HOME}/$$f; \
	done
	@echo -e "\r"
	@seq -s '*' 60 | tr -dc '[*\n]'
	@echo "    Dotfiles installed. Press ENTER to restart the shell."
	@seq -s '*' 60 | tr -dc '[*\n]'
	@read -p ""
	@clear
	@exit 0
	@exec ${SHELL}  # Restart the shell
