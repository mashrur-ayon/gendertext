test_that("gender_suggestions returns detected terms with suggestions", {
  s <- gender_suggestions(text = "The mailman spoke to the fireman.")
  expect_s3_class(s, "data.frame")
  expect_named(s, c("gendered", "suggested_neutral", "count"))
  expect_setequal(s$gendered, c("mailman", "fireman"))
  expect_equal(s$count, c(1L, 1L))
  expect_equal(s$suggested_neutral[s$gendered == "fireman"], "firefighter")
})

test_that("gender_suggestions counts repeated terms and sorts by count", {
  s <- gender_suggestions(
    text = "The chairman, the chairman, and the policeman."
  )
  expect_equal(s$gendered[1L], "chairman")
  expect_equal(s$count[1L], 2L)
  expect_equal(s$count[2L], 1L)
})

test_that("include_counts = FALSE drops the count column", {
  s <- gender_suggestions(text = "The fireman arrived.",
                          include_counts = FALSE)
  expect_named(s, c("gendered", "suggested_neutral"))
})

test_that("gender_suggestions returns empty frame when nothing is found", {
  s <- gender_suggestions(text = "A neutral sentence about a committee.")
  expect_equal(nrow(s), 0L)
  expect_named(s, c("gendered", "suggested_neutral", "count"))
  e <- gender_suggestions(text = "", include_counts = FALSE)
  expect_equal(nrow(e), 0L)
  expect_named(e, c("gendered", "suggested_neutral"))
})

test_that("gender_suggestions is case insensitive", {
  s <- gender_suggestions(text = "The CHAIRMAN and the Policeman.")
  expect_setequal(s$gendered, c("chairman", "policeman"))
})

test_that("gender_suggestions reads files", {
  txt <- system.file("extdata", "test.txt", package = "gendertext")
  s <- gender_suggestions(path = txt)
  expect_gt(nrow(s), 0L)
  expect_true("chairman" %in% s$gendered)
})

test_that("gender_suggestions validates input", {
  expect_error(gender_suggestions(), "either `text` or `path`")
  expect_error(gender_suggestions(text = "x", include_counts = NA),
               "include_counts")
})
