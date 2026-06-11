#' gendertext: Detect Gendered Words in Text and Suggest Neutral Alternatives
#'
#' Tools for identifying gendered language in text and in documents,
#' measuring how much of a text is gendered, and suggesting or applying
#' gender neutral alternatives. The package follows a transparent,
#' dictionary based approach built around the [gender_dictionary] dataset.
#'
#' The main functions are:
#' \itemize{
#'   \item [gender_score()]: share of gendered language in a text or file.
#'   \item [gender_suggestions()]: detected gendered terms with suggested
#'     gender neutral alternatives.
#'   \item [gender_replace()]: rewrite a text using the neutral
#'     alternatives.
#'   \item [read_text()]: read a document into a single character string.
#' }
#'
#' @keywords internal
"_PACKAGE"
