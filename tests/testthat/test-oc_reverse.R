## Test oc_reverse functions ##

library(tibble)
lat <- c(47.21864, 53.55034, 34.05369)
lng <- c(-1.554136, 10.000654, -118.242767)
df <- tibble(id = 1:3, lat = lat, lng = lng)
df2 <- add_column(df,
                  language = c("en", "fr", "ja"),
                  confidence = rep(1L, 3L),
                  annotation = c(FALSE, TRUE, TRUE),
                  roadinfo = c(FALSE, TRUE, TRUE),
                  abbrv = c(FALSE, FALSE, TRUE),
                  address_only = c(TRUE, TRUE, FALSE))
df3 <- add_row(df2, id = 4, lat = 25, lng = 36, confidence = 5)

# oc_reverse --------------------------------------------------------------

test_that("oc_reverse works", {
  skip_if_no_key()
  skip_if_oc_offline()

  res1 <- oc_reverse(lat, lng)
  expect_type(res1, "list")
  expect_length(res1, 3L)
  expect_s3_class(res1[[1]], c("tbl_df", "tbl", "data.frame"))
})

test_that("oc_reverse returns correct type", {
  skip_if_no_key()
  skip_if_oc_offline()

  # json_list
  res2 <- oc_reverse(lat, lng, return = "json_list")
  expect_type(res2, "list")
  expect_length(res2, 3L)
  expect_type(res2[[1]], "list")

  # geojson_list
  res3 <- oc_reverse(lat, lng, return = "geojson_list")
  expect_type(res3, "list")
  expect_length(res3, 3L)
  expect_s3_class(res3[[1]], "geo_list")
})

test_that("oc_reverse adds request with add_request", {
  skip_if_no_key()
  skip_if_oc_offline()

  expected <- paste(lat[1], lng[1], sep = ",")

  # df_list
  res <- oc_reverse(lat[1], lng[1], return = "df_list", add_request = TRUE)
  expect_identical(res[[1]][["oc_query"]], expected)

  # json_list
  res <- oc_reverse(lat[1], lng[1], return = "json_list", add_request = TRUE)
  expect_identical(res[[1]][["request"]][["query"]], expected)
})

test_that("oc_reverse masks key when add_request = TRUE", {
  skip_if_oc_offline()
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))

  res <- oc_reverse(lat[1], lng[1], return = "json_list", add_request = TRUE)
  expect_identical(res[[1]][["request"]][["key"]], "OPENCAGE_KEY")
})

test_that("oc_reverse handles NAs", {
  skip_if_no_key()
  skip_if_oc_offline()

  # df_list
  res1 <- oc_reverse(latitude = 0, longitude = NA_real_)
  expect_identical(res1[[1]][[1, "oc_lat"]], NA_real_)

  res2 <- oc_reverse(latitude = NA_real_, longitude = 0)
  expect_identical(res2[[1]][[1, "oc_lng"]], NA_real_)

  # json_list
  res3 <- oc_reverse(latitude = NA_real_, longitude = 0, return = "json_list")
  expect_identical(res3[[1]][["results"]], list())

  # geojson_list
  res4 <-
    oc_reverse(latitude = NA_real_, longitude = 0, return = "geojson_list")
  expect_identical(res4[[1]][["features"]], list())
})

# oc_reverse_df -----------------------------------------------------------

test_that("oc_reverse_df works", {
  skip_if_no_key()
  skip_if_oc_offline()

  tbl1 <- oc_reverse_df(df, lat, lng)
  expect_s3_class(tbl1, c("tbl_df", "tbl", "data.frame"))
  expect_identical(nrow(tbl1), 3L)

  tbl2 <- oc_reverse_df(df[1, ], lat, lng)
  expect_s3_class(tbl2, c("tbl_df", "tbl", "data.frame"))
  expect_identical(nrow(tbl2), 1L)

  tbl3 <- oc_reverse_df(lat, lng)
  expect_s3_class(tbl3, c("tbl_df", "tbl", "data.frame"))
  expect_identical(nrow(tbl3), 3L)
})

