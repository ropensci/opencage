## Test oc_reverse functions ##

library(tibble)
lat <- c(47.21864, 53.55034, 34.05369)
lng <- c(-1.554136, 10.000654, -118.242767)
df <- tibble(id = 1:3, lat = lat, lng = lng)
df2 <- add_column(df,
                  language = c("en", "fr", "ja"),
                  confidence = c(1, 1, 1),
                  annotation = c(FALSE, TRUE, TRUE),
                  roadinfo = c(FALSE, TRUE, TRUE),
                  abbrv = c(FALSE, FALSE, TRUE))
df3 <- add_row(df2, id = 4, lat = 25, lng = 36, confidence = 5)

equal_after_unnesting <- function(df1, df2){
  all_equal(unnest(df1, data), unnest(df2, data))
}

# oc_reverse --------------------------------------------------------------

test_that("oc_reverse works", {
  skip_on_cran()
  skip_if_offline()

  res1 <- oc_reverse(lat, lng)
  expect_type(res1, "list")
  expect_equal(nrow(res1), 3)
  expect_s3_class(res1, c("tbl_df", "tbl", "data.frame"))
})

test_that("oc_reverse returns correct type", {
  skip_on_cran()
  skip_if_offline()

  # json_list
  res2 <- oc_reverse(lat, lng, return = "json_list")
  expect_type(res2, "list")
  expect_equal(length(res2), 3)
  expect_type(res2[[1]], "list")

  # geojson_list
  res3 <- oc_reverse(lat, lng, return = "geojson_list")
  expect_type(res3, "list")
  expect_equal(length(res3), 3)
  expect_s3_class(res3[[1]], "geo_list")
})

# oc_reverse_df -----------------------------------------------------------

test_that("oc_reverse_df works", {
  skip_on_cran()
  skip_if_offline()

  tbl1 <- oc_reverse_df(df, lat, lng)
  expect_s3_class(tbl1, c("tbl_df", "tbl", "data.frame"))
  expect_equal(nrow(tbl1), 3)

  tbl2 <- oc_reverse_df(df[1, ], lat, lng)
  expect_s3_class(tbl2, c("tbl_df", "tbl", "data.frame"))
  expect_equal(nrow(tbl2), 1)

  tbl3 <- oc_reverse_df(lat, lng)
  expect_s3_class(tbl3, c("tbl_df", "tbl", "data.frame"))
  expect_equal(nrow(tbl3), 3)
})

test_that("oc_reverse_df doesn't work for default class", {
  expect_error(
    oc_reverse_df("Hamburg"),
    "Can't geocode an object of class `character`."
  )
})

test_that("output arguments work", {
  skip_on_cran()
  skip_if_offline()

  expect_equal(names(oc_reverse_df(df, lat, lng, bind_cols = TRUE)),
               c("id", "lat", "lng", "oc_query", "data"))
  expect_equal(names(oc_reverse_df(df, lat, lng, bind_cols = FALSE)),
               c("oc_query", "data"))
  expect_equal(ncol(oc_reverse_df(df, lat, lng, output = "all")), 5)
  expect_gt(
    ncol(unnest(oc_reverse_df(df, lat, lng, bind_cols = FALSE, output = "all"), data)),
    5
  )
})

test_that("tidyeval works for arguments", {
  skip_on_cran()
  skip_if_offline()

  noarg <- oc_reverse_df(df2, lat, lng)

  # language
  lang <- oc_reverse_df(df2, lat, lng, language = language, output = "all")
  expect_equal(unnest(lang, data)$oc_country, c("France", "Allemagne", "アメリカ合衆国")) # nolint

  # min_confidence
  confidence <- oc_reverse_df(df3, lat, lng, min_confidence = confidence)
  no_con <- oc_reverse_df(df3, lat, lng)

  expect_false(isTRUE(equal_after_unnesting(confidence, no_con)))
  expect_true(isTRUE(equal_after_unnesting(confidence[1, ], no_con[1, ])))
  expect_true(isTRUE(equal_after_unnesting(confidence[2, ], no_con[2, ])))
  expect_true(isTRUE(equal_after_unnesting(confidence[3, ], no_con[3, ])))
  expect_false(isTRUE(equal_after_unnesting(confidence[4, ], no_con[4, ])))

  # no_annotations
  ann <- oc_reverse_df(df2, lat, lng, bind_cols = FALSE,
                       no_annotations = annotation)
  expect_gt(ncol(unnest(ann, data)), 40)
  expect_equal(unnest(ann, data)$oc_currency_name, c("Euro", NA, NA))

  # roadinfo
  ri <- oc_reverse_df(
    df2,
    lat,
    lng,
    bind_cols = FALSE,
    roadinfo = roadinfo
  )
  expect_equal(unnest(ri, data)$oc_roadinfo_speed_in, c(NA_character_, "km/h", "mph"))

  # abbrv
  abbrv <- oc_reverse_df(df2, lat, lng,
                         abbrv = abbrv)

  expect_false(isTRUE(equal_after_unnesting(abbrv, noarg)))
  expect_true(isTRUE(equal_after_unnesting(abbrv[1, ], noarg[1, ])))
  expect_true(isTRUE(equal_after_unnesting(abbrv[2, ], noarg[2, ])))
  expect_false(isTRUE(equal_after_unnesting(abbrv[3, ], noarg[3, ])))
})

# Checks ------------------------------------------------------------------

test_that("Check that latitude & longitude are present", {
  # oc_reverse
  expect_error(oc_reverse(latitude = lat),
               "`latitude` and `longitude` must be provided.")
  expect_error(oc_reverse(longitude = lng),
               "`latitude` and `longitude` must be provided.")
  expect_error(oc_reverse(latitude = NULL, longitude = lng),
               "`latitude` and `longitude` must be provided.")
  expect_error(oc_reverse(latitude = lat, longitude = NULL),
               "`latitude` and `longitude` must be provided.")

  # oc_reverse_df
  expect_error(oc_reverse_df(df, latitude = lat),
               "`latitude` and `longitude` must be provided.")
  expect_error(oc_reverse_df(df, longitude = lng),
               "`latitude` and `longitude` must be provided.")
})
