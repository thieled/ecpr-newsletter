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


# Use ---------------------------------------------------------------------

crop_to_square(image_path = "assets/banners/ecr_club.png", 
               output_path = "assets/banners/ecr_club_testsq.png", offset_x_adj = 150)