test_that("oc_reverse_df works with NA", {
  skip_if_no_key()
  skip_if_oc_offline()

  lt <- c(0, NA_real_)
  ln <- c(NA_real_, 0)

  tbl1 <- oc_reverse_df(lt, ln)

  expect_identical(nrow(tbl1), 2L)
  expect_identical(tbl1$latitude, lt)
  expect_identical(tbl1$longitude, ln)
  expect_true(all(is.na(tbl1$oc_formatted)))

  tbl2 <- oc_reverse_df(data.frame(lt_col = lt, ln_col = ln), lt_col, ln_col)

  expect_identical(nrow(tbl2), 2L)
  expect_identical(tbl2$lt_col, lt)
  expect_identical(tbl2$ln_col, ln)
  expect_true(all(is.na(tbl2$oc_formatted)))

  tbl3 <-
    oc_reverse_df(
      data.frame(lt_col = lt, ln_col = ln), lt_col, ln_col, bind_cols = FALSE
    )

  expect_identical(nrow(tbl3), 2L)
  expect_true(
    all(
      is.na(tbl3$oc_query),
      is.na(tbl3$oc_formatted)
    )
  )
})

test_that("oc_reverse_df doesn't work for default class", {
  expect_error(
    oc_reverse_df("Hamburg"),
    "Can't geocode an object of class `character`."
  )
})

test_that("output arguments work", {
  skip_if_no_key()
  skip_if_oc_offline()

  expect_named(oc_reverse_df(df, lat, lng, bind_cols = TRUE),
               c("id", "lat", "lng", "oc_formatted"))
  expect_named(oc_reverse_df(df, lat, lng, bind_cols = FALSE),
               c("oc_query", "oc_formatted"))
  expect_gt(ncol(oc_reverse_df(df, lat, lng, output = "all")), 5L)
  expect_gt(
    ncol(oc_reverse_df(df, lat, lng, bind_cols = FALSE, output = "all")),
    5L
  )
})

test_that("tidyeval works for arguments", {
  skip_if_no_key()
  skip_if_oc_offline()

  noarg <- oc_reverse_df(df2, lat, lng)

  # language
  lang <- oc_reverse_df(df2, lat, lng, language = language, output = "all")
  expect_identical(lang$oc_country, c("France", "Allemagne", "アメリカ合衆国"))

  # min_confidence
  confidence <- oc_reverse_df(df3, lat, lng, min_confidence = confidence)
  no_con <- oc_reverse_df(df3, lat, lng)

  expect_false(isTRUE(all.equal(confidence, no_con)))
  expect_true(isTRUE(all.equal(confidence[1, ], no_con[1, ])))
  expect_true(isTRUE(all.equal(confidence[2, ], no_con[2, ])))
  expect_true(isTRUE(all.equal(confidence[3, ], no_con[3, ])))
  expect_false(isTRUE(all.equal(confidence[4, ], no_con[4, ])))

  # no_annotations
  ann <- oc_reverse_df(df2, lat, lng, bind_cols = FALSE,
                       no_annotations = annotation)
  expect_gt(ncol(ann), 40)
  expect_identical(ann$oc_currency_name, c("Euro", NA, NA))

  # roadinfo
  ri <- oc_reverse_df(
    df2,
    lat,
    lng,
    bind_cols = FALSE,
    roadinfo = roadinfo
  )
  expect_identical(ri$oc_roadinfo_speed_in, c(NA_character_, "km/h", "mph"))

  # abbrv
  abbrv <- oc_reverse_df(df2, lat, lng, abbrv = abbrv)
  expect_false(isTRUE(all.equal(abbrv, noarg)))
  expect_true(all.equal(abbrv[1, ], noarg[1, ]))
  expect_true(all.equal(abbrv[2, ], noarg[2, ]))
  expect_false(isTRUE(all.equal(abbrv[3, ], noarg[3, ])))

  # address_only
  address_only <- oc_reverse_df(df2, lat, lng, address_only = address_only)
  expect_false(identical(
    address_only["oc_formatted"],
    noarg["oc_formatted"]
  ))
  expect_false(identical(
    noarg[1, "oc_formatted"],
    address_only[1, "oc_formatted"]
  ))
  expect_false(identical(
    noarg[2, "oc_formatted"],
    address_only[2, "oc_formatted"]
  ))
  expect_match(
    noarg[[1, "oc_formatted"]],
    address_only[[1, "oc_formatted"]],
    fixed = TRUE
  )
  expect_match(
    noarg[[2, "oc_formatted"]],
    address_only[[2, "oc_formatted"]],
    fixed = TRUE
  )
  expect_identical(address_only[3, "oc_formatted"], noarg[3, "oc_formatted"])
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
