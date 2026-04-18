# dotfiles

Personal development environment configurations managed via Makefile and symlinks.

## Deployment

```bash
make install   # Install all dotfiles
make check     # Verify symlink status
make uninstall # Remove symlinks
```

Individual modules: `make bashrc`, `make nvim`, `make claude`, `make git`, `make tig`, `make tmux`, `make scripts`

## Architecture

Each config module (bash, nvim, git, tig, tmux, claude) has its own Makefile target that creates symlinks from this repo to the appropriate location in `$HOME`. The `claude/` directory contains Claude Code user-level settings (global CLAUDE.md, settings.json, commands, skills, scripts) deployed as mixed symlinks to `~/.claude/`.

## New Machine Setup

When setting up a new machine, follow the complete step-by-step guide in [`docs/SETUP.md`](../docs/SETUP.md). It covers system packages, language runtimes, Claude Code plugins, opencode, oh-my-openagent, environment variables, and verification.

## Adding a New Module

1. Add config files to this repo
2. Add a Makefile target that creates symlinks to `$HOME`
3. Add the target name to `install` and `.PHONY`
4. Update `check` and `uninstall` targets
5. Update this file and README.md
