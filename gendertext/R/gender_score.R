#' Gendered Language Score
#'
#' Computes the share of dictionary-matched gendered terms within a text (or within a file).
#' The function uses the package dataset \code{gender_dictionary} (gendered \eqn{\rightarrow} neutral suggestions).
#'
#' The reported "neutral" share is a *proxy* defined as non-matched units when \code{unit = "tokens"}.
#' In other words, it estimates the proportion of tokens that are not matched to any gendered term
#' in the dictionary (not a comprehensive measure of neutrality).
#'
#' @param text A character string containing the text to analyse. Optional if \code{path} is provided.
#' @param path A character string specifying a file path (\code{.txt}, \code{.pdf}, \code{.docx}, etc.).
#'   Optional if \code{text} is provided.
#' @param unit A character string specifying the counting unit:
#'   \itemize{
#'     \item \code{"tokens"} (default): counts whitespace tokens in the cleaned text and reports
#'       matched gendered occurrences as a share of all tokens.
#'     \item \code{"matches"}: counts total dictionary matches only (useful for quick detection).
#'   }
#'
#' @return A tibble with the following columns:
#' \describe{
#'   \item{total_units}{Total number of units counted (tokens or matches, depending on \code{unit}).}
#'   \item{gendered_units}{Number of gendered matches detected.}
#'   \item{neutral_units}{For \code{unit = "tokens"}, \code{total_units - gendered_units}. Otherwise \code{NA}.}
#'   \item{gendered_percent}{Percentage of gendered units.}
#'   \item{neutral_percent}{Percentage of neutral proxy units (tokens not matched), or \code{NA} for \code{"matches"}.}
#' }
#'
#' @examples
#' # Direct text input
#' gender_score(text = "The chairman said he will call the policeman.")
#'
#' \dontrun{
#' txt <- system.file("extdata", "test.txt", package = "gendertext")
#' pdf <- system.file("extdata", "test.pdf", package = "gendertext")
#' gender_score(path = txt)
#' gender_score(path = pdf)
#' }
#'
#' @export
gender_score <- function(text = NULL, path = NULL, unit = c("tokens", "matches")) {

  unit <- match.arg(unit)

  if (is.null(text) && is.null(path)) {
    stop("Provide either `text` or `path`.", call. = FALSE)
  }
  if (!is.null(text) && (!is.character(text) || length(text) != 1L)) {
    stop("`text` must be a single character string.", call. = FALSE)
  }
  if (!is.null(path)) {
    if (!is.character(path) || length(path) != 1L || is.na(path)) {
      stop("`path` must be a single, non-missing character string.", call. = FALSE)
    }
    text <- read_text(path)
  }

  # Load built-in dictionary from data/
  data("gender_dictionary", package = "gendertext", envir = environment())

  # Normalise text
  txt <- tolower(text)
  txt <- stringr::str_replace_all(txt, "[^a-z\\s']", " ")
  txt <- stringr::str_squish(txt)

  if (nchar(txt) == 0L) {
    return(tibble::tibble(
      total_units = 0L,
      gendered_units = 0L,
      neutral_units = 0L,
      gendered_percent = NA_real_,
      neutral_percent = NA_real_
    ))
  }

  tokens <- unlist(strsplit(txt, "\\s+"), use.names = FALSE)

  dict <- gender_dictionary
  single <- dict[!stringr::str_detect(dict$gendered, "\\s+"), , drop = FALSE]
  multi  <- dict[ stringr::str_detect(dict$gendered, "\\s+"), , drop = FALSE]

  # Single-word matches
  gendered_token_hits <- sum(tokens %in% single$gendered)

  # Multi-word phrase matches
  multi_hits <- 0L
  if (nrow(multi) > 0L) {
    for (g in multi$gendered) {
      pattern <- paste0("\\b", stringr::str_replace_all(g, "\\s+", "\\\\s+"), "\\b")
      multi_hits <- multi_hits + stringr::str_count(txt, pattern)
    }
  }

  total_gendered_matches <- as.integer(gendered_token_hits + multi_hits)

  if (unit == "tokens") {

    total_units <- length(tokens)
    gendered_units <- total_gendered_matches
    neutral_units <- max(total_units - gendered_units, 0L)

    tibble::tibble(
      total_units = as.integer(total_units),
      gendered_units = as.integer(gendered_units),
      neutral_units = as.integer(neutral_units),
      gendered_percent = (gendered_units / total_units) * 100,
      neutral_percent = (neutral_units / total_units) * 100
    )

  } else {

    total_units <- total_gendered_matches

    tibble::tibble(
      total_units = as.integer(total_units),
      gendered_units = as.integer(total_gendered_matches),
      neutral_units = NA_integer_,
      gendered_percent = ifelse(total_units == 0L, 0, 100),
      neutral_percent = NA_real_
    )
  }
}
