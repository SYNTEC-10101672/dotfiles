// OpenCode Commit Gate: block AI-driven `git commit` unless the session was
// authorized by the user's /commit command. Unauthorized sessions get a throw
// that hits the ultrawork COMMIT DISCIPLINE skip condition, so the model skips
// committing and keeps working; authorized sessions pass through and Secret
// Guard (guard.ts) still scans the actual commit.
import type { Plugin } from "@opencode-ai/plugin"

// Matches `git commit` as a subcommand, covering `git -C <path> commit`,
// `&&`/`;` chains, and env-prefixed forms; excludes plumbing (`commit-tree`)
// via the lookahead on word chars and dashes.
const COMMIT_COMMAND_RE = /\bgit\s+(?:-\S+\s+(?:\S+\s+)?)*commit(?![\w-])/

// The wording must keep hitting the ultrawork COMMIT DISCIPLINE skip condition
// ("Skip only when the user forbade commits this session") — do not paraphrase.
const BLOCK_MESSAGE = `git commit blocked by user policy: AI must not run git commit.
The user has forbidden commits this session — per COMMIT DISCIPLINE
("Skip only when the user forbade commits this session"), skip
committing and continue completing the current task. Leave changes
uncommitted; the user will commit manually via /commit.
Do not retry or work around.`

export const CommitGatePlugin: Plugin = async () => {
  // sessionID -> authorized. No TTL; /commit is a multi-phase flow whose
  // phases go idle in between, so only other commands or session.deleted
  // clear the flag. Subagents get their own sessionID and never inherit.
  const authorized = new Map<string, true>()

  return {
    "command.execute.before": async (input) => {
      if (input.command.replace(/^\//, "") === "commit") authorized.set(input.sessionID, true)
      else authorized.delete(input.sessionID)
    },
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return

      const command = (output.args as { command?: unknown } | undefined)?.command
      if (typeof command !== "string" || !COMMIT_COMMAND_RE.test(command)) return

      if (!authorized.has(input.sessionID)) throw new Error(BLOCK_MESSAGE)
    },
    event: async ({ event }) => {
      if (event.type === "session.deleted") authorized.delete(event.properties.info.id)
    },
  }
}
