crop_to_square <- function(image_path, output_path = NULL, 
                           offset_x_adj = 0, offset_y_adj = 0) {
  # Read the image
  img <- magick::image_read(image_path)
  
  # Get image dimensions
  info <- magick::image_info(img)
  width <- info$width
  height <- info$height
  
  # Determine crop size (smallest of width or height)
  crop_size <- min(width, height)
  
  # Calculate offsets to center the crop
  offset_x <- floor((width - crop_size) / 2) + offset_x_adj
  offset_y <- floor((height - crop_size) / 2) + offset_y_adj
  
  # Ensure offsets keep crop inside image bounds
  offset_x <- max(0, min(offset_x, width - crop_size))
  offset_y <- max(0, min(offset_y, height - crop_size))
  
  # Crop to square using center + adjustment
  cropped_img <- magick::image_crop(
    img,
    geometry = paste0(crop_size, "x", crop_size, "+", offset_x, "+", offset_y)
  )
  
  # Save as PNG
  if (!is.null(output_path)) {
    if (!grepl("\\.png$", output_path, ignore.case = TRUE)) {
      output_path <- sub("\\.[^.]*$", ".png", output_path)
    }
    magick::image_write(cropped_img, path = output_path, format = "png")
  }
  
  return(cropped_img)
}


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


