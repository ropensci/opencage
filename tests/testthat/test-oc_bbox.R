library("opencage")
context("oc_bbox")

test_that("oc_bbox works with numeric", {
  bbox1 <- oc_bbox(-5.6, 51.2, 0.2, 51.6)
  expect_type(
    bbox1,
    "list"
  )
  expect_s3_class(
    bbox1,
    "bbox_list"
  )
  expect_s3_class(
    bbox1[[1]],
    "bbox"
  )
  expect_equal(
    unlist(bbox1),
    c(
      xmin = -5.6,
      ymin = 51.2,
      xmax =  0.2,
      ymax = 51.6
    )
  )
})

test_that("oc_bbox works with data.frame", {
  xdf <-
    data.frame(
      northeast_lat = c(54.0,  42.73),
      northeast_lng = c(10.3, -78.81),
      southwest_lat = c(53.3,  42.70),
      southwest_lng = c( 8.1, -78.86)
    )

  bbox2 <-
    oc_bbox(xdf,
            southwest_lng,
            southwest_lat,
            northeast_lng,
            northeast_lat
    )
  expect_type(
    bbox2,
    "list"
  )
  expect_s3_class(
    bbox2,
    "bbox_list"
  )
  expect_s3_class(
    bbox2[[1]],
    "bbox"
  )
  expect_equal(
    unlist(bbox2[1]),
    c(
      xmin =  8.1,
      ymin = 53.3,
      xmax = 10.3,
      ymax = 54.0
    )
  )
  expect_equal(
    unlist(bbox2[2]),
    c(
      xmin = -78.86,
      ymin =  42.70,
      xmax = -78.81,
      ymax =  42.73
    )
  )
})

test_that("oc_bbox works with simple features bbox", {
  skip_if_not_installed("sf")
  sfbbox <-
    sf::st_bbox(c(
      xmin = 16.1,
      xmax = 16.6,
      ymax = 48.6,
      ymin = 47.9
    ),
    crs = 4326)
  ocbbox <- oc_bbox(sfbbox)

  expect_type(
    ocbbox,
    "list"
  )
  expect_s3_class(
    ocbbox,
    "bbox_list"
  )
  expect_s3_class(
    ocbbox[[1]],
    "bbox"
  )
  expect_equal(
    unlist(ocbbox),
    c(
      xmin = 16.1,
      ymin = 47.9,
      xmax = 16.6,
      ymax = 48.6
    )
  )
})
