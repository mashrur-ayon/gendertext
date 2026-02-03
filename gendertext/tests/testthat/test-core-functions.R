test_that("gender_score works on basic text", {
  x <- gender_score(text = "The chairman said he will call the policeman.")
  expect_true(is.data.frame(x))
  expect_true(all(c("gendered_percent", "neutral_percent") %in% names(x)))
})

test_that("gender_suggestions returns suggestions", {
  s <- gender_suggestions(text = "The mailman spoke to the fireman.")
  expect_true(is.data.frame(s))
  # It might be empty if dictionary changes, so just check columns
  expect_true(all(c("gendered", "suggested_neutral") %in% names(s)))
})
