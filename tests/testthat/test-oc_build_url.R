test_that("oc_build_url returns a list", {
  expect_type(
    oc_build_url(
      query_par = list(placename = "Haarlem"),
      endpoint = "json"
    ),
    "list"
  )
})
