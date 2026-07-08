# GCPS Theme Studio — Progress

> This progress log combines the K–12 Dashboard Architect era (Phases 0–5)
> with the GCPS Theme Studio era (Parts A–D). Earlier planning phases are
> preserved as historical context; recent implementation work follows.

---

## Earlier era — K–12 Dashboard Architect (Phases 0–5)

### Completed

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

### In Progress

- None.

### Not Started (K–12 dashboard scope)

- Promise Schools template.
- Assessment Performance template.
- Adding accessibility review mode.
- Adding disclosure review mode.
- Adding Quarto export.
- Adding tests.

### Suggested Phase Plan

#### Phase 0 — Inventory Only
Goal: Let the coding assistant inspect the current app without editing.
Deliverable: Architecture summary, function map, proposed extraction order.

#### Phase 1 — Registries Only
Goal: Add durable K–12 registries without refactoring the existing app.
Files: `R/theme_registry.R`, `R/metric_registry.R`, `R/demo_data_k12.R`

#### Phase 2 — Template Registry
Goal: Add `R/template_registry.R` with BOE Area Snapshot only.

#### Phase 3 — Component Registry
Goal: Add component registry and placeholder render functions.

#### Phase 4 — UI Wiring
Goal: Add template/theme/audience controls to the sidebar with minimal disruption.

#### Phase 5 — BOE Preview Renderer
Goal: Render a polished BOE Area Snapshot using fake data.

#### Phase 6 — Export Scaffold
Goal: Export a runnable Shiny scaffold for the selected BOE template.

### Known Risks

- Cline may choke if asked to modify too many files.
- The monolithic `app.R` may contain tightly coupled functions.
- Existing export logic may be fragile.
- CSS generation may rely on parameter order.
- Preview behavior may be tied to current config shape.
- Adding new dependencies may complicate deployment.

---

## Recent era — GCPS Theme Studio (Parts A–D)

### Completed

#### Part A — Embed the client-side Theme Studio (✅ green)
- Vendored `www/palette-data.js`, `www/theme-studio.js`, `www/theme-studio-app.js`
- Re-scoped all CSS under `.ts-root` in `www/theme-studio.css` (zero global bleed)
- One body reference in `theme-studio-app.js` retargeted to `.ts-root`
- Added the Shiny bridge: `render()` emits `input$ts_theme` on every studio change
- Mounted the studio in the existing `theme_studio_tab` nav_panel via
  `www/_theme_studio_markup.html` (markup → data → engine → app load order)
- `theme-studio.css` linked from the app head
- `www/fonts/README.md` documents the five self-hosted woff2 families

#### Part B — Downloadable project templates (✅ green)
- Added `zip` to the requireNamespace block + `source("R/generate_templates.R")`
- `R/generate_templates.R`: `gcps_resolve_theme()` (null-safe default), six
  builders + `theme_gcps.R` / SCSS / `_brand.yml` / CSS-vars export,
  `gcps_write_template_zip()`, `gcps_template_all()`, `gcps_write_all_zip()`
- `templates_tab` nav_panel (six cards + Download-all) inserted after the studio
- Seven `downloadHandler`s wired (one per kind + combined) driven by
  `input$ts_theme`; `ts_theme_summary` badge echoes the active theme
- Acceptance test passes: every bundle's files exist, accent hex + font label
  are baked in, `GCPS-theme.json` parses with `dataColors == palette_hex`,
  zip round-trips match the tree, the all-zip has six subfolders + README

#### Part C — Studio is the single source of truth (✅ green)
- `gcps_config_theme_from_studio(ts)` maps the studio list into the
  `build_config()` shape (theme/typography/palette)
- `build_config()` now pulls theme/typography/palette from
  `gcps_config_theme_from_studio(input$ts_theme)`; canvas/header/sidebar/
  content/annotations stay on the Architect sidebar
- Removed the old sidebar colour/font/palette inputs; kept
  `annotations_enabled` under a "Preview Options" section
- `gcps_resolve_theme()` returns the GCPS default on first paint so Preview
  and exports render before the studio JS emits
- Generators (`generate_css/html/shiny_code/dax/json_theme`) untouched; they
  receive the same config shape from a single source

#### Part D — Power BI `.pbip` project scaffold (✅ green)
- `gcps_template_pbip(t)` emits the PBIR-enhanced project tree (10 files):
  `GCPS-Report.pbip`, `*.Report/definition.{pbir,report.json,pages/…,
  StaticResources/.../GCPS-theme.json}`, `*.SemanticModel/definition.{pbism,
  database.tmdl}`, `.gitignore`, `README.md`
