library("opencage")
context("opencage_url")
test_that("opencage_url returns a string",{
  expect_is(opencage_url(), "character")
})
