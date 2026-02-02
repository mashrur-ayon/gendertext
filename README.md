# gendertext

**gendertext** is an R package that detects gendered language in text (including documents like `.txt`, `.pdf`, and `.docx`) and suggests gender-neutral alternatives.

## Features

1. **Gendered language share**  
   Reads text (or a file) and estimates:
   - how many dictionary-based gendered terms appear
   - what percentage of the text is gendered vs not matched (proxy for neutral)

2. **Suggestions table**  
   Returns a table of gendered terms found in the text and proposed neutral replacements.

3. **Built-in dictionary**  
   The package ships with a small built-in dictionary (`gender_dictionary`) of gendered terms and suggested alternatives.

> You can replace the built-in dictionary later with your own expanded corpus.

## Installation (development)

```r
# install.packages("devtools")
devtools::install_github("YOUR_GITHUB_USERNAME/gendertext")

```

## What the package does

1. **Calculate gendered vs. neutral language percentages**: `gendered_ratio()`
   reads a text, PDF, or Word document and reports the percentage of gendered
   and gender-neutral terms.
2. **List gendered words with neutral alternatives**: `word_table()` extracts
   gendered words from a document and returns a table of suggested neutral
   replacements.
3. **Built-in corpus**: The package ships with an `RData` dataset named
   `combined_gender_neutral_words`, containing 50–100 gendered terms and their
   recommended neutral alternatives.

## Usage

```r
library(gendertext)

# Calculate ratios
gendered_ratio("path/to/document.txt")

# List gendered terms with suggestions
word_table("path/to/document.txt")
```
