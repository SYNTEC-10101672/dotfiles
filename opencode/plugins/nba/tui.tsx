// NBA scoreboard session panel: `/nba` toggles a panel showing today's
// scoreboard (schedule day = ESPN default day, US Eastern). The transform from
// an ESPN scoreboard response to the panel view model is pure and exported for
// tests; environment dependencies (fetch, clock) are injectable like guard.ts.
import { Plugin } from "@opencode/plugin/tui"
import { TextAttributes } from "@opentui/core"
import type { JSX } from "@opentui/solid"
import { createSignal, onCleanup, For } from "solid-js"

// Minimal structural shape of the ESPN scoreboard response.
export type EspnScoreboard = {
  readonly events?: readonly {
    readonly date: string
    readonly status: {
      readonly type: { readonly state: "pre" | "in" | "post" }
      readonly period?: number
      readonly displayClock?: string
    }
    readonly competitions: readonly {
      readonly competitors: readonly {
        readonly score?: string
        readonly homeAway: "home" | "away"
        readonly team: { readonly abbreviation: string; readonly color?: string }
      }[]
    }[]
  }[]
  readonly day?: { readonly date?: string } | null
}

// A rendered line as flat tokens: concatenated token text is the full line,
// colored tokens carry a brightened hex brand color, `dim` marks dimmed lines.
export type LineToken = { readonly text: string; readonly color?: string }

export type GameLineView = {
  readonly state: "in-progress" | "upcoming" | "finished"
  readonly dim: boolean
  readonly tokens: readonly LineToken[]
}

export type ScoreboardView = {
  readonly header: string
  readonly lines: readonly GameLineView[]
  // Shown instead of lines on an empty schedule day.
  readonly message?: string
  // Off-day: the next scheduled game found by walking future dates.
  readonly nextGame?: GameLineView
}

const taipeiTime = (date: Date) =>
  new Intl.DateTimeFormat("en-US", {
    timeZone: "Asia/Taipei",
    hour: "numeric",
    minute: "2-digit",
  }).format(date)

type EspnEvent = NonNullable<EspnScoreboard["events"]>[number]
export type { EspnEvent }

const sides = (event: EspnEvent) => {
  const competitors = event.competitions[0]?.competitors ?? []
  const away = competitors.find((competitor) => competitor.homeAway === "away")
  const home = competitors.find((competitor) => competitor.homeAway === "home")
  return { away, home }
}

const stateOf = (event: EspnEvent): GameLineView["state"] =>
  event.status.type.state === "in"
    ? "in-progress"
    : event.status.type.state === "pre"
      ? "upcoming"
      : "finished"

// in-progress first, then upcoming (by start time), then finished.
type GameLine = GameLineView & { readonly start: Date }

const sortRank = (line: GameLine) =>
  line.state === "in-progress" ? 0 : line.state === "upcoming" ? 1 : 2

const LIVE_RED = "#ff0000"

// ESPN colors are 6-digit hex without '#'. Colors below a simple luminance
// floor are mixed toward white until they reach it, so dark brand colors
// (e.g. SA black) stay readable against a terminal background.
const LUMINANCE_FLOOR = 0.3
const luminanceOf = (r: number, g: number, b: number) => (0.299 * r + 0.587 * g + 0.114 * b) / 255

const brandColor = (hex: string | undefined): string | undefined => {
  if (!hex) return undefined
  const r = parseInt(hex.slice(0, 2), 16)
  const g = parseInt(hex.slice(2, 4), 16)
  const b = parseInt(hex.slice(4, 6), 16)
  const luminance = luminanceOf(r, g, b)
  if (luminance >= LUMINANCE_FLOOR) return `#${hex}`
  // Ceil (never floor) so rounding cannot drop the result back below the floor.
  const mix = (channel: number) =>
    Math.min(255, Math.ceil(channel + (255 - channel) * ((LUMINANCE_FLOOR - luminance) / (1 - luminance))))
  return `#${[mix(r), mix(g), mix(b)].map((c) => c.toString(16).padStart(2, "0")).join("")}`
}

const periodLabel = (period: number) =>
  period <= 4 ? `Q${period}` : period === 5 ? "OT" : `${period - 4}OT`

const scoreOf = (competitor: { score?: string } | undefined) => competitor?.score ?? "0"

