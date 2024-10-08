#' Read and Extract Text from a File
#'
#' This function reads and extracts text from a provided text, PDF, or Word document file.
#'
#' @param file_path A character string specifying the path to the file.
#' @return A character string containing the extracted text.
#' @examples
#' # Example usage:
#' # text_content <- read_file("path/to/your/document.txt")
#' @importFrom pdftools pdf_text
#' @importFrom readtext readtext
#' @importFrom stringr str_c
#' @export
read_file <- function(file_path) {

  # Check if the file exists
  if (!file.exists(file_path)) {
    stop("The specified file does not exist.")
  }

  # Determine the file extension
  file_extension <- tools::file_ext(file_path)

  # Read and extract text based on the file type
  text_content <- switch(tolower(file_extension),
                         "txt" = readLines(file_path, warn = FALSE),
                         "pdf" = pdftools::pdf_text(file_path),
                         "docx" = readtext::readtext(file_path)$text,
                         stop("Unsupported file type. Please provide a .txt, .pdf, or .docx file."))

  # Collapse the text into a single string
  return(stringr::str_c(text_content, collapse = " "))
}
