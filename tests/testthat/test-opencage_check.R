library("opencage")
context("oc_check")
test_that("oc_check returns error if wrong API",{
  skip_on_cran()
  expect_error(opencage_reverse(latitude = 0, longitude = 0,
                                key = "clearlynotakey"),
               "HTTP failure: 403")
})
