## Test oc_get ##

test_that("oc_get returns a response object", {
  vcr::use_cassette("oc_get_response", {
    res <- oc_get(
      oc_build_url(
        query_par = list(
          placename = "Sarzeau",
          key = Sys.getenv("OPENCAGE_KEY")
        ),
        endpoint = "json"
      )
    )
  })
  expect_s3_class(res, "HttpResponse")
})

test_that("oc_get returns a response object for Namibia NA countrycode", {
  vcr::use_cassette("oc_get_namibia", {
    res <- oc_get(
      oc_build_url(
        query_par = list(
          placename = "Windhoek",
          key = Sys.getenv("OPENCAGE_KEY"),
          countrycode = "NA"
        ),
        endpoint = "json"
      )
    )
  })
  expect_s3_class(res, "HttpResponse")
})

test_that("oc_get returns a response object for vector countrycode", {
  vcr::use_cassette("oc_get_countrycode", {
    res <- oc_get(
      oc_build_url(
        query_par = list(
          placename = "Paris",
          key = Sys.getenv("OPENCAGE_KEY"),
          countrycode = c("FR", "US")
        ),
        endpoint = "json"
      )
    )
  })
  expect_s3_class(res, "HttpResponse")
})

test_that("oc_get_limited is rate limited", {
  skip_on_cran()
  skip_if_offline()

  tm <- system.time({
    replicate(2, oc_get_limited("https://httpbin.org/get"))
  })
  rate <- ratelimitr::get_rates(oc_get_limited)
  expect_gte(tm[["elapsed"]], rate[[1]][["period"]] / rate[[1]][["n"]])
})

test_that("oc_get_memoise memoises", {
  skip_on_cran()
  skip_if_offline()

  oc_get_memoise("https://httpbin.org/get")
  tm <- system.time({
    oc_get_memoise("https://httpbin.org/get")
  })
  expect_lt(tm["elapsed"], 0.5)
})
