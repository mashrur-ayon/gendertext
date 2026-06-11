# CRAN comments for gendertext 0.1.0

## Submission

This is the first submission of gendertext to CRAN.

The package detects gendered words and phrases in text, reports the
share of gendered language, suggests gender neutral alternatives, and
can rewrite text in gender neutral form. The core uses base R only;
the 'readtext' package is an optional suggestion used for reading PDF
and Word documents.

## R CMD check results

0 errors | 0 warnings

One NOTE on the local Windows machine ("checking for future file
timestamps: unable to verify current time"), which comes from the
clock verification web service being unreachable and is unrelated to
the package.

## Test environments

* Local R installation (Windows)
* GitHub Actions (ubuntu-latest, windows-latest, macos-latest)

## Downstream dependencies

There are no downstream dependencies; this is a new package.
