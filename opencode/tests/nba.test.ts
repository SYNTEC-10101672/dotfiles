// Tests for the NBA scoreboard panel plugin (opencode/plugins/nba/tui.tsx).
// The seam is the ESPN-response-to-view-model transform (pure, injected clock)
// plus the plugin registration surface (fake context, no TUI).
import { describe, expect, test } from "bun:test"
import { toScoreboardView, createScoreboardPoller, createNbaPlugin, type ScoreboardView, type EspnScoreboard, type NbaFetch } from "../plugins/nba/tui"
import nbaPlugin from "../plugins/nba/tui"

// Recorded live from the default ESPN NBA scoreboard endpoint (2026-10-24):
// schedule day 2026-10-23, 12 events (6 in-progress, 5 upcoming, 1 finished).
const fixture = (await Bun.file("tests/fixtures/espn-scoreboard.json").json()) as never
const emptyFixture = (await Bun.file("tests/fixtures/espn-scoreboard-empty.json").json()) as never

// 02:30Z on 2026-10-24 is 10:30 AM in Asia/Taipei.
const NOW = new Date("2026-10-24T02:30:00Z")

const lineText = (line: { tokens: readonly { text: string }[] }) =>
  line.tokens.map((token) => token.text).join("")

const findLine = (view: ScoreboardView, prefix: string) =>
  view.lines.find((line) => lineText(line).startsWith(prefix))

// Column grid (GLOSSARY): away field [2,6), away score [7,10), home field
// [11,15), home score [16,19), detail from 21. Status column is [0,1).
// Team fields are 4 wide (UTAH, WSH), scores 3 right-aligned.
const matchupOf = (line: { tokens: readonly { text: string }[] }) => {
  const text = lineText(line)
  return `${text.slice(2, 6).trim()} at ${text.slice(11, 15).trim()}`
}

// Minimal upcoming (pre-state) event shaped like an ESPN scoreboard event.
const upcomingEvent = (date: string, away: string, home: string) => ({
  date,
  status: { type: { state: "pre" as const } },
  competitions: [
    {
      competitors: [
        { homeAway: "away" as const, score: "0", team: { abbreviation: away, color: "e03a3e" } },
        { homeAway: "home" as const, score: "0", team: { abbreviation: home, color: "5a76a9" } },
      ],
    },
  ],
})

describe("sort order", () => {
  test("lists in-progress first, then upcoming, then finished", () => {
    const view = toScoreboardView(fixture, NOW)
    expect(view.lines).toHaveLength(12)
    expect(view.lines.slice(0, 6).every((line) => line.state === "in-progress")).toBe(true)
    expect(view.lines.slice(6, 11).every((line) => line.state === "upcoming")).toBe(true)
    expect(view.lines[11]?.state).toBe("finished")
  })

  test("orders upcoming games by start time", () => {
    const view = toScoreboardView(fixture, NOW)
    const matchups = view.lines.slice(6, 11).map(matchupOf)
    expect(matchups).toEqual(["HOU at SA", "NO at UTAH", "MEM at GS", "LAC at LAL", "POR at SAC"])
  })
})

describe("line formats", () => {
  test("in-progress: red live dot, column-grid scores, period and red clock", () => {
    const view = toScoreboardView(fixture, NOW)
    const line = findLine(view, "● NY")
    expect(line?.state).toBe("in-progress")
    expect(lineText(line!)).toBe("● NY    82 BOS   93  Q4 8:01")
    expect(line?.dim).toBe(false)
    // The live dot and the game clock are red; scores carry no brand color.
    const red = line!.tokens.filter((token) => token.color === "#ff0000").map((t) => t.text)
    expect(red).toEqual(["● ", "8:01"])
  })

  test("upcoming: matchup and Taiwan local start time, dim", () => {
    const view = toScoreboardView(fixture, NOW)
    // 2026-10-24T01:30Z and 02:00Z are 9:30 AM and 10:00 AM in Asia/Taipei.
    const hou = findLine(view, "  HOU")
    const lac = findLine(view, "  LAC")
    expect(lineText(hou!)).toBe("  HOU      SA        9:30 AM")
    expect(lineText(lac!)).toBe("  LAC      LAL       10:00 AM")
    expect(hou?.state).toBe("upcoming")
    expect(hou?.dim).toBe(true)
    expect(lac?.dim).toBe(true)
  })

  test("finished: middle-dot status, final score, dim Final detail", () => {
    const view = toScoreboardView(fixture, NOW)
    const line = findLine(view, "· CHI")
    expect(line?.state).toBe("finished")
    expect(lineText(line!)).toBe("· CHI  132 MIL  125  Final")
    expect(line?.dim).toBe(true)
  })
})

