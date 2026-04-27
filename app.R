# Dashboard Layout Architect
# A Shiny app for designing Power BI and Quarto dashboard layouts

# Load required packages
suppressPackageStartupMessages({
  if (!requireNamespace("shiny", quietly = TRUE)) {
    install.packages("shiny")
  }
  if (!requireNamespace("bslib", quietly = TRUE)) {
    install.packages("bslib")
  }
  if (!requireNamespace("shinyjs", quietly = TRUE)) {
    install.packages("shinyjs")
  }
  if (!requireNamespace("colourpicker", quietly = TRUE)) {
    install.packages("colourpicker")
  }
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    install.packages("jsonlite")
  }
  if (!requireNamespace("htmltools", quietly = TRUE)) {
    install.packages("htmltools")
  }
  if (!requireNamespace("stringr", quietly = TRUE)) {
    install.packages("stringr")
  }

  library(shiny)
  library(bslib)
  library(shinyjs)
  library(colourpicker)
  library(jsonlite)
  library(htmltools)
  library(stringr)
})

# Default Configuration
DEFAULT_CONFIG <- list(
  canvas = list(width = 1600, height = 900),
  theme = list(
    bg_page = "#F8F9FA",
    bg_card = "#FFFFFF",
    border = "#E5E7EB",
    text_primary = "#1F2937",
    text_secondary = "#6B7280",
    accent = "#0097A7",
    radius = "8px",
    radius_lg = "12px"
  ),
  header = list(
    height = 80,
    padding = 20,
    logo_width = 180,
    logo_height = 50,
    nav_button_count = 4
  ),
  sidebar = list(
    width = 260,
    padding = 16,
    nav_item_count = 5
  ),
  content = list(
    kpi_height = 100,
    kpi_count = 4,
    kpi_gap = 20,
    grid_rows = 2,
    grid_cols = 2,
    grid_gap = 16,
    padding = 20,
    layout_type = "uniform",
    # By Row settings
    containers_per_row = "2, 2",
    row_proportions = NULL,
    col_widths_per_row = NULL,
    # By Column settings
    containers_per_col = "2, 2",
    col_widths = NULL,
    row_heights_per_col = NULL,
    # Freeform settings
    ff_rows = 3,
    ff_cols = 3,
    ff_row_heights = NULL,
    ff_col_widths = NULL,
    # KPI settings
    kpi_proportions = NULL
  ),
  annotations = list(enabled = FALSE)
)

# GCPS Color System
gcps_base <- c(
  maroon = "#660000",
  blue = "#2F5FB3",
  teal = "#007C91",
  green = "#5E8C31",
  violet = "#6A4CC3",
  orange = "#D96A1D",
  neutral = "#7A828C"
)

gcps_ramps <- list(
  maroon = c("#DDC7C7", "#BA8C8C", "#944C4C", "#660000", "#540000"),
  blue = c("#D1DCEE", "#A1B7DD", "#6D8FCA", "#2F5FB3", "#274E93"),
  teal = c("#C7E2E7", "#8CC4CE", "#4CA3B2", "#007C91", "#006677"),
  green = c("#DCE6D2", "#B7CBA2", "#8EAE6F", "#5E8C31", "#4D7328"),
  violet = c("#DED8F2", "#BCAEE4", "#9782D5", "#6A4CC3", "#573EA0"),
  orange = c("#F7DECD", "#EEBC99", "#E49761", "#D96A1D", "#B25718"),
  neutral = c("#F4F5F7", "#E3E6EA", "#B6BCC4", "#7A828C", "#4B525A")
)

gcps_diverging <- list(
  maroon = c("#540000", "#944C4C", "#F3F4F6", "#4CA3B2", "#006677"),
  blue = c("#274E93", "#6D8FCA", "#F3F4F6", "#E49761", "#B25718"),
  teal = c("#006677", "#4CA3B2", "#F3F4F6", "#BA8C8C", "#540000"),
  green = c("#4D7328", "#8EAE6F", "#F3F4F6", "#BCAEE4", "#573EA0"),
  violet = c("#573EA0", "#9782D5", "#F3F4F6", "#8EAE6F", "#4D7328"),
  orange = c("#B25718", "#E49761", "#F3F4F6", "#6D8FCA", "#274E93")
)

font_families <- c(
  "Segoe UI" = "'Segoe UI', system-ui, sans-serif",
  "Arial" = "Arial, Helvetica, sans-serif",
  "Trebuchet MS" = "'Trebuchet MS', sans-serif",
  "Verdana" = "Verdana, Geneva, sans-serif",
  "Georgia" = "Georgia, serif",
  "Consolas" = "Consolas, 'Courier New', monospace"
)

font_weights <- c(
  "Light (300)" = "300",
  "Regular (400)" = "400",
  "Medium (500)" = "500",
  "Semi-Bold (600)" = "600",
  "Bold (700)" = "700"
)

# Helper Functions
get_text_color <- function(hex) {
  rgb <- grDevices::col2rgb(hex)
  luminance <- (0.299 * rgb[1, ] + 0.587 * rgb[2, ] + 0.114 * rgb[3, ]) / 255
  ifelse(luminance > 0.62, "#1F2328", "#FFFFFF")
}

generate_swatch_html <- function(colors, labels) {
  swatches <- mapply(
    function(col, lab) {
      fg <- get_text_color(col)
      sprintf(
        '<div style="flex:1;min-width:70px;background:%s;color:%s;border-radius:6px;padding:8px;text-align:center;box-shadow:inset 0 0 0 1px rgba(0,0,0,.1);"><div style="font-weight:600;font-size:10px;">%s</div><div style="font-family:monospace;font-size:9px;opacity:0.9;">%s</div></div>',
        col,
        fg,
        lab,
        col
      )
    },
    colors,
    labels,
    SIMPLIFY = FALSE,
    USE.NAMES = FALSE
  )
  sprintf(
    '<div style="display:flex;gap:6px;flex-wrap:wrap;margin:6px 0;">%s</div>',
    paste(swatches, collapse = "")
  )
}

parse_proportions <- function(prop_str, count) {
  if (is.null(prop_str) || prop_str == "") {
    return(NULL)
  }
  values <- as.numeric(strsplit(trimws(prop_str), "\\s*,\\s*")[[1]])
  values <- values[!is.na(values)]
  if (length(values) == 0) {
    return(NULL)
  }
  values <- (values / sum(values)) * 100
  if (length(values) < count) {
    remaining <- 100 - sum(values)
    values <- c(
      values,
      rep(remaining / (count - length(values)), count - length(values))
    )
  } else if (length(values) > count) {
    values <- (values[1:count] / sum(values[1:count])) * 100
  }
  values
}

calc_pixels <- function(total_px, gap_px, proportions, count) {
  if (is.null(proportions)) {
    return(rep((total_px - gap_px * (count - 1)) / count, count))
  }
  (total_px - gap_px * (count - 1)) * (proportions / 100)
}

parse_row_proportions <- function(prop_str, containers_per_row) {
  if (is.null(prop_str) || prop_str == "") {
    return(NULL)
  }
  row_strings <- strsplit(trimws(prop_str), ";")[[1]]
  lapply(seq_along(containers_per_row), function(i) {
    if (i <= length(row_strings)) {
      parse_proportions(row_strings[i], containers_per_row[i])
    } else {
      NULL
    }
  })
}

get_containers_per_row <- function(config) {
  if (config$content$layout_type == "uniform") {
    return(rep(config$content$grid_cols, config$content$grid_rows))
  } else if (config$content$layout_type == "byrow") {
    containers <- as.integer(strsplit(config$content$containers_per_row, ",")[[
      1
    ]])
    return(containers[!is.na(containers)])
  } else if (config$content$layout_type == "freeform") {
    return(rep(config$content$ff_cols, config$content$ff_rows))
  }
  # Fallback
  return(rep(config$content$grid_cols, config$content$grid_rows))
}

