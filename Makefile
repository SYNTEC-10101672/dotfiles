SHELL := bash

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BACKUP_DIR:=$(HOME)/.dotfiles_backup_$(shell date +%Y%m%d_%H%M%S)

.PHONY: all install bashrc nvim claude gemini opencode git tig tmux scripts backup uninstall clean check help

all: install

help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Usage:"
	@echo "  make install   - Install all dotfiles (with backup)"
	@echo "  make backup    - Backup existing dotfiles"
	@echo "  make uninstall - Remove symlinks and restore backups"
	@echo "  make check     - Check installation status"
	@echo "  make clean     - Remove backup files"
	@echo ""
	@echo "Individual targets:"
	@echo "  make bashrc    - Install bash configuration"
	@echo "  make nvim      - Install neovim configuration"
	@echo "  make claude    - Install Claude Code configuration"
	@echo "  make gemini    - Install Gemini configuration (links to Claude config)"
	@echo "  make opencode  - Install OpenCode configuration"
	@echo "  make git       - Install git configuration"
	@echo "  make tig       - Install tig configuration"
	@echo "  make tmux      - Install tmux configuration"
	@echo "  make scripts   - Install utility scripts to ~/bin"

install: backup bashrc nvim claude gemini opencode git tig tmux scripts
	@echo "✓ Dotfiles installed successfully"

backup:
	@echo "Creating backup at $(BACKUP_DIR)..."
	@mkdir -p $(BACKUP_DIR)
	@for file in .aliases .bashrc .bash_profile .bash_prompt .config/nvim .claude .gemini .config/opencode .gitconfig .gitignore_global .tigrc .tmux.conf; do \
		if [ -e "$(HOME)/$$file" ] && [ ! -L "$(HOME)/$$file" ]; then \
			echo "  Backing up $$file"; \
			mkdir -p "$(BACKUP_DIR)/$$(dirname $$file)"; \
			cp -r "$(HOME)/$$file" "$(BACKUP_DIR)/$$file"; \
		fi; \
	done
	@echo "✓ Backup completed"

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
	@ln -sf $(ROOT_DIR)/.nvim $(HOME)/.config/nvim
	@echo "✓ Neovim configuration installed"
	@echo "  Note: Configuration stored in ~/.dotfiles/.nvim/"

claude:
	@echo "Installing Claude Code configuration..."
	@ln -sf $(ROOT_DIR)/.claude $(HOME)/.claude
	@echo "✓ Claude Code configuration installed"

gemini:
	@echo "Installing Gemini configuration..."
	@mkdir -p $(HOME)/.gemini
	@ln -sf $(ROOT_DIR)/.claude/CLAUDE.md $(HOME)/.gemini/GEMINI.md
	@echo "✓ Gemini configuration installed"
	@echo "  Note: GEMINI.md links to Claude configuration"

opencode:
	@echo "Installing OpenCode configuration..."
	@mkdir -p $(HOME)/.config
	@if [ -d "$(HOME)/.config/opencode" ] && [ ! -L "$(HOME)/.config/opencode" ]; then \
		echo "  Removing existing opencode directory..."; \
		rm -rf $(HOME)/.config/opencode; \
	fi
	@ln -sf $(ROOT_DIR)/.opencode $(HOME)/.config/opencode
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
	@ln -sf $(ROOT_DIR)/scripts/resetcnc $(HOME)/bin/resetcnc
	@ln -sf $(ROOT_DIR)/scripts/setup-git-credentials.sh $(HOME)/bin/setup-git-credentials
	@ln -sf $(ROOT_DIR)/scripts/tig-mark-commit.sh $(HOME)/bin/tig-mark-commit
	@ln -sf $(ROOT_DIR)/scripts/tig-diff-selector.sh $(HOME)/bin/tig-diff-selector
	@ln -sf $(ROOT_DIR)/.claude/scripts/claude-glm $(HOME)/bin/claude-glm
	@ln -sf $(ROOT_DIR)/.claude/scripts/claude-code-statusline $(HOME)/bin/claude-code-statusline
	@echo "✓ Scripts installed to ~/bin"
	@echo "  Note: Ensure ~/bin is in your PATH"

uninstall:
	@echo "Removing dotfiles symlinks..."
	@for file in .aliases .bashrc .bash_profile .bash_prompt .claude .gitconfig .gitignore_global .tigrc .tmux.conf; do \
		if [ -L "$(HOME)/$$file" ]; then \
			echo "  Removing $$file"; \
			rm "$(HOME)/$$file"; \
		fi; \
	done
	@echo "Removing neovim symlinks..."
	@if [ -L "$(HOME)/.config/nvim" ]; then \
		echo "  Removing .config/nvim"; \
		rm "$(HOME)/.config/nvim"; \
	fi
	@echo "Removing gemini symlinks..."
	@if [ -L "$(HOME)/.gemini/GEMINI.md" ]; then \
		echo "  Removing .gemini/GEMINI.md"; \
		rm "$(HOME)/.gemini/GEMINI.md"; \
	fi
	@echo "Removing opencode symlinks..."
	@if [ -L "$(HOME)/.config/opencode" ]; then \
		echo "  Removing .config/opencode"; \
		rm "$(HOME)/.config/opencode"; \
	fi
	@echo "Removing scripts..."
	@for script in resetcnc setup-git-credentials tig-mark-commit tig-diff-selector claude-glm claude-code-statusline; do \
		if [ -L "$(HOME)/bin/$$script" ]; then \
			echo "  Removing ~/bin/$$script"; \
			rm "$(HOME)/bin/$$script"; \
		fi; \
	done
	@echo "✓ Symlinks removed"
	@echo "Note: Run 'make restore' to restore from latest backup"

