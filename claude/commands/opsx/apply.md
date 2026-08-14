---
name: "OPSX: Apply"
description: Implement tasks from an OpenSpec change (Experimental)
category: Workflow
tags: [workflow, artifacts, experimental]
---

Implement tasks from an OpenSpec change using the TDD three-phase flow (Red / Green / Final).

**Input**: Optionally a change name (e.g., `/opsx:apply add-auth`). If omitted, infer from conversation context; if ambiguous, prompt for selection.

Use the `openspec-apply-change` skill to run this workflow.
