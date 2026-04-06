# Validating AI Code Changes

**CRITICAL: After completing ALL tasks, you MUST validate your changes:**

1. Create a visible team agent for the build: - `TeamCreate(team_name: "build-fixer")` - `Agent(team_name: "build-fixer", name: "builder", subagent_type: "tami-buildFixer",
prompt: "Follow your agent definition exactly.")` - Tell the user: **"Press Shift+Down to watch the build agent"**
2. If the build fails, fix the errors the agent identifies and re-spawn until build passes
3. Never consider a task complete until the build agent reports BUILD PASSED
4. Shut down the team when done

**git-build.sh flags:**

- `--local` or `-l`: Run local build (default)

Example: `./scripts/git-build.sh --local`

Build check validates: TypeScript compilation, linting, formatting, tests.
