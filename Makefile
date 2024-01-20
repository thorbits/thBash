SHELL := bash

.PHONY: all
all: dotfiles

.PHONY: dotfiles
dotfiles: ## Installs the dotfiles.
for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github"); do \
    f=$$(basename $$file); \
    cp $$file /$$f; \
done; \

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
