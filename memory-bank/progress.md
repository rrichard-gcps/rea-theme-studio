# Progress

## Completed

- Identified the current app as a monolithic R/Shiny app.
- Decided to pivot from generic layout generation toward a K–12 dashboard pattern generator.
- Identified the medical/business dashboard example as visual inspiration only, not the target content model.
- Defined initial K–12 template priorities:
  1. BOE Area Snapshot
  2. Promise Schools Overview
  3. Assessment Performance Snapshot
- Defined initial registry concepts:
  - theme registry
  - metric registry
  - template registry
  - component registry
  - deterministic demo data
- Added or planned `.clineignore` to reduce context overload.
- Created this memory-bank structure.
- **Phase 0 complete**: Produced architecture inventory of `app.R`.
- **Phase 1 complete**: Created `R/theme_registry.R` (4 themes), `R/metric_registry.R` (10 metrics), `R/demo_data_k12.R` (5 deterministic datasets). All verified with `Rscript` sourcing.
- **Phase 2 complete**: Created `R/template_registry.R` with BOE Area Snapshot template (8 sections, 6 KPI metrics, layout defaults, audience/context metadata). Verified with `Rscript` sourcing.
- **Phase 3 complete**: Created `R/component_registry.R` with 12 component entries and 12 placeholder render functions. All verified with `Rscript` sourcing and HTML output testing.
- **Phase 4/5 complete**: Created `R/boe_preview.R` with template-driven renderer. Added "BOE Snapshot" tab to `app.R` with theme/template selectors and zoom controls. All 8 BOE sections render deterministically. Existing app behavior preserved.

## In Progress

- None.

## Not Started

- Promise Schools template.
- Assessment Performance template.
- Adding accessibility review mode.
- Adding disclosure review mode.
- Adding Quarto export.
- Adding tests.
- Building BOE Area Snapshot preview.
- Adding accessibility review mode.
- Adding disclosure review mode.
- Adding Quarto export.
- Adding tests.

## Suggested Phase Plan

### Phase 0 — Inventory Only

Goal: Let the coding assistant inspect the current app without editing.

Deliverable: Architecture summary, function map, proposed extraction order.

### Phase 1 — Registries Only

Goal: Add durable K–12 registries without refactoring the existing app.

Files:

- `R/theme_registry.R`
- `R/metric_registry.R`
- `R/demo_data_k12.R`

### Phase 2 — Template Registry

Goal: Add `R/template_registry.R` with BOE Area Snapshot only.

### Phase 3 — Component Registry

Goal: Add component registry and placeholder render functions.

### Phase 4 — UI Wiring

Goal: Add template/theme/audience controls to the sidebar with minimal disruption.

### Phase 5 — BOE Preview Renderer

Goal: Render a polished BOE Area Snapshot using fake data.

### Phase 6 — Export Scaffold

Goal: Export a runnable Shiny scaffold for the selected BOE template.

## Known Risks

- Cline may choke if asked to modify too many files.
- The monolithic `app.R` may contain tightly coupled functions.
- Existing export logic may be fragile.
- CSS generation may rely on parameter order.
- Preview behavior may be tied to current config shape.
- Adding new dependencies may complicate deployment.

## Current Best Practice

Use one small prompt per phase.
