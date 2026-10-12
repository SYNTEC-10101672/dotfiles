// Tests for the v2 Secret Guard plugin (opencode/plugins/guard.ts).
// The gitleaks child process is the seam: unit tests inject a fake runner,
// integration tests run the real gitleaks binary against a throwaway repo.
import { describe, expect, test, beforeAll } from "bun:test"
import {
  createGuardHook,
  runGuardProcess,
  type GuardRunner,
  type GuardRunResult,
  type GuardToolEvent,
} from "../plugins/guard"
import plugin from "../plugins/guard"
import { execFileSync } from "node:child_process"
import { mkdtemp, writeFile, rm } from "node:fs/promises"
import { tmpdir } from "node:os"
import path from "node:path"

const shellEvent = (command: unknown): GuardToolEvent => ({
  tool: "shell",
  input: { command },
})

const REPO = "/session/project"

type Call = { command: string[]; env?: Record<string, string | undefined>; cwd?: string }

const makeRunner = (
  script: (command: string[]) => GuardRunResult | Promise<GuardRunResult> | Error,
) => {
  const calls: Call[] = []
  const run: GuardRunner = async (command, options) => {
    calls.push({ command: [...command], env: options?.env, cwd: options?.cwd })
    const outcome = script([...command])
    if (outcome instanceof Error) throw outcome
    return outcome
  }
  return { run, calls }
}

const ok: GuardRunResult = { exitCode: 0, stdout: "", stderr: "" }

describe("tool filtering", () => {
  test("ignores non-shell tools", async () => {
    const { run, calls } = makeRunner(() => ok)
    const hook = createGuardHook(run, REPO)
    await hook({ tool: "read", input: { filePath: ".env" } })
    await hook({ tool: "edit", input: {} })
    expect(calls).toHaveLength(0)
  })

  test("ignores shell commands without git commit", async () => {
    const { run, calls } = makeRunner(() => ok)
    const hook = createGuardHook(run, REPO)
    await hook(shellEvent("git status"))
    await hook(shellEvent("git push origin main"))
    expect(calls).toHaveLength(0)
  })

  test("ignores a non-string command", async () => {
    const { run, calls } = makeRunner(() => ok)
    const hook = createGuardHook(run, REPO)
    await hook(shellEvent(undefined))
    await hook({ tool: "shell", input: {} })
    expect(calls).toHaveLength(0)
  })

  test("intercepts compound commands containing git commit", async () => {
    const { run, calls } = makeRunner((command) =>
      command.includes("version") ? ok : { ...ok, exitCode: 1, stdout: "leak" },
    )
    const hook = createGuardHook(run, REPO)
    await expect(hook(shellEvent("cd /tmp && git commit -m 'wip'"))).rejects.toThrow(
      "found a secret",
    )
    expect(calls).toHaveLength(2)
  })
})

describe("fail-closed policy", () => {
  test("blocks when gitleaks is unavailable", async () => {
    const { run } = makeRunner((command) =>
      command.includes("version")
        ? { exitCode: 127, stdout: "", stderr: "command not found" }
        : ok,
    )
    const hook = createGuardHook(run, REPO)
    await expect(hook(shellEvent("git commit -m x"))).rejects.toThrow(
      "Commit blocked intentionally: gitleaks is required",
    )
  })

  test("allows a clean staged scan", async () => {
    const { run } = makeRunner(() => ok)
    const hook = createGuardHook(run, REPO)
    await hook(shellEvent("git commit -m x"))
  })

  test("blocks with findings when gitleaks exits 1", async () => {
    const { run } = makeRunner((command) =>
      command.includes("version")
        ? ok
        : { exitCode: 1, stdout: "Finding:   aws-key", stderr: "Secret:   AKIA..." },
    )
    const hook = createGuardHook(run, REPO)
    await expect(hook(shellEvent("git commit -m x"))).rejects.toThrow(
      "gitleaks found a secret in staged files",
    )
  })

  test("blocks when gitleaks exits with an unexpected code", async () => {
    const { run } = makeRunner((command) =>
      command.includes("version") ? ok : { ...ok, exitCode: 2, stderr: "no git repo" },
    )
    const hook = createGuardHook(run, REPO)
    await expect(hook(shellEvent("git commit -m x"))).rejects.toThrow(
      "gitleaks scan FAILED (fail-closed). Exit code 2",
    )
  })

  test("blocks when the scan process throws", async () => {
    const { run } = makeRunner((command) =>
      command.includes("version") ? ok : new Error("spawn ENOENT"),
    )
    const hook = createGuardHook(run, REPO)
    await expect(hook(shellEvent("git commit -m x"))).rejects.toThrow(
      "gitleaks scan FAILED (fail-closed)",
    )
  })
})

