# Internal helpers for text normalisation and dictionary matching.
# These functions are not exported.

#' Normalise text for dictionary matching
#'
#' Lowercases the input, replaces every character that is not a letter,
#' whitespace, or apostrophe with a space, removes possessive 's endings,
#' turns remaining apostrophes into spaces, and collapses repeated
#' whitespace. The same normalisation is applied to dictionary entries so
#' that text and dictionary always match on equal terms.
#'
#' @param x A character vector.
#' @return A character vector of the same length as `x`.
#' @noRd
gt_normalize <- function(x) {
  x <- tolower(x)
  x <- gsub("[^a-z\\s']", " ", x, perl = TRUE)
  x <- gsub("'s\\b", " ", x, perl = TRUE)
  x <- gsub("'", " ", x, fixed = TRUE)
  x <- gsub("\\s+", " ", x, perl = TRUE)
  trimws(x)
}

#' Split a normalised string into tokens
#'
#' @param x A single normalised string.
#' @return A character vector of tokens (length zero for empty input).
#' @noRd
gt_tokens <- function(x) {
  if (is.na(x) || !nzchar(x)) {
    return(character(0))
  }
  strsplit(x, " ", fixed = TRUE)[[1]]
}

#' Resolve and validate a gendered language dictionary
#'
#' Returns the built in dictionary when `dictionary` is NULL, otherwise
#' validates a user supplied data frame. The returned data frame carries
#' two extra internal columns: `key` (the normalised form used for
#' matching) and `n_words` (number of words in the key). Entries whose
#' normalised keys are duplicated are dropped with a warning, keeping the
#' first occurrence.
#'
#' @param dictionary NULL or a data frame with character columns
#'   `gendered` and `neutral`.
#' @return A validated data frame with columns `gendered`, `neutral`,
#'   `key`, and `n_words`.
#' @noRd
gt_get_dictionary <- function(dictionary = NULL) {
  if (is.null(dictionary)) {
    dictionary <- gendertext::gender_dictionary
  }
  if (!is.data.frame(dictionary)) {
    stop("`dictionary` must be a data frame with columns `gendered` and `neutral`.",
         call. = FALSE)
  }
  if (!all(c("gendered", "neutral") %in% names(dictionary))) {
    stop("`dictionary` must contain the columns `gendered` and `neutral`.",
         call. = FALSE)
  }
  gendered <- as.character(dictionary[["gendered"]])
  neutral <- as.character(dictionary[["neutral"]])
  if (anyNA(gendered) || anyNA(neutral)) {
    stop("`dictionary` must not contain missing values.", call. = FALSE)
  }

  key <- gt_normalize(gendered)
  keep <- nzchar(key)
  if (!all(keep)) {
    warning("Dropping dictionary entries that are empty after normalisation.",
            call. = FALSE)
  }
  dup <- duplicated(key) & keep
  if (any(dup)) {
    warning("Dropping dictionary entries with duplicated terms: ",
            paste(unique(gendered[dup]), collapse = ", "), call. = FALSE)
    keep <- keep & !dup
  }

  out <- data.frame(
    gendered = gendered[keep],
    neutral = neutral[keep],
    key = key[keep],
    stringsAsFactors = FALSE
  )
  out$n_words <- lengths(strsplit(out$key, " ", fixed = TRUE))
  out
}

#' Count dictionary matches in a normalised text
#'
#' Multi word entries are matched first, from the longest phrase to the
#' shortest, and every matched phrase is removed from the working text
#' before shorter entries are considered. This prevents double counting,
#' for example the phrase "ladies and gentlemen" is never counted again
#' as "ladies" plus "gentlemen". Single word entries are then counted
#' against the remaining tokens.
#'
#' @param txt A single normalised string.
#' @param dict A dictionary as returned by [gt_get_dictionary()].
#' @return A list with `counts` (integer vector aligned with the rows of
#'   `dict`), `total_tokens` (token count of the full text), and
#'   `covered_tokens` (number of tokens covered by matches, where a
#'   phrase contributes one token per word it spans).
#' @noRd
gt_match_counts <- function(txt, dict) {
  total_tokens <- length(gt_tokens(txt))
  counts <- integer(nrow(dict))
  covered <- 0L

  if (total_tokens == 0L || nrow(dict) == 0L) {
    return(list(counts = counts, total_tokens = total_tokens,
                covered_tokens = covered))
  }

  work <- txt

  multi <- which(dict$n_words > 1L)
  if (length(multi) > 0L) {
    multi <- multi[order(-dict$n_words[multi], -nchar(dict$key[multi]))]
    for (i in multi) {
      pattern <- paste0("\\b", gsub(" ", "\\s+", dict$key[i], fixed = TRUE), "\\b")
      hits <- gregexpr(pattern, work, perl = TRUE)[[1]]
      k <- if (hits[1L] == -1L) 0L else length(hits)
      if (k > 0L) {
        counts[i] <- k
        covered <- covered + k * dict$n_words[i]
        work <- gsub(pattern, " ", work, perl = TRUE)
      }
    }
  }

  tokens <- gt_tokens(trimws(gsub("\\s+", " ", work, perl = TRUE)))
  if (length(tokens) > 0L) {
    single <- which(dict$n_words == 1L)
    if (length(single) > 0L) {
      tab <- table(tokens)
      hit <- tab[match(dict$key[single], names(tab))]
      hit[is.na(hit)] <- 0L
      counts[single] <- as.integer(hit)
      covered <- covered + sum(counts[single])
    }
  }

  list(counts = counts, total_tokens = total_tokens, covered_tokens = covered)
}
