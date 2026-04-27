# K–12 Dashboard Architect Memory Bank

This folder contains durable project context for Cline/OpenCode/Claude Code-style coding assistants.

Recommended workflow:

1. Place the `memory-bank/` folder at the root of the `dashboard-layout-architect` project.
2. Keep these files short enough for the coding assistant to read reliably.
3. Update `activeContext.md` and `progress.md` after each work session.
4. Treat `projectbrief.md`, `productContext.md`, `systemPatterns.md`, and `techContext.md` as durable context.
5. Do not store private student data, credentials, production database connection strings, or internal secrets here.

Suggested Cline prompt to start a session:

```text
Read the memory-bank files first. Then inspect the project files that are not ignored. Do not modify files until you summarize your plan and list the files you intend to edit.
```
