// OpenCode Secret Guard Layer 2: scan staged content before AI-driven commits.
// The fail-closed policy rejects commits when gitleaks is unavailable; see
// commit b414b1f (feat(opencode): add three-layer secret guard against AI key
// leaks) for the complete three-layer design.
import { Plugin } from "@opencode/plugin"
import { spawn } from "node:child_process"

export type GuardRunResult = { exitCode: number; stdout: string; stderr: string }

export type GuardRunner = (
  command: readonly string[],
  options?: { env?: Record<string, string | undefined>; cwd?: string },
) => Promise<GuardRunResult>

// Minimal structural shape of the v2 "execute.before" tool hook event.
export type GuardToolEvent = { tool: string; input: unknown }

const commandDetails = (result: { stdout: string; stderr: string }): string =>
  [result.stdout, result.stderr].filter(Boolean).join("\n")

export const runGuardProcess: GuardRunner = (command, options) =>
  new Promise((resolve) => {
    const child = spawn(command[0]!, [...command.slice(1)], {
      env: options?.env,
      cwd: options?.cwd,
    })
    let stdout = ""
    let stderr = ""
    child.stdout.on("data", (chunk) => (stdout += chunk))
    child.stderr.on("data", (chunk) => (stderr += chunk))
    // Resolve instead of reject so callers decide the fail-closed outcome.
    child.on("error", (error) => resolve({ exitCode: -1, stdout, stderr: String(error) }))
    child.on("close", (code) => resolve({ exitCode: code ?? -1, stdout, stderr }))
  })

export const createGuardHook = (run: GuardRunner, scanDirectory: string) => async (event: GuardToolEvent) => {
  if (event.tool !== "shell") return

  const command = (event.input as { command?: unknown } | undefined)?.command
  if (typeof command !== "string" || !command.includes("git commit")) return

  let available: GuardRunResult
  try {
    available = await run(["gitleaks", "version"])
  } catch {
    available = { exitCode: -1, stdout: "", stderr: "" }
  }

  if (available.exitCode !== 0) {
    throw new Error(
      "Commit blocked intentionally: gitleaks is required to scan staged content. Install it from https://github.com/gitleaks/gitleaks/releases, then retry the commit.",
    )
  }

  let result: GuardRunResult
  try {
    // Disable git colors so gitleaks cannot silently scan 0 bytes when color.ui = always.
    // cwd matters: the v2 shared background service does not run in the session
    // project, so the scan must target the plugin location directory explicitly.
    result = await run(["gitleaks", "protect", "--staged", "--redact"], {
      cwd: scanDirectory,
      env: {
        ...process.env,
        GIT_CONFIG_COUNT: "1",
        GIT_CONFIG_KEY_0: "color.ui",
        GIT_CONFIG_VALUE_0: "off",
      },
    })
  } catch (error: unknown) {
    const details = error instanceof Error ? error.message : String(error)
    throw new Error(
      `Commit blocked: gitleaks scan FAILED (fail-closed): ${details}. Do NOT bypass this guard.`,
    )
  }

  if (result.exitCode === 0) return

  const details = commandDetails(result)
  if (result.exitCode === 1) {
    throw new Error(
      `Commit blocked: gitleaks found a secret in staged files. Remove the secret from the staged files and do NOT bypass this guard.\n\n${details}`,
    )
  }

  throw new Error(
    `Commit blocked: gitleaks scan FAILED (fail-closed). Exit code ${result.exitCode}. Fix the scanner environment (is this a git repo? is git available?) and retry — do NOT bypass this guard.\n\n${details}`,
  )
}

export default Plugin.define({
  id: "secret-guard",
  async setup(ctx) {
    await ctx.tool.hook("execute.before", createGuardHook(runGuardProcess, ctx.location.directory))
  },
})
