## Test oc_config ##

test_that("oc_config sets OPENCAGE_KEY environment variable", {

  # leave envvar untouched
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))
  oc_config()
  expect_equal(Sys.getenv("OPENCAGE_KEY"), key_200)

  # unset key
  withr::local_envvar(c("OPENCAGE_KEY" = ""))
  expect_equal(Sys.getenv("OPENCAGE_KEY"), "")

  # set key directly (or via keyring etc.)
  oc_config(key = key_200)
  expect_equal(Sys.getenv("OPENCAGE_KEY"), key_200)

  # error with empty key
  expect_error(oc_config(key = ""), "(OpenCage API key must be a )*.( string.)")
})

# test rate_sec argument

timer <- function(expr) {
  system.time(expr)[["elapsed"]]
}

oc_get_limited_test <- function(reps) {
  replicate(
    reps,
    oc_get_limited("http://httpbin.org/get")
  )
}

test_that("oc_config updates rate limit of oc_get_limit", {
  skip_on_cran()
  skip_if_offline()

  rps <- 5L
  oc_config(rate_sec = rps)
  t <- timer(oc_get_limited_test(rps + 1))
  expect_gt(t, 1)
  expect_lt(t, 2)


  rps <- 3L
  oc_config(rate_sec = rps)
  t <- timer(oc_get_limited_test(rps + 1))
  expect_gt(t, 1)
  expect_lt(t, 2)
})
