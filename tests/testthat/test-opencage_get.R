library("opencage")
context("opencage_get")
test_that("opencage_get returns a response object",{
  expect_is(opencage_get(list(placename = "Sarzeau",
                              key = Sys.getenv("OPENCAGE_KEY"))),
            "response")
})
