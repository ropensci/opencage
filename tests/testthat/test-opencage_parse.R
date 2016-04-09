library("opencage")
context("opencage_parse")

test_that("opencage_parse returns what it should for both functions",{
  skip_on_cran()
  results <- opencage_forward(placename = "Sarzeau", key = Sys.getenv("OPENCAGE_KEY", ""))
  expect_is(results, "list")
  expect_is(results[["results"]], "tbl_df")
  expect_is(results[["total_results"]], "integer")
  expect_is(results[["time_stamp"]], "POSIXct")
  expect_equal(length(results), 3)

  results <- opencage_reverse(longitude = 0, latitude = 0,
                              limit = 2, key = Sys.getenv("OPENCAGE_KEY"))
  expect_is(results, "list")
  expect_is(results[["results"]], "tbl_df")
  expect_is(results[["total_results"]], "integer")
  expect_is(results[["time_stamp"]], "POSIXct")
  expect_equal(length(results), 3)
})
