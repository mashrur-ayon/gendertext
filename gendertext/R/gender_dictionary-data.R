#' Dictionary of Gendered Terms and Gender Neutral Alternatives
#'
#' A curated dictionary of gendered English words and phrases, each paired
#' with a suggested gender neutral alternative. The dictionary covers
#' gendered occupational titles (for example "chairman" and "stewardess"),
#' gendered pronouns, forms of address, family and relationship terms, and
#' common idioms and compounds built on gendered words. It powers
#' [gender_score()], [gender_suggestions()], and [gender_replace()].
#'
#' All entries are stored in lower case. Matching in the package functions
#' is case insensitive and tolerant of possessive forms, so "Chairman's"
#' in a text is matched by the entry "chairman".
#'
#' The selection of terms and replacements is informed by published
#' guidance on gender inclusive language, including the United Nations
#' guidelines for gender inclusive language in English and the European
#' Parliament guidance on gender neutral language.
#'
#' @format A data frame with 208 rows and 2 variables:
#' \describe{
#'   \item{gendered}{Character. A gendered word or phrase, in lower case.}
#'   \item{neutral}{Character. The suggested gender neutral alternative.}
#' }
#'
#' @source Curated by the package author, informed by the United Nations
#'   guidelines for gender inclusive language
#'   (<https://www.un.org/en/gender-inclusive-language/>) and the European
#'   Parliament guidance on gender neutral language
#'   (<https://www.europarl.europa.eu/cmsdata/151780/GNL_Guidelines_EN.pdf>).
#'
#' @examples
#' data(gender_dictionary)
#' head(gender_dictionary)
#' nrow(gender_dictionary)
"gender_dictionary"
