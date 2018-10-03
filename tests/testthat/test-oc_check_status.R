library("opencage")
context("oc_check_status")
test_that("oc_check_status returns error if wrong API", {
  skip_on_cran()
  expect_error(
    oc_reverse(
      latitude = 0, longitude = 0,
      key = "clearlynotakey"
    ),
    "HTTP failure: 403"
  )
})
