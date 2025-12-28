new_issue <- function(year = "2025", issue = "01", overwrite = FALSE) {
  
  stopifnot(
    is.character(year), length(year) == 1,
    is.character(issue), length(issue) == 1
  )
  
  issue_dir <- file.path("issues", year, issue)
  
  if (dir.exists(issue_dir) && !overwrite) {
    stop(
      "Issue directory already exists: ", issue_dir,
      "\nSet overwrite = TRUE to recreate it."
    )
  }
  
  if (overwrite && dir.exists(issue_dir)) {
    unlink(issue_dir, recursive = TRUE, force = TRUE)
  }
  
  # --- create directory structure ----
  
  dir.create(issue_dir, recursive = TRUE, showWarnings = FALSE)
  
  img_dir <- file.path(issue_dir, "img")
  doc_dir <- file.path(issue_dir, "doc")
  summarize_dir <- file.path(issue_dir, "summarize")
  
  dir.create(img_dir, showWarnings = FALSE)
  dir.create(doc_dir, showWarnings = FALSE)
  dir.create(summarize_dir, showWarnings = FALSE)
  
  file.create(file.path(img_dir, ".gitkeep"))
  file.create(file.path(doc_dir, ".gitkeep"))
  file.create(file.path(summarize_dir, ".gitkeep"))
  
  # --- copy publications ----
  
  publications_src <- file.path("template", "publications")
  publications_dst <- file.path(issue_dir, "publications")
  
  if (!dir.exists(publications_src)) {
    stop("publications directory not found at: ", publications_src)
  }
  
  dir.create(publications_dst, showWarnings = FALSE)
  
  files <- list.files(
    publications_src,
    full.names = TRUE,
    recursive = FALSE
  )
  
  if (length(files) == 0L) {
    stop("publications directory is empty: ", publications_src)
  }
  
  ok <- file.copy(
    from = files,
    to   = publications_dst
  )
  
  if (!all(ok)) {
    stop("Failed to copy one or more publication files")
  }
  
  
  # --- copy and modify template ----
  
  template_path <- file.path("template", "newsletter_template.qmd")
  if (!file.exists(template_path)) {
    stop("Template not found at: ", template_path)
  }
  
  target_file <- file.path(
    issue_dir,
    paste0("newsletter_", year, "_", issue, ".qmd")
  )
  
  txt <- readLines(template_path, encoding = "UTF-8")
  
  txt <- txt |>
    gsub("^year:.*$",  paste0("year: ", year),  x = _) |>
    gsub("^issue:.*$", paste0("issue: \"", issue, "\""), x = _)
  
  writeLines(txt, target_file, useBytes = TRUE)
  
  message("Created issue: ", target_file)
  invisible(target_file)
}

