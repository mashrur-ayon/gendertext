#' Read Text from a File
#'
#' Reads text content from common document formats (e.g., \code{.txt}, \code{.pdf}, \code{.docx})
#' using \pkg{readtext}. This function is intended to provide a single, normalised character string
#' for downstream analysis in \code{\link{gender_score}} and \code{\link{gender_suggestions}}.
#'
#' @param path A character string specifying the path to a file. The file must exist.
#'
#' @return A length-1 character string containing the extracted text.
#'
#' @examples
#' \dontrun{
#' txt <- system.file("extdata", "test.txt", package = "gendertext")
#' pdf <- system.file("extdata", "test.pdf", package = "gendertext")
#' read_text(txt)
#' read_text(pdf)
#' }
#' @export
read_text <- function(path) {

  if (!is.character(path) || length(path) != 1L || is.na(path)) {
    stop("`path` must be a single, non-missing character string.", call. = FALSE)
  }
  if (!file.exists(path)) {
    stop("File does not exist: ", path, call. = FALSE)
  }

  x <- readtext::readtext(path)

  # `readtext()` returns a data.frame with a `$text` column
  txt <- x$text
  if (length(txt) == 0L || all(is.na(txt))) {
    return("")
  }

  txt <- paste(txt[!is.na(txt)], collapse = "\n")
  txt
}
