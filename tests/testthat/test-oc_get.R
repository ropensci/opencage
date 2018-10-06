library("opencage")
context("oc_get")
test_that("oc_get returns a response object", {
  skip_on_cran()
  expect_is(
    oc_get(
      oc_build_url(
        query_par = list(
          placename = "Sarzeau",
          key = Sys.getenv("OPENCAGE_KEY")
        ),
        endpoint = "json"
      )
    ),
    "HttpResponse"
  )
})

test_that("oc_get returns a response object for Namibia NA countrycode", {
  skip_on_cran()
  expect_is(
    oc_get(
      oc_build_url(
        query_par = list(
          placename = "Windhoek",
          key = Sys.getenv("OPENCAGE_KEY"),
          countrycode = "NA"
        ),
        endpoint = "json"
      )
    ),
    "HttpResponse"
  )
})

test_that("oc_get returns a response object for vector countrycode", {
  skip_on_cran()
  expect_is(
    oc_get(
      oc_build_url(
        query_par = list(
          placename = "Paris",
          key = Sys.getenv("OPENCAGE_KEY"),
          countrycode = c("FR", "US")
        ),
        endpoint = "json"
      )
    ),
    "HttpResponse"
  )
})
