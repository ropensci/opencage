test_that("oc_api_ok", {
  # API ok
  vcr::use_cassette("oc_api_ok", {
    ok <- oc_api_ok()
  })
  expect_true(ok)

  # not ok
  vcr::use_cassette("oc_api_not_ok", {
    not_ok <- oc_api_ok("https://httpbin.org/status/500")
  })
  expect_false(not_ok)
})
