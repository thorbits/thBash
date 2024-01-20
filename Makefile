SHELL := bash

.PHONY: install
install: ## Installs the dotfiles.
	@for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github"); do \
	    f=$$(basename $$file); \
	    cp $$file ${HOME}/$$f; \
	done
