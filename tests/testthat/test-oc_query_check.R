library("opencage")
context("oc_query_check")

test_that("oc_query_check checks latitude", {
  expect_error(
    oc_query_check(
      latitude = 433,
      longitude = 51.11892
    ),
    "Latitude should be between -90 and 90."
  )
})

test_that("oc_query_check checks longitude", {
  expect_error(
    oc_query_check(
      latitude = 43,
      longitude = 5111892
    ),
    "Longitude should be between -180 and 180."
  )
})

test_that("oc_query_check checks placename", {
  expect_error(
    oc_query_check(
      placename = 222
    ),
    "Placename should be a character."
  )
})

test_that("oc_query_check checks key", {
  expect_error(
    oc_query_check(
      latitude = 43.3,
      longitude = 51.11892,
      key = 45
    ),
    "Key should be a character."
  )
})

test_that("oc_query_check checks bound", {
  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      bound = c(-563160, 51.280430, 0.278970, 51.683979)
    ),
    "min long should be between -180 and 180."
  )

  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      bound = c(-0.563160, 51280430, 0.278970, 51.683979)
    ),
    "min lat should be between -90 and 90."
  )

  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      bound = c(-0.563160, 51.280430, 278970, 51.683979)
    ),
    "max long should be between -180 and 180."
  )

  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      bound = c(-0.563160, 51.280430, 0.278970, 51683979)
    ),
    "max lat should be between -90 and 90."
  )

  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      bound = c(0.563160, 51.280430, 0.278970, 51.683979)
    ),
    "min long has to be smaller than max long"
  )

  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      bound = c(-0.563160, 53.280430, 0.278970, 51.683979)
    ),
    "min lat has to be smaller than max lat"
  )

  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      bound = c(53.280430, 0.278970, 51.683979)
    ),
    "bounds should be a vector of 4 numeric values."
  )
})

test_that("oc_query_check checks countrycode", {
  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      countrycode = "notacountrycode"
    ),
    "countrycode does not have a valid value."
  )
})

test_that("oc_query_check ok with lower case countrycode", {
  expect_equal(
   oc_query_check(
      placename = "Sarzeau",
      countrycode = "fr"
    ),
   oc_query_check(
     placename = "Sarzeau",
     countrycode = "FR"
   )
  )
})

test_that("oc_query_check checks language", {
  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      language = "notalanguagecode"
    ),
    "The language code is not valid."
  )

  expect_error(
    opencage_forward(
      placename = "Sarzeau",
      language = "fr-NOTACOUNTRYCODE"
    ),
    "The country part of language is not valid."
  )
})


test_that("oc_query_check checks min_confidence", {
  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      min_confidence = 20
    ),
    "min_confidence should be an integer between 1 and 10."
  )
})

test_that("oc_query_check checks limit", {
  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      limit = 200
    ),
    "limit should be an integer between 1 and 100."
  )
})

test_that("oc_query_check checks no_annotations", {
  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      no_annotations = "yes"
    ),
    "no_annotations has to be a logical."
  )
})

test_that("oc_query_check checks no_dedupe", {
  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      no_dedupe = "yes"
    ),
    "no_dedupe has to be a logical."
  )
})

test_that("oc_query_check checks no_record", {
  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      no_record = "yes"
    ),
    "no_record has to be a logical."
  )
})


test_that("oc_query_check checks abbrv", {
  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      abbrv = "yes"
    ),
    "abbrv has to be a logical."
  )
})

test_that("oc_query_check checks add_request", {
  expect_error(
    oc_query_check(
      placename = "Sarzeau",
      add_request = "yes"
    ),
    "add_request has to be a logical."
  )
})
