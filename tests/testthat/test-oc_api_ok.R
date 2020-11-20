test_that("oc_api_ok", {
  skip_on_cran()
  skip_if_offline("httpbin.org")

  # API ok
  expect_true(oc_api_ok())

  # not ok
  expect_false(oc_api_ok("https://httpbin.org/status/500"))
})