describe("column grid", () => {
  // Worked example agreed with the spec: status 1 wide, away 4 left-aligned,
  // away score 3 right-aligned, home 4 left, home score 3 right, detail from
  // column 21. Any state must land on the same columns.
  test("places teams, scores and detail at identical columns in every state", () => {
    const view = toScoreboardView(fixture, NOW)
    const live = lineText(findLine(view, "● NY")!)
    const upcoming = lineText(findLine(view, "  HOU")!)
    const finished = lineText(findLine(view, "· CHI")!)

    expect(live.slice(2, 6)).toBe("NY  ")
    expect(live.slice(7, 10)).toBe(" 82")
    expect(live.slice(11, 15)).toBe("BOS ")
    expect(live.slice(16, 19)).toBe(" 93")
    expect(live.slice(21)).toBe("Q4 8:01")

    expect(upcoming.slice(2, 6)).toBe("HOU ")
    expect(upcoming.slice(7, 10)).toBe("   ")
    expect(upcoming.slice(11, 15)).toBe("SA  ")
    expect(upcoming.slice(16, 19)).toBe("   ")
    expect(upcoming.slice(21)).toBe("9:30 AM")

    expect(finished.slice(2, 6)).toBe("CHI ")
    expect(finished.slice(7, 10)).toBe("132")
    expect(finished.slice(11, 15)).toBe("MIL ")
    expect(finished.slice(16, 19)).toBe("125")
    expect(finished.slice(21)).toBe("Final")
  })

  test("keeps every game line on the grid, not only the examples above", () => {
    const view = toScoreboardView(fixture, NOW)
    for (const line of view.lines) {
      const text = lineText(line)
      expect(text.slice(6, 7)).toBe(" ")
      expect(text.slice(10, 11)).toBe(" ")
      expect(text.slice(15, 16)).toBe(" ")
      expect(text.slice(19, 21)).toBe("  ")
      expect(text.slice(21).length).toBeGreaterThan(0)
    }
  })
})

describe("brand colors", () => {
  const luminance = (hex: string) => {
    const r = parseInt(hex.slice(1, 3), 16)
    const g = parseInt(hex.slice(3, 5), 16)
    const b = parseInt(hex.slice(5, 7), 16)
    return (0.299 * r + 0.587 * g + 0.114 * b) / 255
  }
  const FLOOR = 0.3

  test("uses the ESPN brand color for teams above the luminance floor", () => {
    const view = toScoreboardView(fixture, NOW)
    // BOS #008348 and MEM #5d76a9 are readable as-is: passed through unchanged.
    const bos = findLine(view, "● NY")!.tokens.find((token) => token.text === "BOS ")
    expect(bos?.color).toBe("#008348")
    const mem = findLine(view, "  MEM")!.tokens.find((token) => token.text === "MEM ")
    expect(mem?.color).toBe("#5d76a9")
  })

  test("brightens brand colors below the luminance floor", () => {
    const view = toScoreboardView(fixture, NOW)
    // LAL #552583 and SA #000000 are too dark against a terminal background.
    const lal = findLine(view, "  LAC")!.tokens.find((token) => token.text === "LAL ")
    expect(lal?.color).not.toBe("#552583")
    expect(luminance(lal!.color!)).toBeGreaterThanOrEqual(FLOOR)
    const sa = findLine(view, "  HOU")!.tokens.find((token) => token.text === "SA  ")
    expect(sa?.color).not.toBe("#000000")
    expect(luminance(sa!.color!)).toBeGreaterThanOrEqual(FLOOR)
  })

  test("every team abbreviation token meets the luminance floor", () => {
    const view = toScoreboardView(fixture, NOW)
    const teamTokens = view.lines.flatMap((line) =>
      line.tokens.filter((token) => token.color && token.color !== "#ff0000"),
    )
    expect(teamTokens.length).toBeGreaterThan(0)
    for (const token of teamTokens) {
      expect(luminance(token.color!)).toBeGreaterThanOrEqual(FLOOR)
    }
  })
})

