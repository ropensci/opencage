## Test oc_forward functions ##

library(tibble)
lat <- c(47.21864, 53.55034, 34.05369)
lng <- c(-1.554136, 10.000654, -118.242767)
df <- tibble(id = 1:3, lat = lat, lng = lng)
df2 <- add_column(df,
  language = c("en", "fr", "es"),
  confidence = c(1, 1, 1),
  annotation = c(FALSE, TRUE, TRUE),
  abbrv = c(FALSE, FALSE, TRUE)
)
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


# oc_reverse_df -----------------------------------------------------------
vcr::use_cassette("oc_reverse_df_lat_lon", {
  test_that("oc_reverse_df works", {
    tbl1 <- oc_reverse_df(df, lat, lng)
    expect_s3_class(tbl1, c("tbl_df", "tbl", "data.frame"))
    expect_equal(nrow(tbl1), 3)

    tbl2 <- oc_reverse_df(df[1, ], lat, lng)
    expect_s3_class(tbl2, c("tbl_df", "tbl", "data.frame"))
    expect_equal(nrow(tbl2), 1)
  })
})

vcr::use_cassette("oc_reverse_df_output", {
  test_that("output arguments work", {
    expect_equal(
      names(oc_reverse_df(df, lat, lng, bind_cols = TRUE)),
      c("id", "lat", "lng", "formatted")
    )
    expect_equal(
      names(oc_reverse_df(df, lat, lng, bind_cols = FALSE)),
      c("query", "formatted")
    )
    expect_gt(ncol(oc_reverse_df(df, lat, lng, output = "all")), 5)
    expect_gt(ncol(oc_reverse_df(df, lat, lng, bind_cols = FALSE, output = "all")), 5)
  })
})

vcr::use_cassette("oc_reverse_df_tidyeval", {
  test_that("tidyeval works for arguments", {
    noarg <- oc_reverse_df(df2, lat, lng)

    # language
    lang <- oc_reverse_df(df2, lat, lng, language = language, output = "all")
    expect_equal(
      lang$country,
      c("France", "Allemagne", "Estados Unidos de América")
    )

    # min_confidence
    confidence <- oc_reverse_df(df3, lat, lng, min_confidence = confidence)
    no_con <- oc_reverse_df(df3, lat, lng)

    expect_false(isTRUE(all.equal(confidence, no_con)))
    expect_true(isTRUE(all.equal(confidence[1, ], no_con[1, ])))
    expect_true(isTRUE(all.equal(confidence[2, ], no_con[2, ])))
    expect_true(isTRUE(all.equal(confidence[3, ], no_con[3, ])))
    expect_false(isTRUE(all.equal(confidence[4, ], no_con[4, ])))

    # no_annotations
    ann <- oc_reverse_df(df2, lat, lng,
      output = "all",
      bind_cols = FALSE,
      no_annotations = annotation
    )
    expect_gt(ncol(ann), 40)
    expect_equal(ann$currency_name, c("Euro", NA, NA))

    # abbrv
    abbrv <- oc_reverse_df(df2, lat, lng,
      abbrv = abbrv
    )
    expect_false(isTRUE(all.equal(abbrv, noarg)))
    expect_true(all.equal(abbrv[1, ], noarg[1, ]))
    expect_true(all.equal(abbrv[2, ], noarg[2, ]))
    expect_false(isTRUE(all.equal(abbrv[3, ], noarg[3, ])))
  })
})


# Checks ------------------------------------------------------------------

test_that("Checks work", {
  # oc_reverse
  expect_error(
    oc_reverse(latitude = lat),
    "`latitude` and `longitude` must be provided."
  )
  expect_error(
    oc_reverse(longitude = lng),
    "`latitude` and `longitude` must be provided."
  )
  expect_error(
    oc_reverse(latitude = NULL, longitude = lng),
    "`latitude` and `longitude` must be provided."
  )
  expect_error(
    oc_reverse(latitude = lat, longitude = NULL),
    "`latitude` and `longitude` must be provided."
  )

  # oc_reverse_df
  expect_error(
    oc_reverse_df(df, latitude = lat),
    "`latitude` and `longitude` must be provided."
  )
  expect_error(
    oc_reverse_df(df, longitude = lng),
    "`latitude` and `longitude` must be provided."
  )
})
