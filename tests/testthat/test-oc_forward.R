## Test oc_forward functions ##

library(tibble)
locations <- c("Nantes", "Hamburg", "Los Angeles")
df <- tibble(id = 1:3, loc = locations)
df2 <- add_column(df,
                  bounds = oc_bbox(xmin = c(-72, -80, -76),
                                   ymin = c(45, 42, 8),
                                   xmax = c(-70, -78, -74),
                                   ymax = c(46, 43, 10)),
                  proximity = oc_points(latitude = c(45.5, 42.5, 9),
                                        longitude = c(-71, -79, -75)),
                  countrycode = c("ca", "us", "co"),
                  language = c("de", "fr", "es"),
                  limit = 1:3,
                  confidence = c(7, 5, 3),
                  annotation = c(FALSE, TRUE, TRUE),
                  abbrv = c(FALSE, FALSE, TRUE))


# oc_forward --------------------------------------------------------------

test_that("oc_forward works", {
  skip_on_cran()
  skip_if_offline()

  res1 <- oc_forward(locations)
  expect_type(res1, "list")
  expect_equal(length(res1), 3)
  expect_s3_class(res1[[1]], c("tbl_df", "tbl", "data.frame"))
})

test_that("oc_forward returns correct type", {
  skip_on_cran()
  skip_if_offline()

  # json_list
  res2 <- oc_forward(locations, return = "json_list")
  expect_type(res2, "list")
  expect_equal(length(res2), 3)
  expect_type(res2[[1]], "list")

  # geojson_list
  res3 <- oc_forward(locations, return = "geojson_list")
  expect_type(res3, "list")
  expect_equal(length(res3), 3)
  expect_s3_class(res3[[1]], "geo_list")
})


# oc_forward_df -----------------------------------------------------------

test_that("oc_forward_df works", {
  skip_on_cran()
  skip_if_offline()

  tbl1 <- oc_forward_df(df, loc)
  expect_s3_class(tbl1, c("tbl_df", "tbl", "data.frame"))
  expect_equal(nrow(tbl1), 3)

  tbl2 <- oc_forward_df(tibble(loc = "Nantes"), loc)
  expect_s3_class(tbl2, c("tbl_df", "tbl", "data.frame"))
  expect_equal(nrow(tbl2), 1)
})

test_that("output arguments work", {
  skip_on_cran()
  skip_if_offline()

  expect_equal(names(oc_forward_df(df, loc, bind_cols = TRUE)),
               c("id", "loc", "lat", "lng", "formatted"))
  expect_equal(names(oc_forward_df(df, loc, bind_cols = FALSE)),
               c("query", "lat", "lng", "formatted"))
  expect_gt(ncol(oc_forward_df(df, loc, output = "all")), 5)
  expect_gt(ncol(oc_forward_df(df, loc, bind_cols = FALSE, output = "all")), 5)
})

test_that("tidyeval works for arguments", {
  skip_on_cran()
  skip_if_offline()

  noarg <- oc_forward_df(df2, loc, bind_cols = FALSE)

  ## bounds, proximity and countrycode
  bounds <- oc_forward_df(df2, loc, bounds = bounds, bind_cols = FALSE)
  prx <- oc_forward_df(df2, loc, proximity = proximity, bind_cols = FALSE)
  cc <- oc_forward_df(df2, loc, countrycode = countrycode, bind_cols = FALSE)
  expect_false(isTRUE(all.equal(bounds, noarg)))
  expect_false(isTRUE(all.equal(prx, noarg)))
  expect_false(isTRUE(all.equal(cc, noarg)))
  expect_equal(bounds, prx)
  expect_equal(bounds, cc)

  # language
  lang <- oc_forward_df(df2, loc, language = language, output = "all")
  expect_equal(lang$country,
               c("Frankreich", "Allemagne", "Estados Unidos de América"))

  # limit
  limit <- oc_forward_df(df2, loc, limit = limit)
  expect_equal(nrow(limit), 6)
  expect_equal(limit$id, c(1, 2, 2, 3, 3, 3))

  # min_confidence
  confidence <- oc_forward_df(df2, loc,
                              min_confidence = confidence,
                              bind_cols = FALSE)
  expect_false(isTRUE(all.equal(confidence, noarg)))
  expect_false(isTRUE(all.equal(confidence[1, ], noarg[1, ])))
  expect_false(isTRUE(all.equal(confidence[2, ], noarg[2, ])))
  expect_false(isTRUE(all.equal(confidence[3, ], noarg[3, ])))

  #no_annotations
  ann <- oc_forward_df(df2, loc, output = "all",
                       bind_cols = FALSE,
                       no_annotations = annotation)
  expect_gt(ncol(ann), 30)
  expect_equal(ann$currency_name, c("Euro", NA, NA))

  # abbrv
  abbrv <- oc_forward_df(df2, loc,
                         abbrv = abbrv,
                         bind_cols = FALSE)
  expect_false(isTRUE(all.equal(abbrv, noarg)))
  expect_true(all.equal(abbrv[1, ], noarg[1, ]))
  expect_true(all.equal(abbrv[2, ], noarg[2, ]))
  expect_false(isTRUE(all.equal(abbrv[3, ], noarg[3, ])))
})

# Checks ------------------------------------------------------------------

test_that("Check that placename is present work", {
  # oc_forward
  expect_error(oc_forward(), "`placename` must be provided.")
  expect_error(oc_forward(placename = NULL), "`placename` must be provided.")

  # oc_forward_df
  expect_error(oc_forward_df(df), "`placename` must be provided.")
  expect_error(oc_forward_df(df, NULL), "`placename` must be provided.")
})
