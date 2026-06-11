test_that("gender_replace substitutes gendered terms", {
  out <- gender_replace(text = "The chairman called the policeman.")
  expect_equal(out, "The chair called the police officer.")
})

test_that("gender_replace preserves capitalisation", {
  out <- gender_replace(text = "Chairman Smith spoke.")
  expect_equal(out, "Chair Smith spoke.")
  caps <- gender_replace(text = "THE FIREMAN AGREED.")
  expect_equal(caps, "THE FIREFIGHTER AGREED.")
})

test_that("gender_replace handles multi word phrases first", {
  out <- gender_replace(text = "Ladies and gentlemen, welcome!")
  expect_equal(out, "Everyone, welcome!")
})

test_that("gender_replace leaves neutral text unchanged", {
  x <- "The committee approved the budget."
  expect_equal(gender_replace(text = x), x)
  expect_equal(gender_replace(text = ""), "")
})

test_that("gender_replace works with a custom dictionary", {
  d <- data.frame(gendered = "dude", neutral = "person")
  out <- gender_replace(text = "Hey Dude!", dictionary = d)
  expect_equal(out, "Hey Person!")
})

test_that("gender_replace does not touch partial words", {
  out <- gender_replace(text = "The theme was chairmanship history.")
  expect_false(grepl("chairship", out))
  expect_true(grepl("theme", out))
})

test_that("gender_replace validates input", {
  expect_error(gender_replace(), "either `text` or `path`")
  expect_error(gender_replace(text = 5), "single")
})