get_containers_per_col <- function(config) {
  if (config$content$layout_type == "bycol") {
    containers <- as.integer(strsplit(config$content$containers_per_col, ",")[[
      1
    ]])
    return(containers[!is.na(containers)])
  }
  return(NULL)
}

# CSS Generation
generate_css <- function(config) {
  main_height <- config$canvas$height - config$header$height
  main_width <- config$canvas$width - config$sidebar$width
  content_height <- main_height -
    config$content$kpi_height -
    config$content$kpi_gap -
    config$content$padding * 2

  sprintf(
    ":root{--bg-page:%s;--bg-card:%s;--border:%s;--text-primary:%s;--text-secondary:%s;--accent:%s;--radius:%s;--radius-lg:%s}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:var(--bg-page);color:var(--text-primary)}
.dashboard-container{position:relative;width:%dpx;height:%dpx;background:var(--bg-page);overflow:hidden}
.header{position:absolute;top:0;left:0;width:%dpx;height:%dpx;background:var(--bg-card);border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;padding:0 %dpx;z-index:100}
.header-logo{width:%dpx;height:%dpx;background:linear-gradient(135deg,var(--accent),#00796B);border-radius:var(--radius);display:flex;align-items:center;justify-content:center;color:white;font-weight:600;font-size:14px}
.header-nav{display:flex;gap:12px}
.header-nav-btn{width:36px;height:36px;background:var(--bg-page);border:1px solid var(--border);border-radius:var(--radius);display:flex;align-items:center;justify-content:center;color:var(--text-secondary);font-size:12px}
.header-nav-btn.active{background:var(--accent);border-color:var(--accent);color:white}
.sidebar{position:absolute;top:%dpx;left:0;width:%dpx;height:%dpx;background:var(--bg-card);border-right:1px solid var(--border);padding:%dpx;overflow-y:auto}
.sidebar-section{margin-bottom:20px}
.sidebar-section-title{font-size:11px;font-weight:600;color:var(--text-secondary);text-transform:uppercase;letter-spacing:0.5px;margin-bottom:12px}
.sidebar-nav-item{display:flex;align-items:center;gap:12px;padding:10px 12px;border-radius:var(--radius);color:var(--text-primary);font-size:14px;cursor:pointer;margin-bottom:4px}
.sidebar-nav-item:hover{background:var(--bg-page)}
.sidebar-nav-item.active{background:rgba(0,151,167,0.1);color:var(--accent);font-weight:500}
.sidebar-nav-icon{width:20px;height:20px;background:var(--bg-page);border-radius:4px;display:flex;align-items:center;justify-content:center;font-size:10px;color:var(--text-secondary)}
.sidebar-nav-item.active .sidebar-nav-icon{background:var(--accent);color:white}
.main-content{position:absolute;top:%dpx;left:%dpx;width:%dpx;height:%dpx;padding:%dpx;overflow:hidden}
.kpi-container{display:flex;gap:%dpx;margin-bottom:%dpx;height:%dpx}
.kpi-card{flex:1;background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-lg);padding:16px;display:flex;flex-direction:column;justify-content:center;position:relative}
.kpi-label{font-size:12px;color:var(--text-secondary);margin-bottom:4px}
.kpi-value{font-size:28px;font-weight:700;color:var(--text-primary)}
.kpi-change{font-size:12px;margin-top:4px}
.kpi-change.positive{color:#10B981}
.kpi-change.negative{color:#EF4444}
.content-grid{position:relative;height:%dpx}
.grid-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-lg);padding:16px;display:flex;flex-direction:column;position:absolute}
.grid-card-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px}
.grid-card-title{font-size:14px;font-weight:600;color:var(--text-primary)}
.grid-card-content{flex:1;background:var(--bg-page);border-radius:var(--radius);display:flex;align-items:center;justify-content:center;color:var(--text-secondary);font-size:12px}
.dimension-badge{position:absolute;background:rgba(0,121,107,0.9);color:white;font-size:9px;font-family:Consolas,monospace;padding:4px 8px;border-radius:4px;pointer-events:none;z-index:1000;white-space:nowrap;top:4px;right:4px}
.dimension-badge-small{position:absolute;top:2px;left:2px;background:rgba(0,0,0,0.6);color:white;font-size:8px;font-family:Consolas,monospace;padding:1px 3px;border-radius:2px}
.kpi-card,.grid-card,.header-logo,.sidebar-nav-item,.header-nav-btn{position:relative}",
    config$theme$bg_page,
    config$theme$bg_card,
    config$theme$border,
    config$theme$text_primary,
    config$theme$text_secondary,
    config$theme$accent,
    config$theme$radius,
    config$theme$radius_lg,
    config$canvas$width,
    config$canvas$height,
    config$canvas$width,
    config$header$height,
    config$header$padding,
    config$header$logo_width,
    config$header$logo_height,
    config$header$height,
    config$sidebar$width,
    main_height,
    config$sidebar$padding,
    config$header$height,
    config$sidebar$width,
    main_width,
    main_height,
    config$content$padding,
    config$content$kpi_gap,
    config$content$kpi_gap,
    config$content$kpi_height,
    content_height
  )
}

# HTML Builders
build_header_html <- function(config, mode) {
  badge <- ""
  if (mode == "annotated") {
    badge <- sprintf(
      '<span class="dimension-badge">%dx%d @ (0, 0)</span>',
      config$canvas$width,
      config$header$height
    )
  }
  logo_badge <- ""
  if (mode == "annotated") {
    logo_badge <- sprintf(
      '<span class="dimension-badge-small">%dx%d</span>',
      config$header$logo_width,
      config$header$logo_height
    )
  }

  nav_btns <- ""
  if (mode == "blank") {
    nav_btns <- paste(
      rep('<div class="header-nav-btn"></div>', config$header$nav_button_count),
      collapse = ""
    )
  } else if (mode == "annotated") {
    nav_btns <- paste(
      rep(
        '<div class="header-nav-btn"><span class="dimension-badge-small">36x36</span></div>',
        config$header$nav_button_count
      ),
      collapse = ""
    )
  } else {
    nav_btns <- paste(
      rep('<div class="header-nav-btn"></div>', config$header$nav_button_count),
      collapse = ""
    )
  }

  logo_content <- "LOGO"
  if (mode == "blank") {
    logo_content <- ""
  }

  sprintf(
    '<div class="header">%s<div class="header-logo">%s%s</div><div class="header-nav">%s</div></div>',
    badge,
    logo_badge,
    logo_content,
    nav_btns
  )
}

build_sidebar_html <- function(config, mode) {
  main_height <- config$canvas$height - config$header$height
  badge <- ""
  if (mode == "annotated") {
    badge <- sprintf(
      '<span class="dimension-badge">%dx%d @ (0, %d)</span>',
      config$sidebar$width,
      main_height,
      config$header$height
    )
  }

  nav_items <- ""
  if (mode == "blank") {
    nav_items <- paste(
      rep(
        '<div class="sidebar-nav-item"><div class="sidebar-nav-icon"></div><span></span></div>',
        config$sidebar$nav_item_count
      ),
      collapse = ""
    )
  } else {
    nav_items <- paste(
      sapply(1:config$sidebar$nav_item_count, function(i) {
        sprintf(
          '<div class="sidebar-nav-item%s"><div class="sidebar-nav-icon">%d</div><span>Navigation Item</span></div>',
          ifelse(i == 1, " active", ""),
          i
        )
      }),
      collapse = ""
    )
  }

  sprintf(
    '<div class="sidebar">%s<div class="sidebar-section"><div class="sidebar-section-title">Navigation</div>%s</div></div>',
    badge,
    nav_items
  )
}