const toGameLine = (event: EspnEvent): GameLine => {
  const state = stateOf(event)
  const { away, home } = sides(event)
  const awayAbbr = away?.team.abbreviation ?? "???"
  const homeAbbr = home?.team.abbreviation ?? "???"
  const awayColor = brandColor(away?.team.color)
  const homeColor = brandColor(home?.team.color)
  const abbrToken = (abbr: string, color: string | undefined): LineToken => ({
    text: abbr,
    ...(color ? { color } : {}),
  })
  const status = event.status

  if (state === "upcoming") {
    return {
      state,
      dim: true,
      tokens: [
        abbrToken(awayAbbr, awayColor),
        { text: " at " },
        abbrToken(homeAbbr, homeColor),
        { text: ` · ${taipeiTime(new Date(event.date))}` },
      ],
      start: new Date(event.date),
    }
  }

  const scoreTokens =
    state === "in-progress"
      ? [
          { text: "● ", color: LIVE_RED },
          abbrToken(awayAbbr, awayColor),
          { text: ` ${scoreOf(away)} ` },
          abbrToken(homeAbbr, homeColor),
          { text: ` ${scoreOf(home)} · ` },
          { text: status.displayClock || "0:00", color: LIVE_RED },
          { text: ` ${periodLabel(status.period ?? 0)}` },
        ]
      : [
          abbrToken(awayAbbr, awayColor),
          { text: ` ${scoreOf(away)} ` },
          abbrToken(homeAbbr, homeColor),
          { text: ` ${scoreOf(home)} · Final` },
        ]
  return {
    state,
    dim: state !== "in-progress",
    tokens: scoreTokens,
    start: new Date(event.date),
  }
}

export const toScoreboardView = (
  response: EspnScoreboard,
  now: Date,
  nextEvent?: EspnEvent,
): ScoreboardView => {
  const day = response.day?.date
  const events = response.events ?? []
  const view = events.length
    ? {
        lines: events.map(toGameLine).sort((a, b) => {
          const rank = sortRank(a) - sortRank(b)
          return rank !== 0 ? rank : a.start.getTime() - b.start.getTime()
        }),
      }
    : {
        lines: [] as readonly GameLineView[],
        message: "No games today",
        ...(nextEvent ? { nextGame: toGameLine(nextEvent) } : {}),
      }
  return {
    header: `NBA Scoreboard${day ? ` · ${day}` : ""} · Updated ${taipeiTime(now)}`,
    ...view,
  }
}

const PANEL_NAME = "nba.scoreboard"
const ESPN_URL = "https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard"

export type NbaFetch = (url: string) => Promise<{ readonly ok: boolean; json(): Promise<unknown> }>
export type NbaDeps = {
  readonly fetch: NbaFetch
  readonly now: () => Date
  readonly setInterval: (callback: () => void, ms: number) => number | Timer
  readonly clearInterval: (handle: number | Timer) => void
}

// A failed response (network error or non-ok status) throws; callers treat
// every throw as a failed refresh.
const fetchScoreboard = async (fetchLike: NbaFetch, url = ESPN_URL): Promise<EspnScoreboard> => {
  const response = await fetchLike(url)
  if (!response.ok) throw new Error(`scoreboard fetch failed: ${url}`)
  return (await response.json()) as EspnScoreboard
}

const tokenElement = (token: LineToken): JSX.Element =>
  // The solid renderer maps the style prop to renderable setters (style.fg
  // becomes TextNodeRenderable.fg); span props do not expose fg directly.
  token.color ? <span style={{ fg: token.color }}>{token.text}</span> : <span>{token.text}</span>

const gameLineElement = (line: GameLineView): JSX.Element => (
  <text attributes={line.dim ? TextAttributes.DIM : TextAttributes.NONE}>
    {line.tokens.map(tokenElement)}
  </text>
)

const POLL_INTERVAL_MS = 10_000
// Off-day next-game walk: days tried past the schedule day before giving up.
const NEXT_GAME_WALK_DAYS = 5

// The schedule day (US Eastern) as YYYY-MM-DD; the endpoint's date parameter
// walks in US Eastern days.
const scheduleDayOf = (now: Date): string =>
  new Intl.DateTimeFormat("en-CA", { timeZone: "America/New_York" }).format(now)

// yyyymmdd of `day` plus `offset` calendar days, anchored at UTC noon.
const ymdOf = (day: string, offset: number): string => {
  const date = new Date(`${day}T12:00:00Z`)
  date.setUTCDate(date.getUTCDate() + offset)
  return date.toISOString().slice(0, 10).replaceAll("-", "")
}

// Walks the endpoint's date parameter forward one day at a time (bounded by
// `days`) and returns the earliest event found; undefined when the cap is hit.
const findNextGame = async (
  fetchLike: NbaFetch,
  fromDay: string,
  days: number,
): Promise<EspnEvent | undefined> => {
  for (let offset = 1; offset <= days; offset++) {
    const response = await fetchScoreboard(fetchLike, `${ESPN_URL}?dates=${ymdOf(fromDay, offset)}`)
    const events = [...(response.events ?? [])]
    if (events.length > 0) return events.sort((a, b) => Date.parse(a.date) - Date.parse(b.date))[0]
  }
  return undefined
}

