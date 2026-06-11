# gendertext <img src="https://raw.githubusercontent.com/mashrur-ayon/gendertext/main/plots-picture/gender-text-logo.png" align="right" height="120" alt="gendertext logo" />

**gendertext** is an R package that detects gendered language in text and
documents (`.txt`, `.pdf`, `.docx`, and more), measures how much of a text
is gendered, suggests gender neutral alternatives, and can rewrite text in
gender neutral form.

The package is dictionary based and fully transparent: every result can be
traced back to an entry in the built in dictionary of 208 curated gendered
terms, informed by the [United Nations guidelines for gender inclusive
language](https://www.un.org/en/gender-inclusive-language/) and the
[European Parliament guidance on gender neutral
language](https://www.europarl.europa.eu/cmsdata/151780/GNL_Guidelines_EN.pdf).

## Features

1. **Gendered language share**: `gender_score()` reads text or a file and
   reports the number and percentage of gendered versus unmatched (proxy
   neutral) tokens.
2. **Suggestions table**: `gender_suggestions()` lists every gendered term
   found, its suggested neutral replacement, and how often it occurs.
3. **Automatic rewriting**: `gender_replace()` substitutes gendered terms
   with neutral alternatives while preserving capitalisation.
4. **Document support**: `read_text()` reads plain text with base R and
   formats such as PDF and Word through the optional
   [readtext](https://cran.r-project.org/package=readtext) package.
5. **Custom dictionaries**: every function accepts your own dictionary via
   the `dictionary` argument.

## Installation

```r
# From CRAN (once accepted)
install.packages("gendertext")

# Development version from GitHub
# install.packages("devtools")
devtools::install_github("mashrur-ayon/gendertext", subdir = "gendertext")
```

## Usage

```r
library(gendertext)

# Share of gendered language
gender_score(text = "The chairman said he will call the policeman.")
#>   total_units gendered_units neutral_units gendered_percent neutral_percent
#> 1           8              3             5             37.5            62.5

# Gendered terms with neutral alternatives
gender_suggestions(text = "Our chairman said he will email the mailman.")
#>   gendered suggested_neutral count
#> 1 chairman             chair     1
#> 2       he              they     1
#> 3  mailman      mail carrier     1

# Rewrite the text
gender_replace(text = "The Chairman called the policeman.")
#> [1] "The Chair called the police officer."

# Analyse documents
gender_score(path = "report.pdf")
gender_suggestions(path = "minutes.docx")
```

## The dictionary

```r
data(gender_dictionary)
head(gender_dictionary)
```

The dictionary contains 208 lower case gendered terms and phrases with
suggested neutral replacements. Matching is case insensitive, tolerant of
possessive forms, and counts multi word phrases before single words so
nothing is double counted.

## Authors

* **S M Mashrur Arafin Ayon** (maintainer) [ORCID 0000-0002-3659-2891](https://orcid.org/0000-0002-3659-2891)
* **Rodaba Zaman Adrita**: word collection and gender dictionary curation

## License

MIT. See the `LICENSE` file.
