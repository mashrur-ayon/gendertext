# gendertext 0.1.0

Initial CRAN release.

* `gender_score()` reports the share of gendered language in a text or
  document, counted by tokens or by dictionary matches.
* `gender_suggestions()` lists the gendered terms found in a text together
  with suggested gender neutral alternatives and occurrence counts.
* `gender_replace()` rewrites a text by substituting gendered terms with
  their gender neutral alternatives while preserving capitalisation.
* `read_text()` reads plain text files with base R and other document
  formats such as PDF and Word through the optional 'readtext' package.
* Built in dataset `gender_dictionary` with 208 curated gendered terms and
  phrases paired with gender neutral alternatives, informed by United
  Nations and European Parliament guidance on gender inclusive language.
* All functions accept a custom dictionary through the `dictionary`
  argument.
