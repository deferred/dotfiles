import type { Plugin } from "@opencode-ai/plugin"

export const TmuxSession: Plugin = async ({ $ }) => {
  const pane = process.env.TMUX_PANE
  if (!pane) return {}

  return {
    event: async ({ event }) => {
      if (event.type !== "session.created" && event.type !== "session.updated") return
      const session = event.properties.info
      if (session.parentID) return

      await $`tmux set-option -p -t ${pane} @opencode-session-id ${session.id}`.quiet().nothrow()
    },
  }
}
