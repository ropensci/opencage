library("opencage")
context("opencage_query_check")

test_that("opencage_query_check checks latitude",{
  skip_on_cran()
  expect_error(opencage_reverse(latitude = 433,
                                longitude = 51.11892,
                                key = Sys.getenv("OPENCAGE_KEY")),
               "Latitude should be between -90 and 90.")
})

test_that("opencage_query_check checks longitude",{
  skip_on_cran()
  expect_error(opencage_reverse(latitude = 43,
                                longitude = 5111892,
                                key = Sys.getenv("OPENCAGE_KEY")),
               "Longitude should be between -180 and 180.")
})

test_that("opencage_query_check checks placename",{
  skip_on_cran()
          expect_error(opencage_forward(placename = 222,
                                        key = Sys.getenv("OPENCAGE_KEY")),
                       "Placename should be a character.")
          })

test_that("opencage_query_check checks key",{
  skip_on_cran()
          expect_error(opencage_reverse(latitude = 43.3,
                                        longitude = 51.11892,
                                        key = 45),
                       "Key should be a character.")
  })

test_that("opencage_query_check checks bound",{
  skip_on_cran()
  expect_error(opencage_forward(placename = "Sarzeau",
                                bound = c(-563160,51.280430,0.278970,51.683979),
                                key = Sys.getenv("OPENCAGE_KEY")),
               "min long should be between -180 and 180.")

  expect_error(opencage_forward(placename = "Sarzeau",
                                bound = c(-0.563160,51280430,0.278970,51.683979),
                                key = Sys.getenv("OPENCAGE_KEY")),
               "min lat should be between -90 and 90.")

  expect_error(opencage_forward(placename = "Sarzeau",
                                bound = c(-0.563160,51.280430,278970,51.683979),
                                key = Sys.getenv("OPENCAGE_KEY")),
               "max long should be between -180 and 180.")

  expect_error(opencage_forward(placename = "Sarzeau",
                                bound = c(-0.563160,51.280430,0.278970,51683979),
                                key = Sys.getenv("OPENCAGE_KEY")),
               "max lat should be between -90 and 90.")

  expect_error(opencage_forward(placename = "Sarzeau",
                                bound = c(0.563160,51.280430,0.278970,51.683979),
                                key = Sys.getenv("OPENCAGE_KEY")),
               "min long has to be smaller than max long")

  expect_error(opencage_forward(placename = "Sarzeau",
                                bound = c(-0.563160,53.280430,0.278970,51.683979),
                                key = Sys.getenv("OPENCAGE_KEY")),
               "min lat has to be smaller than max lat")

  expect_error(opencage_forward(placename = "Sarzeau",
                                bound = c(53.280430,0.278970,51.683979),
                                key = Sys.getenv("OPENCAGE_KEY")),
               "bounds should be a vector of 4 numeric values.")
})

test_that("opencage_query_check checks countrycode",{
  skip_on_cran()
  expect_error(opencage_forward(placename = "Sarzeau",
                                countrycode = "notacountrycode",
                                key = Sys.getenv("OPENCAGE_KEY")),
               "countrycode does not have a valid value.")
})

test_that("opencage_query_check checks language",{
  skip_on_cran()
  expect_error(opencage_forward(placename = "Sarzeau",
                                language = "notalanguagecode",
                                key = Sys.getenv("OPENCAGE_KEY")),
               "The language code is not valid.")

  expect_error(opencage_forward(placename = "Sarzeau",
                                language = "fr-NOTACOUNTRYCODE",
                                key = Sys.getenv("OPENCAGE_KEY")),
               "The country part of language is not valid.")
})


test_that("opencage_query_check checks min_confidence",{
  skip_on_cran()
  expect_error(opencage_forward(placename = "Sarzeau",
                                min_confidence = 20,
                                key = Sys.getenv("OPENCAGE_KEY")),
               "min_confidence should be an integer between 1 and 10.")
})

test_that("opencage_query_check checks limit",{
  skip_on_cran()
  expect_error(opencage_forward(placename = "Sarzeau",
                                limit = 200,
                                key = Sys.getenv("OPENCAGE_KEY")),
               "limit should be an integer between 1 and 100.")
})

test_that("opencage_query_check checks no_annotations",{
  skip_on_cran()
  expect_error(opencage_forward(placename = "Sarzeau",
                                no_annotations = "yes",
                                key = Sys.getenv("OPENCAGE_KEY")),
               "no_annotations has to be a logical.")
})

test_that("opencage_query_check checks no_dedupe",{
  skip_on_cran()
  expect_error(opencage_forward(placename = "Sarzeau",
                                no_dedupe = "yes",
                                key = Sys.getenv("OPENCAGE_KEY")),
               "no_dedupe has to be a logical.")
})

test_that("opencage_query_check checks no_record",{
  skip_on_cran()
  expect_error(opencage_forward(placename = "Sarzeau",
                                no_record = "yes",
                                key = Sys.getenv("OPENCAGE_KEY")),
               "no_record has to be a logical.")
})


test_that("opencage_query_check checks abbrv",{
  skip_on_cran()
  expect_error(opencage_forward(placename = "Sarzeau",
                                abbrv = "yes",
                                key = Sys.getenv("OPENCAGE_KEY")),
               "abbrv has to be a logical.")
})

test_that("opencage_query_check checks add_request",{
  skip_on_cran()
  expect_error(opencage_forward(placename = "Sarzeau",
                                add_request = "yes",
                                key = Sys.getenv("OPENCAGE_KEY")),
               "add_request has to be a logical.")
})