build_kpi_html <- function(config, mode) {
  main_width <- config$canvas$width - config$sidebar$width
  total_available <- main_width - config$content$padding * 2
  kpi_props <- parse_proportions(
    config$content$kpi_proportions,
    config$content$kpi_count
  )
  kpi_widths <- calc_pixels(
    total_available,
    config$content$kpi_gap,
    kpi_props,
    config$content$kpi_count
  )

  paste(
    sapply(1:config$content$kpi_count, function(i) {
      w <- kpi_widths[i]
      badge <- ""
      if (mode == "annotated") {
        x_pos <- config$sidebar$width +
          config$content$padding +
          sum(kpi_widths[1:i - 1]) +
          config$content$kpi_gap * (i - 1)
        badge <- sprintf(
          '<span class="dimension-badge">%.0fx%d @ (%.0f, %d)</span>',
          w,
          config$content$kpi_height,
          x_pos,
          config$header$height + config$content$padding
        )
      }

      if (mode == "blank") {
        sprintf(
          '<div class="kpi-card" style="flex:none;width:%.0fpx;">%s</div>',
          w,
          badge
        )
      } else {
        sprintf(
          '<div class="kpi-card" style="flex:none;width:%.0fpx;">%s<div class="kpi-label">KPI Metric %d</div><div class="kpi-value">%d</div><div class="kpi-change positive">+%.1f%%</div></div>',
          w,
          badge,
          i,
          sample(1000:9999, 1),
          runif(1, 1, 15)
        )
      }
    }),
    collapse = ""
  )
}

build_grid_html <- function(config, mode) {
  layout_type <- config$content$layout_type

  if (layout_type == "bycol") {
    return(build_grid_html_bycol(config, mode))
  }

  # For uniform, byrow, and freeform - render row by row
  main_width <- config$canvas$width - config$sidebar$width
  main_height <- config$canvas$height - config$header$height
  content_height <- main_height -
    config$content$kpi_height -
    config$content$kpi_gap -
    config$content$padding * 2

  containers_per_row <- get_containers_per_row(config)
  num_rows <- length(containers_per_row)

  # Get row proportions based on layout type
  if (layout_type == "freeform") {
    row_props <- parse_proportions(config$content$ff_row_heights, num_rows)
  } else if (layout_type == "byrow") {
    row_props <- parse_proportions(config$content$row_proportions, num_rows)
  } else {
    row_props <- NULL
  }
  row_heights <- calc_pixels(
    content_height,
    config$content$grid_gap,
    row_props,
    num_rows
  )

  # Get column proportions based on layout type
  if (layout_type == "freeform") {
    # Freeform: same column widths for all rows
    num_cols <- ifelse(
      !is.null(config$content$ff_cols),
      config$content$ff_cols,
      containers_per_row[1]
    )
    col_props <- parse_proportions(config$content$ff_col_widths, num_cols)
    col_props_list <- replicate(num_rows, col_props, simplify = FALSE)
  } else if (layout_type == "byrow") {
    col_props_list <- parse_row_proportions(
      config$content$col_widths_per_row,
      containers_per_row
    )
  } else {
    col_props_list <- replicate(num_rows, NULL, simplify = FALSE)
  }

  cards <- ""
  cell_idx <- 1
  y_off <- 0

  for (row in 1:num_rows) {
    cols <- containers_per_row[row]
    rh <- row_heights[row]
    col_w <- calc_pixels(
      main_width - config$content$padding * 2,
      config$content$grid_gap,
      col_props_list[[row]],
      cols
    )
    x_off <- 0

    for (col in 1:cols) {
      cw <- col_w[col]
      abs_x <- config$sidebar$width + config$content$padding + x_off
      abs_y <- config$header$height +
        config$content$padding +
        config$content$kpi_height +
        config$content$kpi_gap +
        y_off

      badge <- ""
      if (mode == "annotated") {
        badge <- sprintf(
          '<span class="dimension-badge">%.0fx%.0f @ (%.0f, %.0f)</span>',
          cw,
          rh,
          abs_x,
          abs_y
        )
      }

      if (mode == "blank") {
        cards <- paste0(
          cards,
          sprintf(
            '<div class="grid-card" style="position:absolute;left:%.0fpx;top:%.0fpx;width:%.0fpx;height:%.0fpx;">%s<div class="grid-card-content"></div></div>',
            x_off,
            y_off,
            cw,
            rh,
            badge
          )
        )
      } else {
        cards <- paste0(
          cards,
          sprintf(
            '<div class="grid-card" style="position:absolute;left:%.0fpx;top:%.0fpx;width:%.0fpx;height:%.0fpx;">%s<div class="grid-card-header"><span class="grid-card-title">Chart %d</span></div><div class="grid-card-content">Visual Placeholder</div></div>',
            x_off,
            y_off,
            cw,
            rh,
            badge,
            cell_idx
          )
        )
      }
      cell_idx <- cell_idx + 1
      x_off <- x_off + cw + config$content$grid_gap
    }
    y_off <- y_off + rh + config$content$grid_gap
  }
  cards
}

build_grid_html_bycol <- function(config, mode) {
  main_width <- config$canvas$width - config$sidebar$width
  main_height <- config$canvas$height - config$header$height
  content_height <- main_height -
    config$content$kpi_height -
    config$content$kpi_gap -
    config$content$padding * 2

  containers_per_col <- get_containers_per_col(config)
  num_cols <- length(containers_per_col)

  # Column widths from user input
  col_props <- parse_proportions(config$content$col_widths, num_cols)
  col_widths <- calc_pixels(
    main_width - config$content$padding * 2,
    config$content$grid_gap,
    col_props,
    num_cols
  )

  # Row heights per column from user input
  row_props_per_col <- parse_row_proportions(
    config$content$row_heights_per_col,
    containers_per_col
  )

  cards <- ""
  cell_idx <- 1
  x_off <- 0

  for (col in 1:num_cols) {
    rows <- containers_per_col[col]
    cw <- col_widths[col]

    # Row heights within this column (custom or equal distribution)
    row_heights <- calc_pixels(
      content_height,
      config$content$grid_gap,
      row_props_per_col[[col]],
      rows
    )
    y_off <- 0

    for (row in 1:rows) {
      rh <- row_heights[row]
      abs_x <- config$sidebar$width + config$content$padding + x_off
      abs_y <- config$header$height +
        config$content$padding +
        config$content$kpi_height +
        config$content$kpi_gap +
        y_off

      badge <- ""
      if (mode == "annotated") {
        badge <- sprintf(
          '<span class="dimension-badge">%.0fx%.0f @ (%.0f, %.0f)</span>',
          cw,
          rh,
          abs_x,
          abs_y
        )
      }

      if (mode == "blank") {
        cards <- paste0(
          cards,
          sprintf(
            '<div class="grid-card" style="position:absolute;left:%.0fpx;top:%.0fpx;width:%.0fpx;height:%.0fpx;">%s<div class="grid-card-content"></div></div>',
            x_off,
            y_off,
            cw,
            rh,
            badge
          )
        )
      } else {
        cards <- paste0(
          cards,
          sprintf(
            '<div class="grid-card" style="position:absolute;left:%.0fpx;top:%.0fpx;width:%.0fpx;height:%.0fpx;">%s<div class="grid-card-header"><span class="grid-card-title">Chart %d</span></div><div class="grid-card-content">Visual Placeholder</div></div>',
            x_off,
            y_off,
            cw,
            rh,
            badge,
            cell_idx
          )
        )
      }
      cell_idx <- cell_idx + 1
      y_off <- y_off + rh + config$content$grid_gap
    }
    x_off <- x_off + cw + config$content$grid_gap
  }
  cards
}

