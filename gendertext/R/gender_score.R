#' Gendered Language Score
#'
#' Computes the share of gendered language in a text or in a file, based on
#' the built in dictionary [gender_dictionary] or on a user supplied
#' dictionary. Multi word phrases are matched before single words and each
#' piece of text is counted at most once, so a phrase such as
#' "ladies and gentlemen" is never counted again as "ladies" plus
#' "gentlemen".
#'
#' The reported neutral share is a proxy. It is the proportion of tokens
#' that are not matched by any dictionary entry, not a comprehensive
#' linguistic measure of neutrality. When \code{unit = "tokens"}, a matched
#' multi word phrase contributes one gendered unit for every word it spans,
#' so the gendered and neutral percentages always sum to 100.
#'
#' @param text A character string containing the text to analyse. Optional
#'   if \code{path} is provided.
#' @param path A character string giving a file path (txt, pdf, docx, and
#'   other formats supported by [read_text()]). Optional if \code{text} is
#'   provided.
#' @param unit A character string giving the counting unit:
#'   \itemize{
#'     \item \code{"tokens"} (default): reports gendered tokens as a share
#'       of all tokens in the cleaned text.
#'     \item \code{"matches"}: reports the total number of dictionary
#'       matches only (useful for quick detection).
#'   }
#' @param dictionary Optional data frame with character columns
#'   \code{gendered} and \code{neutral} to use instead of the built in
#'   [gender_dictionary].
#'
#' @return A data frame with one row and the following columns:
#' \describe{
#'   \item{total_units}{Total number of units counted (tokens or matches,
#'     depending on \code{unit}).}
#'   \item{gendered_units}{Number of gendered units detected.}
#'   \item{neutral_units}{For \code{unit = "tokens"}, the difference
#'     \code{total_units - gendered_units}. Otherwise \code{NA}.}
#'   \item{gendered_percent}{Percentage of gendered units.}
#'   \item{neutral_percent}{Percentage of unmatched (proxy neutral) units,
#'     or \code{NA} for \code{unit = "matches"}.}
#' }
#'
#' @seealso [gender_suggestions()] to list the terms behind the score,
#'   [gender_replace()] to rewrite the text, and [gender_dictionary] for
#'   the built in dictionary.
#'
#' @examples
#' # Direct text input
#' gender_score(text = "The chairman said he will call the policeman.")
#'
#' # Count matches only
#' gender_score(text = "The chairman spoke.", unit = "matches")
#'
#' # Analyse a file shipped with the package
#' txt <- system.file("extdata", "test.txt", package = "gendertext")
#' gender_score(path = txt)
#'
#' # Use a custom dictionary
#' my_dict <- data.frame(
#'   gendered = c("dude"),
#'   neutral = c("person")
#' )
#' gender_score(text = "Hey dude!", dictionary = my_dict)
#'
#' @export
gender_score <- function(text = NULL, path = NULL,
                         unit = c("tokens", "matches"),
                         dictionary = NULL) {
  unit <- match.arg(unit)

  if (is.null(text) && is.null(path)) {
    stop("Provide either `text` or `path`.", call. = FALSE)
  }
  if (!is.null(path)) {
    text <- read_text(path)
  }
  if (!is.character(text) || length(text) != 1L || is.na(text)) {
    stop("`text` must be a single, non-missing character string.", call. = FALSE)
  }

  dict <- gt_get_dictionary(dictionary)
  txt <- gt_normalize(text)

  if (!nzchar(txt)) {
    return(data.frame(
      total_units = 0L,
      gendered_units = 0L,
      neutral_units = if (unit == "tokens") 0L else NA_integer_,
      gendered_percent = NA_real_,
      neutral_percent = NA_real_
    ))
  }

  res <- gt_match_counts(txt, dict)

  if (unit == "tokens") {
    total_units <- res$total_tokens
    gendered_units <- min(res$covered_tokens, total_units)
    neutral_units <- total_units - gendered_units
    data.frame(
      total_units = as.integer(total_units),
      gendered_units = as.integer(gendered_units),
      neutral_units = as.integer(neutral_units),
      gendered_percent = 100 * gendered_units / total_units,
      neutral_percent = 100 * neutral_units / total_units
    )
  } else {
    total_matches <- sum(res$counts)
    data.frame(
      total_units = as.integer(total_matches),
      gendered_units = as.integer(total_matches),
      neutral_units = NA_integer_,
      gendered_percent = if (total_matches > 0L) 100 else 0,
      neutral_percent = NA_real_
    )
  }
}
