// Guards the opencode-quota config surfaces deployed by the dotfiles repo:
// 1. the plugin entry in opencode/opencode.json must pin an exact version
//    (no dist-tag or range) and the file must stay strict JSON, because it
//    is the symlink source (the installer only adds comments to .jsonc
//    outputs);
// 2. opencode/opencode-quota/quota-toast.jsonc must keep the display
//    consensus: allWindows format at the root (so the /quota report
//    keeps the Weekly cap visible, and toast/sidebar would too if ever
//    enabled), a per-surface singleWindow override on the compact line
//    (short line, shows the binding constraint), the compact line at
//    the TUI Home bottom and under session prompts, zai as the only
//    provider, and every other surface off.
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

  test("keeps every window on full-report surfaces (root formatStyle)", () => {
    // Root allWindows keeps /quota (and toast/sidebar, if ever enabled)
    // showing every window; singleWindow at the root auto-picks the
    // lowest-remaining window, which does not guarantee the Weekly cap
    // appears. The compact line opts out separately below.
    expect(config.formatStyle).toBe("allWindows")
  })

  test("renders the compact line at Home bottom and under session prompts, single-window only", () => {
    // allWindows made the line ~48 chars (three windows with reset
    // countdowns). The per-surface singleWindow override collapses it to
    // the lowest-remaining window (~18 chars); the compact line drops
    // the window label, so a segment reads "Z.ai 98% 5d 0h 2m".
    expect(config.tuiCompactStatus).toEqual({
      enabled: true,
      homeBottom: true,
      sessionPrompt: true,
      formatStyle: "singleWindow",
    })
  })

  test("scopes providers to zai", () => {
    // Copilot is unlimited, so its segment carries no information; with
    // "auto" it re-enters the compact line and demotes Z.ai behind "+1",
    // hiding the windows the line exists for. A future metered provider
    // joins by adding its id here.
    expect(config.enabledProviders).toEqual(["zai"])
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
