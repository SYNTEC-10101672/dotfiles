# dotfiles

Personal development environment configurations managed via Makefile and symlinks.

## Deployment

```bash
make install   # Install all dotfiles
make check     # Verify symlink status
make uninstall # Remove symlinks
```

Individual modules: `make bashrc`, `make nvim`, `make opencode`, `make git`, `make tig`, `make tmux`, `make scripts`

## Architecture

Each config module (bash, nvim, git, tig, tmux, opencode) has its own Makefile target that creates symlinks from this repo to the appropriate location in `$HOME`. The `opencode/` directory contains all opencode settings (`opencode.json`, `package.json`, `oh-my-openagent.json`, the global instruction file `AGENTS.md`, `commands/`, `skills/`, `plugins/`, `scripts/`) deployed as mixed symlinks to `~/.config/opencode/`. The repo root `AGENTS.md` (this file) is the project-level instruction file for this repo.

## New Machine Setup

When setting up a new machine, follow the complete step-by-step guide in [`docs/SETUP.md`](docs/SETUP.md). It covers system packages, language runtimes, opencode, environment variables, and verification.

## Session Handover

When starting a new session, if `HANDOVER.md` exists in the project root, read it and follow its instructions to restore context. If HANDOVER.md points to OpenSpec artifacts (proposal.md, design.md, tasks.md, specs/), read those as well. If the handover is no longer relevant, ignore it and proceed normally.

## Adding a New Module

1. Add config files to this repo
2. Add a Makefile target that creates symlinks to `$HOME`
3. Add the target name to `install` and `.PHONY`
4. Update `check` and `uninstall` targets
5. Update this file and README.md
