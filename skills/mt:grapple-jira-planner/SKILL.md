---
name: mt:grapple-jira-planner
description: "(Minh Tran) Scan assigned Grapple Jira issues in In Progress or Selected for Development, analyze business/wiki and code context across Grapple repos, then write implementation plans into Obsidian."
argument-hint: "[optional JQL override or issue keys]"
allowed-tools: [Bash, Read, Write, Edit, Glob, Grep, WebFetch, WebSearch, TodoWrite, AskUserQuestion]
---

# mt:grapple-jira-planner

Scan the user's active Grapple Jira work, research the relevant wiki/business and code context, and create one Obsidian implementation plan per Jira issue.

**Arguments:** `$ARGUMENTS`

## When to Use

Use this skill when the user asks to:

- scan their Jira tasks in `In Progress` or `Selected for Development`
- plan Grapple tasks before implementation
- create/update Obsidian task planning notes for Grapple work
- analyze Grapple Jira issues against business/wiki docs and these codebases:
  - `grapple-core-app` — frontend admin side
  - `grapple-website` — landing page
  - `grapple-core-api` — backend

## Steps

### 1. Prepare workspace and access

1. Create a todo list for this planning run.
2. Verify these expected local paths exist before using them:
   - Obsidian output directory: `/home/thuan/osidian/grapple/tasks`
   - Repositories, wherever they are cloned locally:
     - `grapple-core-app`
     - `grapple-website`
     - `grapple-core-api`
3. If the user said a path should exist but it does not, stop and tell the user exactly what was expected and what was found. Do not silently recreate or substitute that path.
4. Use available Jira/Wiki access in this order:
   - configured Jira/Confluence MCP tools, if present
   - authenticated browser session
   - environment variables or secrets:
     - `JIRA_BASE_URL`
     - `JIRA_EMAIL`
     - `JIRA_API_TOKEN`
     - `WIKI_BASE_URL` or `CONFLUENCE_BASE_URL`
5. If Jira or wiki access is missing, ask the user for access. Offer a temporary session secret and a permanent saved secret option.

### 2. Scan Jira issues

If `$ARGUMENTS` contains issue keys, plan only those issues.

If `$ARGUMENTS` contains a JQL query, use it.

Otherwise use this JQL:

```jql
assignee = currentUser()
AND status in ("In Progress", "In-progress", "Selected for Development")
ORDER BY priority DESC, updated DESC
```

For each issue, fetch at minimum:

- issue key, summary, status, priority, type, labels, components, fix versions
- description
- acceptance criteria
- comments that clarify scope
- linked issues and blockers
- attachments or designs if referenced
- sprint/epic/parent information

Skip Done/Closed/Cancelled issues unless they were explicitly passed in `$ARGUMENTS`.

### 3. Classify affected Grapple surfaces

For each Jira issue, decide which codebases are likely affected:

- `grapple-core-app`: admin UI, dashboard, internal tools, forms, tables, user/admin workflows
- `grapple-website`: public landing pages, marketing pages, SEO, public content
- `grapple-core-api`: backend APIs, database, services, jobs, auth, integrations, business logic

Use Jira components/labels first, then infer from description, acceptance criteria, routes, API names, domain terms, and linked issues.

If ambiguous, inspect all three repos and record the ambiguity in the plan.

### 4. Research business/wiki context

For each issue:

1. Search the wiki/business docs for:
   - issue key
   - epic/parent key
   - feature names from the summary
   - important nouns from the description and acceptance criteria
   - related API/entity names
2. Read the most relevant pages.
3. Extract:
   - business goal
   - user roles/personas
   - workflow rules
   - constraints and edge cases
   - definitions of domain terms
4. Cite source page titles/URLs or local file paths in the Obsidian note.

If wiki context is unavailable, still create the plan from Jira and code context, but add a `Missing context` section explaining what could not be read.

### 5. Research code context

For each affected repo:

1. Read the README/setup docs only as needed to understand structure.
2. Search narrowly using the issue key, feature names, routes, components, API endpoint names, model/entity names, and domain terms.
3. Inspect likely implementation files, neighboring tests, route definitions, API clients, schemas, models, migrations, services, and UI components.
4. Record concrete file references using repo-relative paths and line numbers when available.
5. Do not implement code during this skill. The deliverable is a plan.

Recommended focus by repo:

- `grapple-core-app`
  - routes/pages
  - React components
  - hooks/state management
  - API client calls
  - form validation
  - admin permissions
  - existing tests/stories
- `grapple-website`
  - page routes
  - landing sections/components
  - content/data files
  - SEO metadata
  - tracking/analytics
  - responsive styling
- `grapple-core-api`
  - routes/controllers
  - services/use cases
  - serializers/DTOs
  - models/entities
  - database migrations
  - permissions/auth
  - background jobs
  - API tests

### 6. Write Obsidian task plans

Create one Markdown file per Jira issue in:

```text
/home/thuan/osidian/grapple/tasks
```

Use this filename format:

```text
<ISSUE-KEY> - <slugified-summary>.md
```

If the file already exists, update generated sections carefully and preserve any manual notes under sections named:

- `## Personal notes`
- `## Decisions`
- `## Work log`

Each note must use this structure:

```markdown
---
jira_key: ISSUE-KEY
status: In Progress
priority: High
type: Story
repos:
  - grapple-core-app
  - grapple-core-api
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# ISSUE-KEY — Summary

## Jira
- Status:
- Priority:
- Type:
- Link:
- Epic/Parent:
- Labels:
- Components:

## Goal
Short business/user goal in plain language.

## Description summary
Concise summary of the Jira description and acceptance criteria.

## Business/wiki context
- Important business rules and constraints.
- Source: wiki page title or URL

## Affected surfaces
- `grapple-core-app`: why it is affected
- `grapple-website`: why it is affected, or `Not expected`
- `grapple-core-api`: why it is affected

## Code context
### grapple-core-app
- `path/to/file.tsx:10-40` — why it matters

### grapple-website
- Not expected / relevant files

### grapple-core-api
- `path/to/file.ts:20-80` — why it matters

## Implementation plan
1. Step-by-step implementation sequence.
2. Include exact repos and likely files.
3. Include data/API contract changes before UI steps.
4. Include migration/backfill steps if needed.

## Test plan
- Unit tests:
- Integration/API tests:
- Frontend tests:
- Manual QA:
- Regression risks:

## Questions / blockers
- Open questions for product/design/backend/frontend.

## Checklist
- [ ] Confirm requirements and edge cases
- [ ] Implement backend changes if needed
- [ ] Implement frontend/admin changes if needed
- [ ] Implement landing page changes if needed
- [ ] Add/update tests
- [ ] Run lint/typecheck/tests
- [ ] Create PR(s)

## Personal notes

## Decisions

## Work log
```

### 7. Maintain an index

Create or update:

```text
/home/thuan/osidian/grapple/tasks/_index.md
```

Include a table:

```markdown
# Grapple Jira task plans

| Jira | Status | Priority | Repos | Plan |
| ---- | ------ | -------- | ----- | ---- |
| GRAP-123 | In Progress | High | api, app | [[GRAP-123 - summary]] |
```

### 8. Completion report

When finished, tell the user:

- how many Jira issues were scanned
- how many Obsidian plans were created/updated
- the exact output directory
- any missing Jira/wiki/repo context
- open questions or blockers
