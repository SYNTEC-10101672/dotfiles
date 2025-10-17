SHELL := bash

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BACKUP_DIR:=$(HOME)/.dotfiles_backup_$(shell date +%Y%m%d_%H%M%S)

.PHONY: all install bashrc vim claude git tig tmux scripts backup uninstall clean check help

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
	@echo "  make vim       - Install vim configuration"
	@echo "  make claude    - Install Claude Code configuration"
	@echo "  make git       - Install git configuration"
	@echo "  make tig       - Install tig configuration"
	@echo "  make tmux      - Install tmux configuration"
	@echo "  make scripts   - Install utility scripts to ~/bin"

install: backup bashrc vim claude git tig tmux scripts
	@echo "✓ Dotfiles installed successfully"

backup:
	@echo "Creating backup at $(BACKUP_DIR)..."
	@mkdir -p $(BACKUP_DIR)
	@for file in .aliases .bashrc .bash_profile .bash_prompt .vimrc .vim .claude .gitconfig .gitignore_global .tigrc .tmux.conf; do \
		if [ -e "$(HOME)/$$file" ] && [ ! -L "$(HOME)/$$file" ]; then \
			echo "  Backing up $$file"; \
			cp -r "$(HOME)/$$file" "$(BACKUP_DIR)/"; \
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

vim:
	@echo "Installing vim configuration..."
	@ln -sf $(ROOT_DIR)/.vim/vimrc $(HOME)/.vimrc
	@ln -sf $(ROOT_DIR)/.vim $(HOME)/.vim
	@echo "✓ Vim configuration installed"

claude:
	@echo "Installing Claude Code configuration..."
	@ln -sf $(ROOT_DIR)/.claude $(HOME)/.claude
	@echo "✓ Claude Code configuration installed"

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
	@echo "✓ Scripts installed to ~/bin"
	@echo "  Note: Ensure ~/bin is in your PATH"

uninstall:
	@echo "Removing dotfiles symlinks..."
	@for file in .aliases .bashrc .bash_profile .bash_prompt .vimrc .vim .claude .gitconfig .gitignore_global .tigrc .tmux.conf; do \
		if [ -L "$(HOME)/$$file" ]; then \
			echo "  Removing $$file"; \
			rm "$(HOME)/$$file"; \
		fi; \
	done
	@echo "Removing scripts..."
	@for script in resetcnc setup-git-credentials tig-mark-commit; do \
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
	@for file in .aliases .bashrc .bash_profile .bash_prompt .vimrc .vim .claude .gitconfig .gitignore_global .tigrc .tmux.conf; do \
		if [ -L "$(HOME)/$$file" ]; then \
			target=$$(readlink "$(HOME)/$$file"); \
			if [ "$$target" = "$(ROOT_DIR)/$$file" ] || [ "$$target" = "$(ROOT_DIR)/.vim/vimrc" ]; then \
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
	@echo "Checking scripts installation..."
	@for script in resetcnc setup-git-credentials tig-mark-commit; do \
		if [ -L "$(HOME)/bin/$$script" ]; then \
			target=$$(readlink "$(HOME)/bin/$$script"); \
			echo "✓ ~/bin/$$script -> $$target"; \
		elif [ -e "$(HOME)/bin/$$script" ]; then \
			echo "✗ ~/bin/$$script (exists but not a symlink)"; \
		else \
			echo "✗ ~/bin/$$script (not found)"; \
		fi; \
	done
