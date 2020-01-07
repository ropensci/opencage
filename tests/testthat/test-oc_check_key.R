## Test oc_check_key ##

test_that("oc_check_key checks key", {
  expect_error(
    oc_check_key(
      key = 45
    ),
    "`key` must be a character vector."
  )
  expect_error(
    oc_check_key(
      key = c(key_200, key_402)
    ),
    "`key` must be a vector of length one."
  )
  expect_error(
    oc_check_key(
      key = NULL
    ),
    "`key` must be provided."
  )
  expect_error(
    oc_check_key(substr(key_200, 1L, 30L)),
    "32 character long, alphanumeric string"
  )
})
