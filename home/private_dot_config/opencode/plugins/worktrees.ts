import type { Plugin } from "@opencode-ai/plugin"

type Action = "allow" | "ask" | "deny"

/**
 * Allow tool access to every git worktree of the current project.
 *
 * Worktrees of a bare repo live in sibling directories, so opencode treats
 * them as external and asks for permission. Resolve them at startup and
 * append allow rules, which win because the last matching rule applies.
 */
export const WorktreeAccess: Plugin = async ({ $, directory, worktree }) => {
  const root = worktree || directory
  const listed = await $`git worktree list --porcelain`.cwd(root).quiet().nothrow()
  if (listed.exitCode !== 0) return {}

  const paths: string[] = []
  for (const line of listed.text().split("\n")) {
    if (line.startsWith("worktree ")) paths.push(line.slice("worktree ".length).trim())
    // a bare entry is the repo directory itself and holds no checkout
    else if (line === "bare") paths.pop()
  }
  if (paths.length === 0) return {}

  return {
    config: (config) => {
      if (typeof config.permission === "string") config.permission = { "*": config.permission }
      config.permission ??= {}

      const current = config.permission.external_directory
      const rules: Record<string, Action> =
        typeof current === "object" ? current : { "*": (current as Action) ?? "ask" }

      for (const path of paths) {
        // match both the globstar form and the single-star glob the
        // external_directory check builds from a file's parent directory
        rules[`${path}/**`] = "allow"
        rules[`${path}/*`] = "allow"
      }

      config.permission.external_directory = rules
    },
  }
}
