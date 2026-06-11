test_that("gender_dictionary has the documented structure", {
  expect_s3_class(gender_dictionary, "data.frame")
  expect_named(gender_dictionary, c("gendered", "neutral"))
  expect_type(gender_dictionary$gendered, "character")
  expect_type(gender_dictionary$neutral, "character")
  expect_gte(nrow(gender_dictionary), 200L)
})

test_that("gender_dictionary entries are clean", {
  expect_false(anyNA(gender_dictionary))
  expect_false(any(duplicated(gender_dictionary$gendered)))
  expect_identical(gender_dictionary$gendered,
                   tolower(gender_dictionary$gendered))
  expect_true(all(nzchar(gender_dictionary$gendered)))
  expect_true(all(nzchar(gender_dictionary$neutral)))
})

test_that("custom dictionaries are validated", {
  expect_error(gender_score(text = "x", dictionary = "not a frame"),
               "data frame")
  bad <- data.frame(a = "chairman", b = "chair")
  expect_error(gender_score(text = "x", dictionary = bad), "columns")
  na_dict <- data.frame(gendered = NA_character_, neutral = "x")
  expect_error(gender_score(text = "x", dictionary = na_dict), "missing")
  dup <- data.frame(gendered = c("dude", "dude"),
                    neutral = c("person", "human"))
  expect_warning(gender_score(text = "hey dude", dictionary = dup),
                 "duplicated")
})
