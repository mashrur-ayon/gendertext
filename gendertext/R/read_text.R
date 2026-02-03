#' Read text from a file (txt, pdf, docx, etc.)
#'
#' Uses \pkg{readtext} to import text from common document formats.
#'
#' @param path Character. Path to the file.
#'
#' @return A single character string containing the extracted text.
#' @export
#'
#' @examples
#' \dontrun{
#' read_text("myfile.pdf")
#' }
read_text <- function(path) {
  if (!is.character(path) || length(path) != 1) {
    stop("`path` must be a single character string.")
  }
  if (!file.exists(path)) {
    stop("File does not exist: ", path)
  }
  
  x <- readtext::readtext(path)
  
  # readtext returns a data.frame with a $text column
  txt <- x$text
  if (length(txt) == 0 || is.na(txt)) {
    txt <- ""
  }
  
  txt <- paste(txt, collapse = "\n")
  txt
}