export type ScoreboardStatus = "connecting" | "live" | "reconnecting"

export type ScoreboardState = {
  readonly status: ScoreboardStatus
  // The last good view model; absent until the first successful refresh.
  readonly view?: ScoreboardView
}

// Owns the panel's live state: fetch on start, then every poll tick. A failed
// refresh keeps the last good view and reports reconnecting; before the first
// success the state stays connecting. stop() releases the interval and stops
// all further requests.
export const createScoreboardPoller = (deps: NbaDeps) => {
  const [state, setState] = createSignal<ScoreboardState>({ status: "connecting" })
  let stopped = false
  // Next-game lookup per schedule day, so an empty day does not re-walk
  // future dates on every poll tick.
  let nextGameCache: { readonly day: string; readonly event?: EspnEvent } | undefined

  // One refresh at a time: a tick landing mid-refresh is skipped, so a slow
  // older response can never overwrite a newer view.
  let refreshInFlight = false

  const refresh = async () => {
    if (refreshInFlight) return
    refreshInFlight = true
    try {
      const today = await fetchScoreboard(deps.fetch)
      if (stopped) return
      const now = deps.now()
      let nextEvent: EspnEvent | undefined
      if ((today.events ?? []).length === 0) {
        const day = today.day?.date ?? scheduleDayOf(now)
        if (nextGameCache?.day !== day) {
          nextGameCache = { day, event: await findNextGame(deps.fetch, day, NEXT_GAME_WALK_DAYS) }
        }
        if (stopped) return
        nextEvent = nextGameCache.event
      }
      setState({ status: "live", view: toScoreboardView(today, now, nextEvent) })
    } catch {
      // Keep the last good view; before the first success stay connecting.
      if (!stopped)
        setState((previous) => (previous.view ? { status: "reconnecting", view: previous.view } : previous))
    } finally {
      refreshInFlight = false
    }
  }

  const timer = deps.setInterval(() => void refresh(), POLL_INTERVAL_MS)
  void refresh()
  const stop = () => {
    stopped = true
    deps.clearInterval(timer)
  }
  return { state, stop }
}

type ScoreboardPoller = ReturnType<typeof createScoreboardPoller>

const ScoreboardPanel = (props: { readonly poller: ScoreboardPoller }): JSX.Element => {
  // Panel dispose (close or slot unregistration) stops polling. The plugin
  // cleanup function stops the same poller too: a host may tear the plugin
  // down without disposing the rendered panel.
  onCleanup(() => props.poller.stop())
  const view = () => props.poller.state().view
  return (
    <box>
      <text>{view()?.header ?? "NBA Scoreboard · Connecting…"}</text>
      {props.poller.state().status === "reconnecting" && <text>Reconnecting…</text>}
      {view()?.message !== undefined && (
        <text attributes={TextAttributes.DIM}>{view()?.message}</text>
      )}
      {view()?.nextGame !== undefined && gameLineElement(view()?.nextGame!)}
      <For each={view()?.lines ?? []}>{gameLineElement}</For>
    </box>
  )
}

export const createNbaPlugin = (deps: NbaDeps) =>
  Plugin.define({
    id: "nba-scoreboard",
    setup(ctx) {
      let poller: ScoreboardPoller | undefined
      const unregister = ctx.ui.slot({
        append: "session.panel",
        // The render call mounts the panel: polling starts there.
        render: (input) => {
          if (input.name !== PANEL_NAME) return null
          poller = createScoreboardPoller(deps)
          return <ScoreboardPanel poller={poller} />
        },
      })
      ctx.keymap.layer(() => ({
        mode: "global",
        commands: [
          {
            id: "nba.scoreboard.toggle",
            description: "Toggle the NBA scoreboard panel",
            bind: false,
            slash: { name: "nba" },
            // The command run callback has no context parameter: close over ctx.
            run: () => {
              if (ctx.ui.panel.current()?.name === PANEL_NAME) {
                ctx.ui.panel.close()
                return
              }
              if (!ctx.ui.panel.open(PANEL_NAME)) {
                ctx.ui.toast.show({
                  message: "The NBA scoreboard panel needs an open session.",
                  variant: "info",
                })
              }
            },
          },
        ],
      }))
      return () => {
        // Second stop path: the host may tear the plugin down without
        // disposing the rendered panel.
        poller?.stop()
        unregister()
      }
    },
  })

export default createNbaPlugin({
  fetch: (url) => globalThis.fetch(url),
  now: () => new Date(),
  setInterval,
  clearInterval,
})
