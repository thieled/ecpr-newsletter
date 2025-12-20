crop_image_action <- function(
    input_path,
    output_path = "",
    offset_x_adj = 0,
    offset_y_adj = 0
) {
  # --- sanitize inputs (critical for GitHub UI) ----
  input_path  <- trimws(input_path)
  input_path  <- gsub("[\r\n]", "", input_path)
  
  output_path <- trimws(output_path)
  output_path <- gsub("[\r\n]", "", output_path)
  
  if (!file.exists(input_path)) {
    stop("Input image does not exist: '", input_path, "'")
  }
  
  # --- determine output path ----
  if (!nzchar(output_path)) {
    base <- tools::file_path_sans_ext(input_path)
    output_path <- paste0(base, "_sq.png")
  }
  
  # ensure output dir exists
  out_dir <- dirname(output_path)
  if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  }
  
  # --- crop ----
  crop_to_square(
    image_path   = input_path,
    output_path  = output_path,
    offset_x_adj = offset_x_adj,
    offset_y_adj = offset_y_adj
  )
  
  message("Saved cropped image: ", output_path)
  invisible(output_path)
}
