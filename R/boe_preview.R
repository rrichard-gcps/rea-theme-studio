# BOE Area Snapshot Preview Renderer
# K-12 Dashboard Architect
# Assembles a complete BOE Area Snapshot dashboard using component render functions
# and deterministic fake data. Returns a standalone HTML document.

# ── Data Map ──────────────────────────────────────────────────────────────
# Maps template section data_key to the corresponding demo data object

get_boe_demo_data <- function(data_key) {
  if (is.null(data_key) || length(data_key) == 0) {
    return(NULL)
  }
  switch(
    data_key[1],
    boe_area = demo_boe_area,
    kpi_values = demo_kpi_values,
    trend_years = demo_trend_years,
    student_groups = demo_student_groups,
    schools = demo_schools,
    NULL
  )
}

# ── Section Renderer ─────────────────────────────────────────────────────
# Renders a single template section by looking up the component registry

render_boe_section <- function(section, theme = NULL) {
  comp_id <- section$component
  comp <- component_registry[[comp_id]]

  if (is.null(comp)) {
    return(sprintf(
      '<div style="background:#FFF3CD;border:1px solid #FFC107;border-radius:8px;padding:16px;font-size:12px;color:#856404;">Unknown component: %s</div>',
      comp_id
    ))
  }

  # Get data for this section
  # Priority: section data_key, then component registry data_keys
  if (
    !is.null(section$data_key) &&
      length(section$data_key) > 0 &&
      nzchar(section$data_key[1])
  ) {
    data <- get_boe_demo_data(section$data_key)
  } else if (length(comp$data_keys) > 0) {
    # Use the first data_key from the component registry
    data <- get_boe_demo_data(comp$data_keys[1])
  } else {
    data <- NULL
  }

  # Merge default options with template overrides
  opts <- comp$default_options
  if (!is.null(section$options)) {
    opts <- modifyList(opts, section$options)
  }

  # Call the render function
  render_fn <- get(comp$render_fn)
  render_fn(data, opts, theme)
}

# ── Full BOE Preview ─────────────────────────────────────────────────────
# Assembles all sections into a complete HTML dashboard

render_boe_preview <- function(
  template_id = "boe_area_snapshot",
  theme_id = "gcps_default"
) {
  template <- template_registry[[template_id]]
  if (is.null(template)) {
    return("<p>Template not found.</p>")
  }

  theme <- theme_registry[[theme_id]]

  # Render all sections
  sections_html <- paste(
    sapply(template$sections, function(sec) {
      render_boe_section(sec, theme)
    }),
    collapse = "\n"
  )

  # Wrap in dashboard shell with Lexend font and GCPS page background
  sprintf(
    '<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>%s</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: "Lexend", "Segoe UI", system-ui, sans-serif;
    background: %s;
    color: %s;
  }
  .boe-dashboard {
    max-width: 1100px;
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    gap: 12px;
    padding: 0;
  }
  .boe-two-col {
    display: flex;
    gap: 12px;
  }
  .boe-two-col > div { flex: 1; }
  .boe-three-col {
    display: flex;
    gap: 12px;
  }
  .boe-three-col > div { flex: 1; }
</style>
</head>
<body>
<div class="boe-dashboard">
%s
</div>
</body>
</html>',
    template$name,
    if (!is.null(theme)) theme$colors$page_bg else "#F6F7F9",
    if (!is.null(theme)) theme$colors$text else "#1F2933",
    sections_html
  )
}
