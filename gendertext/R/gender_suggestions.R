#' Gender Neutral Suggestions for Detected Gendered Terms
#'
#' Identifies the gendered terms and phrases that occur in a text or in a
#' file, using the built in dictionary [gender_dictionary] or a user
#' supplied dictionary, and returns the suggested gender neutral
#' alternative for each detected term, optionally with occurrence counts.
#'
#' @param text A character string containing the text to analyse. Optional
#'   if \code{path} is provided.
#' @param path A character string giving a file path (txt, pdf, docx, and
#'   other formats supported by [read_text()]). Optional if \code{text} is
#'   provided.
#' @param include_counts Logical; if \code{TRUE} (default), the result
#'   includes the number of occurrences found for each detected term.
#' @param dictionary Optional data frame with character columns
#'   \code{gendered} and \code{neutral} to use instead of the built in
#'   [gender_dictionary].
#'
#' @return A data frame with one row per detected term, sorted by
#'   decreasing count and then alphabetically:
#' \describe{
#'   \item{gendered}{Detected gendered term or phrase from the dictionary.}
#'   \item{suggested_neutral}{Suggested gender neutral replacement.}
#'   \item{count}{Number of occurrences in the text (only when
#'     \code{include_counts = TRUE}).}
#' }
#'
#' @seealso [gender_score()] for an overall share, [gender_replace()] to
#'   apply the suggestions, and [gender_dictionary] for the built in
#'   dictionary.
#'
#' @examples
#' gender_suggestions(text = "Our chairman said he will email the mailman.")
#'
#' # Without counts
#' gender_suggestions(
#'   text = "The fireman and the policeman arrived.",
#'   include_counts = FALSE
#' )
#'
#' # Analyse a file shipped with the package
#' txt <- system.file("extdata", "test.txt", package = "gendertext")
#' head(gender_suggestions(path = txt))
#'
#' @export
gender_suggestions <- function(text = NULL, path = NULL,
                               include_counts = TRUE,
                               dictionary = NULL) {
  if (is.null(text) && is.null(path)) {
    stop("Provide either `text` or `path`.", call. = FALSE)
  }
  if (!is.null(path)) {
    text <- read_text(path)
  }
  if (!is.character(text) || length(text) != 1L || is.na(text)) {
    stop("`text` must be a single, non-missing character string.", call. = FALSE)
  }
  if (!is.logical(include_counts) || length(include_counts) != 1L ||
      is.na(include_counts)) {
    stop("`include_counts` must be TRUE or FALSE.", call. = FALSE)
  }

  dict <- gt_get_dictionary(dictionary)
  txt <- gt_normalize(text)

  empty <- data.frame(
    gendered = character(0),
    suggested_neutral = character(0),
    count = integer(0),
    stringsAsFactors = FALSE
  )

  if (!nzchar(txt)) {
    if (!include_counts) {
      empty$count <- NULL
    }
    return(empty)
  }

  res <- gt_match_counts(txt, dict)
  hit <- which(res$counts > 0L)

  if (length(hit) == 0L) {
    if (!include_counts) {
      empty$count <- NULL
    }
    return(empty)
  }

  out <- data.frame(
    gendered = dict$gendered[hit],
    suggested_neutral = dict$neutral[hit],
    count = res$counts[hit],
    stringsAsFactors = FALSE
  )
  out <- out[order(-out$count, out$gendered), , drop = FALSE]
  rownames(out) <- NULL

  if (!include_counts) {
    out$count <- NULL
  }
  out
}
