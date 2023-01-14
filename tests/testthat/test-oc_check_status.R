# Test oc_check_status() --------------------------------------------------

test_that("oc_check_status returns no error if HTTP status 200", {
  skip_on_cran()
  skip_if_oc_offline()

  withr::local_envvar(c("OPENCAGE_KEY" = key_200))
  expect_type(
    oc_reverse(latitude = 0, longitude = 0),
    "list"
  )
})

test_that("oc_check_status returns 400 error if request is invalid", {
  skip_if_no_key()
  skip_if_oc_offline()

  # This shouldn't happen since we oc_check_query
  expect_error(
    oc_process(
      latitude = 280,
      longitude = 0,
      return = "json_list"
    ),
    "HTTP failure: 400"
  )

  # We don't send queries with nchar(query) <= 1 to the API, see .oc_process()
  expect_error(
    oc_process(
      placename = "  ",
      return = "json_list"
    ),
    "HTTP failure: 400"
  )
})

test_that("oc_check_status returns 401 error if key is invalid", {
  skip_on_cran()
  skip_if_oc_offline()

  withr::local_envvar(c("OPENCAGE_KEY" = "32charactersandnumbers1234567890"))
  expect_error(
    oc_reverse(latitude = 0, longitude = 0),
    "HTTP failure: 401"
  )
})

test_that("oc_check_status returns 402 error if quota exceeded", {
  skip_on_cran()
  skip_if_oc_offline()

  withr::local_envvar(c("OPENCAGE_KEY" = key_402))
  expect_error(
    oc_reverse(latitude = 0, longitude = 0),
    "HTTP failure: 402"
  )
})

test_that("oc_check_status returns 403 error if key is blocked", {
  skip_on_cran()
  skip_if_oc_offline()

  withr::local_envvar(c("OPENCAGE_KEY" = key_403))
  expect_error(
    oc_reverse(latitude = 0, longitude = 0),
    "HTTP failure: 403"
  )
})

test_that("oc_check_status returns 429 error if rate limit is exceeded", {
  skip_on_cran()
  skip_if_oc_offline()

  withr::local_envvar(c("OPENCAGE_KEY" = key_429))
  expect_error(
    oc_reverse(latitude = 0, longitude = 0),
    "HTTP failure: 429"
  )
})
