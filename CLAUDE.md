# CLAUDE.md — test-task

This is a standalone TypeScript project for a coding challenge.

## Project Structure

```
test-task/
├── src/
│   └── cache.ts          # Main task file — implement the Cache class
├── scripts/
│   └── git-build.sh      # Build validation (tsc + eslint + prettier + jest)
├── .claude/
│   ├── settings.json      # Claude Code configuration
│   ├── agents/            # Build fixer agent
│   ├── hooks/             # Auto-format, ts-check, notifications
│   └── rules/             # Behavioral rules
├── package.json
├── tsconfig.json
├── .eslintrc.json
├── .prettierrc
└── jest.config.js
```

## Build & Validation

Run the build script to validate all checks pass:

```bash
./scripts/git-build.sh --local
```

This runs:

1. TypeScript type-checking (`tsc --noEmit`)
2. ESLint linting
3. Prettier format check
4. Jest tests

## Rules

- **[git-workflow.md](.claude/rules/git-workflow.md)** — NEVER run git add/commit
- **[no-try-catch.md](.claude/rules/no-try-catch.md)** — No try-catch blocks
- **[line-width.md](.claude/rules/line-width.md)** — 100 char line width
- **[validate-changes.md](.claude/rules/validate-changes.md)** — Must run build after changes
- **[team-agent-rules.md](.claude/rules/team-agent-rules.md)** — Team agent behavior
- **[instruction-reminders.md](.claude/rules/instruction-reminders.md)** — Do what's asked, nothing more

## Development

```bash
npm install          # Install dependencies
npm run build        # TypeScript check
npm run lint         # ESLint
npm run format       # Prettier format
npm run test         # Jest tests
```
