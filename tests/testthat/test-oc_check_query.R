## Test oc_check_query: error messages ##

test_that("oc_check_query checks placename", {
  expect_error(
    oc_check_query(
      placename = 222
    ),
    "`placename` must be a character vector."
  )
})

test_that("oc_check_query checks latitude", {
  expect_error(
    oc_check_query(
      latitude = "fortytwo",
      longitude = 51.11892
    ),
    "Every `latitude` must be numeric."
  )
  expect_error(
    oc_check_query(
      latitude = 433,
      longitude = 51.11892
    ),
    "Every `latitude` must be between -90 and 90."
  )
})

test_that("oc_check_query checks longitude", {
  expect_error(
    oc_check_query(
      latitude = 43,
      longitude = TRUE
    ),
    "Every `longitude` must be numeric."
  )
  expect_error(
    oc_check_query(
      latitude = 43,
      longitude = 5111892
    ),
    "Every `longitude` must be between -180 and 180."
  )
})

test_that("oc_check_query checks bounds", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      bounds = list(c(-5, 51, 0))
    ),
    "Every `bbox` must be a numeric vector of length 4."
  )
})

test_that("oc_check_query checks proximity", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      proximity = list(c(47.5, longitude = -2.7)) # latitude not named
    ),
    "must be named 'latitude' and 'longitude'"
  )
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      proximity = list(c(longitude = 47.5, -2.7)) # longitude not named
    ),
    "must be named 'latitude' and 'longitude'"
  )
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
    proximity = list(c(1, 2, 3)) # too many coordinates
    ),
    "Every `proximity` point must be a numeric vector of length 2."
  )
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      proximity = list(c(1)) # too few coordinates
    ),
    "Every `proximity` point must be a numeric vector of length 2."
  )
  expect_error(
    oc_check_query(
      placename = c("Sarzeau", "Biarritz"),
      proximity = c(1, 2) # not wrapped in a list
    ),
    "Every `proximity` point must be a numeric vector of length 2."
  )
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      proximity = list(c(latitude = -91, longitude = 2)) # latitude < -90
    ),
    "Every `latitude` must be between -90 and 90.",
    fixed = TRUE
  )
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      proximity = list(c(latitude = 0, longitude = 181)) # longitude > 180
    ),
    "Every `longitude` must be between -180 and 180.",
    fixed = TRUE
  )
})

test_that("oc_check_query checks countrycode", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      countrycode = "notacountrycode"
    ),
    "Every `countrycode` must be valid.*"
  )
})

test_that("oc_check_query ok with lower case countrycode", {
  expect_silent(
    oc_check_query(
      placename = "Sarzeau",
      countrycode = "fr"
    )
  )
  expect_silent(
    oc_check_query(
      placename = "Sarzeau",
      countrycode = "FR"
    )
  )
})

test_that("oc_check_query checks language", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      language = TRUE
    ),
    "`language` must be a character vector."
  )
})

test_that("oc_check_query checks limit", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      limit = 200
    ),
    "`limit` must be an integer between 1 and 100."
  )
})

test_that("oc_check_query checks min_confidence", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      min_confidence = 20
    ),
    "`min_confidence` must be an integer between 1 and 10."
  )
})

test_that("oc_check_query checks no_annotations", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      no_annotations = "yes"
    ),
    "`no_annotations` must be a logical vector."
  )
})

test_that("oc_check_query checks roadinfo", {
  expect_error(
    oc_check_query(
      placename = "Afsluitdijk",
      roadinfo = "yes"
    ),
    "`roadinfo` must be a logical vector."
  )
  expect_silent(
    oc_check_query(
      placename = "Afsluitdijk",
      roadinfo = TRUE
    )
  )
})

test_that("oc_check_query checks no_dedupe", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      no_dedupe = "yes"
    ),
    "`no_dedupe` must be a logical vector."
  )
})

test_that("oc_check_query checks abbrv", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      abbrv = "yes"
    ),
    "`abbrv` must be a logical vector."
  )
})

test_that("oc_check_query checks add_request", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      add_request = "yes"
    ),
    "`add_request` must be a logical vector."
  )
})

test_that("oc_check_query checks argument lengths", {
  expect_error(
    oc_check_query(
      placename = "Sarzeau",
      abbrv = c(TRUE, FALSE)
    ),
    "same length as `placename` or `latitude`"
  )
})


# Test oc_check_logical() -------------------------------------------------
test_that("oc_check_logical checks no_record", {
  no_record <- "yes"
  expect_error(
    oc_check_logical(
      variable = no_record,
      check_length_one = TRUE
    ),
    "`no_record` must be a logical vector."
  )

  no_record <- c(TRUE, FALSE)
  expect_error(
    oc_check_logical(
      variable = no_record,
      check_length_one = TRUE
    ),
    "`no_record` must be a vector of length one."
  )

  no_record <- TRUE
  expect_silent(
    oc_check_logical(
      variable = no_record,
      check_length_one = TRUE
    )
  )
})
