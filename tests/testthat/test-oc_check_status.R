## Test oc_check_status ##

vcr::use_cassette("oc_check_status_200", {
  test_that("oc_check_status returns no error if HTTP status 200", {

    withr::local_envvar(c("OPENCAGE_KEY" = key_200))
    expect_type(
      oc_reverse(latitude = 0, longitude = 0),
      "list"
    )
  })
})
vcr::use_cassette("oc_check_status_400", {
  test_that("oc_check_status returns 400 error if request is invalid", {

    # Both shouldn't happen since we oc_check_query
    expect_error(
      oc_process(
        latitude = 280,
        longitude = 0,
        return = "json_list"
      ),
      "HTTP failure: 400"
    )

    expect_error(
      oc_process(
        placename = "",
        return = "json_list"
      ),
      "HTTP failure: 400"
    )
  })
})

vcr::use_cassette("oc_check_status_401", {
  test_that("oc_check_status returns 401 error if key is invalid", {

    withr::local_envvar(c("OPENCAGE_KEY" = key_401))
    expect_error(
      oc_reverse(latitude = 0, longitude = 0),
      "HTTP failure: 401"
    )
  })
})

vcr::use_cassette("oc_check_status_402", {
  test_that("oc_check_status returns 402 error if quota exceeded", {

    withr::local_envvar(c("OPENCAGE_KEY" = key_402))
    expect_error(
      oc_reverse(latitude = 0, longitude = 0),
      "HTTP failure: 402"
    )
  })
})

vcr::use_cassette("oc_check_status_403", {
  test_that("oc_check_status returns 403 error if key is blocked", {
    withr::local_envvar(c("OPENCAGE_KEY" = key_403))
    expect_error(
      oc_reverse(latitude = 0, longitude = 0),
      "HTTP failure: 403"
    )
  })
})

vcr::use_cassette("oc_check_status_429", {
  test_that("oc_check_status returns 429 error if rate limit is exceeded", {
    withr::local_envvar(c("OPENCAGE_KEY" = key_429))
    expect_error(
      oc_reverse(latitude = 0, longitude = 0),
      "HTTP failure: 429"
    )
  })
})
