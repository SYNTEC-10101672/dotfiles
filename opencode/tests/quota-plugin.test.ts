// Guards the opencode-quota config surfaces deployed by the dotfiles repo:
// 1. the plugin entry in opencode/opencode.json must pin an exact version
//    (no dist-tag or range) and the file must stay strict JSON, because it
//    is the symlink source (the installer only adds comments to .jsonc
//    outputs);
// 2. opencode/opencode-quota/quota-toast.jsonc must keep the display
//    consensus: allWindows format (so the Weekly cap stays visible), one
//    compact line at the TUI Home bottom, and every other surface off.
import { describe, expect, test } from "bun:test"
import { readFileSync } from "node:fs"
import path from "node:path"

const configPath = path.join(import.meta.dir, "..", "opencode.json")
const quotaToastPath = path.join(import.meta.dir, "..", "opencode-quota", "quota-toast.jsonc")
const EXACT_PIN = /^@slkiser\/opencode-quota@\d+\.\d+\.\d+$/

describe("quota plugin entry", () => {
  test("opencode-quota is pinned to an exact version", () => {
    // JSON.parse (not a JSONC parser) on purpose: strict JSON is the contract.
    const plugin = JSON.parse(readFileSync(configPath, "utf8")).plugin
    const entries = (Array.isArray(plugin) ? plugin : []).map(String)
    const quotaEntries = entries.filter((entry) =>
      entry.startsWith("@slkiser/opencode-quota@"),
    )
    expect(quotaEntries.length).toBeGreaterThan(0)
    // Every quota entry must be an exact pin; catches @latest, @next,
    // ranges, and partial pins like @5 or @5.0 in one assertion.
    for (const entry of quotaEntries) {
      expect(entry).toMatch(EXACT_PIN)
    }
  })
})

describe("quota toast config", () => {
  // JSON.parse (not a JSONC parser) on purpose: the file is comment-free
  // JSON so simple tooling (jq, grep) keeps working on the symlinked repo
  // copy; the .jsonc extension only follows the plugin's expected name.
  const config = JSON.parse(readFileSync(quotaToastPath, "utf8"))

  test("shows every window so the Weekly cap stays visible", () => {
    // singleWindow auto-picks the lowest-remaining window, which does not
    // guarantee the Weekly cap appears.
    expect(config.formatStyle).toBe("allWindows")
  })

  test("renders one compact line at the TUI Home bottom only", () => {
    expect(config.tuiCompactStatus).toEqual({
      enabled: true,
      homeBottom: true,
      sessionPrompt: false,
    })
  })

  test("keeps toast, sidebar panel, and prompt bar off", () => {
    expect(config.enableToast).toBe(false)
    expect(config.tuiSidebarPanel?.enabled).toBe(false)
    expect(config.tuiPromptBar?.enabled).toBe(false)
  })

  test("leaves waitForQuotaReset on (explicit true or default)", () => {
    // The key is absent in the shipped config, which keeps the plugin
    // default (true). An explicit false must fail this guard.
    expect(config.waitForQuotaReset ?? true).toBe(true)
  })
})
