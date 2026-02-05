---
description: Git commit
agent: build
model: anthropic/claude-sonnet-4-5
---

Create a git commit following the Conventional Commits specification.

## Arguments

- `$1` (optional): Scope of the commit (e.g., `auth`, `api`, `ui`, `config`)

## Scope Handling

**IMPORTANT:** Check if `$1` is provided:
- If `$1` has a value (e.g., `/commit api`): use scope → `type(api): description`
- If `$1` is empty or not provided (e.g., `/commit`): **DO NOT include scope** → `type: description`

**Never invent or guess a scope. Only use scope if explicitly passed as `$1`.**

## Instructions

1. Stage all changes:
   ```bash
   git add --all
   ```

2. Analyze the staged changes:
   ```bash
   git status
   git diff --cached
   ```

3. Generate a commit message following the format below

4. Create the commit using `git commit -m "message"` (or with body if needed)

## Commit Message Format

```
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```

### Structure Rules

- **Type**: Required, lowercase
- **Scope**: ONLY if `$1` argument was provided. If `$1` is empty, omit scope entirely (no parentheses)
- **Breaking change indicator**: Use `!` before `:` for ANY breaking change
- **Description**: Short summary, imperative mood, no period, max 72 chars
- **Body**: Only for complex changes, separated by blank line
- **Footer**: For references, co-authors, etc.

## Commit Types

| Type | When to Use | Example |
|------|-------------|---------|
| `feat` | New feature or capability | `feat(auth): add OAuth2 login` |
| `fix` | Bug fix | `fix(api): handle null response` |
| `docs` | Documentation only | `docs: update README` |
| `style` | Formatting, whitespace, no code change | `style: fix indentation` |
| `refactor` | Code restructuring, no feature/fix | `refactor(db): extract query builder` |
| `perf` | Performance improvement | `perf: cache database queries` |
| `test` | Adding or updating tests | `test(auth): add login tests` |
| `build` | Build system, dependencies | `build: upgrade to node 20` |
| `ci` | CI/CD configuration | `ci: add github actions workflow` |
| `chore` | Maintenance, tooling | `chore: update gitignore` |
| `revert` | Reverting previous commit | `revert: undo feature X` |

### Type Selection Guide

- Adding new functionality users can use? → `feat`
- Fixing something that was broken? → `fix`
- Changing code structure without changing behavior? → `refactor`
- Making something faster? → `perf`
- Only changing comments, README, or docs? → `docs`
- Only fixing formatting/whitespace? → `style`
- Adding/fixing tests? → `test`
- Changing build config, dependencies? → `build`
- Changing CI/CD pipelines? → `ci`
- Everything else (cleanup, tooling)? → `chore`

## Breaking Changes

**ALWAYS mark breaking changes with `!` before the colon.**

A change is breaking when it:
- Removes or renames public API, function, class, or method
- Changes function signature (parameters, return type)
- Changes default behavior that users rely on
- Removes or renames configuration options
- Changes file format or data structure
- Requires users to update their code or config

### Breaking Change Format

```
<type>(scope)!: <description>

BREAKING CHANGE: <explanation of what breaks and how to migrate>
```

### Examples

```
feat(api)!: change authentication response format

BREAKING CHANGE: auth endpoint now returns {token, expiresAt} instead of {accessToken, expiry}
```

```
refactor(config)!: rename environment variables

BREAKING CHANGE: ENV_API_KEY renamed to API_KEY, ENV_DEBUG renamed to DEBUG
```

## Body Guidelines

**IMPORTANT: Most commits do NOT need a body. Keep commits simple.**

**Include body ONLY when the commit is genuinely complex:**

- Changes span multiple files with non-obvious connections
- The "why" behind the change isn't clear from the description
- There are important implementation details to note
- Migration steps or side effects need documentation

**Do NOT include body for (this is the majority of commits):**
- Simple, self-explanatory changes
- Single-file changes with clear intent
- Routine updates (dependency bumps, typo fixes)
- Adding/removing/modifying a single feature or fix
- Config changes

**When in doubt, skip the body. A clear description is usually enough.**

### Body Format

- Separate from description with a blank line
- Wrap at 72 characters
- Explain what and why, not how
- Use bullet points for multiple items

## Footer Tokens

| Token | Usage |
|-------|-------|
| `BREAKING CHANGE` | Describe what breaks (required with `!`) |
| `Closes` | Close issues: `Closes #123` |
| `Fixes` | Fix issues: `Fixes #456` |
| `Refs` | Reference: `Refs #789, #012` |
| `Co-authored-by` | Credit co-authors |
| `Reviewed-by` | Credit reviewers |

## Complete Examples

### Simple feature (no scope argument)
```
feat: add dark mode toggle
```

### Feature with scope (`/commit ui`)
```
feat(ui): add dark mode toggle
```

### Bug fix with scope (`/commit auth`)
```
fix(auth): prevent token expiration race condition
```

### Complex change with body
```
refactor(database): migrate from callbacks to async/await

Convert all database operations to use async/await pattern
for better readability and error handling:

- Update connection pool management
- Refactor transaction handling
- Simplify error propagation

Refs #234
```

### Breaking change
```
feat(api)!: require authentication for all endpoints

BREAKING CHANGE: all API endpoints now require a valid JWT token
in the Authorization header. Public endpoints have been moved to /public/*

Closes #567
```

### Revert
```
revert: feat(ui): add dark mode toggle

This reverts commit abc123def456.
Feature caused rendering issues on Safari.
```

## Execution

After analyzing changes and determining the appropriate message:

1. If simple commit (no body needed):
   ```bash
   git commit -m "type(scope): description"
   ```

2. If complex commit (with body):
   ```bash
   git commit -m "type(scope): description" -m "body paragraph" -m "footer"
   ```

   Or use heredoc for multi-line:
   ```bash
   git commit -m "$(cat <<'EOF'
   type(scope): description

   Body explaining the complex changes.

   Footer-token: value
   EOF
   )"
   ```

Remember: Be concise but descriptive. The commit message should tell future developers what changed and why.
