## Test oc_check_status ##

# keys from https://opencagedata.com/api#codes or
# https://github.com/OpenCageData/opencagedata-misc-docs/blob/master/library-guidelines.md # nolint
key_402 <- "4372eff77b8343cebfc843eb4da4ddc4" # always returns a 402 responce
key_403 <- "2e10e5e828262eb243ec0b54681d699a" # always returns a 403 responce
key_429 <- "d6d0f0065f4348a4bdfe4587ba02714b" # always returns a 429 responce

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
