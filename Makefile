SHELL := bash

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

OPENCODE_ITEMS := commands skills AGENTS.md opencode.json package.json oh-my-openagent.json plugins scripts

.PHONY: all install bashrc zshrc nvim opencode git tig tmux scripts uninstall check help

all: install

help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Usage:"
	@echo "  make install   - Install all dotfiles"
	@echo "  make uninstall - Remove symlinks"
	@echo "  make check     - Check installation status"
	@echo ""
	@echo "Individual targets:"
	@echo "  make zshrc     - Install zsh configuration (symlinks + clone p10k/plugins)"
	@echo "  make bashrc    - Install bash configuration (legacy, not in install)"
	@echo "  make nvim      - Install neovim configuration"
	@echo "  make opencode  - Install OpenCode configuration (opencode.json, AGENTS.md, commands/, skills/, plugins/)"
	@echo "  make git       - Install git configuration"
	@echo "  make tig       - Install tig configuration"
	@echo "  make tmux      - Install tmux configuration"
	@echo "  make scripts   - Install utility scripts to ~/bin"

install: zshrc nvim opencode git tig tmux scripts
	@echo "✓ Dotfiles installed successfully"

zshrc:
	@echo "Installing zsh configuration..."
	@ln -sf $(ROOT_DIR)/.aliases $(HOME)/.aliases
	@ln -sf $(ROOT_DIR)/.zshrc $(HOME)/.zshrc
	@ln -sf $(ROOT_DIR)/.p10k.zsh $(HOME)/.p10k.zsh
	@[ -d $(HOME)/powerlevel10k ] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $(HOME)/powerlevel10k
	@mkdir -p $(HOME)/.zsh
	@[ -d $(HOME)/.zsh/zsh-autosuggestions ] || git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions $(HOME)/.zsh/zsh-autosuggestions
	@[ -d $(HOME)/.zsh/zsh-syntax-highlighting ] || git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting $(HOME)/.zsh/zsh-syntax-highlighting
	@echo "✓ Zsh configuration installed"

bashrc:
	@echo "Installing bash configuration..."
	@ln -sf $(ROOT_DIR)/.aliases $(HOME)/.aliases
	@ln -sf $(ROOT_DIR)/.bashrc $(HOME)/.bashrc
	@ln -sf $(ROOT_DIR)/.bash_profile $(HOME)/.bash_profile
	@ln -sf $(ROOT_DIR)/.bash_prompt $(HOME)/.bash_prompt
	@echo "✓ Bash configuration installed"

nvim:
	@echo "Installing neovim configuration..."
	@mkdir -p $(HOME)/.config
	@ln -sfn $(ROOT_DIR)/nvim $(HOME)/.config/nvim
	@echo "✓ Neovim configuration installed"
	@echo "  Note: Configuration stored in $(ROOT_DIR)/nvim/"

opencode:
	@echo "Installing OpenCode configuration..."
	@[ -L "$(HOME)/.config/opencode" ] && rm "$(HOME)/.config/opencode" || true
	@mkdir -p $(HOME)/.config/opencode
	@ln -sfn $(ROOT_DIR)/opencode/commands $(HOME)/.config/opencode/commands
	@ln -sfn $(ROOT_DIR)/opencode/skills $(HOME)/.config/opencode/skills
	@ln -sf $(ROOT_DIR)/opencode/AGENTS.md $(HOME)/.config/opencode/AGENTS.md
	@ln -sf $(ROOT_DIR)/opencode/opencode.json $(HOME)/.config/opencode/opencode.json
	@ln -sf $(ROOT_DIR)/opencode/package.json $(HOME)/.config/opencode/package.json
	@ln -sf $(ROOT_DIR)/opencode/oh-my-openagent.json $(HOME)/.config/opencode/oh-my-openagent.json
	@for d in plugins scripts; do \
			if [ -e "$(HOME)/.config/opencode/$$d" ] && [ ! -L "$(HOME)/.config/opencode/$$d" ]; then \
				echo "⚠ .config/opencode/$$d exists and is not a symlink — remove it manually and re-run"; \
			else \
				ln -sfn $(ROOT_DIR)/opencode/$$d $(HOME)/.config/opencode/$$d; \
			fi; \
		done
	@echo "✓ OpenCode configuration installed"

git:
	@echo "Installing git configuration..."
	@ln -sf $(ROOT_DIR)/.gitconfig $(HOME)/.gitconfig
	@ln -sf $(ROOT_DIR)/.gitignore_global $(HOME)/.gitignore_global
	@echo "✓ Git configuration installed"

tig:
	@echo "Installing tig configuration..."
	@ln -sf $(ROOT_DIR)/.tigrc $(HOME)/.tigrc
	@echo "✓ Tig configuration installed"

