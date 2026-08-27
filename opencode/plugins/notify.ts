// opencode native notify plugin: tmux window-state notifications
// - session.idle (main session only)    -> notify-stop.sh    (@claude_state "done" + BEL)
// - permission.asked                    -> notify-waiting.sh (@claude_state "waiting" + BEL)
// - tool.execute.before (question tool) -> notify-waiting.sh (question UI does not emit permission.asked)
// Scripts skip on their own when not in tmux or the window is already active.
import type { Plugin } from "@opencode-ai/plugin"

// opencode loads plugins with its bundled bun runtime where `process` exists,
// but the local SDK types ship without node types - declare the minimal shape.
declare const process: { env: Record<string, string | undefined> }

export const NotifyPlugin: Plugin = async ({ client, $ }) => {
  const script = (name: string) => `${process.env.HOME}/.config/opencode/scripts/${name}`
  const notifyWaiting = async () => {
    await $`${script("notify-waiting.sh")}`
  }

  return {
    event: async ({ event }) => {
      // Cast to string: the binary emits "permission.asked" but the installed
      // SDK type union lags behind (verified against opencode 1.18.22 at runtime).
      const type = event.type as string

      if (type === "permission.asked") {
        await notifyWaiting()
        return
      }
      if (type !== "session.idle") return

      // session.idle payload shape varies across opencode versions - probe known keys
      const props = (event.properties ?? {}) as Record<string, unknown>
      const sessionID =
        (props.sessionID as string | undefined) ??
        (props.session as { id?: string } | undefined)?.id ??
        (props.info as { id?: string } | undefined)?.id
      if (!sessionID) return

      // Background agent sessions are parented; only notify for the main session
      const result = await client.session.get({ path: { id: sessionID } })
      if (result.data?.parentID) return

      await $`${script("notify-stop.sh")}`
    },
    "tool.execute.before": async (input) => {
      // Question-type tools render an interactive prompt without a permission dialog
      if (input.tool === "question") await notifyWaiting()
    },
  }
}
