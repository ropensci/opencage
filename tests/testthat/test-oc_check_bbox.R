library("opencage")
context("oc_check_bbox")

test_that("oc_check_bbox checks bbox", {
  expect_error(
    oc_check_bbox(NA_real_, 51.280430, 0.278970, 51.683979),
    "Every `bbox` element must be non-missing."
  )

  expect_error(
    oc_check_bbox("-0.563160", 51.280430, 0.278970, 51.683979),
    "Every `bbox` must be a numeric vector."
  )

  expect_error(
    oc_check_bbox(-563160, 51.280430, 0.278970, 51.683979),
    "`xmin` must be between -180 and 180."
  )

  expect_error(
    oc_check_bbox(-0.563160, 51280430, 0.278970, 51.683979),
    "`ymin` must be between -90 and 90."
  )

  expect_error(
    oc_check_bbox(-0.563160, 51.280430, 278970, 51.683979),
    "`xmax` must be between -180 and 180."
  )

  expect_error(
    oc_check_bbox(-0.563160, 51.280430, 0.278970, 51683979),
    "`ymax` must be between -90 and 90."
  )

  expect_error(
    oc_check_bbox(0.563160, 51.280430, 0.278970, 51.683979),
    "`xmin` must be smaller than `xmax`"
  )

  expect_error(
    oc_check_bbox(-0.563160, 53.280430, 0.278970, 51.683979),
    "`ymin` must be smaller than `ymax`"
  )
})
