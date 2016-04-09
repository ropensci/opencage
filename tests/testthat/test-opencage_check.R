library("opencage")
context("opencage_check")
test_that("opencage_check returns error if wrong API",{
  expect_error(opencage_reverse(latitude = 0, longitude = 0,
                                key = "clearlynotakey"),
               "HTTP failure: 403")
})
