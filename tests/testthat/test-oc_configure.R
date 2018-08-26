library("opencage")
context("oc_configure")

timer <- function(expr) {
  system.time(expr)[["elapsed"]]
}

oc_get_limited_test <- function(reps) {
  replicate(
    reps,
    oc_get_limited("http://httpbin.org/get")
  )
}

test_that("oc_configure updates rate limit of oc_get_limit", {
  rps <- 5L
  oc_configure(max_rate_per_sec = rps)
  expect_gt(timer(oc_get_limited_test(rps + 1)), 1)
  rps <- 3L
  oc_configure(max_rate_per_sec = rps)
  expect_gt(timer(oc_get_limited_test(rps + 1)), 1)
  }
)
