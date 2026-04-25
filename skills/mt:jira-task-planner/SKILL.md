---
name: mt:jira-task-planner
description: "(Minh Tran) Scan assigned Jira issues, analyze business/wiki and code context, then write implementation plans into a user-configured notes directory."
argument-hint: "[optional JQL override or issue keys]"
allowed-tools: [Bash, Read, Write, Edit, Glob, Grep, WebFetch, WebSearch, TodoWrite, AskUserQuestion]
---

# mt:jira-task-planner

Scan the user's active Jira work, research relevant business/wiki and code context, and create one implementation plan note per Jira issue.

**Arguments:** `$ARGUMENTS`

## When to Use

Use this skill when the user asks to:

- scan their Jira tasks in `In Progress` or `Selected for Development`
- plan Jira tasks before implementation
- create or update task planning notes in Obsidian or another Markdown notes folder
- analyze Jira issues against business/wiki docs and one or more related codebases

## Steps

### 1. Prepare workspace and access

1. Create a todo list for this planning run.
2. Resolve the notes output directory in this order:
   - `$TASK_PLANNER_OUTPUT_DIR`
   - `$OBSIDIAN_TASKS_DIR`
   - a path explicitly passed in `$ARGUMENTS`
   - a path explicitly provided by the user in the current request
3. Resolve related code repositories in this order:
   - `$TASK_PLANNER_REPOS`, a colon-separated or newline-separated list of absolute repo paths
   - `$PROJECT_REPOS`, a colon-separated or newline-separated list of absolute repo paths
   - the current working directory if it is inside a git repository
   - sibling git repositories under the parent directory of the current repo when the Jira issue clearly references them
4. Resolve optional project metadata from:
   - `$TASK_PLANNER_PROJECT_NAME`
   - `$TASK_PLANNER_WIKI_HINTS`, comma-separated wiki spaces, page names, or URLs
   - `$TASK_PLANNER_DEFAULT_JQL`
5. Verify every resolved path exists before using it.
6. If the user said a path should exist but it does not, stop and tell the user exactly what was expected and what was found. Do not silently recreate or substitute that path.
7. Use available Jira/Wiki access in this order:
   - configured Jira/Confluence MCP tools, if present
   - authenticated browser session
   - environment variables or secrets:
     - `JIRA_BASE_URL`
     - `JIRA_EMAIL`
     - `JIRA_API_TOKEN`
     - `WIKI_BASE_URL` or `CONFLUENCE_BASE_URL`
8. If Jira or wiki access is missing, ask the user for access. Offer a temporary session secret and a permanent saved secret option.

Recommended environment variables:

```bash
export TASK_PLANNER_OUTPUT_DIR="/absolute/path/to/notes/tasks"
export TASK_PLANNER_REPOS="/absolute/path/to/repo-one:/absolute/path/to/repo-two"
export TASK_PLANNER_PROJECT_NAME="Project name"
export TASK_PLANNER_WIKI_HINTS="Confluence space, product wiki URL, domain docs"
export TASK_PLANNER_DEFAULT_JQL='assignee = currentUser() AND status in ("In Progress", "Selected for Development") ORDER BY priority DESC, updated DESC'
```

### 2. Scan Jira issues

If `$ARGUMENTS` contains issue keys, plan only those issues.

If `$ARGUMENTS` contains a JQL query, use it.

Otherwise use `$TASK_PLANNER_DEFAULT_JQL` if set.

If no JQL is configured, use this default:

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

### 3. Classify affected repositories and surfaces

For each Jira issue, decide which resolved repositories and application surfaces are likely affected.

Use repo names, README files, package metadata, directory structure, Jira components, labels, and issue text to infer the role of each repository. Common roles include:

- frontend application
- public website or documentation site
- backend API or service
- worker or job processor
- shared package or library
- infrastructure/configuration
- mobile app
- data pipeline

Use Jira components/labels first, then infer from description, acceptance criteria, routes, API names, domain terms, and linked issues.

If ambiguous, inspect all configured repos and record the ambiguity in the plan.

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

Recommended focus by surface:

- Frontend application
  - routes/pages
  - components
  - hooks/state management
  - API client calls
  - form validation
  - permissions
  - existing tests/stories
- Public website or documentation site
  - page routes
  - content/data files
  - metadata/SEO
  - analytics/tracking
  - responsive styling
- Backend API or service
  - routes/controllers
  - services/use cases
  - serializers/DTOs
  - models/entities
  - database migrations
  - permissions/auth
  - background jobs
  - API tests
- Shared library
  - exported interfaces
  - consumers
  - package build/test setup
  - versioning or release notes
- Infrastructure/configuration
  - environment variables
  - deployment manifests
  - CI/CD workflows
  - observability and alerts

### 6. Write task plan notes

Create one Markdown file per Jira issue in the resolved notes output directory.

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
  - repo-name
project: Project name
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
- `repo-name`: surface/role and why it is affected
- `other-repo`: Not expected, or why it may be affected

## Code context
### repo-name
- `path/to/file.tsx:10-40` — why it matters

### other-repo
- Not expected / relevant files

## Implementation plan
1. Step-by-step implementation sequence.
2. Include exact repos and likely files where possible.
3. Include data/API contract changes before dependent UI/client steps.
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
- [ ] Implement service/backend changes if needed
- [ ] Implement frontend/client changes if needed
- [ ] Implement content/site changes if needed
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
<resolved-notes-output-directory>/_index.md
```

Include a table:

```markdown
# Jira task plans

| Jira | Status | Priority | Repos | Plan |
| ---- | ------ | -------- | ----- | ---- |
| PROJ-123 | In Progress | High | api, app | [[PROJ-123 - summary]] |
```

### 8. Completion report

When finished, tell the user:

- how many Jira issues were scanned
- how many Markdown plans were created/updated
- the exact output directory
- which repositories were used for code context
- any missing Jira/wiki/repo/path context
- open questions or blockers
