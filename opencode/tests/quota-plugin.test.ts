// Guards the opencode-quota plugin entry in opencode/opencode.json:
// the specifier must pin an exact version (no dist-tag or range) and
// the file must stay strict JSON, because it is the symlink source
// deployed by the dotfiles repo (the installer only adds comments to
// .jsonc outputs).
import { describe, expect, test } from "bun:test"
import { readFileSync } from "node:fs"
import path from "node:path"

const configPath = path.join(import.meta.dir, "..", "opencode.json")
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
