test_that("read_text reads plain text files with base R", {
  txt <- system.file("extdata", "test.txt", package = "gendertext")
  out <- read_text(txt)
  expect_type(out, "character")
  expect_length(out, 1L)
  expect_gt(nchar(out), 0L)
  expect_match(out, "chairman", ignore.case = TRUE)
})

test_that("read_text reads pdf files when readtext is installed", {
  skip_if_not_installed("readtext")
  pdf <- system.file("extdata", "test.pdf", package = "gendertext")
  out <- read_text(pdf)
  expect_type(out, "character")
  expect_length(out, 1L)
})

test_that("read_text validates input", {
  expect_error(read_text(NULL), "single")
  expect_error(read_text(c("a.txt", "b.txt")), "single")
  expect_error(read_text(NA_character_), "single")
  expect_error(read_text("no-such-file-12345.txt"), "does not exist")
})
