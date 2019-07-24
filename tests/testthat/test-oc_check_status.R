## Test oc_check_status ##

# keys from https://opencagedata.com/api#codes or
# https://github.com/OpenCageData/opencagedata-misc-docs/blob/master/library-guidelines.md # nolint
key_402 <- "4372eff77b8343cebfc843eb4da4ddc4" # always returns a 402 responce
key_403 <- "2e10e5e828262eb243ec0b54681d699a" # always returns a 403 responce

vcr::use_cassette("oc_check_status_402", {
  test_that("oc_check_status returns 402 error if quota exceeded", {
    expect_error(
      oc_reverse(latitude = 0, longitude = 0, key = key_402),
      "HTTP failure: 402"
    )
  })
})

vcr::use_cassette("oc_check_status_403", {
  test_that("oc_check_status returns 403 error if key is blocked", {
    expect_error(
      oc_reverse(latitude = 0, longitude = 0, key = key_403),
      "HTTP failure: 403"
    )
  })
})

vcr::use_cassette("oc_check_status_401", {
  test_that("oc_check_status returns 401 error if key is invalid", {
    expect_error(
      oc_reverse(latitude = 0, longitude = 0, key = "thisisaninvalidkey"),
      "HTTP failure: 401"
    )
  })
})

# Shouldn't happen since we oc_check coordinates
vcr::use_cassette("oc_check_status_400", {
  test_that("oc_check_status returns 400 error if coordinates are invalid", {
    skip_if_no_key()

    expect_error(
      oc_process(latitude = 280, longitude = 0, return = "json_list"),
      "HTTP failure: 400"
    )
  })
})
