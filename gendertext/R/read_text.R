#' Read Text from a File
#'
#' Reads text content from a document and returns it as a single character
#' string for downstream analysis in [gender_score()], [gender_suggestions()],
#' and [gender_replace()]. Plain text files (extensions txt, text, md, and
#' rmd) are read with base R. Other formats such as pdf, docx, rtf, odt,
#' csv, and json are read with the suggested 'readtext' package when it is
#' installed.
#'
#' @param path A character string giving the path to a file. The file must
#'   exist.
#'
#' @return A length one character string containing the extracted text.
#'
#' @seealso [gender_score()], [gender_suggestions()], [gender_replace()]
#'
#' @examples
#' txt <- system.file("extdata", "test.txt", package = "gendertext")
#' substr(read_text(txt), 1, 60)
#'
#' if (requireNamespace("readtext", quietly = TRUE)) {
#'   pdf <- system.file("extdata", "test.pdf", package = "gendertext")
#'   substr(read_text(pdf), 1, 60)
#' }
#' @export
read_text <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path)) {
    stop("`path` must be a single, non-missing character string.", call. = FALSE)
  }
  if (!file.exists(path)) {
    stop("File does not exist: ", path, call. = FALSE)
  }

  ext <- tolower(sub(".*\\.", "", basename(path)))
  plain <- c("txt", "text", "md", "rmd")

  if (ext %in% plain || !grepl(".", basename(path), fixed = TRUE)) {
    lines <- readLines(path, encoding = "UTF-8", warn = FALSE)
    return(paste(lines, collapse = "\n"))
  }

  if (!requireNamespace("readtext", quietly = TRUE)) {
    stop("Reading '.", ext, "' files requires the 'readtext' package. ",
         "Install it with install.packages(\"readtext\") or supply a ",
         "plain text file.", call. = FALSE)
  }

  x <- readtext::readtext(path)
  txt <- x$text
  if (length(txt) == 0L || all(is.na(txt))) {
    return("")
  }
  paste(txt[!is.na(txt)], collapse = "\n")
}
