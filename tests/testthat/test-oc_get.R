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

test_that("oc_get_limited is rate limited", {
  skip_on_cran()
  tm <- system.time({
    replicate(oc_get_limited("https://httpbin.org/get"), 2)
  })
  expect_gte(
    tm[["elapsed"]],
    ratelimitr::get_rates(oc_get_limited)[[1]][["period"]]
  )
})

test_that("oc_get_memoise memoises", {
  skip_on_cran()
  oc_get_memoise("https://httpbin.org/get")
  tm <- system.time({
    oc_get_memoise("https://httpbin.org/get")
  })
  expect_lt(tm["elapsed"], 0.5)
})
