# Demo Data K-12
# K-12 Dashboard Architect
# Deterministic fake data for preview rendering.
# All values are hardcoded. No random values.

# ── KPI Values (one per metric) ──────────────────────────────────────────

demo_kpi_values <- list(
  enrollment = list(
    value = 82453,
    label = "Total Enrollment",
    change = 1.2,
    direction = "up"
  ),
  school_count = list(
    value = 84,
    label = "Schools",
    change = 0.0,
    direction = "flat"
  ),
  chronic_absenteeism = list(
    value = 14.3,
    label = "Chron. Absent. %",
    change = -1.8,
    direction = "down"
  ),
  mobility_rate = list(
    value = 11.7,
    label = "Mobility Rate %",
    change = -0.5,
    direction = "down"
  ),
  reading_on_grade_level = list(
    value = 47.2,
    label = "Reading GL %",
    change = 2.1,
    direction = "up"
  ),
  proficient_distinguished = list(
    value = 41.8,
    label = "%P/D",
    change = 1.4,
    direction = "up"
  ),
  ccrpi_score = list(
    value = 76.4,
    label = "CCRPI Score",
    change = 0.8,
    direction = "up"
  ),
  graduation_rate = list(
    value = 82.6,
    label = "Graduation Rate %",
    change = 1.6,
    direction = "up"
  ),
  discipline_incident_rate = list(
    value = 3.42,
    label = "Discipline Rate",
    change = -0.3,
    direction = "down"
  ),
  teacher_retention = list(
    value = 87.1,
    label = "Teacher Ret. %",
    change = 0.4,
    direction = "up"
  )
)

# ── Schools Table ─────────────────────────────────────────────────────────

demo_schools <- tibble::tibble(
  school_name = c(
    "Cedar Hill Elementary",
    "Parkview High School",
    "Sweetwater Middle",
    "Brookwood Elementary",
    "Mountain View High",
    "Riverside Middle",
    "Meadowcrest Primary",
    "Lakeview Academy"
  ),
  level = c(
    "Elementary",
    "High",
    "Middle",
    "Elementary",
    "High",
    "Middle",
    "Primary",
    "K-12"
  ),
  enrollment = c(812, 2341, 1156, 734, 2187, 1023, 489, 1567),
  pct_pd = c(45.2, 39.8, 41.3, 52.1, 37.6, 43.7, 48.9, 40.2),
  chronic_absent = c(8.4, 16.2, 13.7, 7.1, 17.8, 14.2, 6.3, 12.9),
  ccrpi = c(78.3, 72.1, 74.8, 81.6, 70.4, 76.2, 80.1, 73.5),
  promise_school = c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE)
)

# ── Trend Data (5 years) ─────────────────────────────────────────────────

demo_trend_years <- tibble::tibble(
  school_year = c("2020-21", "2021-22", "2022-23", "2023-24", "2024-25"),
  enrollment = c(79542, 80134, 81067, 81891, 82453),
  pct_pd = c(36.2, 37.8, 39.1, 40.4, 41.8),
  chronic_absent = c(18.6, 17.1, 16.2, 15.7, 14.3),
  graduation_rate = c(78.3, 79.5, 80.7, 81.2, 82.6)
)

# ── Student Groups ────────────────────────────────────────────────────────

demo_student_groups <- tibble::tibble(
  group_name = c(
    "Asian",
    "Black/African American",
    "Hispanic/Latino",
    "Multiracial",
    "White",
    "Economically Disadvantaged"
  ),
  enrollment = c(8240, 25430, 18970, 6810, 20050, 38920),
  pct_pd = c(58.2, 32.4, 35.7, 44.1, 48.3, 30.8),
  gap_vs_district = c(16.4, -9.4, -6.1, 2.3, 6.5, -11.0)
)

# ── BOE Area Summary ─────────────────────────────────────────────────────

demo_boe_area <- list(
  area_id = 3,
  area_name = "BOE District 3",
  board_member = "Jane Rivera",
  school_count = 12,
  enrollment = 14823,
  pct_pd = 43.1,
  chronic_absent = 12.8,
  graduation_rate = 81.4,
  map_center_lat = 33.96,
  map_center_lon = -84.14,
  map_zoom = 11,
  schools = tibble::tibble(
    school_name = c(
      "Cedar Hill Elementary",
      "Sweetwater Middle",
      "Parkview High School",
      "Brookwood Elementary",
      "Mountain View High",
      "Meadowcrest Primary"
    ),
    lat = c(33.951, 33.968, 33.942, 33.978, 33.937, 33.960),
    lon = c(-84.130, -84.145, -84.152, -84.118, -84.160, -84.138),
    level = c("Elementary", "Middle", "High", "Elementary", "High", "Primary"),
    enrollment = c(812, 1156, 2341, 734, 2187, 489),
    pct_pd = c(45.2, 41.3, 39.8, 52.1, 37.6, 48.9)
  ),
  source_note = "Source: GA DOE Student Record System (SRS), Fall 2024 FTE Count. Data as of October 2024.",
  methodology_note = "Chronic absenteeism defined as missing 10% or more of enrolled days. %P/D reflects Georgia Milestones Proficient Learner and Distinguished Learner combined.",
  refresh_date = "October 2024",
  disclosure_note = "Cell sizes below 10 are suppressed. All data uses synthetic values for preview purposes."
)
