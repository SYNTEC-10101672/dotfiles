// Tests for the commit-gate plugin (repo-local; opencode/test/ is not deployed).
// Hooks are invoked directly with fake sessionIDs to simulate event sequences.
// Event payload shapes verified against the deployed opencode 1.18.22 event bus.
import { describe, expect, test } from "bun:test"
import type { Plugin } from "@opencode-ai/plugin"
import type { Event, Session } from "@opencode-ai/sdk"
import { CommitGatePlugin } from "../plugins/commit-gate"

type Hooks = Awaited<ReturnType<Plugin>>

// The plugin factory reads nothing from its input, so a stub suffices.
const loadHooks = async (): Promise<Hooks> => CommitGatePlugin({} as Parameters<Plugin>[0])

const bashHook = (hooks: Hooks) => {
  const fn = hooks["tool.execute.before"]
  if (!fn) throw new Error("tool.execute.before hook missing")
  return fn
}

const commandHook = (hooks: Hooks) => {
  const fn = hooks["command.execute.before"]
  if (!fn) throw new Error("command.execute.before hook missing")
  return fn
}

const eventHook = (hooks: Hooks) => {
  const fn = hooks.event
  if (!fn) throw new Error("event hook missing")
  return fn
}

// Simulate an AI bash tool call in `sessionID`.
const runBash = (hooks: Hooks, sessionID: string, command: string) =>
  bashHook(hooks)({ tool: "bash", sessionID, callID: "call_test" }, { args: { command } })

// Simulate the user running a slash command in `sessionID`.
const runCommand = (hooks: Hooks, sessionID: string, command: string) =>
  commandHook(hooks)({ command, sessionID, arguments: "" }, { parts: [] })

const sessionStub = (id: string): Session => ({
  id,
  projectID: "proj_test",
  directory: "/home/syntec/personal/dotfiles",
  title: "commit-gate test",
  version: "1.18.22",
  time: { created: 0, updated: 0 },
})

// opencode 1.18.22 emits session.deleted with both sessionID and info.id.
const sessionDeletedEvent = (sessionID: string): Event => {
  const properties = { sessionID, info: sessionStub(sessionID) }
  return { type: "session.deleted", properties }
}

// Returns the thrown error message, or "" when the call was not blocked.
const blockMessage = async (promise: Promise<void>): Promise<string> => {
  try {
    await promise
    return ""
  } catch (error: unknown) {
    if (error instanceof Error) return error.message
    return String(error)
  }
}

describe("commit-gate", () => {
  test("detect: blocks plain git commit", async () => {
    const hooks = await loadHooks()
    expect(await blockMessage(runBash(hooks, "s_detect_plain", 'git commit -m "x"'))).not.toBe("")
  })

  test("detect: blocks git -C <path> commit", async () => {
    const hooks = await loadHooks()
    expect(
      await blockMessage(runBash(hooks, "s_detect_dash_c", 'git -C /some/path commit -m "x"')),
    ).not.toBe("")
  })

  test("detect: blocks git commit inside a && chain", async () => {
    const hooks = await loadHooks()
    expect(
      await blockMessage(runBash(hooks, "s_detect_chain", 'git add . && git commit -m "x"')),
    ).not.toBe("")
  })

  test("detect: blocks env-prefixed git commit", async () => {
    const hooks = await loadHooks()
    expect(
      await blockMessage(runBash(hooks, "s_detect_env", "GIT_EDITOR=true git commit")),
    ).not.toBe("")
  })

  test("detect: allows git commit-tree (plumbing)", async () => {
    const hooks = await loadHooks()
    await expect(
      runBash(hooks, "s_detect_tree", 'git commit-tree 0f1a2b -m "x"'),
    ).resolves.toBeUndefined()
  })

  test("detect: allows git rebase --continue", async () => {
    const hooks = await loadHooks()
    await expect(runBash(hooks, "s_detect_rebase", "git rebase --continue")).resolves.toBeUndefined()
  })

  test("detect: allows git merge --continue", async () => {
    const hooks = await loadHooks()
    await expect(runBash(hooks, "s_detect_merge", "git merge --continue")).resolves.toBeUndefined()
  })

  test("detect: allows git cherry-pick --continue", async () => {
    const hooks = await loadHooks()
    await expect(
      runBash(hooks, "s_detect_cherry", "git cherry-pick --continue"),
    ).resolves.toBeUndefined()
  })

  test("message: block error carries all required elements", async () => {
    const hooks = await loadHooks()
    const message = await blockMessage(runBash(hooks, "s_message", 'git commit -m "x"'))
    expect(message).toContain("forbidden commits this session")
    expect(message).toContain("continue completing")
    expect(message).toContain("/commit")
    expect(message).toContain("Do not retry or work around")
  })

  test("lifecycle: /commit authorizes commits in the same session", async () => {
    const hooks = await loadHooks()
    await runCommand(hooks, "s_life_auth_slash", "/commit")
    await expect(
      runBash(hooks, "s_life_auth_slash", 'git commit -m "x"'),
    ).resolves.toBeUndefined()
    await runCommand(hooks, "s_life_auth_bare", "commit")
    await expect(
      runBash(hooks, "s_life_auth_bare", 'git commit -m "x"'),
    ).resolves.toBeUndefined()
  })

  test("lifecycle: authorization is not inherited by other session IDs (subagents)", async () => {
    const hooks = await loadHooks()
    await runCommand(hooks, "s_life_main", "commit")
    expect(await blockMessage(runBash(hooks, "s_life_sub", 'git commit -m "x"'))).not.toBe("")
  })

  test("lifecycle: another slash command clears authorization", async () => {
    const hooks = await loadHooks()
    await runCommand(hooks, "s_life_clear", "commit")
    await runCommand(hooks, "s_life_clear", "eli5")
    expect(await blockMessage(runBash(hooks, "s_life_clear", 'git commit -m "x"'))).not.toBe("")
  })

  test("lifecycle: session.deleted clears authorization", async () => {
    const hooks = await loadHooks()
    await runCommand(hooks, "s_life_deleted", "commit")
    await eventHook(hooks)({ event: sessionDeletedEvent("s_life_deleted") })
    expect(await blockMessage(runBash(hooks, "s_life_deleted", 'git commit -m "x"'))).not.toBe("")
  })

  test("lifecycle: session.idle keeps authorization", async () => {
    const hooks = await loadHooks()
    await runCommand(hooks, "s_life_idle", "commit")
    await eventHook(hooks)({
      event: { type: "session.idle", properties: { sessionID: "s_life_idle" } },
    })
    await expect(
      runBash(hooks, "s_life_idle", 'git commit -m "x"'),
    ).resolves.toBeUndefined()
  })

  test("lifecycle: non-commit git commands are untouched", async () => {
    const hooks = await loadHooks()
    await expect(runBash(hooks, "s_life_innocent", "git status")).resolves.toBeUndefined()
    await expect(runBash(hooks, "s_life_innocent", "git add .")).resolves.toBeUndefined()
  })
})
