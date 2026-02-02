#' Suggest gender-neutral alternatives for gendered terms found in text or a file
#'
#' Extracts dictionary terms present in the text and returns suggested alternatives.
#'
#' @param text Character. Text to analyse. Optional if `path` is provided.
#' @param path Character. Path to a file to analyse. Optional if `text` is provided.
#' @param include_counts Logical. If TRUE, counts occurrences in the text.
#'
#' @return A tibble with gendered terms found and suggested neutral alternatives.
#' @export
#'
#' @examples
#' gender_suggestions(text = "Our chairman said he will email the mailman.")
#' \dontrun{
#' gender_suggestions(path = "policy.pdf")
#' }
gender_suggestions <- function(text = NULL, path = NULL, include_counts = TRUE) {
  if (is.null(text) && is.null(path)) {
    stop("Provide either `text` or `path`.")
  }
  if (!is.null(path)) {
    text <- read_text(path)
  }
  if (!is.character(text)) {
    stop("`text` must be character.")
  }
  
  data("gender_dictionary", package = "gendertext", envir = environment())
  
  txt <- tolower(text)
  txt <- stringr::str_replace_all(txt, "[^a-z\\s']", " ")
  txt <- stringr::str_squish(txt)
  
  if (nchar(txt) == 0) {
    return(tibble::tibble(
      gendered = character(),
      suggested_neutral = character(),
      count = integer()
    ))
  }
  
  dict <- gender_dictionary
  
  found <- list()
  
  for (i in seq_len(nrow(dict))) {
    g <- dict$gendered[i]
    n <- dict$neutral[i]
    
    if (stringr::str_detect(g, "\\s+")) {
      pattern <- paste0("\\b", stringr::str_replace_all(g, "\\s+", "\\\\s+"), "\\b")
      k <- stringr::str_count(txt, pattern)
    } else {
      # token-style match
      pattern <- paste0("\\b", g, "\\b")
      k <- stringr::str_count(txt, pattern)
    }
    
    if (k > 0) {
      found[[length(found) + 1]] <- tibble::tibble(
        gendered = g,
        suggested_neutral = n,
        count = k
      )
    }
  }
  
  if (length(found) == 0) {
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