restore:
	@if [ -z "$(BACKUP)" ]; then \
		echo "Error: Please specify backup directory with BACKUP=<dir>"; \
		echo "Available backups:"; \
		ls -d $(HOME)/.dotfiles_backup_* 2>/dev/null || echo "  No backups found"; \
		exit 1; \
	fi
	@echo "Restoring from $(BACKUP)..."
	@cp -r $(BACKUP)/* $(HOME)/
	@echo "✓ Restored from backup"

clean:
	@echo "Removing backup files..."
	@rm -rf $(HOME)/.dotfiles_backup_*
	@echo "✓ Backup files removed"

check:
	@echo "Checking dotfiles installation..."
	@echo ""
	@for file in .aliases .bashrc .bash_profile .bash_prompt .claude .gitconfig .gitignore_global .tigrc .tmux.conf; do \
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
	@echo "Checking neovim installation..."
	@if [ -L "$(HOME)/.config/nvim" ]; then \
		target=$$(readlink "$(HOME)/.config/nvim"); \
		echo "✓ .config/nvim -> $$target"; \
		if [ -L "$$target/init.vim" ]; then \
			init_target=$$(readlink "$$target/init.vim"); \
			echo "✓ .nvim/init.vim -> $$init_target"; \
		elif [ -e "$$target/init.vim" ]; then \
			echo "✗ .nvim/init.vim (exists but not a symlink)"; \
		else \
			echo "✗ .nvim/init.vim (not found)"; \
		fi; \
	elif [ -e "$(HOME)/.config/nvim" ]; then \
		echo "✗ .config/nvim (exists but not a symlink)"; \
	else \
		echo "✗ .config/nvim (not found)"; \
	fi
	@echo ""
	@echo "Checking gemini installation..."
	@if [ -L "$(HOME)/.gemini/GEMINI.md" ]; then \
		target=$$(readlink "$(HOME)/.gemini/GEMINI.md"); \
		if [ "$$target" = "$(ROOT_DIR)/.claude/CLAUDE.md" ]; then \
			echo "✓ .gemini/GEMINI.md -> $$target"; \
		else \
			echo "⚠ .gemini/GEMINI.md -> $$target (unexpected target)"; \
		fi; \
	elif [ -e "$(HOME)/.gemini/GEMINI.md" ]; then \
		echo "✗ .gemini/GEMINI.md (exists but not a symlink)"; \
	else \
		echo "✗ .gemini/GEMINI.md (not found)"; \
	fi
	@echo ""
	@echo "Checking opencode installation..."
	@if [ -L "$(HOME)/.config/opencode" ]; then \
		target=$$(readlink "$(HOME)/.config/opencode"); \
		if [ "$$target" = "$(ROOT_DIR)/.opencode" ]; then \
			echo "✓ .config/opencode -> $$target"; \
			if [ -L "$$target/AGENTS.md" ]; then \
				agents_target=$$(readlink "$$target/AGENTS.md"); \
				echo "✓ .opencode/AGENTS.md -> $$agents_target"; \
			elif [ -e "$$target/AGENTS.md" ]; then \
				echo "✗ .opencode/AGENTS.md (exists but not a symlink)"; \
			else \
				echo "✗ .opencode/AGENTS.md (not found)"; \
			fi; \
			if [ -e "$$target/opencode.json" ]; then \
				echo "✓ .opencode/opencode.json (found)"; \
			else \
				echo "✗ .opencode/opencode.json (not found)"; \
			fi; \
		else \
			echo "⚠ .config/opencode -> $$target (unexpected target)"; \
		fi; \
	elif [ -e "$(HOME)/.config/opencode" ]; then \
		echo "✗ .config/opencode (exists but not a symlink)"; \
	else \
		echo "✗ .config/opencode (not found)"; \
	fi
	@echo ""
	@echo "Checking scripts installation..."
	@for script in resetcnc setup-git-credentials tig-mark-commit tig-diff-selector claude-glm claude-code-statusline; do \
		if [ -L "$(HOME)/bin/$$script" ]; then \
			target=$$(readlink "$(HOME)/bin/$$script"); \
			echo "✓ ~/bin/$$script -> $$target"; \
		elif [ -e "$(HOME)/bin/$$script" ]; then \
			echo "✗ ~/bin/$$script (exists but not a symlink)"; \
		else \
			echo "✗ ~/bin/$$script (not found)"; \
		fi; \
	done
