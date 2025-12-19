
# Helper to create folders and qmd for a specific issue -------------------


new_issue <- function(year = "2025", issue = "01") {
  
  issue_dir <- file.path("issues", year, issue)
  
  if (!dir.exists(issue_dir)) {
    dir.create(issue_dir, recursive = TRUE, showWarnings = FALSE)
  }
  
  img_dir <- file.path(issue_dir, "img")
  doc_dir <- file.path(issue_dir, "doc")
  
  if (!dir.exists(img_dir)) dir.create(img_dir, showWarnings = FALSE)
  if (!dir.exists(doc_dir)) dir.create(doc_dir, showWarnings = FALSE)
  
  template_path <- file.path("template", "newsletter_template.qmd")
  if (!file.exists(template_path)) {
    stop("Template not found at ", template_path)
  }
  
  target_file <- file.path(
    issue_dir,
    paste0("newsletter_", year, "_", issue, ".qmd")
  )
  
  txt <- readLines(template_path, encoding = "UTF-8")
  
  txt <- txt |>
    gsub("^year:.*$",  paste0("year: ", year),  x = _) |>
    gsub("^issue:.*$", paste0("issue: ", issue), x = _)
  
  writeLines(txt, target_file, useBytes = TRUE)
  
  invisible(target_file)
}



# Helper function to Inline .css in a specific issue  ---------------------

inline_issue <- function(year = "2025", issue = "01") {
  
  issue_dir <- file.path("issues", year, issue)
  
  qmd_file <- file.path(
    issue_dir,
    paste0("newsletter_", year, "_", issue, ".qmd")
  )
  
  if (!file.exists(qmd_file)) {
    stop("QMD file not found: ", qmd_file)
  }
  
  # Render with Quarto
  quarto::quarto_render(qmd_file, quiet = TRUE)
  
  html_file <- sub("\\.qmd$", ".html", qmd_file)
  
  if (!file.exists(html_file)) {
    stop("Rendered HTML not found: ", html_file)
  }
  
  # Inline CSS
  html <- readr::read_file(html_file)
  html <- juicyjuice::css_inline(html)
  
  readr::write_file(html, html_file)
  
  invisible(html_file)
}


# Apply -------------------------------------------------------------------

new_issue(year = "2025", issue = "12")

inline_issue(year = "2025", issue = "12")
