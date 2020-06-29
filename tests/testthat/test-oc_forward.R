## Test oc_forward functions ##

library(tibble)
library(tidyr)
library(dplyr)
locations <- c("Nantes", "Flensburg", "Los Angeles")
df <- tibble(id = 1:3, loc = locations)
df2 <- add_column(df,
                  bounds = oc_bbox(xmin = c(-72, -98, -76),
                                   ymin = c(45, 43, 8),
                                   xmax = c(-70, -90, -74),
                                   ymax = c(46, 49, 10)),
                  proximity = oc_points(latitude = c(45.5, 46, 9),
                                        longitude = c(-71, -95, -75)),
                  countrycode = c("ca", "us", "co"),
                  language = c("de", "fr", "ja"),
                  limit = 1:3,
                  confidence = c(7, 9, 3),
                  annotation = c(FALSE, TRUE, TRUE),
                  abbrv = c(FALSE, FALSE, TRUE))

df3 <- tibble(
  id = 1:3,
  loc = c("Nantes", "Elbphilharmonie Hamburg", "Los Angeles City Hall"),
  roadinfo = c(FALSE, TRUE, TRUE)
)

equal_after_unnesting <- function(df1, df2){
  all_equal(unnest(df1, data), unnest(df2, data))
}

# oc_forward --------------------------------------------------------------

test_that("oc_forward works", {
  skip_on_cran()
  skip_if_offline()

  res1 <- oc_forward(locations)
  expect_type(res1, "list")
  expect_equal(nrow(res1), 3)
  expect_s3_class(res1, c("tbl_df", "tbl", "data.frame"))
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

  tbl3 <- oc_forward_df(locations)
  expect_s3_class(tbl3, c("tbl_df", "tbl", "data.frame"))
  expect_equal(nrow(tbl3), 3)
})

test_that("oc_reverse_df doesn't work for default class", {
  expect_error(
    oc_forward_df(53.6),
    "Can't geocode an object of class `numeric`."
  )
})

test_that("output arguments work", {
  skip_on_cran()
  skip_if_offline()

  expect_equal(names(oc_forward_df(df, loc, bind_cols = TRUE)),
               c("id", "loc", "oc_query", "data"))
  expect_equal(names(oc_forward_df(df, loc, bind_cols = FALSE)),
               c("oc_query", "data"))
  expect_equal(ncol(oc_forward_df(df, loc, output = "all")), 4)
  expect_equal(ncol(oc_forward_df(df, loc, bind_cols = FALSE, output = "all")), 2)
})

test_that("tidyeval works for arguments", {
  skip_on_cran()
  skip_if_offline()

  noarg <- oc_forward_df(df2, loc, bind_cols = FALSE)

  ## bounds, proximity and countrycode
  bounds <- oc_forward_df(df2, loc, bounds = bounds, bind_cols = FALSE)
  prx <- oc_forward_df(df2, loc, proximity = proximity, bind_cols = FALSE)
  cc <- oc_forward_df(df2, loc, countrycode = countrycode, bind_cols = FALSE)

  expect_false(isTRUE(equal_after_unnesting(bounds, noarg)))
  expect_false(isTRUE(equal_after_unnesting(prx, noarg)))
  expect_false(isTRUE(equal_after_unnesting(cc, noarg)))
  expect_true(isTRUE(equal_after_unnesting(bounds, prx)))
  expect_false(isTRUE(equal_after_unnesting(bounds, cc)))

  # language
  lang <- oc_forward_df(df2, loc, language = language, output = "all")

  expect_equal(unnest(lang, data)$oc_country, c("Frankreich", "Allemagne", "アメリカ合衆国")) # nolint

  # limit
  limit <- oc_forward_df(df2, loc, limit = limit)
  expect_equal(nrow(unnest(limit, data)), 6)
  expect_equal(unnest(limit, data)$id, c(1, 2, 2, 3, 3, 3))

  # min_confidence
  confidence <- oc_forward_df(df2, loc,
                              min_confidence = confidence,
                              bind_cols = FALSE)

  expect_false(isTRUE(equal_after_unnesting(confidence, noarg)))
  expect_false(isTRUE(equal_after_unnesting(confidence[1, ], noarg[1, ])))
  expect_false(isTRUE(equal_after_unnesting(confidence[2, ], noarg[2, ])))
  expect_false(isTRUE(equal_after_unnesting(confidence[3, ], noarg[3, ])))

  # no_annotations
  ann <- oc_forward_df(df2, loc, bind_cols = FALSE,
                       no_annotations = annotation)
  expect_equal(ncol(unnest(ann, data)), 71)
  expect_equal(unnest(ann, data)$oc_currency_name, c("Euro", NA, NA))

  # roadinfo
  ri <- oc_forward_df(
    df3,
    loc,
    roadinfo = roadinfo
  )
  expect_equal(unnest(ri, data)$oc_roadinfo_speed_in, c(NA_character_, "km/h", "mph"))

  # abbrv
  abbrv <- oc_forward_df(df2, loc,
                         abbrv = abbrv,
                         bind_cols = FALSE)

  expect_false(isTRUE(equal_after_unnesting(abbrv, noarg)))
  expect_true(isTRUE(all_equal(equal_after_unnesting(abbrv[1, ], noarg[1, ]))))
  expect_true(isTRUE(all_equal(equal_after_unnesting(abbrv[2, ], noarg[2, ]))))
  expect_false(isTRUE(equal_after_unnesting(abbrv[3, ], noarg[3, ])))
})

test_that("list columns are not dropped (by tidyr)", {
  bnds <- oc_forward_df(df2, loc, bounds = bounds, bind_cols = TRUE)
  expect_true(!is.null(bnds[["bounds"]]))
})

# Checks ------------------------------------------------------------------

test_that("Check that placename is present", {
  # oc_forward
  expect_error(oc_forward(), "`placename` must be provided.")
  expect_error(oc_forward(placename = NULL), "`placename` must be provided.")

  # oc_forward_df
  expect_error(oc_forward_df(df), "`placename` must be provided.")
  expect_error(oc_forward_df(df, NULL), "`placename` must be provided.")
})
