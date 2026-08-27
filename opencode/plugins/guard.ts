// OpenCode Secret Guard Layer 2: scan staged content before AI-driven commits.
// The fail-closed policy rejects commits when gitleaks is unavailable; see
// openspec/changes/add-opencode-secret-guard/ for the complete three-layer design.
import type { Plugin } from "@opencode-ai/plugin"

// opencode loads plugins with its bundled bun runtime where `process` exists,
// but the local SDK types ship without node types - declare the minimal shape.
declare const process: { env: Record<string, string | undefined> }

const outputText = (value: unknown): string => {
  if (typeof value === "string") return value
  if (value instanceof Uint8Array) return new TextDecoder().decode(value)
  return String(value)
}

const commandOutput = (value: unknown): string => {
  if (typeof value !== "object" || value === null) return String(value)
  const result = value as { stdout?: unknown; stderr?: unknown }
  const stdout = result.stdout === undefined ? "" : outputText(result.stdout)
  const stderr = result.stderr === undefined ? "" : outputText(result.stderr)
  return [stdout, stderr].filter(Boolean).join("\n") || String(value)
}

export const GuardPlugin: Plugin = async ({ $ }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return

      const command = (output.args as { command?: unknown } | undefined)?.command
      if (typeof command !== "string" || !command.includes("git commit")) return

      let gitleaksAvailable = false
      try {
        const result = await $`gitleaks version`.quiet().nothrow()
        gitleaksAvailable = result.exitCode === 0
      } catch {
        gitleaksAvailable = false
      }

      if (!gitleaksAvailable) {
        throw new Error(
          "Commit blocked intentionally: gitleaks is required to scan staged content. Install it from https://github.com/gitleaks/gitleaks/releases, then retry the commit.",
        )
      }

      let result: { exitCode: number; stdout: unknown; stderr: unknown }
      try {
        // Disable git colors so gitleaks cannot silently scan 0 bytes when color.ui = always.
        result = await $`gitleaks protect --staged --redact`.quiet().nothrow().env({
          ...process.env,
          GIT_CONFIG_COUNT: "1",
          GIT_CONFIG_KEY_0: "color.ui",
          GIT_CONFIG_VALUE_0: "off",
        })
      } catch (error: unknown) {
        const details = commandOutput(error)
        throw new Error(
          `Commit blocked: gitleaks scan FAILED (fail-closed): ${details}. Do NOT bypass this guard.`,
        )
      }

      if (result.exitCode === 0) return

      const details = commandOutput(result)
      if (result.exitCode === 1) {
        throw new Error(
          `Commit blocked: gitleaks found a secret in staged files. Remove the secret from the staged files and do NOT bypass this guard.\n\n${details}`,
        )
      }

      throw new Error(
        `Commit blocked: gitleaks scan FAILED (fail-closed). Exit code ${result.exitCode}. Fix the scanner environment (is this a git repo? is git available?) and retry — do NOT bypass this guard.\n\n${details}`,
      )
    },
  }
}
