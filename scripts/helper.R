
# Helper to create folders and qmd for a specific issue -------------------


new_issue <- function(year = "2025", issue = "01") {
  
  issue_dir <- file.path("issues", year, issue)
  
  if (!dir.exists(issue_dir)) {
    dir.create(issue_dir, recursive = TRUE, showWarnings = FALSE)
  }
  
  img_dir <- file.path(issue_dir, "img")
  doc_dir <- file.path(issue_dir, "doc")
  
  if (!dir.exists(img_dir)) {
    dir.create(img_dir, showWarnings = FALSE)
    file.create(file.path(img_dir, ".gitkeep"))
  }
  
  if (!dir.exists(doc_dir)) {
    dir.create(doc_dir, showWarnings = FALSE)
    file.create(file.path(doc_dir, ".gitkeep"))
  }
  
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




inline_issue <- function(year = "2025", issue = "01") {
  
  issue_dir <- file.path("issues", year, issue)
  
  qmd_file <- file.path(
    issue_dir,
    paste0("newsletter_", year, "_", issue, ".qmd")
  )
  
  if (!file.exists(qmd_file)) {
    stop("QMD file not found: ", qmd_file)
  }
  
  quarto::quarto_render(qmd_file, quiet = TRUE)
  
  html_file <- sub("\\.qmd$", ".html", qmd_file)
  if (!file.exists(html_file)) {
    stop("Rendered HTML not found: ", html_file)
  }
  
  html <- readr::read_file(html_file)
  
  # Build mini TOC from H2 headings (skip first H2 = main headline)
  doc <- xml2::read_html(html)
  
  h2_nodes <- xml2::xml_find_all(doc, "//h2[@id]")
  if (length(h2_nodes) >= 2) {
    ids <- vapply(h2_nodes, xml2::xml_attr, character(1), "id")
    txt <- vapply(h2_nodes, xml2::xml_text, character(1))
    
    ids <- ids[-1]
    txt <- txt[-1]
    
    toc_rows <- paste0(
      "<tr>",
      "<td><a href=\"#", ids, "\">", txt, "</a></td>",
      "</tr>"
    )
    
    toc_html <- paste0(
      "<div class=\"mini-toc\">",
      "<table role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\">",
      paste(toc_rows, collapse = ""),
      "</table>",
      "</div>"
    )
  } else {
    toc_html <- ""
  }
  
  if (!grepl("<!--MINI_TOC-->", html, fixed = TRUE)) {
    stop("Placeholder <!--MINI_TOC--> not found in HTML. Add it under the first headline.")
  }
  
  html <- sub("<!--MINI_TOC-->", toc_html, html, fixed = TRUE)
  
  # Inline CSS (your correct juicyjuice function)
  html <- juicyjuice::inline_css(html)
  
  readr::write_file(html, html_file)
  
  invisible(html_file)
}


# Apply -------------------------------------------------------------------

new_issue(year = "2025", issue = "13")

inline_issue(year = "2025", issue = "13")