build_content_html <- function(config, mode) {
  main_width <- config$canvas$width - config$sidebar$width
  main_height <- config$canvas$height - config$header$height
  badge <- ""
  if (mode == "annotated") {
    badge <- sprintf(
      '<span class="dimension-badge">%dx%d @ (%d, %d)</span>',
      main_width,
      main_height,
      config$sidebar$width,
      config$header$height
    )
  }
  sprintf(
    '<div class="main-content">%s<div class="kpi-container">%s</div><div class="content-grid">%s</div></div>',
    badge,
    build_kpi_html(config, mode),
    build_grid_html(config, mode)
  )
}

generate_html <- function(config, include_css, view_mode) {
  css <- ""
  if (include_css) {
    css <- sprintf("<style>%s</style>", generate_css(config))
  }
  sprintf(
    '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Dashboard Layout</title>%s</head><body><div class="dashboard-container">%s%s%s</div></body></html>',
    css,
    build_header_html(config, view_mode),
    build_sidebar_html(config, view_mode),
    build_content_html(config, view_mode)
  )
}

generate_shiny_code <- function(config) {
  # ── Internal helpers ──────────────────────────────────────────────────

  # Convert percentage proportions to a 12-column Bootstrap grid
  props_to_12grid <- function(proportions, count) {
    if (is.null(proportions)) {
      base <- 12 %/% count
      remainder <- 12 - base * count
      widths <- rep(base, count)
      if (remainder > 0) {
        widths[1:remainder] <- widths[1:remainder] + 1
      }
      return(widths)
    }
    widths <- round(proportions / 100 * 12)
    widths <- pmax(widths, 1)
    diff <- 12 - sum(widths)
    if (diff != 0) {
      idx <- if (diff > 0) which.max(widths) else which.min(widths)
      widths[idx] <- widths[idx] + diff
    }
    widths
  }

  # Generate a single card placeholder (no trailing comma)
  card_code <- function(idx, indent = 4) {
    pad <- paste(rep(" ", indent), collapse = "")
    paste0(
      pad,
      sprintf(
        "card(card_header('Chart %d'), card_body(plotOutput('plot_%d')))",
        idx,
        idx
      )
    )
  }

  # Generate a single value_box placeholder (no trailing comma)
  vbox_code <- function(idx, indent = 4) {
    pad <- paste(rep(" ", indent), collapse = "")
    has_bsicons <- requireNamespace("bsicons", quietly = TRUE)
    showcase_part <- if (has_bsicons) {
      "showcase = bsicons::bs_icon('graph-up')"
    } else {
      "showcase = NULL"
    }
    paste0(
      pad,
      sprintf(
        "value_box(title = 'KPI %d', value = '...', %s)",
        idx,
        showcase_part
      )
    )
  }

  # ── Layout type ───────────────────────────────────────────────────────
  layout_type <- config$content$layout_type

  # ── Theme code ────────────────────────────────────────────────────────
  radius_val <- gsub("px$", "", config$theme$radius)
  theme_lines <- c(
    "theme <- bs_theme(",
    sprintf("  bg      = '%s',", config$theme$bg_page),
    sprintf("  fg      = '%s',", config$theme$text_primary),
    sprintf("  primary = '%s'", config$theme$accent),
    ") |> bs_add_variables(",
    sprintf("  'card-bg'      = '%s',", config$theme$bg_card),
    sprintf("  'border-color' = '%s',", config$theme$border),
    sprintf("  'border-radius' = '%spx'", radius_val),
    ")"
  )

  # ── Title / header code ───────────────────────────────────────────────
  lw <- config$header$logo_width
  lh <- config$header$logo_height
  title_lines <- c(
    "  title = div(",
    "    img(src = 'logo.png', height = '40px', alt = 'Logo',",
    sprintf(
      "        style = 'margin-right:12px; display:%s;'),",
      ifelse(lw > 0, "inline-block", "none")
    ),
    "    'My Dashboard'",
    "  ),"
  )

  # ── Sidebar code ──────────────────────────────────────────────────────
  nav_count <- config$sidebar$nav_item_count
  nav_lines <- vapply(
    seq_len(nav_count),
    function(i) {
      sprintf("    nav_item(actionLink('nav_%d', 'Menu Item %d')),", i, i)
    },
    character(1)
  )
  sidebar_lines <- c(
    "  sidebar = sidebar(",
    sprintf("    width = %d,", config$sidebar$width),
    "    h4('Navigation'),",
    nav_lines,
    "  ),"
  )

  # ── KPI row code ──────────────────────────────────────────────────────
  kpi_count <- config$content$kpi_count
  kpi_lines <- NULL
  if (kpi_count > 0) {
    kpi_props <- parse_proportions(config$content$kpi_proportions, kpi_count)
    kpi_cw <- props_to_12grid(kpi_props, kpi_count)
    vbox_items <- vapply(
      seq_len(kpi_count),
      function(i) {
        vbox_code(i, indent = 4)
      },
      character(1)
    )
    kpi_lines <- c(
      "  # KPI Row",
      "  layout_columns(",
      sprintf("    fill = FALSE,"),
      sprintf("    col_widths = c(%s),", paste(kpi_cw, collapse = ", ")),
      paste(vbox_items, collapse = ",\n"),
      "  ),"
    )
  }

  # ── Main grid code ────────────────────────────────────────────────────
  cell_idx <- 1
  grid_lines <- NULL

  if (layout_type == "uniform") {
    cols <- config$content$grid_cols
    rows <- config$content$grid_rows
    cw <- props_to_12grid(NULL, cols)
    n_cards <- rows * cols
    card_items <- vapply(
      seq_len(n_cards),
      function(i) {
        card_code(i, indent = 4)
      },
      character(1)
    )
    grid_lines <- c(
      "  # Main Grid (Uniform)",
      "  layout_columns(",
      sprintf("    col_widths = c(%s),", paste(cw, collapse = ", ")),
      "    fill = TRUE,",
      paste(card_items, collapse = ",\n"),
      "  )"
    )
    cell_idx <- n_cards + 1
  } else if (layout_type == "byrow") {
    containers_per_row <- get_containers_per_row(config)
    num_rows <- length(containers_per_row)
    col_props_list <- parse_row_proportions(
      config$content$col_widths_per_row,
      containers_per_row
    )
    row_block_list <- list()
    for (r in seq_len(num_rows)) {
      n <- containers_per_row[r]
      cw <- props_to_12grid(col_props_list[[r]], n)
      cards <- vapply(
        seq_len(n),
        function(j) {
          idx <- cell_idx
          cell_idx <<- cell_idx + 1
          card_code(idx, indent = 4)
        },
        character(1)
      )
      block <- c(
        sprintf("  # Row %d", r),
        "  layout_columns(",
        sprintf("    col_widths = c(%s),", paste(cw, collapse = ", ")),
        "    fill = TRUE,",
        paste(cards, collapse = ",\n"),
        sprintf("  )%s", ifelse(r < num_rows, ",", ""))
      )
      row_block_list[[r]] <- block
    }
    # Flatten
    for (r in seq_along(row_block_list)) {
      if (r == 1) {
        grid_lines <- c("  # Main Grid (By Row)", row_block_list[[r]])
      } else {
        grid_lines <- c(grid_lines, "", row_block_list[[r]])
      }
    }
  } else if (layout_type == "bycol") {
    containers_per_col <- get_containers_per_col(config)
    num_cols <- length(containers_per_col)
    col_props <- parse_proportions(config$content$col_widths, num_cols)
    outer_cw <- props_to_12grid(col_props, num_cols)
    row_props_per_col <- parse_row_proportions(
      config$content$row_heights_per_col,
      containers_per_col
    )
    col_blocks <- character(num_cols)
    for (cl in seq_len(num_cols)) {
      n_rows <- containers_per_col[cl]
      cards <- vapply(
        seq_len(n_rows),
        function(j) {
          idx <- cell_idx
          cell_idx <<- cell_idx + 1
          sprintf(
            "        card(card_header('Chart %d'), card_body(plotOutput('plot_%d')))",
            idx,
            idx
          )
        },
        character(1)
      )
      col_blocks[cl] <- paste0(
        sprintf(
          "    div(style = 'display:flex; flex-direction:column; gap:1rem;',\n"
        ),
        paste(cards, collapse = ",\n"),
        "\n    ),"
      )
    }
    grid_lines <- c(
      "  # Main Grid (By Column)",
      "  layout_columns(",
      sprintf("    col_widths = c(%s),", paste(outer_cw, collapse = ", ")),
      col_blocks,
      "  )"
    )
  } else if (layout_type == "freeform") {
    ff_rows <- config$content$ff_rows
    ff_cols <- config$content$ff_cols
    col_props <- parse_proportions(config$content$ff_col_widths, ff_cols)
    cw <- props_to_12grid(col_props, ff_cols)
    n_cards <- ff_rows * ff_cols
    card_items <- vapply(
      seq_len(n_cards),
      function(i) {
        card_code(i, indent = 4)
      },
      character(1)
    )
    grid_lines <- c(
      "  # Main Grid (Freeform)",
      "  layout_columns(",
      sprintf("    col_widths = c(%s),", paste(cw, collapse = ", ")),
      "    fill = TRUE,",
      paste(card_items, collapse = ",\n"),
      "  )"
    )
    cell_idx <- n_cards + 1
  } else {
    # Fallback
    cols <- config$content$grid_cols
    rows <- config$content$grid_rows
    cw <- props_to_12grid(NULL, cols)
    n_cards <- rows * cols
    card_items <- vapply(
      seq_len(n_cards),
      function(i) {
        card_code(i, indent = 4)
      },
      character(1)
    )
    grid_lines <- c(
      "  # Main Grid",
      "  layout_columns(",
      sprintf("    col_widths = c(%s),", paste(cw, collapse = ", ")),
      "    fill = TRUE,",
      paste(card_items, collapse = ",\n"),
      "  )"
    )
    cell_idx <- n_cards + 1
  }

  # ── Server code ───────────────────────────────────────────────────────
  total_cards <- cell_idx - 1
  server_card_lines <- vapply(
    seq_len(total_cards),
    function(i) {
      sprintf(
        "  output$plot_%d <- renderPlot({ plot(cars, main = 'Chart %d') })",
        i,
        i
      )
    },
    character(1)
  )

  server_lines <- c(
    "server <- function(input, output, session) {",
    server_card_lines,
    "}"
  )

  # ── Assemble final code ───────────────────────────────────────────────
  code <- c(
    "# Generated by Dashboard Layout Architect",
    "# Copy-paste into a new app.R file and run",
    "",
    "library(shiny)",
    "library(bslib)",
    "library(bsicons)",
    "",
    "# ── Theme ──────────────────────────────────────────────────────────",
    theme_lines,
    "",
    "# ── UI ─────────────────────────────────────────────────────────────",
    "ui <- page_sidebar(",
    title_lines,
    "  theme = theme,",
    sidebar_lines,
    ""
  )

  if (!is.null(kpi_lines)) {
    code <- c(code, kpi_lines, "")
  }

  code <- c(code, grid_lines, ")")

  code <- c(
    code,
    "",
    "# ── Server ────────────────────────────────────────────────",
    server_lines,
    "",
    "shinyApp(ui, server)"
  )

  paste(code, collapse = "\n")
}

