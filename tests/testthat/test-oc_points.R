library("opencage")
context("oc_points")

test_that("oc_points works with numeric", {
  pnts1 <- oc_points(-5.6, 51.2)
  expect_type(
    pnts1,
    "list"
  )
  expect_s3_class(
    pnts1,
    "point_list"
  )
  expect_is(
    pnts1[[1]],
    "numeric"
  )
  expect_equal(
    unlist(pnts1),
    c(
      latitude = -5.6,
      longitude = 51.2
    )
  )
})

test_that("oc_points works with data.frame", {
  xdf <-
    data.frame(
      y = c(54.0,  42.73),
      x = c(10.3, -78.81)
    )

  pnts2 <-
    oc_points(data = xdf,
            latitude = y,
            longitude = x
    )
  expect_type(
    pnts2,
    "list"
  )
  expect_s3_class(
    pnts2,
    "point_list"
  )
  expect_is(
    pnts2[[1]],
    "numeric"
  )
  expect_equal(
    unlist(pnts2[1]),
    c(
      latitude = 54.0,
      longitude = 10.3
    )
  )
  expect_equal(
    unlist(pnts2[2]),
    c(
      latitude =  42.73,
      longitude = -78.81
    )
  )
})