- Theme JSON under `StaticResources` is byte-identical to the B2 builder
  (single source); `report.json` references it via the correct relative path
- `download_tmpl_pbip` handler + a 7th card added to the Project Templates
  grid; registered in `gcps_template_all()` / `gcps_write_all_zip()` as the
  `powerbi-pbip/` subfolder
- Acceptance test passes: all 10 paths present, pointers parse, theme JSON
  parses and equals B2, zip round-trips (10 entries), all-zip has 7 subfolders
  incl. `powerbi-pbip`
- README documents the two required Desktop preview features + recovery steps

### Files changed (this session)
- `www/palette-data.js`, `www/theme-studio.js`, `www/theme-studio-app.js`,
  `www/theme-studio.css`, `www/_theme_studio_markup.html`, `www/fonts/README.md`
- `R/generate_templates.R` (new)
- `app.R` (studio mount, templates tab + handlers, Part C rewiring)
---

## GCPS Theme Studio — Parts A/B/C (2026-06-25)

### Part A — Quarto / flexdashboard code-view tabs (✅ complete)

#### A1 — Generator functions (app.R)
- `generate_quarto_dashboard(config)`: Quarto `format: dashboard`, cosmo + theme.scss, valueBox rows, ggplot chart grid, inline SCSS note
- `generate_quarto_html(config)`: Quarto `format: html`, page-layout: full, bslib `layout_columns` + `value_box` KPIs, `card()` charts, SCSS note
- `generate_flexdashboard(config)`: `.Rmd` YAML, `output: flexdashboard::flex_dashboard`, bslib theme via YAML, `valueBox()` KPIs, By-Column charts

#### A2 — nav_panels (app.R, ~line 2337)
Three nav_panels inserted after `shiny_tab`, before `powerbi_tab`:
- `Quarto Dashboard` / `quarto_dash_tab`
- `Quarto HTML` / `quarto_html_tab`
- `flexdashboard` / `flex_tab`
CSS `.code-output` block updated with `#quarto_dash_output`, `#quarto_html_output`, `#flex_output`

#### A3 — Server wiring (app.R)
- `output$quarto_dash_output`, `output$quarto_html_output`, `output$flex_output` — renderText
- `output$download_quarto_dash` (.qmd), `output$download_quarto_html` (.qmd), `output$download_flex` (.Rmd) — downloadHandlers
- `copy_quarto_dash`, `copy_quarto_html`, `copy_flex` — observeEvents → `copy_to_clipboard`

### Part B — 4 new palette families (✅ complete)