generate_dax <- function(config) {
  paste(
    c(
      "// ============================================",
      "// Dashboard Layout DAX Measures",
      "// ============================================",
      "",
      "// Canvas Dimensions",
      sprintf("Canvas_Width = %d", config$canvas$width),
      sprintf("Canvas_Height = %d", config$canvas$height),
      "",
      "// Header Settings",
      sprintf("Header_Height = %d", config$header$height),
      sprintf("Header_Padding = %d", config$header$padding),
      sprintf("Logo_Width = %d", config$header$logo_width),
      sprintf("Logo_Height = %d", config$header$logo_height),
      "",
      "// Sidebar Settings",
      sprintf("Sidebar_Width = %d", config$sidebar$width),
      sprintf("Sidebar_Padding = %d", config$sidebar$padding),
      "",
      "// KPI Card Settings",
      sprintf("KPI_Height = %d", config$content$kpi_height),
      sprintf("KPI_Count = %d", config$content$kpi_count),
      sprintf("KPI_Gap = %d", config$content$kpi_gap),
      "",
      "// Grid Settings",
      sprintf("Grid_Rows = %d", config$content$grid_rows),
      sprintf("Grid_Cols = %d", config$content$grid_cols),
      sprintf("Grid_Gap = %d", config$content$grid_gap),
      "",
      "// Theme Colors",
      sprintf("Theme_BG_Page = \"%s\"", config$theme$bg_page),
      sprintf("Theme_BG_Card = \"%s\"", config$theme$bg_card),
      sprintf("Theme_Border = \"%s\"", config$theme$border),
      sprintf("Theme_Accent = \"%s\"", config$theme$accent),
      "",
      "// Layout HTML (copy from Power BI HTML tab)",
      "Layout HTML = \"<style>...</style><div class='dashboard-container'>...</div>\""
    ),
    collapse = "\n"
  )
}

generate_json_theme <- function(config) {
  # Power BI valid theme structure
  theme <- list(
    name = "Dashboard Layout Theme",
    dataColors = c(
      config$theme$accent,
      gcps_base["blue"],
      gcps_base["teal"],
      gcps_base["green"],
      gcps_base["violet"],
      gcps_base["orange"],
      gcps_base["neutral"]
    ),
    background = config$theme$bg_page,
    foreground = config$theme$text_primary,
    tableAccent = config$theme$accent
  )
  toJSON(theme, pretty = TRUE, auto_unbox = TRUE)
}

# Collapsible Section Helper
collapsible_section <- function(id, title, icon_name, content, open = FALSE) {
  tagList(
    div(
      class = "section-wrapper",
      div(
        class = "section-header-clickable",
        `data-bs-toggle` = "collapse",
        `data-bs-target` = paste0("#", id),
        icon(icon_name),
        title,
        icon(
          ifelse(open, "chevron-up", "chevron-down"),
          class = "chevron pull-right"
        )
      ),
      div(
        id = id,
        class = ifelse(
          open,
          "section-content collapse show",
          "section-content collapse"
        ),
        content
      )
    )
  )
}

