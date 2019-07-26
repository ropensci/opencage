## Test oc_check_query: error messages ##

test_that("oc_check_query checks placename", {
  expect_error(
    oc_check_query(
      placename = 222,
      key = "32randomlettersanddigits12345678"
    ),
    "`placename` must be a character vector."
  )
})

test_that("oc_check_query checks latitude", {
  expect_error(
    oc_check_query(
      latitude = 433,
      longitude = 51.11892,
      key = "32randomlettersanddigits12345678"
    ),
    "Every `latitude` must be numeric and between -90 and 90."
  )
})

test_that("oc_check_query checks longitude", {
  expect_error(
    oc_check_query(
      latitude = 43,
      longitude = 5111892,
      key = "32randomlettersanddigits12345678"
    ),
    "Every `longitude` must be numeric and between -180 and 180."
  )
})

test_that("oc_check_query checks key", {
  expect_error(
    oc_check_query(
      latitude = 43.3,
      longitude = 51.11892,
      key = 45
    ),
    "`key` must be a character vector."
  )
  expect_error(
    oc_check_query(
      latitude = 43.3,
      longitude = 51.11892,
      key = c("fakekey1", "fakekey2")
    ),
    "`key` must be a vector of length one."
  )
  expect_error(
    oc_check_query(
      latitude = 43.3,
      longitude = 51.11892,
      key = NULL
    ),
    "A `key` must be provided."
  )
})

test_that("oc_check_query checks bounds", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      bounds = list(c(-5, 51, 0))
    ),
    "Every `bbox` must be a numeric vector of length 4."
  )
})

test_that("oc_check_query checks countrycode", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      countrycode = "notacountrycode"
    ),
    "Every `countrycode` must be valid.*"
  )
})

test_that("oc_check_query ok with lower case countrycode", {
  expect_silent(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      countrycode = "fr"
    )
  )
  expect_silent(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      countrycode = "FR"
    )
  )
})

test_that("oc_check_query checks language", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      language = "notalanguagecode"
    ),
    "languagecode"
  )

  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      language = "fr-NOTACOUNTRYCODE"
    ),
    "countrycode"
  )
})


test_that("oc_check_query checks limit", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      limit = 200
    ),
    "`limit` must be an integer between 1 and 100."
  )
})

test_that("oc_check_query checks min_confidence", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      min_confidence = 20
    ),
    "`min_confidence` must be an integer between 1 and 10."
  )
})

test_that("oc_check_query checks no_annotations", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      no_annotations = "yes"
    ),
    "`no_annotations` must be a logical vector."
  )
})

test_that("oc_check_query checks no_dedupe", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      no_dedupe = "yes"
    ),
    "`no_dedupe` must be a logical vector."
  )
})

test_that("oc_check_query checks no_record", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      no_record = "yes"
    ),
    "`no_record` must be a logical vector."
  )
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      no_record = c(TRUE, FALSE)
    ),
    "`no_record` must be a vector of length one."
  )
})

test_that("oc_check_query checks abbrv", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      abbrv = "yes"
    ),
    "`abbrv` must be a logical vector."
  )
})

test_that("oc_check_query checks add_request", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      key = "32randomlettersanddigits12345678",
      add_request = "yes"
    ),
    "`add_request` must be a logical vector."
  )
})
