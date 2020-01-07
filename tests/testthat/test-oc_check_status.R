## Test oc_check_status ##


test_that("oc_check_status returns 400 error if request is invalid", {
  skip_on_cran()
  skip_if_offline()

  # Both shouldn't happen since we oc_check_query
  expect_error(
    oc_process(latitude = 280, longitude = 0, return = "json_list"),
    "HTTP failure: 400"
  )
  expect_error(
    oc_process(placename = "", return = "json_list"),
    "HTTP failure: 400"
  )
})

test_that("oc_check_status returns 401 error if key is invalid", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    oc_reverse(latitude = 0, longitude = 0, key = "thisisaninvalidkey"),
    "HTTP failure: 401"
  )
})

test_that("oc_check_status returns 402 error if quota exceeded", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    oc_reverse(latitude = 0, longitude = 0, key = key_402),
    "HTTP failure: 402"
  )
})

test_that("oc_check_status returns 403 error if key is blocked", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    oc_reverse(latitude = 0, longitude = 0, key = key_403),
    "HTTP failure: 403"
  )
})

test_that("oc_check_status returns 429 error if rate limit is exceeded", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    oc_reverse(latitude = 0, longitude = 0, key = key_429),
    "HTTP failure: 429"
  )
})
