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

## Test oc_mask_key ##

test_that("oc_mask_key masks key", {
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))
  expect_match(oc_mask_key(key_200), "OPENCAGE_KEY", fixed = TRUE)
})

## Test oc_key_present ##

test_that("oc_key_present detects if key is present", {
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))
  expect_true(oc_key_present())
})

test_that("oc_key_present detects if key is not present", {
  withr::local_envvar(c("OPENCAGE_KEY" = ""))
  expect_false(oc_key_present())

  withr::local_envvar(c("OPENCAGE_KEY" = "string_but_no_key!!!11"))
  expect_false(oc_key_present())
})