describe("empty schedule day", () => {
  // The full off-day walk (next game lookup) is ticket 02; here only the
  // minimal empty view.
  test("shows No games today instead of lines", () => {
    const view = toScoreboardView(emptyFixture, NOW)
    expect(view.lines).toHaveLength(0)
    expect(view.message).toBe("No games today")
  })

  test("header omits the schedule day when the response carries none", () => {
    const view = toScoreboardView(emptyFixture, NOW)
    expect(view.header).toBe("NBA Scoreboard · Updated 10:30 AM")
  })

  test("with a found next game shows its matchup and Taiwan start time", () => {
    // 2026-10-26T00:00Z is 8:00 AM in Asia/Taipei.
    const view = toScoreboardView(emptyFixture, NOW, upcomingEvent("2026-10-26T00:00:00Z", "POR", "SAC"))
    expect(view.lines).toHaveLength(0)
    expect(view.message).toBe("No games today")
    expect(view.nextGame?.state).toBe("upcoming")
    expect(view.nextGame?.dim).toBe(true)
    expect(lineText(view.nextGame!)).toBe("  POR      SAC       8:00 AM")
  })

  test("without a found next game keeps the bare No games today view", () => {
    const view = toScoreboardView(emptyFixture, NOW)
    expect(view.nextGame).toBeUndefined()
  })
})

