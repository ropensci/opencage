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

# oc_reverse --------------------------------------------------------------

vcr::use_cassette("oc_reverse_type", {
  test_that("oc_reverse returns correct type", {
    # df_list
    res1 <- oc_reverse(lat, lng)
    expect_type(res1, "list")
    expect_equal(length(res1), 3)
    expect_s3_class(res1[[1]], c("tbl_df", "tbl", "data.frame"))

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
})

vcr::use_cassette("oc_reverse_add_request", {
  test_that("oc_reverse adds request with add_request", {
    expected <- paste(lat[1], lng[1], sep = ",")

    # df_list
    res <- oc_reverse(lat[1], lng[1], return = "df_list", add_request = TRUE)
    expect_equal(res[[1]][["oc_query"]], expected)

    # json_list
    res <- oc_reverse(lat[1], lng[1], return = "json_list", add_request = TRUE)
    expect_equal(res[[1]][["request"]][["query"]], expected)
  })
})

vcr::use_cassette("oc_reverse_add_request_mask_key", {
  test_that("oc_reverse masks key when add_request = TRUE", {
    withr::local_envvar(c("OPENCAGE_KEY" = key_200))

    res <- oc_reverse(lat[1], lng[1], return = "json_list", add_request = TRUE)
    expect_equal(res[[1]][["request"]][["key"]], "OPENCAGE_KEY")
  })
})

test_that("oc_reverse handles NAs", {
  vcr::use_cassette("oc_reverse_longitude_na", {
    res1 <- oc_reverse(latitude = 0, longitude = NA_real_)
  })
  expect_equal(res1[[1]][[1, "oc_lat"]], NA_real_)

  vcr::use_cassette("oc_reverse_latitude_na", {
    res2 <- oc_reverse(latitude = NA_real_, longitude = 0)
  })
  expect_equal(res2[[1]][[1, "oc_lng"]], NA_real_)

  vcr::use_cassette("oc_reverse_latitude_na_json", {
    res3 <- oc_reverse(latitude = NA_real_, longitude = 0, return = "json_list")
  })
  expect_equal(res3[[1]][["results"]], list())

  vcr::use_cassette("oc_reverse_latitude_na_geojson", {
    res4 <-
      oc_reverse(latitude = NA_real_, longitude = 0, return = "geojson_list")
  })
  expect_equal(res4[[1]][["features"]], list())
})

# oc_reverse_df -----------------------------------------------------------
vcr::use_cassette("oc_reverse_df_lat_lon", {
  test_that("oc_reverse_df works", {
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
})

test_that("oc_reverse_df works with NA", {
  lt <- c(0, NA_real_)
  ln <- c(NA_real_, 0)
  vcr::use_cassette("oc_reverse_df_na_tbl1", {
    tbl1 <- oc_reverse_df(lt, ln)
  })
  expect_equal(nrow(tbl1), 2)
  expect_equal(tbl1$latitude, lt)
  expect_equal(tbl1$longitude, ln)
  expect_true(all(is.na(tbl1$oc_formatted)))

  vcr::use_cassette("oc_reverse_df_na_tbl2", {
    tbl2 <- oc_reverse_df(data.frame(lt, ln, stringsAsFactors = FALSE), lt, ln)
  })
  expect_equal(nrow(tbl2), 2)
  expect_equal(tbl2$lt, lt)
  expect_equal(tbl2$ln, ln)
  expect_true(all(is.na(tbl2$oc_formatted)))

  vcr::use_cassette("oc_reverse_df_na_tbl3", {
    tbl3 <-
      oc_reverse_df(
        data.frame(lt, ln, stringsAsFactors = FALSE),
        lt,
        ln,
        bind_cols = FALSE
      )
  })
  expect_equal(nrow(tbl3), 2)
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

vcr::use_cassette("oc_reverse_df_lat_lon", {
  test_that("output arguments work", {

    expect_equal(names(oc_reverse_df(df, lat, lng, bind_cols = TRUE)),
                 c("id", "lat", "lng", "oc_formatted"))
    expect_equal(names(oc_reverse_df(df, lat, lng, bind_cols = FALSE)),
                 c("oc_query", "oc_formatted"))
    expect_gt(ncol(oc_reverse_df(df, lat, lng, output = "all")), 5)
    expect_gt(
      ncol(oc_reverse_df(df, lat, lng, bind_cols = FALSE, output = "all")),
      5
    )
  })
})

test_that("tidyeval works for arguments", {
  noarg <- oc_reverse_df(df2, lat, lng)

  # language
  vcr::use_cassette("oc_reverse_df_language", {
    lang <- oc_reverse_df(df2, lat, lng, language = language, output = "all")
  })
  expect_equal(lang$oc_country, c("France", "Allemagne", "アメリカ合衆国")) # nolint

  # min_confidence
  vcr::use_cassette("oc_reverse_df_confidence", {
    confidence <- oc_reverse_df(df3, lat, lng, min_confidence = confidence)
  })
  vcr::use_cassette("oc_reverse_df_default_confidence", {
    no_con <- oc_reverse_df(df3, lat, lng)
  })

  expect_false(isTRUE(all.equal(confidence, no_con)))
  expect_true(isTRUE(all.equal(confidence[1, ], no_con[1, ])))
  expect_true(isTRUE(all.equal(confidence[2, ], no_con[2, ])))
  expect_true(isTRUE(all.equal(confidence[3, ], no_con[3, ])))
  expect_false(isTRUE(all.equal(confidence[4, ], no_con[4, ])))

  # no_annotations
  vcr::use_cassette("oc_reverse_df_annotations", {
    ann <- oc_reverse_df(df2, lat, lng, no_annotations = annotation)
  })
  expect_gt(ncol(ann), 40)
  expect_equal(ann$oc_currency_name, c("Euro", NA, NA))

  # roadinfo
  vcr::use_cassette("oc_reverse_df_roadinfo", {
    ri <- oc_reverse_df(df2, lat, lng, roadinfo = roadinfo)
  })
  expect_equal(ri$oc_roadinfo_speed_in, c(NA_character_, "km/h", "mph"))

  # abbrv
  vcr::use_cassette("oc_reverse_df_abbrv", {
    abbrv <- oc_reverse_df(df2, lat, lng, abbrv = abbrv)
  })
  expect_false(isTRUE(all.equal(abbrv, noarg)))
  expect_true(all.equal(abbrv[1, ], noarg[1, ]))
  expect_true(all.equal(abbrv[2, ], noarg[2, ]))
  expect_false(isTRUE(all.equal(abbrv[3, ], noarg[3, ])))
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
