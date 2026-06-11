# Build the gender_dictionary dataset shipped with the gendertext package.
#
# The canonical source is data-raw/gender_dictionary.csv, a curated list of
# gendered terms and phrases with suggested gender neutral alternatives.
# The selection is informed by the United Nations guidelines for gender
# inclusive language and the European Parliament guidance on gender
# neutral language.
#
# Run this script from the repository root after editing the CSV:
#   Rscript data-raw/make_gender_dictionary.R

gender_dictionary <- read.csv(
  "data-raw/gender_dictionary.csv",
  stringsAsFactors = FALSE,
  encoding = "UTF-8"
)

# Basic quality checks before saving
stopifnot(
  identical(names(gender_dictionary), c("gendered", "neutral")),
  is.character(gender_dictionary$gendered),
  is.character(gender_dictionary$neutral),
  !anyNA(gender_dictionary),
  !any(duplicated(gender_dictionary$gendered)),
  identical(gender_dictionary$gendered, tolower(gender_dictionary$gendered)),
  all(nzchar(gender_dictionary$gendered)),
  all(nzchar(gender_dictionary$neutral))
)

# Keep the dictionary sorted for readable diffs
gender_dictionary <- gender_dictionary[order(gender_dictionary$gendered), ]
rownames(gender_dictionary) <- NULL

save(
  gender_dictionary,
  file = "gendertext/data/gender_dictionary.RData",
  version = 2,
  compress = "bzip2"
)

message("Saved ", nrow(gender_dictionary),
        " entries to gendertext/data/gender_dictionary.RData")