describe("scan invocation", () => {
  test("checks availability first, then scans staged content with color off", async () => {
    const { run, calls } = makeRunner(() => ok)
    const hook = createGuardHook(run, REPO)
    await hook(shellEvent("git commit -m x"))

    expect(calls[0]?.command).toEqual(["gitleaks", "version"])
    expect(calls[1]?.command).toEqual(["gitleaks", "protect", "--staged", "--redact"])

    const env = calls[1]?.env
    expect(env?.GIT_CONFIG_COUNT).toBe("1")
    expect(env?.GIT_CONFIG_KEY_0).toBe("color.ui")
    expect(env?.GIT_CONFIG_VALUE_0).toBe("off")
    expect(env?.PATH).toBe(process.env.PATH)

    // The shared v2 service cwd is not the session project, so the scan
    // must run in the plugin location directory explicitly.
    expect(calls[1]?.cwd).toBe(REPO)
  })
})

describe("plugin definition", () => {
  test("registers execute.before on the tool domain", async () => {
    const registrations: { name: string; callback: (event: GuardToolEvent) => Promise<void> }[] = []
    const ctx = {
      location: { directory: REPO },
      tool: {
        hook: async (name: string, callback: (event: GuardToolEvent) => Promise<void>) => {
          registrations.push({ name, callback })
        },
      },
    }
    await plugin.setup?.(ctx as never)

    expect(plugin.id).toBe("secret-guard")
    expect(registrations).toHaveLength(1)
    expect(registrations[0]?.name).toBe("execute.before")

    // Benign shell commands pass straight through the registered hook.
    await registrations[0]?.callback(shellEvent("git status"))
  })
})

// test.skipIf() evaluates at registration time, so probe gitleaks up front.
const gitleaksAvailable = (await runGuardProcess(["gitleaks", "version"])).exitCode === 0
let repo = ""

beforeAll(async () => {
  if (!gitleaksAvailable) return
  repo = await mkdtemp(path.join(tmpdir(), "guard-test-"))
  execFileSync("git", ["init", "--quiet"], { cwd: repo })
})

describe("integration with real gitleaks", () => {
  test.skipIf(!gitleaksAvailable)("blocks a staged AWS key", async () => {
    // Assemble the fake key at runtime so this fixture does not trip
    // secret scanners on the repo's own staged content.
    const fakeAwsKey = ["AKIA", "Q7ZXW3LPE9TN4MVB"].join("")
    await writeFile(path.join(repo, "creds.txt"), `aws_key = ${fakeAwsKey}\n`)
    execFileSync("git", ["add", "creds.txt"], { cwd: repo })

    const run: GuardRunner = (command, options) =>
      runGuardProcess(command, { ...options, cwd: repo })
    const hook = createGuardHook(run, REPO)

    await expect(hook(shellEvent("git commit -m x"))).rejects.toThrow(
      "gitleaks found a secret in staged files",
    )

    // Unstage so later tests start from a clean index.
    execFileSync("git", ["reset", "--quiet"], { cwd: repo })
  })

  test.skipIf(!gitleaksAvailable)("allows a staged clean file", async () => {
    await writeFile(path.join(repo, "notes.txt"), "just some notes\n")
    execFileSync("git", ["add", "notes.txt"], { cwd: repo })

    const run: GuardRunner = (command, options) =>
      runGuardProcess(command, { ...options, cwd: repo })
    const hook = createGuardHook(run, REPO)

    await hook(shellEvent("git commit -m x"))
  })

  test.skipIf(!gitleaksAvailable)("cleans up the throwaway repo", async () => {
    await rm(repo, { recursive: true, force: true })
  })
})