# Builder Sidebar (structure controls only)
builder_sidebar <- sidebar(
  width = 350,
  open = "always",

  # Canvas Section
  collapsible_section(
    "sec_canvas",
    "Canvas Settings",
    "tv",
    tagList(
      fluidRow(
        column(
          6,
          numericInput(
            "canvas_width",
            "Width",
            value = DEFAULT_CONFIG$canvas$width,
            min = 400,
            max = 3840
          )
        ),
        column(
          6,
          numericInput(
            "canvas_height",
            "Height",
            value = DEFAULT_CONFIG$canvas$height,
            min = 300,
            max = 2160
          )
        )
      ),
      selectInput(
        "aspect_ratio",
        "Aspect Ratio",
        c("Custom", "16:9", "4:3", "21:9"),
        selected = "16:9"
      )
    ),
    open = TRUE
  ),

  # Header Section
  collapsible_section(
    "sec_header",
    "Header",
    "window-maximize",
    tagList(
      fluidRow(
        column(
          6,
          numericInput(
            "header_height",
            "Height",
            value = DEFAULT_CONFIG$header$height,
            min = 40,
            max = 200
          )
        ),
        column(
          6,
          numericInput(
            "header_padding",
            "Padding",
            value = DEFAULT_CONFIG$header$padding,
            min = 0,
            max = 40
          )
        )
      ),
      fluidRow(
        column(
          6,
          numericInput(
            "logo_width",
            "Logo Width",
            value = DEFAULT_CONFIG$header$logo_width,
            min = 50,
            max = 300
          )
        ),
        column(
          6,
          numericInput(
            "logo_height",
            "Logo Height",
            value = DEFAULT_CONFIG$header$logo_height,
            min = 20,
            max = 100
          )
        )
      ),
      numericInput(
        "nav_button_count",
        "Nav Buttons",
        value = DEFAULT_CONFIG$header$nav_button_count,
        min = 0,
        max = 8
      )
    ),
    open = FALSE
  ),

  # Sidebar Section
  collapsible_section(
    "sec_sidebar",
    "Sidebar",
    "columns",
    tagList(
      fluidRow(
        column(
          6,
          numericInput(
            "sidebar_width",
            "Width",
            value = DEFAULT_CONFIG$sidebar$width,
            min = 100,
            max = 400
          )
        ),
        column(
          6,
          numericInput(
            "sidebar_padding",
            "Padding",
            value = DEFAULT_CONFIG$sidebar$padding,
            min = 0,
            max = 32
          )
        )
      ),
      numericInput(
        "nav_item_count",
        "Nav Items",
        value = DEFAULT_CONFIG$sidebar$nav_item_count,
        min = 1,
        max = 15
      )
    ),
    open = FALSE
  ),

  # KPI Cards Section
  collapsible_section(
    "sec_kpi",
    "KPI Cards",
    "chart-bar",
    tagList(
      fluidRow(
        column(
          4,
          numericInput(
            "kpi_height",
            "Height",
            value = DEFAULT_CONFIG$content$kpi_height,
            min = 60,
            max = 150
          )
        ),
        column(
          4,
          numericInput(
            "kpi_count",
            "Count",
            value = DEFAULT_CONFIG$content$kpi_count,
            min = 1,
            max = 8
          )
        ),
        column(
          4,
          numericInput(
            "kpi_gap",
            "Gap",
            value = DEFAULT_CONFIG$content$kpi_gap,
            min = 0,
            max = 40
          )
        )
      ),
      textInput(
        "kpi_proportions",
        "Width Proportions",
        value = "",
        placeholder = "e.g., 40, 30, 20, 10"
      )
    ),
    open = FALSE
  ),

  # Content Grid Section
  collapsible_section(
    "sec_grid",
    "Content Grid",
    "th",
    tagList(
      radioButtons(
        "layout_type",
        "Layout Type",
        c(
          "Uniform Grid" = "uniform",
          "By Row (varying cols)" = "byrow",
          "By Column (varying rows)" = "bycol",
          "Freeform" = "freeform"
        ),
        selected = "uniform",
        inline = TRUE
      ),

      # Uniform: Same rows and columns throughout
      conditionalPanel(
        condition = "input.layout_type == 'uniform'",
        fluidRow(
          column(
            6,
            numericInput(
              "grid_rows",
              "Rows",
              value = DEFAULT_CONFIG$content$grid_rows,
              min = 1,
              max = 10
            )
          ),
          column(
            6,
            numericInput(
              "grid_cols",
              "Columns",
              value = DEFAULT_CONFIG$content$grid_cols,
              min = 1,
              max = 6
            )
          )
        ),
        p(class = "text-muted small", "Same number of columns in each row")
      ),

      # By Row: Different number of columns per row
      conditionalPanel(
        condition = "input.layout_type == 'byrow'",
        textInput(
          "containers_per_row",
          "Containers Per Row",
          value = DEFAULT_CONFIG$content$containers_per_row,
          placeholder = "e.g., 2, 3, 2"
        ),
        p(
          class = "text-muted small",
          "Comma-separated: number of containers in each row (top to bottom)"
        ),
        hr(),
        strong("Row Heights"),
        textInput(
          "row_heights",
          "Height Per Row (%)",
          value = "",
          placeholder = "e.g., 40, 35, 25"
        ),
        p(
          class = "text-muted small",
          "Comma-separated percentages for each row's height"
        ),
        hr(),
        strong("Column Widths Per Row"),
        textInput(
          "col_widths_per_row",
          "Column Widths by Row",
          value = "",
          placeholder = "e.g., 50,50; 33,33,34; 60,40"
        ),
        p(
          class = "text-muted small",
          "Semicolon separates rows; comma separates columns within each row"
        )
      ),

      # By Column: Different number of rows per column
      conditionalPanel(
        condition = "input.layout_type == 'bycol'",
        textInput(
          "containers_per_col",
          "Containers Per Column",
          value = "2, 2",
          placeholder = "e.g., 2, 3, 2"
        ),
        p(
          class = "text-muted small",
          "Comma-separated: number of containers in each column (left to right)"
        ),
        hr(),
        strong("Column Widths"),
        textInput(
          "col_widths",
          "Width Per Column (%)",
          value = "",
          placeholder = "e.g., 30, 40, 30"
        ),
        p(
          class = "text-muted small",
          "Comma-separated percentages for each column's width"
        ),
        hr(),
        strong("Row Heights Per Column"),
        textInput(
          "row_heights_per_col",
          "Row Heights by Column",
          value = "",
          placeholder = "e.g., 50,50; 33,33,34; 60,40"
        ),
        p(
          class = "text-muted small",
          "Semicolon separates columns; comma separates rows within each column"
        )
      ),

      # Freeform: Specify exact grid with custom widths/heights per cell
      conditionalPanel(
        condition = "input.layout_type == 'freeform'",
        numericInput(
          "ff_rows",
          "Number of Rows",
          value = 3,
          min = 1,
          max = 10
        ),
        numericInput(
          "ff_cols",
          "Number of Columns",
          value = 3,
          min = 1,
          max = 6
        ),
        hr(),
        strong("Row Heights"),
        textInput(
          "ff_row_heights",
          "Height Per Row (%)",
          value = "",
          placeholder = "e.g., 30, 40, 30"
        ),
        strong("Column Widths"),
        textInput(
          "ff_col_widths",
          "Width Per Column (%)",
          value = "",
          placeholder = "e.g., 25, 50, 25"
        ),
        p(class = "text-muted small", "Uniform grid with custom proportions")
      ),

      hr(),
      numericInput(
        "grid_gap",
        "Gap (px)",
        value = DEFAULT_CONFIG$content$grid_gap,
        min = 0,
        max = 40
      )
    ),
    open = FALSE
  ),

  hr(),
  actionButton(
    "reset_config",
    "Reset to Defaults",
    class = "btn-outline-danger w-100"
  )
)