Added to `gcps_base`, `gcps_ramps`, `gcps_diverging` in `app.R` and `FAMILY_NAMES`/`FAMILY_LABELS` in `R/gcps_palettes.R`:
- `gold` (#C49A22) — warm highlight, award & recognition; diverges toward teal
- `plum` (#7B2D8B) — deep contrast, adult literacy & workforce; diverges toward green
- `slate` (#4A6D8C) — steel-blue, operations & infrastructure; diverges toward orange
- `emerald` (#1A7D5A) — deep green, sustainability & wellness; diverges toward maroon

`length(gcps_base) == length(gcps_ramps) == 11`

### Part C — Accent panel moved to Palette tab (✅ complete)

- Accent `.panel` div (containing `#accentRow`) moved from `#tab-surfaces` to be the first panel inside `#tab-palette` in `www/_theme_studio_markup.html`
- `id="accentRow"` preserved; JS still resolves by ID

### git diff --stat
 R/gcps_palettes.R             |  12 +-
 app.R                         | 440 +++++++++++++++++++++++++++++++++++++++++-
 www/_theme_studio_markup.html |  10 +-
 3 files changed, 452 insertions(+), 10 deletions(-)
---

## New — Canvas layout → Power BI, and Deneb chart exports (Claude Code, design-handoff session)

Two new, additive exports requested directly (no upstream Cline prompt for
these — spec came from user chat). No existing generator, tab, or the
`.pbip` theme scaffold was modified in place; everything below is new code
alongside it.

### 1. Canvas layout → Power BI `.pbip` "Layout" page

A true binary `.pbix`/`.pbit` can't be hand-built outside Power BI Desktop or
the Fabric/XMLA APIs (it embeds a compiled Analysis Services data model).
Extended the existing `.pbip`/PBIR scaffold instead — the only format where
real visual containers can be placed at real coordinates without a compiled
model.

- `R/generate_templates.R`:
  - `gcps_layout_rects(config)` — new pure function. Takes the *Architect's*
    `build_config()` output (not the Studio theme `t`) and returns one rect
    per header/sidebar/KPI-card/grid-cell, mirroring the exact pixel math in
    `build_header_html()`/`build_sidebar_html()`/`build_kpi_html()`/
    `build_grid_html()`/`build_grid_html_bycol()` (same helpers:
    `parse_proportions`, `calc_pixels`, `parse_row_proportions`,
    `get_containers_per_row/col`) — covers all four layout modes (uniform,
    byrow, bycol, freeform). Verified against `DEFAULT_CONFIG` in a Node port
    of the same math: all rects positive-size and within canvas bounds.
  - `gcps_pbir_textbox_visual(...)` — emits one PBIR `visual.json` per rect
    as a Power BI native "textbox" visual (position + one text run only —
    fill/border "objects" styling deliberately omitted to minimize the risk
    of Desktop rejecting an unfamiliar nested property; positions are exact
    regardless).
  - `gcps_template_pbip(t, config = NULL)` — signature extended
    (backward-compatible default). When `config` is supplied, adds a second
    page ("Layout", opens by default via `pages.json` `activePageName`) with
    one textbox per rect. `Page1` (blank, themed) is untouched and still
    included. README gets an appended "Layout page" section when `config` is
    passed.
- `app.R`: new "Power BI Layout (.pbip)" card in the Project Templates grid
  (8th card, after the existing "Power BI .pbip Project" card) +
  `output$download_tmpl_pbip_layout`, calling
  `gcps_template_pbip(t, build_config())`. The existing `download_tmpl_pbip`,
  `download_tmpl_all`, and `gcps_template_all()`/`gcps_write_all_zip()` are
  untouched — this is a new, separate button.

**Caveat documented in the generated README (and worth repeating here):**
the PBIR visual-container schema is Microsoft's, evolves with Desktop
versions, and isn't fully public. Positions (x/y/width/height) are the part
of the schema that's stable and well-understood, and are exact. If Desktop
rejects or silently normalizes the textbox `visual.objects` block on first
open, that's expected — same caveat the existing `.pbip` README already
carries for the overall format; re-saving from Desktop normalizes it.

### 2. Deneb chart exports (bar + line)

New "starter code" tabs following the exact Quarto/flexdashboard pattern
(nav_panel + `renderText` output + `downloadButton` + `actionButton` copy),
inserted after "flexdashboard" and before "Power BI HTML":

- `generate_deneb_bar(config)` / `generate_deneb_line(config)` in `app.R`
  (next to `generate_flexdashboard`) — each emits a Vega-Lite v5 spec via
  `jsonlite::toJSON`, themed from the same `config` every other exporter
  reads (`config$theme$bg_card/text_primary/text_secondary/border`,
  `config$typography$font_family`, `config$palette$base` for the data color).
  Ships with the tool's existing deterministic sample rows embedded as
  `data.values` (bar: `demo_schools` school/proficiency; line:
  `demo_trend_years`/`demo_trend_pcts` from `R/demo_data_k12.R`, reused
  as-is, not duplicated) so pasting the spec into Deneb's spec editor renders
  immediately. A `usermeta.instructions` field (valid JSON, not a comment)
  explains that mapping real columns in the Deneb visual's Fields pane
  (named to match the sample fields: `school`/`proficiency` or `year`/`pct`)
  makes Deneb use the live data instead.
- Tabs: `deneb_bar_tab` (title "Deneb Bar"), `deneb_line_tab` (title "Deneb
  Line") — `download_deneb_bar`/`download_deneb_line` (.json),
  `copy_deneb_bar`/`copy_deneb_line`. `.code-output` CSS selector list
  extended with `#deneb_bar_output`/`#deneb_line_output` to match the
  existing per-tab styling convention.

### Not done / explicitly out of scope this round
- The "Download all" template zip and `gcps_template_all()` still only
  produce the theme-only `.pbip` (no Layout page) — left untouched by
  choice to avoid touching a shared, already-tested code path for a
  single-button addition.
- No stub semantic model / real Card-and-chart visuals on the Layout page —
  per your call, this round ships text-box placeholders only.
- Color palette / categorical-palette refinement (flagged by you as a
  separate, later task) not touched.

### Verification
No R runtime available in this environment. Verified via:
- Brace/paren/bracket balance check on both edited files (identical to the
  pre-edit baseline plus my additions, no net imbalance introduced).
- A Node.js port of `gcps_layout_rects()`'s exact math, run against the real
  `DEFAULT_CONFIG` (1600×900 canvas, 4 KPIs, uniform 2×2 grid) — all 10
  rects (header, sidebar, 4 KPIs, 4 grid cells) land at positive size, fully
  within canvas bounds, matching the same coordinates the CSS/HTML preview
  already renders at.
- Grep-verified every new identifier (nav_panel `value`, `output$...`,
  `input$copy_...`, CSS `#...`) appears exactly once, in the expected spot.
- **Not yet verified**: actually opening the generated `.pbip` in Power BI
  Desktop, or pasting a Deneb spec into a live Deneb visual. Recommend doing
  both before relying on this in production — flag back here if either
  needs a fix.

---

## New — Palette re-key to "Prompt" design tokens + Milestones gradient + Race/School categoricals (Claude Code, design-handoff session)

Applied an external design handoff (`Analytics_Template_Generator_2.zip`,
`design_handoff_palette_milestones/`) that replaces the 7/11-base analytics
palette with a re-keyed, 7-token "Prompt" set and adds new palette
capabilities. User confirmed (via explicit question) to adopt the re-key
everywhere rather than layer the new features onto the old key names.

### Base palette re-key
`gcps_base` renamed/recolored from
`{maroon, blue, teal, green, violet, orange, neutral, gold, plum, slate, emerald}`
(11 keys) to `{maroon, ocean, forest, sienna, amethyst, goldenrod, slate}`
(7 keys):
- `maroon #660000` (unchanged · district anchor)
- `ocean #2D708E` (cool primary)
- `forest #297864` (growth / positive)
- `sienna #C0593C` (warm attention)
- `amethyst #715981` (categorical)
- `goldenrod #D19C2F` (warm highlight)
- `slate #5B6D7A` (structure / neutral)

`gold`, `plum`, and `emerald` are dropped as named bases; `blue`/`teal`/
`green`/`violet`/`orange`/`neutral` are replaced by the new keys above.
Default base changed from `teal` to `ocean` throughout (`DEFAULT_CONFIG`,
`DEFAULT_GCPS_FAMILY`, studio first-paint state).

### Files touched
- `app.R` — `gcps_base`, `gcps_ramps`, `gcps_diverging`, `DEFAULT_CONFIG$palette`
  re-keyed. Ramps/diverging values recomputed (not hand-picked) from the OKLCH
  engine's own formulas — `gcps_ramps` via the 5-stop sequential formula that
  anchors position 4 (700) to the exact base hex (matches
  `R/gcps_palette_library.R`'s `gcps_sequential()`), `gcps_diverging` via the
  generic 5-stop diverging function paired per the new `DIVERGE_PAIR` map.
  Verified against the reference R module's own `ACCEPTANCE` hex values before
  applying (exact match).
- `R/gcps_palettes.R` — `FAMILY_NAMES`, `FAMILY_LABELS`, `DEFAULT_GCPS_FAMILY`
  re-keyed to match.
- `R/gcps_palette_data.R`, `R/gcps_palette_library.R` — replaced with the
  handoff's `shiny-R/` versions (re-keyed `GCPS_BASE`/`DIVERGE_PAIR`, new
  `GCPS_NEUTRALS`, `CAT_RACE_*`/`CAT_SCHOOL_*`, `MILESTONE_ANCHORS` +
  `gcps_perf_gradient()`, `gcps_build_palette()` gains `perf_stops` +
  `gradient` variant + `race`/`school` categorical schemes). These files are
  not currently `source()`-d by `app.R` — kept in sync as the documented R
  reference spec, per the handoff's intent.
- `R/generate_templates.R` — `gcps_default_theme()` fallback (source label +
  `pal_hex`) updated from the old teal ramp to the ocean ramp so it still
  matches the studio's first-paint state.
- `palette-library/palette-data.js`, `palette-library/theme-studio.js`,
  `www/palette-data.js`, `www/theme-studio.js`, `GCPS Theme Studio.html` —
  replaced with the handoff's `src/` versions verbatim. Verified first that
  the currently-committed versions of these three were a clean subset of the
  handoff's versions (no functions/markup lost), so a verbatim swap was safe.
- `palette-library/theme-studio-app.js` / `www/theme-studio-app.js` —
  **NOT** replaced verbatim. The handoff's `src/theme-studio-app.js` (323
  lines) turned out to be forked from a much older point in this repo's
  history than what's actually committed (969 lines) — it's missing the
  Microsoft Fabric App export, the DAX/Quarto/Shiny/flexdashboard code
  generators, and the interactive Theme Preview, all shipped in later
  commits. Overwriting would have deleted all of that. Instead, applied only
  the scoped delta the handoff's own README describes: `baseKey`/default
  rekeyed to `ocean`, `perfStops` state, `DIVERGE_PAIR_` rekeyed,
  `catMax()` capped via `T.catFixedMax()`, a `gradient` branch in
  `currentPalette()`, `semLabel()` Low/High for the gradient ends, and the
  Stops button wiring/visibility toggle (mirrors the `perfVariant`/
  `perfLevels` pattern already in the file). Also fixed one incidental bug
  this surfaced: `fabricThemeFromState()`'s `success`/`warning` colors read
  `GCPS_BASE.green`/`GCPS_BASE.gold`, which no longer exist post-rekey
  (silently fell back to hardcoded hex via `||`) — repointed to
  `GCPS_BASE.forest`/`GCPS_BASE.goldenrod`.
- `www/_theme_studio_markup.html` — the Shiny app's embedded studio-tab
  fragment (separate from the root `GCPS Theme Studio.html`, read via
  `readLines()` in `app.R`) had its own, separate copy of the Performance
  sub-controls markup and was still missing the gradient button/Stops
  segmented control. Patched identically to the root HTML's controls.
- `www/explorer.css` — `--gcps-<family>-<stop>` custom properties re-keyed to
  the new 7 families (this file was already stale — missing `gold`/`plum`/
  `slate`/`emerald` — before this change; not previously kept in sync
  rigorously despite its "source of truth" header comment).

### New palette capabilities (from the handoff, additive)
- **Milestones gradient** — Warm-to-Cool (Burnt Sienna → Goldenrod → Forest
  Green) ordered, unlabeled 3/5/7-stop ramp for binning performance data,
  alongside the existing Semantic/Source-tinted performance variants.
- **Race/Ethnicity** and **School Level** fixed-identity categorical
  palettes (count stepper capped to their fixed length).
- `LENS_BINARY` (ML/FRL/Gifted/SWD focus-vs-comparison pairs) present in data
  but not yet surfaced in the UI (per the handoff).

### Not done / out of scope this round
- `palette-library/gcps-theme-studio.html` — the ~1MB pre-bundled single-file
  artifact GitHub Pages actually deploys (see `.github/workflows/pages.yml`,
  which uploads `palette-library/` as-is, no build step). It's a packaged
  bundle (`<script type="__bundler/...">` payload), not hand-editable source,
  and wasn't regenerated — the live Pages site will keep showing the old
  palette until that bundle is rebuilt from the updated `src/`-equivalent
  files above.
- No refactor of `app.R` to `source()` `R/gcps_palette_data.R` /
  `R/gcps_palette_library.R` instead of keeping its own inline
  `gcps_base`/`gcps_ramps`/`gcps_diverging` — out of scope for this change.

### Verification
No R runtime available in this environment. Verified via:
- A Node harness loading the handoff's actual `theme-studio.js`/
  `palette-data.js` and calling its real functions (not reimplementing the
  math) to compute `gcps_ramps`/`gcps_diverging` for the new 7 keys, and to
  regenerate the 5-stop sequential formula, checked against the R module's
  own `ACCEPTANCE` comment values for known inputs (`#007C91`, `#660000`) —
  exact match.
- `perfGradient(3)` verified against the handoff's stated expected output
  (`#C0593C #D19C2F #297864`) — exact match.
- Grep-swept the whole repo for the old key names (`blue|teal|green|violet|
  orange|neutral|gold|plum|slate|emerald`) after the edits; every remaining
  hit is either the new `slate` key, a generic English word ("neutral
  center", surface-theme option, Tailwind tone name), or an untouched
  historical changelog entry.
- Separately grepped for direct property access (`GCPS_BASE.x` / `GCPS_BASE
  [["x"]]` / `gcps_base[[x]]`) across every `.js`/`.R` file to catch dead
  references the word-sweep would miss if the key were used as a bare
  identifier — this is what caught the `fabricThemeFromState()` bug above.
- `node --check` on every touched `.js` file; brace/paren/bracket counts on
  every touched `.R` file compared to their pre-edit counts (no R runtime
  available in this environment).
