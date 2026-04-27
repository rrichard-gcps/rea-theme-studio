# Metric Registry
# K-12 Dashboard Architect
# Each metric is a named list of metadata for K-12 dashboard indicators.

metric_registry <- list(
  enrollment = list(
    id = "enrollment",
    label = "Total Enrollment",
    short_label = "Enrollment",
    unit = "count",
    format = "comma",
    description = "Headcount of enrolled students as of the official count date.",
    higher_is_good = TRUE
  ),

  school_count = list(
    id = "school_count",
    label = "Number of Schools",
    short_label = "Schools",
    unit = "count",
    format = "comma",
    description = "Count of schools in the selected scope.",
    higher_is_good = FALSE
  ),

  chronic_absenteeism = list(
    id = "chronic_absenteeism",
    label = "Chronic Absenteeism Rate",
    short_label = "Chron. Absent.",
    unit = "percent",
    format = "pct1",
    description = "Percentage of students missing 10% or more of enrolled school days.",
    higher_is_good = FALSE
  ),

  mobility_rate = list(
    id = "mobility_rate",
    label = "Student Mobility Rate",
    short_label = "Mobility",
    unit = "percent",
    format = "pct1",
    description = "Measure of student movement into or out of a school during the reporting period.",
    higher_is_good = FALSE
  ),

  reading_on_grade_level = list(
    id = "reading_on_grade_level",
    label = "Reading on Grade Level",
    short_label = "Reading GL",
    unit = "percent",
    format = "pct1",
    description = "Percentage of students meeting the grade-level reading benchmark.",
    higher_is_good = TRUE
  ),

  proficient_distinguished = list(
    id = "proficient_distinguished",
    label = "% Proficient/Distinguished",
    short_label = "%P/D",
    unit = "percent",
    format = "pct1",
    description = "Percentage of tested students scoring Proficient Learner or Distinguished Learner.",
    higher_is_good = TRUE
  ),

  ccrpi_score = list(
    id = "ccrpi_score",
    label = "CCRPI Score",
    short_label = "CCRPI",
    unit = "score",
    format = "num1",
    description = "College and Career Ready Performance Index single-digit accountability score.",
    higher_is_good = TRUE
  ),

  graduation_rate = list(
    id = "graduation_rate",
    label = "Graduation Rate",
    short_label = "Grad. Rate",
    unit = "percent",
    format = "pct1",
    description = "Four-year adjusted cohort graduation rate.",
    higher_is_good = TRUE
  ),

  discipline_incident_rate = list(
    id = "discipline_incident_rate",
    label = "Discipline Incident Rate",
    short_label = "Discipline",
    unit = "percent",
    format = "pct2",
    description = "Number of discipline incidents per 100 students.",
    higher_is_good = FALSE
  ),

  teacher_retention = list(
    id = "teacher_retention",
    label = "Teacher Retention Rate",
    short_label = "Teacher Ret.",
    unit = "percent",
    format = "pct1",
    description = "Percentage of teachers returning year-over-year.",
    higher_is_good = TRUE
  )
)
