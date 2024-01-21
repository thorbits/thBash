SHELL := bash

.PHONY: install
install: ## Installs the dotfiles.
	@for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github"); do \
	    f=$$(basename $$file); \
	    cp $$file ${HOME}/$$f; \
	done
	@echo "Dotfiles installed. Press ENTER to restart your shell."
	@read -p ""
	@clear
	@exec ${SHELL}  # Restart the shell
	@exit 0

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
