# dotfiles

Personal development environment configurations managed via Makefile and symlinks.

## Deployment

```bash
make install   # Install all dotfiles
make check     # Verify symlink status
make uninstall # Remove symlinks
```

Individual modules: `make bashrc`, `make nvim`, `make opencode`, `make git`, `make tig`, `make herdr`, `make scripts`

## Architecture

Each config module (bash, nvim, git, tig, herdr, opencode) has its own Makefile target that creates symlinks from this repo to the appropriate location in `$HOME`. The herdr module (`herdr/config.toml` → `~/.config/herdr/config.toml`, plus `herdr/shell.zsh` → `~/.config/herdr/shell.zsh`, a tab auto-naming integration sourced by `.zshrc` that self-guards on `HERDR_TAB_ID`; see ADR-0003) is the only configured terminal; the tmux module is retired (superseded by `docs/adr/0006-remove-tmux-module.md`, rollback path = git history). The `opencode/` directory contains all opencode settings (`opencode.json` with top-level `model` pinned, `package.json`, the global instruction file `AGENTS.md`, `commands/`, `skills/`, `plugins/`) deployed as symlinks to `~/.config/opencode/` (pure opencode core harness; the OmO scheduling layer and quota plugin are retired per `docs/adr/0007-remove-omo-and-quota-plugin.md`, rollback path = git history). The repo root `AGENTS.md` (this file) is the project-level instruction file for this repo.

## New Machine Setup

When setting up a new machine, follow the complete step-by-step guide in [`docs/SETUP.md`](docs/SETUP.md). It covers system packages, language runtimes, opencode, environment variables, and verification.

## Adding a New Module

1. Add config files to this repo
2. Add a Makefile target that creates symlinks to `$HOME`
3. Add the target name to `install` and `.PHONY`
4. Update `check` and `uninstall` targets
5. Update this file and README.md

## Agent skills

### Teaching workspace

herdr 教學工作區（`/teach` command）位於 `docs/teach-herdr/`：MISSION.md、RESOURCES.md、NOTES.md、`lessons/`、`reference/`、`learning-records/`、`assets/`。執行 `/teach` 時以該目錄為 teaching workspace root（非 repo root）。

### Issue tracker

Issues are tracked as local markdown files under `.scratch/<feature>/`. See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: one `GLOSSARY.md` at the repo root, ADRs in `docs/adr/`. See `docs/agents/domain.md`.
