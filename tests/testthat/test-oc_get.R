# Test oc_get() -----------------------------------------------------------

test_that("oc_get returns a response object", {
  skip_if_oc_offline()
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
    "httr2_response"
  )
})

test_that("oc_get returns a response object for Namibia NA countrycode", {
  skip_if_no_key()
  skip_if_oc_offline()

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
    "httr2_response"
  )
})

test_that("oc_get returns a response object for vector countrycode", {
  skip_if_no_key()
  skip_if_oc_offline()

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
    "httr2_response"
  )
})

test_that("oc_get_memoise memoises", {
  skip_on_cran()
  skip_if_offline("httpbin.org")

  oc_get_memoise("https://httpbin.org/get")
  tm <- system.time({
    oc_get_memoise("https://httpbin.org/get")
  })
  expect_lt(tm["elapsed"], 0.5)
})
