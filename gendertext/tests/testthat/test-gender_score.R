test_that("gender_score works on basic text", {
  x <- gender_score(text = "The chairman said he will call the policeman.")
  expect_s3_class(x, "data.frame")
  expect_equal(nrow(x), 1L)
  expect_named(x, c("total_units", "gendered_units", "neutral_units",
                    "gendered_percent", "neutral_percent"))
  expect_equal(x$total_units, 8L)
  expect_equal(x$gendered_units, 3L)
  expect_equal(x$neutral_units, 5L)
  expect_equal(x$gendered_percent + x$neutral_percent, 100)
})

test_that("gender_score finds no matches in neutral text", {
  x <- gender_score(text = "The committee met and the chair spoke.")
  expect_equal(x$gendered_units, 0L)
  expect_equal(x$gendered_percent, 0)
  expect_equal(x$neutral_percent, 100)
})

test_that("multi word phrases are not double counted", {
  x <- gender_score(text = "ladies and gentlemen")
  expect_equal(x$total_units, 3L)
  expect_equal(x$gendered_units, 3L)
  s <- gender_suggestions(text = "ladies and gentlemen")
  expect_equal(s$gendered, "ladies and gentlemen")
  expect_equal(s$count, 1L)
})

test_that("possessive forms are matched", {
  x <- gender_score(text = "The chairman's report arrived.")
  expect_equal(x$gendered_units, 1L)
})

test_that("unit = 'matches' counts dictionary matches only", {
  x <- gender_score(text = "The chairman and the chairman met.",
                    unit = "matches")
  expect_equal(x$total_units, 2L)
  expect_equal(x$gendered_units, 2L)
  expect_true(is.na(x$neutral_units))
  expect_equal(x$gendered_percent, 100)
  y <- gender_score(text = "Nothing gendered here.", unit = "matches")
  expect_equal(y$total_units, 0L)
  expect_equal(y$gendered_percent, 0)
})

test_that("empty and punctuation-only text returns zero counts", {
  x <- gender_score(text = "")
  expect_equal(x$total_units, 0L)
  expect_true(is.na(x$gendered_percent))
  y <- gender_score(text = "123 !!! ...")
  expect_equal(y$total_units, 0L)
})

test_that("gender_score reads files", {
  txt <- system.file("extdata", "test.txt", package = "gendertext")
  x <- gender_score(path = txt)
  expect_gt(x$total_units, 0L)
  expect_gt(x$gendered_units, 0L)
})

test_that("gender_score accepts a custom dictionary", {
  d <- data.frame(gendered = "dude", neutral = "person")
  x <- gender_score(text = "Hey dude, the chairman is here.", dictionary = d)
  expect_equal(x$gendered_units, 1L)
})

test_that("gender_score validates input", {
  expect_error(gender_score(), "either `text` or `path`")
  expect_error(gender_score(text = c("a", "b")), "single")
  expect_error(gender_score(text = 1), "single")
  expect_error(gender_score(text = "x", unit = "letters"))
})