describe("plugin registration", () => {
  type PanelState = { name: string } | undefined

  const makeCtx = (inSession: boolean) => {
    const layers: { mode?: string; commands?: { id?: string; slash?: { name: string }; bind?: false | string; run: () => void }[] }[] = []
    const slots: { append: string; render: unknown }[] = []
    const toasts: { message: string }[] = []
    const opened: string[] = []
    const closed: number[] = []
    const dispatched: string[] = []
    const slotUnregisters: number[] = []
    let current: PanelState
    const ctx = {
      keymap: {
        layer: (factory: () => unknown) => layers.push(factory() as never),
        dispatch: (id: string) => dispatched.push(id),
      },
      ui: {
        slot: (registration: { append: string; render: unknown }) => {
          slots.push(registration)
          return () => {
            slotUnregisters.push(1)
          }
        },
        panel: {
          current: () => current,
          open: (name: string) => {
            if (!inSession) return false
            current = { name }
            opened.push(name)
            return true
          },
          close: () => {
            closed.push(1)
            current = undefined
          },
        },
        toast: { show: (toast: { message: string }) => toasts.push(toast) },
      },
    }
    return { ctx: ctx as never, layers, slots, toasts, opened, closed, dispatched, slotUnregisters }
  }

  test("registers a global slash command named nba and a session.panel slot", async () => {
    const { ctx, layers, slots } = makeCtx(true)
    await nbaPlugin.setup?.(ctx)

    expect(nbaPlugin.id).toBe("nba-scoreboard")
    expect(slots[0]?.append).toBe("session.panel")
    expect(typeof slots[0]?.render).toBe("function")

    const command = layers[0]?.commands?.[0]
    expect(layers[0]?.mode).toBe("global")
    // The host rejects slash commands without a stable id.
    expect(command?.id).toBe("nba.scoreboard.toggle")
    expect(command?.slash?.name).toBe("nba")
    // The toggle lives on the leader chord; the slash command stays as an
    // alternative. The leader key itself is ctrl+\ (cli.json).
    expect(command?.bind).toBe("<leader>f")
  })

  test("run opens the scoreboard panel and returns pane focus to the session pane, then closes it without dispatching", async () => {
    const { ctx, layers, opened, closed, dispatched } = makeCtx(true)
    await nbaPlugin.setup?.(ctx)
    const run = layers[0]?.commands?.[0]?.run

    await run?.()
    expect(opened).toEqual(["nba.scoreboard"])
    // Opening the panel grabs focus; the plugin hands it back to the prompt.
    expect(dispatched).toEqual(["pane.focus.left"])

    await run?.()
    expect(closed).toHaveLength(1)
    // Closing leaves keyboard focus where it is.
    expect(dispatched).toEqual(["pane.focus.left"])
  })

  test("run shows a toast when no session is open", async () => {
    const { ctx, layers, toasts, opened, dispatched } = makeCtx(false)
    await nbaPlugin.setup?.(ctx)
    const run = layers[0]?.commands?.[0]?.run

    await run?.()
    expect(opened).toHaveLength(0)
    expect(toasts).toHaveLength(1)
    expect(toasts[0]?.message).toMatch(/session/i)
    expect(dispatched).toHaveLength(0)
  })

  test("plugin cleanup unregisters the session.panel slot", async () => {
    const { ctx, slotUnregisters } = makeCtx(true)
    const cleanup = await nbaPlugin.setup?.(ctx)
    expect(slotUnregisters).toHaveLength(0)

    cleanup?.()
    expect(slotUnregisters).toHaveLength(1)
  })

  test("plugin cleanup stops the poller when the panel element was never disposed", async () => {
    const scheduler = makeScheduler()
    const { fetchLike } = makeFetch({ [ESPN_URL]: [gameDay("LAC", "LAL")] })
    const plugin = createNbaPlugin({
      fetch: fetchLike,
      now: () => NOW,
      setInterval: scheduler.setInterval,
      clearInterval: scheduler.clearInterval,
    })
    const { ctx, slots, slotUnregisters } = makeCtx(true)
    const cleanup = await plugin.setup?.(ctx)

    // Mount the panel by invoking the registered slot render; the poller
    // starts there before the element is built. Building the intrinsic JSX
    // throws without an OpenTUI renderer (tests run no TUI harness), so the
    // throw is tolerated — the element is never disposed either way.
    try {
      ;(slots[0]!.render as (input: { name: string }) => unknown)({ name: "nba.scoreboard" })
    } catch {
      // The poller has already started by the time the renderer is needed.
    }
    expect(scheduler.intervals).toHaveLength(1)

    cleanup?.()
    expect(slotUnregisters).toHaveLength(1)
    expect(scheduler.intervals.every((interval) => interval.cleared)).toBe(true)
  })
})

describe("header", () => {
  test("shows the schedule day and the last update time", () => {
    const view = toScoreboardView(fixture, NOW)
    expect(view.header).toBe("NBA Scoreboard · 2026-10-23 · Updated 10:30 AM")
  })
})

// Poller seam: injected fetch, clock and interval scheduler drive the panel's
// live state machine without a TUI.
const ESPN_URL = "https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard"
const dateUrl = (ymd: string) => `${ESPN_URL}?dates=${ymd}`

// Fake fetch with scripted per-URL response queues; a null (or missing) entry
// is a failed response.
const makeFetch = (scripts: Record<string, (unknown | null)[]>) => {
  const urls: string[] = []
  const fetchLike = async (url: string) => {
    urls.push(url)
    const body = scripts[url]?.shift()
    return body === null || body === undefined
      ? { ok: false, json: async () => ({}) }
      : { ok: true, json: async () => body }
  }
  return { fetchLike: fetchLike as unknown as NbaFetch, urls }
}

