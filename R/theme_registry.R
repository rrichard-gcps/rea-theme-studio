# Theme Registry
# K-12 Dashboard Architect
# Each theme is a named list of design tokens.

theme_registry <- list(
  gcps_light = list(
    id = "gcps_light",
    name = "GCPS Light",
    description = "Default dashboard theme. Clean, modern, leadership-friendly.",
    colors = list(
      primary = "#9B2743",
      secondary = "#2C3641",
      accent_blue = "#374E8E",
      accent_teal = "#2F7C73",
      bg_page = "#F6F7F9",
      bg_card = "#FFFFFF",
      border = "#D8DEE8",
      text = "#1F2933",
      text_muted = "#667085",
      success = "#1A7F37",
      warning = "#9A6700",
      danger = "#CF222E"
    ),
    typography = list(
      font_family = "Lexend, 'Segoe UI', system-ui, sans-serif",
      base_size = "14px",
      heading_size = "18px",
      weight = "400"
    ),
    radius = "8px",
    spacing = list(
      card_padding = "16px",
      section_gap = "16px",
      kpi_gap = "16px"
    )
  ),

  gcps_board_report = list(
    id = "gcps_board_report",
    name = "GCPS Board Report",
    description = "Board-facing theme. Higher contrast, larger type, restrained accents.",
    colors = list(
      primary = "#9B2743",
      secondary = "#1F2933",
      accent_blue = "#374E8E",
      accent_teal = "#2F7C73",
      bg_page = "#FFFFFF",
      bg_card = "#FFFFFF",
      border = "#D8DEE8",
      text = "#1F2933",
      text_muted = "#4B5563",
      success = "#1A7F37",
      warning = "#9A6700",
      danger = "#CF222E"
    ),
    typography = list(
      font_family = "Lexend, 'Segoe UI', system-ui, sans-serif",
      base_size = "16px",
      heading_size = "22px",
      weight = "500"
    ),
    radius = "6px",
    spacing = list(
      card_padding = "20px",
      section_gap = "20px",
      kpi_gap = "20px"
    )
  ),

  public_data_story = list(
    id = "public_data_story",
    name = "Public Data Story",
    description = "Public-facing theme. Warmer palette, accessible contrast, plain language.",
    colors = list(
      primary = "#9B2743",
      secondary = "#374151",
      accent_blue = "#3B82F6",
      accent_teal = "#0D9488",
      bg_page = "#FAFAF9",
      bg_card = "#FFFFFF",
      border = "#E5E7EB",
      text = "#111827",
      text_muted = "#6B7280",
      success = "#059669",
      warning = "#D97706",
      danger = "#DC2626"
    ),
    typography = list(
      font_family = "Lexend, Georgia, serif",
      base_size = "16px",
      heading_size = "24px",
      weight = "400"
    ),
    radius = "10px",
    spacing = list(
      card_padding = "20px",
      section_gap = "24px",
      kpi_gap = "20px"
    )
  ),

  technical_analyst = list(
    id = "technical_analyst",
    name = "Technical Analyst",
    description = "Internal QA theme. Denser layout, smaller radius, data-heavy views.",
    colors = list(
      primary = "#6B7280",
      secondary = "#1F2933",
      accent_blue = "#3B82F6",
      accent_teal = "#0D9488",
      bg_page = "#F3F4F6",
      bg_card = "#FFFFFF",
      border = "#D1D5DB",
      text = "#111827",
      text_muted = "#6B7280",
      success = "#059669",
      warning = "#D97706",
      danger = "#DC2626"
    ),
    typography = list(
      font_family = "'Cascadia Code', 'Fira Code', 'Consolas', monospace",
      base_size = "13px",
      heading_size = "15px",
      weight = "400"
    ),
    radius = "4px",
    spacing = list(
      card_padding = "10px",
      section_gap = "10px",
      kpi_gap = "10px"
    )
  )
)
