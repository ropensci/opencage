## Test oc_config ##

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