# Theme Studio Tab (styling controls + preview)
theme_studio_tab <- nav_panel(
  title = "🎨 Theme & Typography Studio",
  value = "theme_studio_tab",
  bslib::layout_columns(
    col_widths = c(4, 8),

    # Left Column: Theme & Typography Controls
    card(
      card_header("Theme & Typography"),
      fluidRow(
        column(
          6,
          colourInput(
            "bg_page",
            "Page Background",
            value = DEFAULT_CONFIG$theme$bg_page
          )
        ),
        column(
          6,
          colourInput(
            "bg_card",
            "Card Background",
            value = DEFAULT_CONFIG$theme$bg_card
          )
        )
      ),
      fluidRow(
        column(
          6,
          colourInput(
            "border",
            "Border Color",
            value = DEFAULT_CONFIG$theme$border
          )
        ),
        column(
          6,
          colourInput(
            "accent",
            "Accent Color",
            value = DEFAULT_CONFIG$theme$accent
          )
        )
      ),
      fluidRow(
        column(
          6,
          textInput(
            "radius",
            "Border Radius",
            value = DEFAULT_CONFIG$theme$radius
          )
        ),
        column(
          6,
          textInput(
            "radius_lg",
            "Large Radius",
            value = DEFAULT_CONFIG$theme$radius_lg
          )
        )
      ),
      hr(),
      selectInput(
        "base_color",
        "Palette Base",
        choices = names(gcps_base),
        selected = "teal"
      ),
      hr(),
      selectInput(
        "font_family",
        "Font Family",
        choices = names(font_families),
        selected = "Segoe UI"
      ),
      selectInput(
        "font_weight",
        "Font Weight",
        choices = font_weights,
        selected = "400"
      ),
      fluidRow(
        column(
          6,
          numericInput(
            "base_font_size",
            "Base (px)",
            value = 14,
            min = 10,
            max = 24
          )
        ),
        column(
          6,
          numericInput(
            "heading_font_size",
            "Heading (px)",
            value = 18,
            min = 14,
            max = 36
          )
        )
      ),
      hr(),
      checkboxInput(
        "annotations_enabled",
        "Show Dimension Badges",
        value = FALSE
      ),
      p(
        class = "text-muted small",
        "Display width x height @ (x, y) on elements"
      )
    ),

    # Right Column: Preview & Export
    card(
      card_header("Preview & Export"),
      h5("Color Ramp"),
      uiOutput("ramp_preview"),
      hr(),
      h5("Theme Preview"),
      uiOutput("theme_preview"),
      hr(),
      downloadButton(
        "download_json",
        "Export JSON Theme",
        class = "btn-primary btn-sm w-100"
      )
    )
  )
)

# UI Definition (assembled from builder sidebar + tabs)
ui <- page_sidebar(
  title = "Dashboard Architect",
  theme = bs_theme(bootswatch = "yeti", version = 5),
  sidebar = builder_sidebar,
  navset_tab(
    id = "main_tabs",

    # Layout Preview Tab
    nav_panel(
      title = "Layout Preview",
      value = "preview_tab",
      div(
        class = "p-3 bg-light border-bottom",
        fluidRow(
          column(
            6,
            radioButtons(
              "view_mode",
              "View Mode",
              c(
                "Example" = "example",
                "Blank" = "blank",
                "Annotated" = "annotated"
              ),
              selected = "example",
              inline = TRUE
            )
          ),
          column(
            6,
            div(
              class = "d-flex align-items-center gap-2",
              "Zoom:",
              actionButton(
                "zoom_out",
                "-",
                class = "btn btn-sm btn-outline-secondary"
              ),
              textOutput("zoom_display", inline = TRUE),
              actionButton(
                "zoom_in",
                "+",
                class = "btn btn-sm btn-outline-secondary"
              )
            )
          )
        )
      ),
      div(
        class = "p-4 bg-secondary",
        style = "overflow: auto; height: calc(100vh - 200px);",
        div(class = "d-flex justify-content-center", uiOutput("preview_frame"))
      )
    ),

    theme_studio_tab,

    #  Shiny Tab
    nav_panel(
      title = "Shiny Code",
      value = "shiny_tab",
      div(
        class = "p-3",
        div(
          class = "d-flex gap-2 mb-3",
          downloadButton(
            "download_shiny",
            "Download .R",
            class = "btn-primary btn-sm"
          ),
          actionButton(
            "copy_shiny",
            "Copy Code",
            class = "btn-outline-primary btn-sm"
          )
        ),
        p(
          class = "text-muted small",
          "Starter code for an R Shiny application using bslib."
        ),
        div(class = "code-output", verbatimTextOutput("shiny_output"))
      )
    ),

    # Power BI HTML Tab
    nav_panel(
      title = "Power BI HTML",
      value = "powerbi_tab",
      div(
        class = "p-3",
        div(
          class = "d-flex gap-2 mb-3",
          downloadButton(
            "download_powerbi",
            "Download",
            class = "btn-primary btn-sm"
          ),
          actionButton(
            "copy_powerbi",
            "Copy",
            class = "btn-outline-primary btn-sm"
          ),
          checkboxInput("single_line", "Single Line (for DAX)", value = TRUE)
        ),
        p(
          class = "text-muted small",
          "HTML formatted for Power BI HTML Content visual. Use in DAX: Layout HTML = \"...\""
        ),
        div(class = "code-output", verbatimTextOutput("powerbi_output"))
      )
    ),

    # DAX Tab
    nav_panel(
      title = "DAX",
      value = "dax_tab",
      div(
        class = "p-3",
        div(
          class = "d-flex gap-2 mb-3",
          downloadButton(
            "download_dax",
            "Download",
            class = "btn-primary btn-sm"
          ),
          actionButton("copy_dax", "Copy", class = "btn-outline-primary btn-sm")
        ),
        p(class = "text-muted small", "DAX measures for layout configuration."),
        div(class = "code-output", verbatimTextOutput("dax_output"))
      )
    ),

    # Full HTML Tab
    nav_panel(
      title = "Full HTML",
      value = "html_tab",
      div(
        class = "p-3",
        div(
          class = "d-flex gap-2 mb-3",
          downloadButton(
            "download_html",
            "Download",
            class = "btn-primary btn-sm"
          ),
          actionButton(
            "copy_html",
            "Copy",
            class = "btn-outline-primary btn-sm"
          )
        ),
        p(
          class = "text-muted small",
          "Complete HTML document for standalone use."
        ),
        div(class = "code-output", verbatimTextOutput("html_output"))
      )
    )
  )
)

