library("opencage")
context("oc_build_url")
test_that("oc_build_url returns a string", {
  expect_is(oc_build_url(query_par = list(placename = "Haarlem")), "character")
})
