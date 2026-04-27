# Active Context

## Current Focus

Evolve Dashboard Layout Architect into a K–12 Dashboard Architect.

Phases 0 and 1 are complete. The project now has three registry files in `R/` alongside the monolithic `app.R`.

## Completed Phases

- **Phase 0**: Architecture inventory of `app.R` (2,159 lines). Identified all function locations, config structure, and extraction priorities.
- **Phase 1**: Created `R/theme_registry.R` (4 themes), `R/metric_registry.R` (10 metrics), `R/demo_data_k12.R` (5 deterministic datasets). All verified via `Rscript` sourcing. No changes to `app.R`.

## Current Priority

**Phase 2**: Create `R/template_registry.R` with the BOE Area Snapshot template only. Do not modify existing app behavior.

## Next Cline Prompt

```text
Implement Phase 2 only.

Create R/template_registry.R with one template:
BOE Area Snapshot.

Do not modify preview rendering yet.
Do not add Promise Schools or Assessment templates yet.
Do not refactor the existing app.

After editing, summarize the template structure and how it will connect to the current app in the next step.
```

## Working Assumptions

- The project root contains `app.R`.
- The current app works or mostly works before refactor.
- `_app_archive/` should be ignored unless explicitly needed.
- The first serious template should be BOE Area Snapshot.
- Promise Schools and Assessment Performance should come after the BOE template pattern works.
- Existing export behavior should be preserved during early refactor phases.
- Avoid drag-and-drop for now.