// Fake interval scheduler: records registrations, fires ticks manually.
const makeScheduler = () => {
  const intervals: { handle: number; callback: () => void; ms: number; cleared: boolean }[] = []
  let nextHandle = 1
  return {
    setInterval: (callback: () => void, ms: number) => {
      const interval = { handle: nextHandle++, callback, ms, cleared: false }
      intervals.push(interval)
      return interval.handle
    },
    clearInterval: (handle: unknown) => {
      const interval = intervals.find((candidate) => candidate.handle === handle)
      if (interval) interval.cleared = true
    },
    intervals,
    tick: () => {
      for (const interval of [...intervals]) if (!interval.cleared) interval.callback()
    },
  }
}

const settle = () => new Promise((resolve) => setTimeout(resolve, 0))

const gameDay = (away: string, home: string): EspnScoreboard => ({
  day: { date: "2026-10-23" },
  events: [upcomingEvent("2026-10-24T02:00:00Z", away, home)],
})

describe("scoreboard poller", () => {
  const makePoller = (fetchLike: NbaFetch) => {
    const scheduler = makeScheduler()
    const poller = createScoreboardPoller({
      fetch: fetchLike,
      now: () => NOW,
      setInterval: scheduler.setInterval,
      clearInterval: scheduler.clearInterval,
    })
    return { poller, scheduler }
  }

  test("starts connecting, fetches immediately, and re-fetches on each 10-second tick", async () => {
    const day = gameDay("LAC", "LAL")
    const { fetchLike, urls } = makeFetch({ [ESPN_URL]: [day, day, day] })
    const { poller, scheduler } = makePoller(fetchLike)

    expect(poller.state()).toEqual({ status: "connecting" })
    await settle()
    expect(urls).toEqual([ESPN_URL])
    expect(poller.state().status).toBe("live")
    expect(poller.state().view?.lines).toHaveLength(1)
    expect(scheduler.intervals.map((interval) => interval.ms)).toEqual([10_000])

    scheduler.tick()
    await settle()
    scheduler.tick()
    await settle()
    expect(urls).toEqual([ESPN_URL, ESPN_URL, ESPN_URL])
  })

  test("a failed fetch keeps the last good view with a reconnecting status until recovery", async () => {
    const { fetchLike } = makeFetch({
      [ESPN_URL]: [gameDay("LAC", "LAL"), null, gameDay("POR", "SAC")],
    })
    const { poller, scheduler } = makePoller(fetchLike)
    await settle()
    const good = poller.state().view
    expect(poller.state().status).toBe("live")
    expect(lineText(good!.lines[0])).toBe("  LAC      LAL       10:00 AM")

    scheduler.tick()
    await settle()
    expect(poller.state().status).toBe("reconnecting")
    expect(poller.state().view).toBe(good)

    scheduler.tick()
    await settle()
    expect(poller.state().status).toBe("live")
    expect(lineText(poller.state().view!.lines[0])).toBe("  POR      SAC       10:00 AM")
  })

  test("before the first successful fetch the state stays connecting", async () => {
    const { fetchLike } = makeFetch({ [ESPN_URL]: [null, null] })
    const { poller, scheduler } = makePoller(fetchLike)

    expect(poller.state()).toEqual({ status: "connecting" })
    await settle()
    expect(poller.state()).toEqual({ status: "connecting" })
    scheduler.tick()
    await settle()
    expect(poller.state()).toEqual({ status: "connecting" })
  })

  test("stop clears the interval and a stopped poller sends no further requests", async () => {
    const { fetchLike, urls } = makeFetch({ [ESPN_URL]: [gameDay("LAC", "LAL")] })
    const { poller, scheduler } = makePoller(fetchLike)
    await settle()
    expect(urls).toEqual([ESPN_URL])

    poller.stop()
    expect(scheduler.intervals.every((interval) => interval.cleared)).toBe(true)
    scheduler.tick()
    await settle()
    expect(urls).toEqual([ESPN_URL])
  })

  test("a tick while a refresh is in flight is skipped, so refreshes cannot interleave", async () => {
    // The first fetch is held open: if the overlapping tick started its own
    // refresh, that newer result could be overwritten by the older response
    // completing later. The guard makes the overlap impossible instead.
    const urls: string[] = []
    let releaseFirst: () => void = () => {}
    const firstHeld = new Promise<void>((resolve) => (releaseFirst = resolve))
    let calls = 0
    const fetchLike: NbaFetch = async (url) => {
      urls.push(url)
      calls += 1
      if (calls === 1) {
        await firstHeld
        return { ok: true, json: async () => gameDay("LAC", "LAL") }
      }
      return { ok: true, json: async () => gameDay("POR", "SAC") }
    }
    const { poller, scheduler } = makePoller(fetchLike)

    // The tick lands while the initial refresh is still in flight.
    scheduler.tick()
    expect(urls).toEqual([ESPN_URL])

    releaseFirst()
    await settle()
    expect(poller.state().status).toBe("live")
    expect(lineText(poller.state().view!.lines[0])).toBe("  LAC      LAL       10:00 AM")

    // The next tick after the refresh completed fetches normally again.
    scheduler.tick()
    await settle()
    expect(urls).toEqual([ESPN_URL, ESPN_URL])
    expect(lineText(poller.state().view!.lines[0])).toBe("  POR      SAC       10:00 AM")
  })

  test("off-day walks future dates and shows the next game in Taiwan time", async () => {
    // emptyFixture carries no day, so the walk falls back to the injected
    // clock: NOW is 2026-10-23 in US Eastern, first walked date 20261024.
    const { fetchLike, urls } = makeFetch({
      [ESPN_URL]: [emptyFixture],
      [dateUrl("20261024")]: [{ events: [] }],
      [dateUrl("20261025")]: [{ events: [upcomingEvent("2026-10-26T00:00:00Z", "POR", "SAC")] }],
    })
    const { poller } = makePoller(fetchLike)
    await settle()

    expect(urls).toEqual([ESPN_URL, dateUrl("20261024"), dateUrl("20261025")])
    expect(poller.state().status).toBe("live")
    expect(poller.state().view?.message).toBe("No games today")
    expect(poller.state().view?.lines).toHaveLength(0)
    expect(lineText(poller.state().view?.nextGame!)).toBe("  POR      SAC       8:00 AM")
  })

  test("the walk stops after five empty days without a next game", async () => {
    const emptyDay: EspnScoreboard = { day: { date: "2026-07-10" }, events: [] }
    const walked = ["20260711", "20260712", "20260713", "20260714", "20260715"]
    const { fetchLike, urls } = makeFetch({
      [ESPN_URL]: [emptyDay],
      ...Object.fromEntries(walked.map((ymd) => [dateUrl(ymd), [{ events: [] }]])),
    })
    const { poller } = makePoller(fetchLike)
    await settle()

    expect(urls).toEqual([ESPN_URL, ...walked.map(dateUrl)])
    expect(poller.state().status).toBe("live")
    expect(poller.state().view?.message).toBe("No games today")
    expect(poller.state().view?.nextGame).toBeUndefined()
  })

  test("an empty day re-walks only after the schedule day changes", async () => {
    const emptyDay: EspnScoreboard = { day: { date: "2026-07-10" }, events: [] }
    const walked = ["20260711", "20260712", "20260713", "20260714", "20260715"]
    const { fetchLike, urls } = makeFetch({
      [ESPN_URL]: [emptyDay, emptyDay],
      ...Object.fromEntries(walked.map((ymd) => [dateUrl(ymd), [{ events: [] }]])),
    })
    const { poller, scheduler } = makePoller(fetchLike)
    await settle()
    expect(urls).toHaveLength(6)

    scheduler.tick()
    await settle()
    expect(urls).toEqual([ESPN_URL, ...walked.map(dateUrl), ESPN_URL])
  })
})
