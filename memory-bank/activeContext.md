# Active Context

## Current Focus

Evolve Dashboard Layout Architect into a K–12 Dashboard Architect.

The immediate goal is to make the project easier for a coding assistant to work with by adding a memory bank, reducing prompt size, and breaking future work into small phases.

## Current Problem

A large Cline prompt failed with:

```text
Invalid API Response: The provider returned an empty or unparsable response.
```

Likely cause:

- The prompt asked for too much in one pass.
- The project is large and monolithic.
- Cline/tool-calling context likely overloaded.
- The provider/model may have returned invalid or empty output.

## Current Recovery Strategy

Use small phased prompts.

Do not ask Cline to "build the next version" in one task.

Recommended next tasks:

1. Inventory only; no edits.
2. Create registry files only.
3. Add BOE Area Snapshot template only.
4. Wire one template selector only.
5. Build one preview renderer only.
6. Export one Shiny scaffold only.

## Current Priority

Build durable context files in `memory-bank/`, then ask Cline to inspect the project and produce an inventory without editing.

## Next Cline Prompt

```text
Read the memory-bank files first. Then inspect the project files that are not ignored.

Do not modify files yet.

Your task is only to produce a concise inventory of the current app structure.

Focus on:
1. Where DEFAULT_CONFIG is defined
2. Where build_config() is defined
3. Where CSS is generated
4. Where preview HTML is generated
5. Where Shiny code export is generated
6. Which functions should be extracted first

Return:
- a short architecture summary
- a proposed 5-step refactor plan
- the first 3 files you recommend creating

Do not write code yet.
```

## Working Assumptions

- The project root contains `app.R`.
- The current app works or mostly works before refactor.
- `_app_archive/` should be ignored unless explicitly needed.
- The first serious template should be BOE Area Snapshot.
- Promise Schools and Assessment Performance should come after the BOE template pattern works.
- Existing export behavior should be preserved during early refactor phases.
- Avoid drag-and-drop for now.
