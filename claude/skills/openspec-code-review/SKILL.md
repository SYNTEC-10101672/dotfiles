---
name: openspec-code-review
description: Review a change's diff along two axes - Standards (CLAUDE.md code standards + Fowler smells baseline) and Spec (does it faithfully implement the OpenSpec change artifacts?). Runs both as parallel sub-agents. Use when openspec-apply completes, when the user wants to review a change, asks to "review since X", or mentions code review.
---

Two-axis review of the diff since change started:

- **Standards** - code follows repo conventions + avoids Fowler smells
- **Spec** - faithfully implements proposal/specs/design/tasks

Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

## Process

### 1. Pin the fixed point

Use `git merge-base <change-start-commit> HEAD` as fixed point. Capture:
- `git diff <fixed-point>...HEAD` (three-dot)
- `git log <fixed-point>..HEAD --oneline`

Confirm fixed point resolves and diff is non-empty.

### 2. Identify spec source

OpenSpec change artifacts for current change:
- `openspec/changes/<name>/proposal.md`
- `openspec/changes/<name>/specs/<capability>/spec.md` (all delta specs)
- `openspec/changes/<name>/design.md`
- `openspec/changes/<name>/tasks.md`

### 3. Identify standards sources

- `~/.claude/CLAUDE.md` "程式碼規範" section (code standards)
- repo CODING_STANDARDS.md / CONTRIBUTING.md (if present)
- Fowler 12 smells baseline (fixed, sub-agent always carries it):
  - Mysterious Name
  - Duplicated Code
  - Feature Envy
  - Data Clumps
  - Primitive Obsession
  - Repeated Switches
  - Shotgun Surgery
  - Divergent Change
  - Speculative Generality
  - Message Chains
  - Middle Man
  - Refused Bequest

Rules:
- Documented repo standard always overrides smell baseline
- Each smell is a heuristic (labelled), not a hard violation
- Skip anything tooling already enforces

### 4. Spawn both sub-agents in parallel (single message, 2 task calls)

Use `general-purpose` subagent type for both.

**Standards sub-agent** brief (include diff command, commit list, CLAUDE.md code standards section content, full Fowler 12 baseline list):
```
Report - per file/hunk:
(a) violations of CLAUDE.md code standards (cite rule)
(b) Fowler smells spotted (name + quote hunk)
Distinguish hard violations from judgement calls.
When a documented repo standard exists, standard overrides smell baseline.
Skip anything tooling enforces. Under 400 words.
```

**Spec sub-agent** brief (include diff command, commit list, all OpenSpec change artifact paths or contents):
```
Report:
(a) requirements from proposal/specs/design that are missing or partial
(b) behavior in the diff not asked for (scope creep)
(c) implementation that looks wrong
Quote the spec line for each finding. Under 400 words.
```

### 5. Aggregate

Present under `## Standards` and `## Spec` headings, separately.
**Do NOT merge or rerank findings** - the two axes are deliberately separate.

End with: total findings per axis, worst issue per axis.
Do not pick a single winner.

## Why two axes

- Standards pass / Spec fail: beautiful code doing the wrong thing
- Spec pass / Standards fail: correct behavior breaking conventions

Reporting them separately stops one axis from masking the other.
