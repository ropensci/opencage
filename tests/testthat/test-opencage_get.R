library("opencage")
context("oc_get")
test_that("oc_get returns a response object", {
  skip_on_cran()
  expect_is(
    oc_get(oc_build_url(
      list(
        placename = "Sarzeau",
        key = Sys.getenv("OPENCAGE_KEY")
      )
    )),
    "HttpResponse"
  )
})

test_that("oc_get returns a response object for Namibia NA countrycode", {
  skip_on_cran()
  expect_is(
    oc_get(oc_build_url(
      list(
        placename = "Windhoek",
        key = Sys.getenv("OPENCAGE_KEY"),
        countrycode = "NA"
      )
    )),
    "HttpResponse"
  )
})

test_that("oc_get returns a response object for vector countrycode", {
  skip_on_cran()
  expect_is(
    oc_get(oc_build_url(list(
      placename = "Paris",
      key = Sys.getenv("OPENCAGE_KEY"),
      countrycode = c("FR", "US")
    ))),
    "HttpResponse"
  )
})
