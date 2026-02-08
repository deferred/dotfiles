---
name: skill-creator
description: Helps create new OpenCode skills following the Anthropic Agent Skills Specification v1.0. Provides templates, validation guidance, and best practices for skill development.
license: MIT
compatibility: opencode
metadata:
  category: development
  audience: skill-authors
---

# Skill Creator

I help you create new OpenCode skills that follow the official Anthropic Agent Skills Specification.

## What I Do

- Guide you through the skill creation process
- Provide templates and examples
- Validate skill names and descriptions
- Explain directory structure and discovery
- Help with permissions and configuration

## When to Use Me

Use this skill when:
- Creating a new skill for your project or team
- Converting existing documentation into a skill
- Understanding skill validation rules
- Troubleshooting skill loading issues

## Quick Start Template

```bash
mkdir -p .opencode/skills/your-skill-name
```

Create `.opencode/skills/your-skill-name/SKILL.md`:

```markdown
---
name: your-skill-name
description: A clear, specific description of what this skill does (20+ characters recommended)
license: MIT
compatibility: opencode
metadata:
  category: category-name
  audience: target-users
---

# Your Skill Name

## What I Do

- List specific capabilities
- Be concrete about actions
- Include expected outcomes

## When to Use Me

Describe the scenarios where this skill is appropriate. Include any prerequisites or context needed.

## Instructions

1. Step-by-step workflow
2. Reference supporting files like `scripts/helper.py`
3. Include validation or verification steps

## Examples

Provide concrete examples of inputs and expected outputs.
```

## Validation Rules

### Name Requirements
- Must match directory name exactly
- 1-64 characters
- Lowercase alphanumeric with single hyphens only
- Cannot start/end with hyphen
- Cannot contain consecutive hyphens
- Regex: `^[a-z0-9]+(-[a-z0-9]+)*$`

**Good names:** `git-release`, `api-testing`, `code-review`
**Bad names:** `GitRelease`, `api_testing`, `code--review`, `-release`

### Description Requirements
- 1-1024 characters
- Be specific enough for agents to choose correctly
- Include what the skill does and when to use it
- Minimum 20 characters recommended for discoverability

**Good description:** "Create consistent GitHub releases with changelogs, version bumps, and release notes from merged PRs"
**Bad description:** "Makes releases" (too vague)

## Directory Structure

```
.opencode/skills/<skill-name>/
├── SKILL.md              # Required: Main skill definition with frontmatter
├── scripts/              # Optional: Helper scripts, executables
│   ├── setup.sh
│   └── validate.py
├── references/           # Optional: Documentation, guides, examples
│   ├── api-reference.md
│   └── examples.md
└── assets/               # Optional: Templates, configs, other files
    └── template.json
```

## Discovery Locations

OpenCode searches these paths (in order of priority):

1. **Project-local** (walks up to git root):
   - `.opencode/skills/<name>/SKILL.md`
   - `.claude/skills/<name>/SKILL.md`

2. **Global**:
   - `~/.config/opencode/skills/<name>/SKILL.md`
   - `~/.claude/skills/<name>/SKILL.md`

## Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill identifier, must match directory |
| `description` | Yes | What the skill does (1-1024 chars) |
| `license` | No | License identifier (e.g., MIT, Apache-2.0) |
| `compatibility` | No | Target platform (e.g., opencode, claude) |
| `metadata` | No | Key-value pairs for categorization |

## Permissions Configuration

Control skill access in `opencode.json`:

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "skill-creator": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

- `allow`: Skill loads immediately
- `deny`: Skill hidden from agent
- `ask`: User prompted before loading

### Per-Agent Overrides

**Custom agents** (in agent frontmatter):
```yaml
---
permission:
  skill:
    "skill-creator": "allow"
---
```

**Built-in agents** (in `opencode.json`):
```json
{
  "agent": {
    "plan": {
      "permission": {
        "skill": {
          "skill-creator": "allow"
        }
      }
    }
  }
}
```

## Complete Example: Git Release Skill

```markdown
---
name: git-release
description: Create consistent GitHub releases with changelogs, version bumps, and release notes from merged PRs
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  workflow: github
---

## What I Do

- Draft release notes from merged PRs since last tag
- Propose semantic version bump (major/minor/patch)
- Generate copy-pasteable `gh release create` command
- Verify release checklist completion

## When to Use Me

Use this when preparing a tagged release. I work best when:
- You have conventional commit messages
- PRs are properly labeled
- You have push access to the repository

Ask clarifying questions if the target versioning scheme is unclear.

## Instructions

1. Fetch merged PRs since last release tag
2. Categorize changes by type (feat, fix, breaking)
3. Draft release notes in markdown
4. Suggest version bump based on changes
5. Provide release command with proper arguments

## Checklist

- [ ] Review all merged PRs
- [ ] Verify version bump appropriateness
- [ ] Check release notes accuracy
- [ ] Confirm target commit/branch
```

## Troubleshooting

### Skill Not Showing Up

1. **Verify filename**: Must be `SKILL.md` (all caps)
2. **Check frontmatter**: Must include `name` and `description`
3. **Validate name**: Must match directory name exactly
4. **Check permissions**: Skills with `deny` are hidden
5. **Restart OpenCode**: Skills are discovered at startup

### Common Errors

- **"Name must match directory"**: Ensure `name` in frontmatter matches the folder name
- **"Description too short"**: Add more detail (aim for 50+ characters)
- **"Invalid name format"**: Use only lowercase letters, numbers, and single hyphens

## Best Practices

1. **Be specific in descriptions** - Help agents choose the right skill
2. **Include clear instructions** - Step-by-step workflows work best
3. **Add examples** - Show inputs and expected outputs
4. **Use supporting files** - Keep SKILL.md clean, put details in `references/`
5. **Test your skill** - Try it after creation to ensure it loads
6. **Version your skills** - Consider adding version metadata
7. **Document prerequisites** - List what users need before using the skill

## Advanced: Supporting Files

Reference files relative to the skill directory:

```markdown
See [API Reference](references/api-reference.md) for details.

Run the setup script:
\`\`\`bash
bash scripts/setup.sh
\`\`\`
```

## Next Steps

After creating your skill:

1. Save the SKILL.md file
2. Add any supporting files to `scripts/`, `references/`, or `assets/`
3. Restart OpenCode to discover the skill
4. Test by invoking: `skills_your-skill-name`
5. Iterate based on usage feedback

## Resources

- Anthropic Agent Skills Specification v1.0
- OpenCode Documentation: https://opencode.ai/docs/skills
- Example Skills: https://github.com/malhashemi/opencode-skills