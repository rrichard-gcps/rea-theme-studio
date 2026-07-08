# =============================================================================
# R/gcps_palette_data.R — GCPS Palette Library source data
# Mirrors palette-library/palette-data.js. Self-contained (no CSV read needed),
# so it deploys cleanly to Posit Connect. Norcross uses the XML navy #1D2252
# (the cluster CSV's #CCCCCC is a placeholder).
# =============================================================================

# 7 GCPS analytics bases — Prompt design tokens (anchor + 6 primaries) ---------
GCPS_BASE <- c(
  maroon = "#660000", ocean = "#2D708E", forest = "#297864", sienna = "#C0593C",
  amethyst = "#715981", goldenrod = "#D19C2F", slate = "#5B6D7A"
)
BASE_ORDER <- names(GCPS_BASE)

# Prompt neutrals (surface anchors, not chart hues) --------------------------
GCPS_NEUTRALS <- c(light = "#F4F4F6", dark = "#2A2A2E")

# diverging partner per base (paired by opposite temperature) ----------------
DIVERGE_PAIR <- c(
  maroon = "ocean", ocean = "sienna", forest = "amethyst", sienna = "ocean",
  amethyst = "forest", goldenrod = "ocean", slate = "maroon"
)

# Curated GCPS qualitative palette (gcps_viz_palette_test from the Tableau lib)
GCPS_QUALITATIVE <- c(
  "#374E8E", "#4FBBAE", "#DF7C18", "#AC004F", "#1B87AA",
  "#E3B13E", "#CE4631", "#8D7A81", "#7E7E8F"
)

# Prompt fixed-identity qualitative categories (consistent order, capped length)
CAT_RACE_COLORS <- c("#2D708E", "#C0593C", "#297864", "#D19C2F", "#715981", "#5B6D7A")
CAT_RACE_NAMES  <- c("Asian", "Black", "Hispanic", "American Indian", "Multiracial", "White")
CAT_SCHOOL_COLORS <- c("#4E95B8", "#489E88", "#D87A60", "#8D779C")
CAT_SCHOOL_NAMES  <- c("Elementary", "Middle", "High", "Special School")

# 21 cluster brand colors (cluster_colors_and_logos.csv + GCPS Clusters XML) --
CLUSTERS <- c(
  "Archer" = "#CC3333", "Berkmar" = "#003366", "Brookwood" = "#660000",
  "Central Gwinnett" = "#FFCC33", "Collins Hill" = "#336633", "Dacula" = "#CCCC99",
  "Discovery" = "#66CC33", "Duluth" = "#330066", "Grayson" = "#336633",
  "Lanier" = "#CC6600", "Meadowcreek" = "#6699CC", "Mill Creek" = "#993333",
  "Mountain View" = "#CCCC66", "Norcross" = "#1D2252", "North Gwinnett" = "#CC3333",
  "Parkview" = "#FF6633", "Peachtree Ridge" = "#000066", "Seckinger" = "#0099CC",
  "Shiloh" = "#000000", "South Gwinnett" = "#000033", "Special Entity" = "#CCCCCC"
)
CLUSTER_ORDER <- names(CLUSTERS)

# all-clusters categorical (dedupe identical hexes) --------------------------
ALL_CLUSTERS_CAT <- unique(unname(CLUSTERS))

# color-theory harmony hue offsets (degrees) --------------------------------
HARMONY <- list(
  analogous     = c(0, 30, -30, 60, -60, 90, -90, 45),
  complementary = c(0, 180, 30, 210, -30, 150, 60, 240),
  split         = c(0, 150, 210, 30, 330, 180, 75, 285),
  triadic       = c(0, 120, 240, 60, 180, 300, 30, 210),
  tetradic      = c(0, 90, 180, 270, 45, 135, 225, 315),
  qualitative   = c(0, 51, 103, 154, 206, 257, 309, 26)
)

# performance level names ----------------------------------------------------
PERF_NAMES <- list(
  `4` = c("Beginning", "Developing", "Proficient", "Distinguished"),
  `5` = c("Beginning", "Developing", "Approaching", "Proficient", "Distinguished"),
  `6` = c("Entering", "Beginning", "Developing", "Expanding", "Bridging", "Reaching")
)

