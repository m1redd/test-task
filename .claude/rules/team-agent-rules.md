# Team Agent Rules

- **NEVER** launch team agents in the background (`run_in_background: true`). Always run in foreground.
- **Do NOT** use `isolation: "worktree"` when spawning team agents unless the user explicitly requests it.
- When planning, **ALWAYS ask the user** if they want to use team agents before launching them.
  Never autonomously decide to create a team — the user must opt in.
