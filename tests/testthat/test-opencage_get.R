library("opencage")
context("opencage_get")
test_that("opencage_get returns a response object",{
  skip_on_cran()
  expect_is(opencage_get(list(placename = "Sarzeau",
                              key = Sys.getenv("OPENCAGE_KEY"))),
            "response")
})

test_that("opencage_get returns a response object for Namibia NA countrycode",{
  skip_on_cran()
  expect_is(opencage_get(list(placename = "Windhoek",
                              key = Sys.getenv("OPENCAGE_KEY"),
                              country = "NA")),
            "response")
})
