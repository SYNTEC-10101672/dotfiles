SHELL := bash

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

CLAUDE_FILES := settings.json CLAUDE.md
CLAUDE_DIRS  := commands skills scripts

.PHONY: all install bashrc nvim claude opencode git tig tmux scripts uninstall check help

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
	@echo "  make bashrc    - Install bash configuration"
	@echo "  make nvim      - Install neovim configuration"
	@echo "  make claude    - Install Claude Code configuration"
	@echo "  make opencode  - Install OpenCode commands (symlink from claude/commands)"
	@echo "  make git       - Install git configuration"
	@echo "  make tig       - Install tig configuration"
	@echo "  make tmux      - Install tmux configuration"
	@echo "  make scripts   - Install utility scripts to ~/bin"

install: bashrc nvim claude opencode git tig tmux scripts
	@echo "✓ Dotfiles installed successfully"

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

claude:
	@echo "Installing Claude Code configuration..."
	@if [ -L "$(HOME)/.claude" ]; then \
			echo "✗ ~/.claude is a directory symlink (old layout) — migration required:"; \
			echo "  rm ~/.claude && mkdir ~/.claude && make claude"; \
			exit 1; \
		fi
	@mkdir -p $(HOME)/.claude
	@for f in $(CLAUDE_FILES); do ln -sf $(ROOT_DIR)/claude/$$f $(HOME)/.claude/$$f; done
	@for d in $(CLAUDE_DIRS); do ln -sfn $(ROOT_DIR)/claude/$$d $(HOME)/.claude/$$d; done
	@echo "✓ Claude Code configuration installed"

opencode:
	@echo "Installing OpenCode commands..."
	@[ -L "$(HOME)/.config/opencode" ] && rm "$(HOME)/.config/opencode" || true
	@mkdir -p $(HOME)/.config/opencode
	@ln -sfn $(ROOT_DIR)/claude/commands $(HOME)/.config/opencode/commands
	@echo "✓ OpenCode commands installed"

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
	@ln -sf $(ROOT_DIR)/scripts/setup-git-credentials.sh $(HOME)/bin/setup-git-credentials
	@ln -sf $(ROOT_DIR)/scripts/tig-mark-commit.sh $(HOME)/bin/tig-mark-commit
	@ln -sf $(ROOT_DIR)/scripts/tig-diff-selector.sh $(HOME)/bin/tig-diff-selector
	@ln -sf $(ROOT_DIR)/claude/scripts/claude-glm $(HOME)/bin/claude-glm
	@ln -sf $(ROOT_DIR)/claude/scripts/claude-code-statusline $(HOME)/bin/claude-code-statusline
	@echo "✓ Scripts installed to ~/bin"
	@echo "  Note: Ensure ~/bin is in your PATH"

uninstall:
	@echo "Removing dotfiles symlinks..."
	@for file in .aliases .bashrc .bash_profile .bash_prompt .gitconfig .gitignore_global .tigrc .tmux.conf; do \
			if [ -L "$(HOME)/$$file" ]; then \
				echo "  Removing $$file"; \
				rm "$(HOME)/$$file"; \
			fi; \
		done
	@echo "Removing Claude Code configuration symlinks..."
	@for item in $(CLAUDE_FILES) $(CLAUDE_DIRS); do \
			if [ -L "$(HOME)/.claude/$$item" ]; then \
				echo "  Removing .claude/$$item"; \
				rm "$(HOME)/.claude/$$item"; \
			fi; \
		done
	@echo "Removing OpenCode commands symlink..."
	@if [ -L "$(HOME)/.config/opencode/commands" ]; then \
			echo "  Removing .config/opencode/commands"; \
			rm "$(HOME)/.config/opencode/commands"; \
		fi
	@echo "Removing neovim symlinks..."
	@if [ -L "$(HOME)/.config/nvim" ]; then \
			echo "  Removing .config/nvim"; \
			rm "$(HOME)/.config/nvim"; \
		fi
	@echo "Removing scripts..."
	@for script in setup-git-credentials tig-mark-commit tig-diff-selector claude-glm claude-code-statusline; do \
			if [ -L "$(HOME)/bin/$$script" ]; then \
				echo "  Removing ~/bin/$$script"; \
				rm "$(HOME)/bin/$$script"; \
			fi; \
		done
	@echo "✓ Symlinks removed"

check:
	@echo "Checking dotfiles installation..."
	@echo ""
	@for file in .aliases .bashrc .bash_profile .bash_prompt .gitconfig .gitignore_global .tigrc .tmux.conf; do \
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
	@echo "Checking Claude Code installation..."
	@if [ -d "$(HOME)/.claude" ] && [ ! -L "$(HOME)/.claude" ]; then \
			for item in $(CLAUDE_FILES) $(CLAUDE_DIRS); do \
				if [ -L "$(HOME)/.claude/$$item" ]; then \
					target=$$(readlink "$(HOME)/.claude/$$item"); \
					if [ "$$target" = "$(ROOT_DIR)/claude/$$item" ]; then \
						echo "✓ .claude/$$item -> $$target"; \
					else \
						echo "⚠ .claude/$$item -> $$target (unexpected target)"; \
					fi; \
				elif [ -e "$(HOME)/.claude/$$item" ]; then \
					echo "✗ .claude/$$item (exists but not a symlink)"; \
				else \
					echo "✗ .claude/$$item (not found)"; \
				fi; \
			done; \
	elif [ -L "$(HOME)/.claude" ]; then \
			echo "⚠ ~/.claude is a directory symlink (old layout) — run migration first"; \
	else \
			echo "✗ ~/.claude (not found)"; \
	fi
	@echo ""
	@echo "Checking OpenCode commands..."
	@if [ -L "$(HOME)/.config/opencode/commands" ]; then \
			target=$$(readlink "$(HOME)/.config/opencode/commands"); \
			if [ "$$target" = "$(ROOT_DIR)/claude/commands" ]; then \
				echo "✓ .config/opencode/commands -> $$target"; \
			else \
				echo "⚠ .config/opencode/commands -> $$target (unexpected target)"; \
			fi; \
	elif [ -e "$(HOME)/.config/opencode/commands" ]; then \
			echo "✗ .config/opencode/commands (exists but not a symlink)"; \
	else \
			echo "✗ .config/opencode/commands (not found)"; \
	fi
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
	@for script in setup-git-credentials tig-mark-commit tig-diff-selector claude-glm claude-code-statusline; do \
			if [ -L "$(HOME)/bin/$$script" ]; then \
				target=$$(readlink "$(HOME)/bin/$$script"); \
				echo "✓ ~/bin/$$script -> $$target"; \
			elif [ -e "$(HOME)/bin/$$script" ]; then \
				echo "✗ ~/bin/$$script (exists but not a symlink)"; \
			else \
				echo "✗ ~/bin/$$script (not found)"; \
			fi; \
		done