# School -> serving cluster (DimSchool.csv "Cluster"; NA -> Special Entity) ---
SCHOOL_CLUSTER <- c(
  "Alcova ES"="Dacula","Alford ES"="Discovery","Anderson-Livsey ES"="Shiloh","Annistown ES"="Shiloh",
  "Arcado ES"="Parkview","Baggett ES"="Discovery","Baldwin ES"="Norcross","Beaver Ridge ES"="Norcross",
  "Benefield ES"="Discovery","Berkeley Lake ES"="Duluth","Bethesda ES"="Berkmar","Britt ES"="South Gwinnett",
  "Brookwood ES"="Brookwood","Burnette ES"="Peachtree Ridge","Camp Creek ES"="Parkview","Cedar Hill ES"="Discovery",
  "Centerville ES"="Shiloh","Chattahoochee ES"="Duluth","Chesney ES"="Duluth","Cooper ES"="Archer",
  "Corley ES"="Berkmar","Craig ES"="Brookwood","Dacula ES"="Dacula","Duncan Creek ES"="Mill Creek",
  "Dyer ES"="Mountain View","Ferguson ES"="Meadowcreek","Fort Daniel ES"="Mill Creek","Freeman's Mill ES"="Mountain View",
  "Graves ES"="Meadowcreek","Grayson ES"="Grayson","Gwin Oaks ES"="Brookwood","Harbins ES"="Archer",
  "Harmony ES"="Seckinger","Harris ES"="Duluth","Head ES"="Brookwood","Hopkins ES"="Berkmar",
  "Ivy Creek ES"="Seckinger","Jackson ES"="Peachtree Ridge","Jenkins ES"="Central Gwinnett","Kanoheda ES"="Berkmar",
  "Knight ES"="Parkview","Lawrenceville ES"="Central Gwinnett","Level Creek ES"="North Gwinnett","Lilburn ES"="Meadowcreek",
  "Lovin ES"="Archer","Magill ES"="South Gwinnett","Mason ES"="Peachtree Ridge","McKendree ES"="Collins Hill",
  "Meadowcreek ES"="Meadowcreek","Minor ES"="Berkmar","Mountain Park ES"="Parkview","Mulberry ES"="Dacula",
  "Nesbit ES"="Meadowcreek","Norcross ES"="Norcross","North Metro Academy"="Norcross","Norton ES"="South Gwinnett",
  "Parsons ES"="Peachtree Ridge","Partee ES"="Shiloh","Patrick ES"="Seckinger","Peachtree ES"="Norcross",
  "Pharr ES"="Grayson","Puckett's Mill ES"="Mill Creek","Riverside ES"="North Gwinnett","Roberts ES"="North Gwinnett",
  "Rock Springs ES"="Collins Hill","Rockbridge ES"="Meadowcreek","Rosebud ES"="South Gwinnett","Shiloh ES"="Shiloh",
  "Simonton ES"="Central Gwinnett","Simpson ES"="Norcross","Starling ES"="Grayson","Stripling ES"="Norcross",
  "Sugar Hill ES"="Lanier","Suwanee ES"="North Gwinnett","Sycamore ES"="Lanier","Taylor ES"="Collins Hill",
  "Trip ES"="Grayson","Walnut Grove ES"="Collins Hill","White Oak ES"="Lanier","Winn Holt ES"="Central Gwinnett",
  "Woodward Mill ES"="Mountain View",
  "Bay Creek MS"="Grayson","Berkmar MS"="Berkmar","Coleman MS"="Duluth","Couch MS"="Grayson",
  "Creekland MS"="Collins Hill","Crews MS"="Brookwood","Dacula MS"="Dacula","Duluth MS"="Duluth",
  "Five Forks MS"="Brookwood","Grace Snell MS"="South Gwinnett","Hull MS"="Peachtree Ridge","Jones MS"="Seckinger",
  "Jordan MS"="Central Gwinnett","Lanier MS"="Lanier","Lilburn MS"="Meadowcreek","McConnell MS"="Archer",
  "Moore MS"="Central Gwinnett","North Gwinnett MS"="North Gwinnett","Northbrook MS"="Peachtree Ridge","Osborne MS"="Mill Creek",
  "Pinckneyville MS"="Norcross","Radloff MS"="Meadowcreek","Richards MS"="Discovery","Shiloh MS"="Shiloh",
  "Snellville MS"="South Gwinnett","Summerour MS"="Norcross","Sweetwater MS"="Berkmar","Trickum MS"="Parkview",
  "Twin Rivers MS"="Mountain View",
  "Archer HS"="Archer","Berkmar HS"="Berkmar","Brookwood HS"="Brookwood","Central Gwinnett HS"="Central Gwinnett",
  "Collins Hill HS"="Collins Hill","Dacula HS"="Dacula","Discovery HS"="Discovery","Duluth HS"="Duluth",
  "GSMST"="Discovery","Grayson HS"="Grayson","Lanier HS"="Lanier","McClure Health Science HS"="Meadowcreek",
  "Meadowcreek HS"="Meadowcreek","Mill Creek HS"="Mill Creek","Mountain View HS"="Mountain View","Norcross HS"="Norcross",
  "North Gwinnett HS"="North Gwinnett","Parkview HS"="Parkview","Paul Duke STEM HS"="Norcross","Peachtree Ridge HS"="Peachtree Ridge",
  "Seckinger HS"="Seckinger","Shiloh HS"="Shiloh","South Gwinnett HS"="South Gwinnett",
  "Buice Center"="Special Entity","Devereux - GCPS"="Special Entity","GIVE East"="Mountain View","GIVE West"="Norcross",
  "GOC"="Special Entity","Grayson Tech"="Special Entity","ITC"="Special Entity","Maxwell HS"="Discovery",
  "Oakland Meadow"="Central Gwinnett","Phoenix HS"="Central Gwinnett","New Life Academy"="Duluth"
)
SCHOOL_ORDER <- sort(names(SCHOOL_CLUSTER))
