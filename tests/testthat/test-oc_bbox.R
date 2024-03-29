# Test oc_bbox ------------------------------------------------------------

test_that("oc_bbox works with numeric", {
  bbox1 <- oc_bbox(-5.6, 51.2, 0.2, 51.6)
  expect_type(bbox1, "list")
  expect_s3_class(bbox1[[1]], "bbox")
  expect_identical(
    unlist(bbox1),
    c(xmin = -5.6, ymin = 51.2, xmax = 0.2, ymax = 51.6)
  )
  expect_output(
    object = print(bbox1),
    regexp = "xmin\\s+ymin\\s+xmax\\s+ymax\\s+\\n-5.6\\s+51.2\\s+0.2\\s+51.6"
  )
})

test_that("oc_bbox works with data.frame", {
  xdf <-
    data.frame(
      northeast_lat = c(54.0, 42.73),
      northeast_lng = c(10.3, -78.81),
      southwest_lat = c(53.3, 42.70),
      southwest_lng = c(8.1, -78.86)
    )

  bbox2 <-
    oc_bbox(
      xdf,
      southwest_lng,
      southwest_lat,
      northeast_lng,
      northeast_lat
    )
  expect_type(bbox2, "list")
  expect_s3_class(bbox2[[1]], "bbox")
  expect_identical(
    unlist(bbox2[1]),
    c(xmin = 8.1, ymin = 53.3, xmax = 10.3, ymax = 54.0)
  )
  expect_identical(
    unlist(bbox2[2]),
    c(xmin = -78.86, ymin = 42.70, xmax = -78.81, ymax = 42.73)
  )
})

test_that("oc_bbox works with simple features bbox", {
  skip_if_not_installed("sf")

  sfbbox <-
    sf::st_bbox(
      c(xmin = 16.1, xmax = 16.6, ymax = 48.6, ymin = 47.9),
      crs = 4326
    )
  ocbbox <- oc_bbox(sfbbox)

  expect_type(ocbbox, "list")
  expect_s3_class(ocbbox[[1]], "bbox")
  expect_identical(
    unlist(ocbbox),
    c(xmin = 16.1, ymin = 47.9, xmax = 16.6, ymax = 48.6)
  )

  sfbbox_3857 <-
    sf::st_bbox(
      c(xmin = 1792244, ymin = 6090234, xmax = 1847904, ymax = 6207260),
      crs = 3857
    )
  expect_error(
    object = oc_bbox(sfbbox_3857),
    regexp = "The coordinate reference system of `bbox` must be EPSG 4326."
  )
})

test_that("oc_bbox.default gives informative error message", {
  expect_error(
    object = oc_bbox(TRUE),
    regexp = "Can't create a list of bounding boxes",
    fixed = TRUE
  )
})

# Test checks for oc_bbox -------------------------------------------------

test_that("oc_bbox checks bbox", {
  expect_error(
    oc_bbox(NA_real_, 51.280430, 0.278970, 51.683979),
    "Every `bbox` element must be non-missing."
  )
  expect_error(
    oc_bbox(-0.563160, "51.280430", 0.278970, 51.683979),
    "Every `ymin` must be numeric."
  )
  expect_error(
    oc_bbox(-563160, 51.280430, 0.278970, 51.683979),
    "`xmin` must be between -180 and 180."
  )
  expect_error(
    oc_bbox(-0.563160, 51280430, 0.278970, 51.683979),
    "`ymin` must be between -90 and 90."
  )
  expect_error(
    oc_bbox(-0.563160, 51.280430, 278970, 51.683979),
    "`xmax` must be between -180 and 180."
  )
  expect_error(
    oc_bbox(-0.563160, 51.280430, 0.278970, 51683979),
    "`ymax` must be between -90 and 90."
  )
  expect_error(
    oc_bbox(0.563160, 51.280430, 0.278970, 51.683979),
    "`xmin` must always be smaller than `xmax`"
  )
  expect_error(
    oc_bbox(-0.563160, 53.280430, 0.278970, 51.683979),
    "`ymin` must always be smaller than `ymax`"
  )
})
