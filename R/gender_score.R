#' Calculate gendered language share in a text or file
#'
#' Computes the share of dictionary-matched gendered terms within the text.
#' Returns both counts and percentages.
#'
#' @param text Character. Text to analyse. Optional if `path` is provided.
#' @param path Character. Path to a file to analyse (txt/pdf/docx/etc.). Optional if `text` is provided.
#' @param unit Character. "tokens" (default) counts word tokens; "matches" counts total dictionary matches.
#'
#' @return A tibble with counts and percentages.
#' @export
#'
#' @examples
#' gender_score(text = "The chairman said he will help.")
#' \dontrun{
#' gender_score(path = "report.docx")
#' }
gender_score <- function(text = NULL, path = NULL, unit = c("tokens","matches")) {
  unit <- match.arg(unit)
  
  if (is.null(text) && is.null(path)) {
    stop("Provide either `text` or `path`.")
  }
  if (!is.null(text) && !is.character(text)) {
    stop("`text` must be character.")
  }
  if (!is.null(path)) {
    text <- read_text(path)
  }
  
  # Load built-in dictionary from data/
  data("gender_dictionary", package = "gendertext", envir = environment())
  
  # Normalise text
  txt <- tolower(text)
  # Keep apostrophes, replace other punctuation with spaces
  txt <- stringr::str_replace_all(txt, "[^a-z\\s']", " ")
  txt <- stringr::str_squish(txt)
  
  if (nchar(txt) == 0) {
    return(tibble::tibble(
      total_units = 0,
      gendered_units = 0,
      neutral_units = 0,
      gendered_percent = NA_real_,
      neutral_percent = NA_real_
    ))
  }
  
  # Tokenise (simple whitespace tokenisation)
  tokens <- unlist(strsplit(txt, "\\s+"), use.names = FALSE)
  
  # Match logic:
  # - single-word dictionary entries: token match
  # - multi-word dictionary entries: phrase match in the full string
  dict <- gender_dictionary
  
  single <- dict[!stringr::str_detect(dict$gendered, "\\s+"), , drop = FALSE]
  multi  <- dict[ stringr::str_detect(dict$gendered, "\\s+"), , drop = FALSE]
  
  # Single-word matches: count tokens that equal any gendered word
  gendered_token_hits <- sum(tokens %in% single$gendered)
  
  # Multi-word matches: count occurrences using fixed boundary-ish matching
  multi_hits <- 0
  if (nrow(multi) > 0) {
    for (g in multi$gendered) {
      # Match phrase with word boundaries around it
      pattern <- paste0("\\b", stringr::str_replace_all(g, "\\s+", "\\\\s+"), "\\b")
      multi_hits <- multi_hits + stringr::str_count(txt, pattern)
    }
  }
  
  total_gendered_matches <- gendered_token_hits + multi_hits
  
  if (unit == "tokens") {
    total_units <- length(tokens)
    gendered_units <- total_gendered_matches
    neutral_units <- max(total_units - gendered_units, 0)
    
    tibble::tibble(
      total_units = total_units,
      gendered_units = gendered_units,
      neutral_units = neutral_units,
      gendered_percent = (gendered_units / total_units) * 100,
      neutral_percent = (neutral_units / total_units) * 100
    )
  } else {
    # "matches": neutral is defined as non-matched tokens + (optional) not super meaningful,
    # but we keep a consistent shape.
    total_units <- total_gendered_matches
    tibble::tibble(
      total_units = total_units,
      gendered_units = total_gendered_matches,
      neutral_units = NA_integer_,
      gendered_percent = ifelse(total_units == 0, 0, 100),
      neutral_percent = NA_real_
    )
  }
}
