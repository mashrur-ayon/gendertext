#' Rewrite Text with Gender Neutral Alternatives
#'
#' Replaces gendered terms and phrases in a text or in a file with the
#' gender neutral alternatives from the built in dictionary
#' [gender_dictionary] or from a user supplied dictionary. Longer phrases
#' are replaced before shorter ones and matching is case insensitive. The
#' capitalisation of each replacement follows the matched text: an all
#' caps match yields an all caps replacement and a match starting with a
#' capital letter yields a capitalised replacement.
#'
#' The function performs plain dictionary substitution. It does not adjust
#' the surrounding grammar, so a replacement such as "they" for "he" may
#' require manual revision of verb forms. It is intended as a drafting
#' aid, not a fully automatic rewriter.
#'
#' @param text A character string containing the text to rewrite. Optional
#'   if \code{path} is provided.
#' @param path A character string giving a file path (txt, pdf, docx, and
#'   other formats supported by [read_text()]). Optional if \code{text} is
#'   provided.
#' @param dictionary Optional data frame with character columns
#'   \code{gendered} and \code{neutral} to use instead of the built in
#'   [gender_dictionary].
#'
#' @return A length one character string containing the rewritten text.
#'
#' @seealso [gender_suggestions()] to preview the replacements,
#'   [gender_score()] for an overall share, and [gender_dictionary] for
#'   the built in dictionary.
#'
#' @examples
#' gender_replace(text = "The chairman called the policeman.")
#'
#' # Capitalisation is preserved
#' gender_replace(text = "Chairman Smith spoke. THE FIREMAN AGREED.")
#'
#' # Use a custom dictionary
#' my_dict <- data.frame(gendered = "dude", neutral = "person")
#' gender_replace(text = "Hey dude!", dictionary = my_dict)
#'
#' @export
gender_replace <- function(text = NULL, path = NULL, dictionary = NULL) {
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
  if (nrow(dict) == 0L || !nzchar(text)) {
    return(text)
  }

  ord <- order(-dict$n_words, -nchar(dict$key))
  out <- text

  for (i in ord) {
    pattern <- gt_replace_pattern(dict$gendered[i])
    matches <- gregexpr(pattern, out, perl = TRUE)
    starts <- matches[[1L]]
    if (starts[1L] == -1L) {
      next
    }
    found <- regmatches(out, matches)[[1L]]
    regmatches(out, matches) <- list(
      vapply(found, gt_apply_case, character(1L),
             replacement = dict$neutral[i], USE.NAMES = FALSE)
    )
  }

  out
}

#' Build a case insensitive matching pattern for a dictionary entry
#'
#' Escapes regex metacharacters, allows flexible whitespace between the
#' words of a phrase, makes apostrophes optional, and anchors the pattern
#' on word boundaries.
#'
#' @param entry A single dictionary entry (original spelling).
#' @return A perl compatible regular expression.
#' @noRd
gt_replace_pattern <- function(entry) {
  words <- strsplit(trimws(entry), "\\s+", perl = TRUE)[[1L]]
  words <- vapply(words, function(w) {
    w <- gsub("([.\\\\|()\\[\\]{}^$*+?])", "\\\\\\1", w, perl = TRUE)
    gsub("'", "'?", w, fixed = TRUE)
  }, character(1L), USE.NAMES = FALSE)
  paste0("(?i)\\b", paste(words, collapse = "\\s+"), "\\b")
}

#' Apply the capitalisation of a matched string to its replacement
#'
#' @param matched The matched text.
#' @param replacement The neutral replacement (lower case).
#' @return The replacement with adjusted capitalisation.
#' @noRd
gt_apply_case <- function(matched, replacement) {
  letters_only <- gsub("[^A-Za-z]", "", matched)
  if (nchar(letters_only) > 1L && letters_only == toupper(letters_only)) {
    return(toupper(replacement))
  }
  if (grepl("^[A-Z]", matched)) {
    return(paste0(toupper(substr(replacement, 1L, 1L)),
                  substring(replacement, 2L)))
  }
  replacement
}