tmux:
	@echo "Installing tmux configuration..."
	@ln -sf $(ROOT_DIR)/.tmux.conf $(HOME)/.tmux.conf
	@echo "✓ Tmux configuration installed"

scripts:
	@echo "Installing utility scripts..."
	@mkdir -p $(HOME)/bin
	@ln -sf $(ROOT_DIR)/scripts/tig-mark-commit.sh $(HOME)/bin/tig-mark-commit
	@ln -sf $(ROOT_DIR)/scripts/tig-diff-selector.sh $(HOME)/bin/tig-diff-selector
	@echo "✓ Scripts installed to ~/bin"
	@echo "  Note: Ensure ~/bin is in your PATH"

uninstall:
	@echo "Removing dotfiles symlinks..."
	@for file in .aliases .zshrc .p10k.zsh .bashrc .bash_profile .bash_prompt .gitconfig .gitignore_global .tigrc .tmux.conf; do \
			if [ -L "$(HOME)/$$file" ]; then \
				echo "  Removing $$file"; \
				rm "$(HOME)/$$file"; \
			fi; \
		done
	@echo "Removing OpenCode configuration symlinks..."
	@for f in $(OPENCODE_ITEMS); do \
			if [ -L "$(HOME)/.config/opencode/$$f" ]; then \
				echo "  Removing .config/opencode/$$f"; \
				rm "$(HOME)/.config/opencode/$$f"; \
			fi; \
		done
	@echo "Removing neovim symlinks..."
	@if [ -L "$(HOME)/.config/nvim" ]; then \
			echo "  Removing .config/nvim"; \
			rm "$(HOME)/.config/nvim"; \
		fi
	@echo "Removing scripts..."
	@for script in tig-mark-commit tig-diff-selector; do \
			if [ -L "$(HOME)/bin/$$script" ]; then \
				echo "  Removing ~/bin/$$script"; \
				rm "$(HOME)/bin/$$script"; \
			fi; \
		done
	@echo "✓ Symlinks removed"

check:
	@echo "Checking dotfiles installation..."
	@echo ""
	@for file in .zshrc .p10k.zsh .aliases .bashrc .bash_profile .bash_prompt .gitconfig .gitignore_global .tigrc .tmux.conf; do \
			if [ -L "$(HOME)/$$file" ]; then \
				target=$$(readlink "$(HOME)/$$file"); \
				if [ "$$target" = "$(ROOT_DIR)/$$file" ]; then \
					echo "✓ $$file -> $$target"; \
				else \
					echo "⚠ $$file -> $$target (unexpected target)"; \
				fi; \
			elif [ -e "$(HOME)/$$file" ]; then \
				echo "✗ $$file (exists but not a symlink)"; \
			else \
				echo "✗ $$file (not found)"; \
			fi; \
		done
	@echo ""
	@echo "Checking OpenCode configuration..."
	@for f in $(OPENCODE_ITEMS); do \
			if [ -L "$(HOME)/.config/opencode/$$f" ]; then \
				target=$$(readlink "$(HOME)/.config/opencode/$$f"); \
				if [ "$$target" = "$(ROOT_DIR)/opencode/$$f" ]; then \
					echo "✓ .config/opencode/$$f -> $$target"; \
				else \
					echo "⚠ .config/opencode/$$f -> $$target (unexpected target)"; \
				fi; \
			elif [ -e "$(HOME)/.config/opencode/$$f" ]; then \
				echo "✗ .config/opencode/$$f (exists but not a symlink)"; \
			else \
				echo "✗ .config/opencode/$$f (not found)"; \
			fi; \
		done
	@echo ""
	@echo "Checking neovim installation..."
	@if [ -L "$(HOME)/.config/nvim" ]; then \
			target=$$(readlink "$(HOME)/.config/nvim"); \
			echo "✓ .config/nvim -> $$target"; \
			if [ -e "$$target/init.lua" ]; then \
				echo "✓ nvim/init.lua (found)"; \
			else \
				echo "✗ nvim/init.lua (not found)"; \
			fi; \
	elif [ -e "$(HOME)/.config/nvim" ]; then \
			echo "✗ .config/nvim (exists but not a symlink)"; \
	else \
			echo "✗ .config/nvim (not found)"; \
	fi
	@echo ""
	@echo "Checking scripts installation..."
	@for script in tig-mark-commit tig-diff-selector; do \
			if [ -L "$(HOME)/bin/$$script" ]; then \
				target=$$(readlink "$(HOME)/bin/$$script"); \
				echo "✓ ~/bin/$$script -> $$target"; \
			elif [ -e "$(HOME)/bin/$$script" ]; then \
				echo "✗ ~/bin/$$script (exists but not a symlink)"; \
			else \
				echo "✗ ~/bin/$$script (not found)"; \
			fi; \
		done