# Additional CSS
tags_style <- tags$style(HTML(
  "
  .section-wrapper { margin-bottom: 8px; }
  .section-header-clickable {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 12px;
    background: #f8f9fa;
    border: 1px solid #dee2e6;
    border-radius: 6px;
    cursor: pointer;
    font-weight: 500;
    font-size: 13px;
    transition: background 0.2s;
  }
  .section-header-clickable:hover { background: #e9ecef; }
  .section-header-clickable .chevron { margin-left: auto; transition: transform 0.2s; }
  .section-content { padding: 12px; border: 1px solid #dee2e6; border-top: none; border-radius: 0 0 6px 6px; }
  .section-content .form-group { margin-bottom: 8px; }
  .section-content .form-group label { font-size: 11px; margin-bottom: 2px; }
  .code-output {
    background: #1e1e1e !important;
    border-radius: 8px;
    padding: 15px;
    max-height: 500px;
    overflow: auto;
  }
  .code-output pre,
  .code-output #shiny_output,
  .code-output #powerbi_output,
  .code-output #dax_output,
  .code-output #json_output,
  .code-output #html_output {
    color: #d4d4d4 !important;
    background: transparent !important;
    font-family: 'Consolas', Monaco, monospace;
    font-size: 12px;
    white-space: pre-wrap;
  }
  .preview-frame {
    background: white;
    box-shadow: 0 4px 20px rgba(0,0,0,0.15);
    transform-origin: top center;
  }
"
))

# Server Logic
server <- function(input, output, session) {
  # Zoom reactive value
  rv <- reactiveValues(zoom = 0.5)

  # Build config reactively
  build_config <- reactive({
    list(
      canvas = list(width = input$canvas_width, height = input$canvas_height),
      theme = list(
        bg_page = input$bg_page,
        bg_card = input$bg_card,
        border = input$border,
        text_primary = "#1F2937",
        text_secondary = "#6B7280",
        accent = input$accent,
        radius = input$radius,
        radius_lg = input$radius_lg
      ),
      header = list(
        height = input$header_height,
        padding = input$header_padding,
        logo_width = input$logo_width,
        logo_height = input$logo_height,
        nav_button_count = input$nav_button_count
      ),
      sidebar = list(
        width = input$sidebar_width,
        padding = input$sidebar_padding,
        nav_item_count = input$nav_item_count
      ),
      content = list(
        kpi_height = input$kpi_height,
        kpi_count = input$kpi_count,
        kpi_gap = input$kpi_gap,
        grid_rows = input$grid_rows,
        grid_cols = input$grid_cols,
        grid_gap = input$grid_gap,
        padding = 20,
        layout_type = input$layout_type,
        # By Row settings
        containers_per_row = input$containers_per_row,
        row_proportions = input$row_heights,
        col_widths_per_row = input$col_widths_per_row,
        # By Column settings
        containers_per_col = input$containers_per_col,
        col_widths = input$col_widths,
        row_heights_per_col = input$row_heights_per_col,
        # Freeform settings
        ff_rows = input$ff_rows,
        ff_cols = input$ff_cols,
        ff_row_heights = input$ff_row_heights,
        ff_col_widths = input$ff_col_widths,
        # KPI settings
        kpi_proportions = input$kpi_proportions
      ),
      annotations = list(enabled = input$annotations_enabled)
    )
  })

  # Aspect ratio presets
  observeEvent(input$aspect_ratio, {
    if (input$aspect_ratio != "Custom") {
      ratios <- list(
        "16:9" = c(1600, 900),
        "4:3" = c(1200, 900),
        "21:9" = c(2100, 900)
      )
      if (input$aspect_ratio %in% names(ratios)) {
        updateNumericInput(
          session,
          "canvas_width",
          value = ratios[[input$aspect_ratio]][1]
        )
        updateNumericInput(
          session,
          "canvas_height",
          value = ratios[[input$aspect_ratio]][2]
        )
      }
    }
  })

  # Zoom controls
  observeEvent(input$zoom_in, {
    rv$zoom <- min(1.5, rv$zoom + 0.1)
  })
  observeEvent(input$zoom_out, {
    rv$zoom <- max(0.25, rv$zoom - 0.1)
  })

  output$zoom_display <- renderText({
    paste0(round(rv$zoom * 100), "%")
  })

  # Reset to defaults
  observeEvent(input$reset_config, {
    updateNumericInput(
      session,
      "canvas_width",
      value = DEFAULT_CONFIG$canvas$width
    )
    updateNumericInput(
      session,
      "canvas_height",
      value = DEFAULT_CONFIG$canvas$height
    )
    updateSelectInput(session, "aspect_ratio", selected = "16:9")
    updateColourInput(session, "bg_page", value = DEFAULT_CONFIG$theme$bg_page)
    updateColourInput(session, "bg_card", value = DEFAULT_CONFIG$theme$bg_card)
    updateColourInput(session, "border", value = DEFAULT_CONFIG$theme$border)
    updateColourInput(session, "accent", value = DEFAULT_CONFIG$theme$accent)
    updateNumericInput(
      session,
      "header_height",
      value = DEFAULT_CONFIG$header$height
    )
    updateNumericInput(
      session,
      "sidebar_width",
      value = DEFAULT_CONFIG$sidebar$width
    )
    updateNumericInput(
      session,
      "kpi_count",
      value = DEFAULT_CONFIG$content$kpi_count
    )
    updateNumericInput(
      session,
      "grid_rows",
      value = DEFAULT_CONFIG$content$grid_rows
    )
    updateNumericInput(
      session,
      "grid_cols",
      value = DEFAULT_CONFIG$content$grid_cols
    )
    # Reset layout type and related fields
    updateRadioButtons(session, "layout_type", selected = "uniform")
    updateTextInput(
      session,
      "containers_per_row",
      value = DEFAULT_CONFIG$content$containers_per_row
    )
    updateTextInput(
      session,
      "containers_per_col",
      value = DEFAULT_CONFIG$content$containers_per_col
    )
    updateTextInput(session, "row_heights", value = "")
    updateTextInput(session, "col_widths", value = "")
    updateTextInput(session, "col_widths_per_row", value = "")
    updateTextInput(session, "row_heights_per_col", value = "")
    updateNumericInput(
      session,
      "ff_rows",
      value = DEFAULT_CONFIG$content$ff_rows
    )
    updateNumericInput(
      session,
      "ff_cols",
      value = DEFAULT_CONFIG$content$ff_cols
    )
    updateTextInput(session, "ff_row_heights", value = "")
    updateTextInput(session, "ff_col_widths", value = "")
    updateCheckboxInput(session, "annotations_enabled", value = FALSE)
    showNotification("Reset to defaults", type = "message")
  })

  # Preview output
  output$preview_frame <- renderUI({
    config <- build_config()
    view_mode <- if (input$annotations_enabled) "annotated" else input$view_mode
    html_content <- generate_html(
      config,
      include_css = TRUE,
      view_mode = view_mode
    )
    div(
      style = sprintf(
        "transform: scale(%s); transform-origin: top center;",
        rv$zoom
      ),
      class = "preview-frame",
      HTML(html_content)
    )
  })

  output$shiny_output <- renderText({
    generate_shiny_code(build_config())
  })

  # Power BI HTML output
  output$powerbi_output <- renderText({
    config <- build_config()
    view_mode <- if (config$annotations$enabled) "annotated" else "blank"
    html <- generate_html(config, include_css = TRUE, view_mode = view_mode)
    if (input$single_line) {
      html <- gsub("\n", " ", html)
      html <- gsub("\\s+", " ", html)
    }
    html
  })

  # DAX output
  output$dax_output <- renderText({
    generate_dax(build_config())
  })

  # JSON output
  output$json_output <- renderText({
    generate_json_theme(build_config())
  })

  # Full HTML output
  output$html_output <- renderText({
    config <- build_config()
    view_mode <- if (config$annotations$enabled) "annotated" else "example"
    generate_html(config, include_css = TRUE, view_mode = view_mode)
  })

  # Color palette preview
  output$ramp_preview <- renderUI({
    if (input$base_color %in% names(gcps_ramps)) {
      HTML(generate_swatch_html(
        gcps_ramps[[input$base_color]],
        c("Lt", "Light", "Med", "Dark", "Dk")
      ))
    }
  })

  # Download handlers

  output$download_shiny <- downloadHandler(
    filename = function() paste0("app-", format(Sys.Date(), "%Y%m%d"), ".R"),
    content = function(file) {
      writeLines(generate_shiny_code(build_config()), file)
    }
  )

  output$download_powerbi <- downloadHandler(
    filename = function() {
      paste0("dashboard-layout-", format(Sys.Date(), "%Y%m%d"), ".html")
    },
    content = function(file) {
      config <- build_config()
      view_mode <- if (config$annotations$enabled) "annotated" else "blank"
      writeLines(generate_html(config, TRUE, view_mode), file)
    }
  )

  output$download_dax <- downloadHandler(
    filename = function() {
      paste0("dashboard-measures-", format(Sys.Date(), "%Y%m%d"), ".dax")
    },
    content = function(file) writeLines(generate_dax(build_config()), file)
  )

  output$download_json <- downloadHandler(
    filename = function() {
      paste0("dashboard-theme-", format(Sys.Date(), "%Y%m%d"), ".json")
    },
    content = function(file) {
      writeLines(generate_json_theme(build_config()), file)
    }
  )

  output$download_html <- downloadHandler(
    filename = function() {
      paste0("dashboard-full-", format(Sys.Date(), "%Y%m%d"), ".html")
    },
    content = function(file) {
      config <- build_config()
      view_mode <- if (config$annotations$enabled) "annotated" else "example"
      writeLines(generate_html(config, TRUE, view_mode), file)
    }
  )

  # Copy notifications

  observeEvent(
    input$copy_shiny,
    showNotification("Shiny code copied!", type = "message")
  )

  observeEvent(
    input$copy_powerbi,
    showNotification("HTML copied!", type = "message")
  )
  observeEvent(
    input$copy_dax,
    showNotification("DAX copied!", type = "message")
  )
  observeEvent(
    input$copy_json,
    showNotification("JSON copied!", type = "message")
  )
  observeEvent(
    input$copy_html,
    showNotification("HTML copied!", type = "message")
  )
}

# Run application
shinyApp(ui = tagList(tags_style, ui), server = server)
