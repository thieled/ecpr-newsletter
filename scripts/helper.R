
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




new_issue <- function(year = "2025", issue = "01", toc = TRUE) {
  
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
    stop("Template not found: ", template_path)
  }
  
  target_file <- file.path(
    issue_dir,
    paste0("newsletter_", year, "_", issue, ".qmd")
  )
  
  txt <- readLines(template_path, encoding = "UTF-8")
  
  txt <- gsub("^year:.*$",  paste0("year: ", year),  txt)
  txt <- gsub("^issue:.*$", paste0("issue: \"", issue, "\""), txt)
  
  if (!toc) {
    txt <- txt[!grepl("<!--TOC_START-->|<!--TOC_END-->", txt)]
  }
  
  writeLines(txt, target_file, useBytes = TRUE)
  
  invisible(target_file)
}



inline_issue <- function(year = "2025", issue = "01", toc = TRUE) {
  
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
  html <- readr::read_file(html_file)
  
  if (toc && grepl("<!--TOC_START-->", html, fixed = TRUE)) {
    
    doc <- xml2::read_html(html)
    h2 <- xml2::xml_find_all(doc, "//h2[@id]")
    
    if (length(h2) > 1) {
      ids  <- vapply(h2[-1], xml2::xml_attr, character(1), "id")
      text <- vapply(h2[-1], xml2::xml_text, character(1))
      
      items <- paste0(
        "<li><a href=\"#", ids, "\">", text, "</a></li>",
        collapse = ""
      )
      
      toc_html <- paste0(
        "<div class=\"toc-section\">",
        "<h3>Table of Contents</h3>",
        "<ul>", items, "</ul>",
        "</div>"
      )
    } else {
      toc_html <- ""
    }
    
    html <- sub(
      "<!--TOC_START-->.*<!--TOC_END-->",
      toc_html,
      html,
      fixed = FALSE
    )
  } else {
    html <- gsub("<!--TOC_START-->|<!--TOC_END-->", "", html)
  }
  
  html <- juicyjuice::css_inline(html)
  readr::write_file(html, html_file)
  
  invisible(html_file)
}


# Apply -------------------------------------------------------------------

new_issue(year = "2025", issue = "13")

inline_issue(year = "2025", issue = "13")
