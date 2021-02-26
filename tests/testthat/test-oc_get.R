## Test oc_get ##

vcr::use_cassette("oc_get_response", {
  test_that("oc_get returns a response object", {
    withr::local_envvar(c("OPENCAGE_KEY" = key_200))

    expect_s3_class(
      oc_get(
        oc_build_url(
          query_par = list(
            placename = "irrelevant",
            key = Sys.getenv("OPENCAGE_KEY")
          ),
          endpoint = "json"
        )
      ),
      "HttpResponse"
    )
  })
})

 vcr::use_cassette("oc_get_namibia", {
  test_that("oc_get returns a response object for Namibia NA countrycode", {
    expect_s3_class(
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
})

vcr::use_cassette("oc_get_countrycode", {
  test_that("oc_get returns a response object for vector countrycode", {
    expect_s3_class(
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
})

test_that("oc_get_limited is rate limited", {
  tm <- system.time({
    replicate(
      2,
      vcr::use_cassette("oc_get_limited", {
        oc_get_limited("https://httpbin.org/get")
      })
    )
  })
  rate <- ratelimitr::get_rates(oc_get_limited)
  expect_gte(tm[["elapsed"]], rate[[1]][["period"]] / rate[[1]][["n"]])
})

test_that("oc_get_memoise memoises", {
  vcr::use_cassette("oc_get_memoise", {
    oc_get_memoise("https://httpbin.org/get")
  })
  expect_true(memoise::has_cache(oc_get_memoise)("https://httpbin.org/get"))
})
