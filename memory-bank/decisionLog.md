# Decision Log

## Decision 001 — K–12 First

The next version should be K–12-specific, not a generic business dashboard clone.

Reason: The actual work context is education analytics. Reusable templates should reflect real K–12 reporting patterns. The medical/business dashboard was only a visual reference.

## Decision 002 — Template-Driven Architecture

The app should move from generic layout boxes toward dashboard templates and component slots.

Reason: Repeatable K–12 products need repeatable design patterns. Templates reduce manual layout tuning. Templates make exports more consistent.

## Decision 003 — Registries Before Refactor

Create theme, metric, template, component, and demo-data registries before deep refactoring.

Reason: Registries provide structure without breaking the app. Cline can handle small file creation better than whole-app rewrites. The current app can keep working during incremental migration.

## Decision 004 — No Drag-and-Drop Yet

Do not add drag-and-drop in the next version.

Reason: It would add complexity before the product model is stable. Template selection and component-aware preview are higher value right now.

## Decision 005 — Deterministic Fake Data

Use deterministic synthetic K–12 data only.

Reason: Preview should be stable. Random values cause unnecessary reactivity churn. Synthetic data avoids privacy and disclosure concerns.

## Decision 006 — BOE Area Snapshot First

Build BOE Area Snapshot before Promise Schools and Assessment templates.

Reason: It contains the core dashboard shell: header, tabs, filters, KPIs, map, school table, trend, student group comparison, detail table, and footer. Later templates can reuse this structure.

## Decision 007 — Absolute Preview, CSS Grid Export

Keep absolute positioning for the architect canvas preview, but prefer CSS Grid for generated Shiny/Quarto output.

Reason: Absolute positioning supports design-canvas precision. CSS Grid is more maintainable in exported apps.
