# mt-skills

Custom agent skills by Minh Tran. All skills are prefixed with `mt:` (Minh Tran).

## Skills

| Skill | Description |
|-------|-------------|
| [mt:commit-push-pr](./skills/mt:commit-push-pr/) | Commit, push, and open a PR in one shot |
| [mt:grapple-jira-planner](./skills/mt:grapple-jira-planner/) | Scan Grapple Jira tasks and write implementation plans to Obsidian |

## Install

### Install to specific agents

```bash
# Claude Code
npx skills add voxuanthuan/skills -a claude-code

# OpenCode
npx skills add voxuanthuan/skills -a opencode

# Antigravity
npx skills add voxuanthuan/skills -a antigravity
```

### Install to all three agents at once

```bash
npx skills add voxuanthuan/skills -a claude-code -a opencode -a antigravity
```

### Install globally (available across all projects)

```bash
npx skills add voxuanthuan/skills -g -a claude-code -a opencode -a antigravity
```

### Install a single skill

```bash
npx skills add voxuanthuan/skills --skill "mt:commit-push-pr" -a claude-code -a opencode -a antigravity
```

```bash
npx skills add voxuanthuan/skills --skill "mt:grapple-jira-planner" -a claude-code -a opencode -a antigravity
```

## Compatibility

| Agent | Project Path | Global Path | Supported |
|-------|-------------|-------------|-----------|
| Claude Code | `.claude/skills/` | `~/.claude/skills/` | Yes |
| OpenCode | `.agents/skills/` | `~/.config/opencode/skills/` | Yes |
| Antigravity | `.agents/skills/` | `~/.gemini/antigravity/skills/` | Yes |

All skills follow the [Agent Skills specification](https://agentskills.io) and are compatible with any agent that supports the standard `SKILL.md` format.

## Creating New Skills

Use the scaffold script to create a new skill:

```bash
./scripts/create-skill.sh mt:my-new-skill
```

This generates a `skills/mt:my-new-skill/SKILL.md` with the required frontmatter and structure.

Browse all skills at [skills.sh](https://skills.sh).
