## Test oc_build_url ##

test_that("oc_build_url returns a string", {
  expect_type(
    oc_build_url(
      query_par = list(placename = "Haarlem"),
      endpoint = "json"
    ),
    "character"
  )
})
