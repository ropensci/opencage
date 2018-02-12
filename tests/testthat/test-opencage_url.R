library("opencage")
context("oc_url")
test_that("oc_url returns a string", {
  expect_is(oc_url(), "character")
})
