## Test oc_forward functions ##

library(tibble)
locations <- c("Nantes", "Hamburg", "Los Angeles")
df <- tibble(id = 1:3, loc = locations)
df2 <-
  add_column(
    df,
    bounds = oc_bbox(
      xmin = c(-72, -80, -76),
      ymin = c(45, 42, 8),
      xmax = c(-70, -78, -74),
      ymax = c(46, 43, 10)
    ),
    countrycode = c("ca", "us", "co"),
    language = c("de", "fr", "es"),
    limit = 1:3,
    confidence = c(7, 5, 3),
    annotation = c(FALSE, TRUE, TRUE),
    abbrv = c(FALSE, FALSE, TRUE)
  )

# oc_forward --------------------------------------------------------------
vcr::use_cassette("oc_forward_type", {
  test_that("oc_forward returns correct type", {
    skip_if_no_key()

    # df_list
    res1 <- oc_forward(locations, return = "df_list")
    expect_type(res1, "list")
    expect_equal(length(res1), 3)
    expect_s3_class(res1[[1]], c("tbl_df", "tbl", "data.frame"))

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

    memoise::forget(opencage:::oc_get_memoise)
  })
})

# oc_forward_df -----------------------------------------------------------

vcr::use_cassette("oc_forward_df_place", {
  test_that("oc_forward_df works", {
  skip_if_no_key()

    tbl1 <- oc_forward_df(df, loc)
    expect_s3_class(tbl1, c("tbl_df", "tbl", "data.frame"))
    expect_equal(nrow(tbl1), 3)

    tbl2 <- oc_forward_df(tibble(loc = "Kyoto"), loc)
    expect_s3_class(tbl2, c("tbl_df", "tbl", "data.frame"))
    expect_equal(nrow(tbl2), 1)

    # Error with no placename
    expect_error(oc_forward_df(df), "`placename` must be provided.")
    expect_error(oc_forward_df(df, NULL), "`placename` must be provided.")

    memoise::forget(opencage:::oc_get_memoise)
  })
})

vcr::use_cassette("oc_forward_df_output", {
  test_that("output arguments work", {
    skip_if_no_key()

    expect_equal(
      names(oc_forward_df(df, loc, bind_cols = TRUE, output = "short")),
      c("id", "loc", "lat", "lng", "formatted")
    )
    expect_equal(
      names(oc_forward_df(df, loc, bind_cols = FALSE, output = "short")),
      c("query", "lat", "lng", "formatted")
    )
    expect_gt(
      ncol(oc_forward_df(df, loc, bind_cols = TRUE, output = "all")),
      5
    )
    expect_gt(
      ncol(oc_forward_df(df, loc, bind_cols = FALSE, output = "all")),
      5
    )

    memoise::forget(opencage:::oc_get_memoise)
  })
})

vcr::use_cassette("oc_forward_df_tidyeval", {
  test_that("tidyeval works for arguments", {
    skip_if_no_key()

    noarg <- oc_forward_df(df2, loc, bind_cols = FALSE)

    # bounds and countrycode
    bounds <- oc_forward_df(df2, loc, bounds = bounds, bind_cols = FALSE)
    cc <- oc_forward_df(df2, loc, countrycode = countrycode, bind_cols = FALSE)
    expect_false(isTRUE(all.equal(bounds, noarg)))
    expect_false(isTRUE(all.equal(cc, noarg)))
    expect_equal(bounds, cc)

    # language
    lang <- oc_forward_df(df2, loc, language = language, output = "all")
    expect_equal(
      lang$country,
      c("Frankreich", "Allemagne", "Estados Unidos de América")
    )

    # limit
    limit <- oc_forward_df(df2, loc, limit = limit)
    expect_equal(nrow(limit), 6)
    expect_equal(limit$id, c(1, 2, 2, 3, 3, 3))

    # min_confidence
    confidence <-
      oc_forward_df(df2, loc, min_confidence = confidence, bind_cols = FALSE)
    expect_false(isTRUE(all.equal(confidence, noarg)))
    expect_false(isTRUE(all.equal(confidence[1, ], noarg[1, ])))
    expect_false(isTRUE(all.equal(confidence[2, ], noarg[2, ])))
    expect_false(isTRUE(all.equal(confidence[3, ], noarg[3, ])))

    # no_annotations
    ann <-
      oc_forward_df(
        df2,
        loc,
        output = "all",
        bind_cols = FALSE,
        no_annotations = annotation
      )
    expect_gt(ncol(ann), 30)
    expect_equal(ann$currency_name, c("Euro", NA, NA))

    # abbrv
    abbrv <-
      oc_forward_df(
        df2, loc,
        abbrv = abbrv,
        bind_cols = FALSE
      )
    expect_false(isTRUE(all.equal(abbrv, noarg)))
    expect_true(all.equal(abbrv[1, ], noarg[1, ]))
    expect_true(all.equal(abbrv[2, ], noarg[2, ]))
    expect_false(isTRUE(all.equal(abbrv[3, ], noarg[3, ])))
  })
})
