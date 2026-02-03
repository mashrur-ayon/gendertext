#' Gender-Neutral Suggestions for Detected Gendered Terms
#'
#' Identifies gendered terms/phrases found in text (or in a file) using the package dataset
#' \code{gender_dictionary}, and returns suggested gender-neutral alternatives. Optionally includes
#' counts of occurrences.
#'
#' @param text A character string containing the text to analyse. Optional if \code{path} is provided.
#' @param path A character string specifying a file path (\code{.txt}, \code{.pdf}, \code{.docx}, etc.).
#'   Optional if \code{text} is provided.
#' @param include_counts Logical; if \code{TRUE} (default), includes the number of occurrences found
#'   for each detected gendered term.
#'
#' @return A tibble with:
#' \describe{
#'   \item{gendered}{Detected gendered term/phrase from the dictionary.}
#'   \item{suggested_neutral}{Suggested gender-neutral replacement.}
#'   \item{count}{Number of occurrences in the text (if \code{include_counts = TRUE}).}
#' }
#'
#' @examples
#' gender_suggestions(text = "Our chairman said he will email the mailman.")
#'
#' \dontrun{
#' txt <- system.file("extdata", "test.txt", package = "gendertext")
#' gender_suggestions(path = txt)
#' }
#'
#' @export
gender_suggestions <- function(text = NULL, path = NULL, include_counts = TRUE) {

  if (is.null(text) && is.null(path)) {
    stop("Provide either `text` or `path`.", call. = FALSE)
  }
  if (!is.null(path)) {
    if (!is.character(path) || length(path) != 1L || is.na(path)) {
      stop("`path` must be a single, non-missing character string.", call. = FALSE)
    }
    text <- read_text(path)
  }
  if (!is.character(text) || length(text) != 1L) {
    stop("`text` must be a single character string.", call. = FALSE)
  }
  if (!is.logical(include_counts) || length(include_counts) != 1L || is.na(include_counts)) {
    stop("`include_counts` must be TRUE or FALSE.", call. = FALSE)
  }

  data("gender_dictionary", package = "gendertext", envir = environment())

  txt <- tolower(text)
  txt <- stringr::str_replace_all(txt, "[^a-z\\s']", " ")
  txt <- stringr::str_squish(txt)

  if (nchar(txt) == 0L) {
    out <- tibble::tibble(
      gendered = character(),
      suggested_neutral = character(),
      count = integer()
    )
    if (!include_counts) {
      out <- dplyr::select(out, .data$gendered, .data$suggested_neutral)
    }
    return(out)
  }

  dict <- gender_dictionary
  found <- vector("list", length = 0L)

  for (i in seq_len(nrow(dict))) {

    g <- dict$gendered[i]
    n <- dict$neutral[i]

    if (stringr::str_detect(g, "\\s+")) {
      pattern <- paste0("\\b", stringr::str_replace_all(g, "\\s+", "\\\\s+"), "\\b")
      k <- stringr::str_count(txt, pattern)
    } else {
      pattern <- paste0("\\b", g, "\\b")
      k <- stringr::str_count(txt, pattern)
    }

    if (k > 0L) {
      found[[length(found) + 1L]] <- tibble::tibble(
        gendered = g,
        suggested_neutral = n,
        count = as.integer(k)
      )
    }
  }

  if (length(found) == 0L) {
    out <- tibble::tibble(
      gendered = character(),
      suggested_neutral = character(),
      count = integer()
    )
  } else {
    out <- dplyr::bind_rows(found) |>
      dplyr::arrange(dplyr::desc(.data$count), .data$gendered)
  }

  if (!include_counts) {
    out <- dplyr::select(out, .data$gendered, .data$suggested_neutral)
  }

  out
}
