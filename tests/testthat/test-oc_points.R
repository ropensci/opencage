# Test oc_points ----------------------------------------------------------

test_that("oc_points works with numeric", {
  pnts1 <- oc_points(-5.6, 51.2)
  expect_type(pnts1, "list")
  expect_type(pnts1[[1]], "double")
  expect_length(pnts1[[1]], 2)
  expect_equal(unlist(pnts1), c(latitude = -5.6, longitude = 51.2))
  expect_output(
    object = print(pnts1),
    regexp = "latitude\\s+longitude\\s+\\n\\s+-5.6\\s+51.2"
  )
})

test_that("oc_points works with data.frame", {
  xdf <-
    data.frame(
      y = c(54.0,  42.73),
      x = c(10.3, -78.81)
    )

  pnts2 <- oc_points(data = xdf, latitude = y, longitude = x)
  expect_type(pnts2, "list")
  expect_type(pnts2[[1]], "double")
  expect_type(pnts2[[2]], "double")
  expect_length(pnts2[[1]], 2)
  expect_length(pnts2[[2]], 2)
  expect_equal(unlist(pnts2[1]), c(latitude = 54.0, longitude = 10.3))
  expect_equal(unlist(pnts2[2]), c(latitude =  42.73, longitude = -78.81))
})

test_that("oc_points.default gives informative error message", {
  expect_error(
    object = oc_points("one", "two"),
    regexp = "Can't create a list of points",
    fixed = TRUE
    )
})

# Test checks for oc_points -------------------------------------------------

test_that("oc_point checks point", {
  expect_error(
    oc_points(NA_real_, 51.280430),
    "Every `point` element must be non-missing."
  )
  expect_error(
    oc_points(-0.563160, "51.280430"),
    "Every `point` must be a numeric vector."
  )
  expect_error(
    oc_points(-0.563160, 51280430),
    "Every `longitude` must be between -180 and 180."
  )
  expect_error(
    oc_points(-563160, 51.280430),
    "Every `latitude` must be between -90 and 90."
  )
})
