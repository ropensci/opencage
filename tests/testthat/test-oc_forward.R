## Test oc_forward functions ##

library(tibble)
locations <- c("Nantes", "Flensburg", "Los Angeles")
df <- tibble(id = 1:3, loc = locations)
df2 <- add_column(df,
                  bounds = oc_bbox(xmin = c(-72, -98, -73),
                                   ymin = c(45, 43, -38),
                                   xmax = c(-70, -90, -71),
                                   ymax = c(46, 49, -36)),
                  proximity = oc_points(latitude = c(45.5, 46, -37),
                                        longitude = c(-71, -95, -72)),
                  countrycode = c("ca", "us", "cl"),
                  language = c("de", "fr", "ja"),
                  limit = 1:3,
                  confidence = c(7, 9, 5),
                  annotation = c(FALSE, TRUE, TRUE),
                  abbrv = c(FALSE, FALSE, TRUE))

df3 <- tibble(
  id = 1:3,
  loc = c("Nantes", "Elbphilharmonie Hamburg", "Los Angeles City Hall"),
  roadinfo = c(FALSE, TRUE, TRUE)
)

# oc_forward --------------------------------------------------------------
vcr::use_cassette("oc_forward_type_df_list", {
  test_that("oc_forward works", {
    res1 <- oc_forward(locations)
    expect_type(res1, "list")
    expect_equal(length(res1), 3)
    expect_s3_class(res1[[1]], c("tbl_df", "tbl", "data.frame"))
  })
})

test_that("oc_forward returns correct type", {

  # json_list
  vcr::use_cassette("oc_forward_type_df_list", {
    res2 <- oc_forward(locations, return = "json_list")
  })
  expect_type(res2, "list")
  expect_equal(length(res2), 3)
  expect_type(res2[[1]], "list")

  # geojson_list
  vcr::use_cassette("oc_forward_type_geojson_list", {
    res3 <- oc_forward(locations, return = "geojson_list")
  })
  expect_type(res3, "list")
  expect_equal(length(res3), 3)
  expect_s3_class(res3[[1]], "geo_list")
})

vcr::use_cassette("oc_forward_add_request", {
  test_that("oc_forward adds request with add_request", {
    # df_list
    res <- oc_forward("Hmbg", return = "df_list", add_request = TRUE)
    expect_equal(res[[1]][["oc_query"]], "Hmbg")

    # json_list
    res <- oc_forward("Hmbg", return = "json_list", add_request = TRUE)
    expect_equal(res[[1]][["request"]][["query"]], "Hmbg")
  })
})

vcr::use_cassette("oc_forward_add_request_mask_key", {
  test_that("oc_forward masks key when add_request = TRUE", {
    withr::local_envvar(c("OPENCAGE_KEY" = key_200))

    # json_list
    res <- oc_forward("irrelevant", return = "json_list", add_request = TRUE)
    expect_equal(res[[1]][["request"]][["key"]], "OPENCAGE_KEY")
  })
})

vcr::use_cassette("oc_forward_no_result", {
  test_that("oc_forward handles response with no results", {
    # https://opencagedata.com/api#no-results
    nores <- oc_forward("NOWHERE-INTERESTING")
    expect_type(nores, "list")
    expect_equal(length(nores), 1)
    expect_s3_class(nores[[1]], c("tbl_df", "tbl", "data.frame"))
    expect_equal(nores[[1]][[1, "oc_lat"]], NA_real_)
  })
})

# oc_forward_df -----------------------------------------------------------

vcr::use_cassette("oc_forward_df_works", {
  test_that("oc_forward_df works", {

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
})

test_that("oc_forward_df doesn't work for default class", {
  expect_error(
    oc_forward_df(53.6),
    "Can't geocode an object of class `numeric`."
  )
})

vcr::use_cassette("oc_forward_df_works", {
  test_that("output arguments work", {

    expect_equal(names(oc_forward_df(df, loc, bind_cols = TRUE)),
                 c("id", "loc", "oc_lat", "oc_lng", "oc_formatted"))
    expect_equal(names(oc_forward_df(df, loc, bind_cols = FALSE)),
                 c("oc_query", "oc_lat", "oc_lng", "oc_formatted"))
    expect_gt(ncol(oc_forward_df(df, loc, output = "all")), 5)
    expect_gt(
      ncol(oc_forward_df(df, loc, bind_cols = FALSE, output = "all")), 5
    )
  })
})

test_that("tidyeval works for arguments", {
  ## query without arguments to test against
  vcr::use_cassette("oc_forward_df_works", {
    noarg <- oc_forward_df(df2, loc)
  })

  ## bounds, proximity and countrycode
  vcr::use_cassette("oc_forward_df_bounds", {
    bounds <- oc_forward_df(df2, loc, bounds = bounds)
  })
  vcr::use_cassette("oc_forward_df_proximity", {
    prx <- oc_forward_df(df2, loc, proximity = proximity)
  })
  vcr::use_cassette("oc_forward_df_countrycode", {
    cc <- oc_forward_df(df2, loc, countrycode = countrycode)
  })
  expect_false(isTRUE(all.equal(bounds, noarg)))
  expect_false(isTRUE(all.equal(prx, noarg)))
  expect_false(isTRUE(all.equal(cc, noarg)))
  expect_equal(bounds, prx)
  expect_equal(bounds, cc)

  # language
  vcr::use_cassette("oc_forward_df_language", {
    lang <- oc_forward_df(df2, loc, language = language, output = "all")
  })
  expect_equal(lang$oc_country, c("Frankreich", "Allemagne", "アメリカ合衆国")) # nolint

  # limit
  vcr::use_cassette("oc_forward_df_limit", {
    limit <- oc_forward_df(df2, loc, limit = limit)
  })
  expect_equal(nrow(limit), 6)
  expect_equal(limit$id, c(1, 2, 2, 3, 3, 3))

  # min_confidence
  vcr::use_cassette("oc_forward_df_confidence", {
    confidence <-
      oc_forward_df(df2, loc, min_confidence = confidence)
  })

  # make sure we get actual results, not only NA
  expect_false(any(is.na(confidence$oc_formatted)))

  expect_false(isTRUE(all.equal(confidence, noarg)))
  expect_false(isTRUE(all.equal(confidence[1, ], noarg[1, ])))
  expect_false(isTRUE(all.equal(confidence[2, ], noarg[2, ])))
  expect_false(isTRUE(all.equal(confidence[3, ], noarg[3, ])))

  # no_annotations
  vcr::use_cassette("oc_forward_df_annotations", {
    ann <-
      oc_forward_df(df2, loc, no_annotations = annotation)
  })
  expect_gt(ncol(ann), 30)
  expect_equal(ann$oc_currency_name, c("Euro", NA, NA))

  # roadinfo
  vcr::use_cassette("oc_forward_df_roadinfo", {
    ri <- oc_forward_df(df3, loc, roadinfo = roadinfo)
  })
  expect_equal(ri$oc_roadinfo_speed_in, c(NA_character_, "km/h", "mph"))

  # abbrv
  vcr::use_cassette("oc_forward_df_abbrv", {
    abbrv <- oc_forward_df(df2, loc, abbrv = abbrv)
  })
  expect_false(isTRUE(all.equal(abbrv, noarg)))
  expect_true(all.equal(abbrv[1, ], noarg[1, ]))
  expect_true(all.equal(abbrv[2, ], noarg[2, ]))
  expect_false(isTRUE(all.equal(abbrv[3, ], noarg[3, ])))
})

vcr::use_cassette("oc_forward_df_bounds", {
  test_that("list columns are not dropped (by tidyr)", {
    bnds <- oc_forward_df(df2, loc, bounds = bounds)
    expect_true(!is.null(bnds[["bounds"]]))
  })
})

vcr::use_cassette("oc_forward_df_no_result", {
  test_that("oc_forward_df handles response with no results", {
     # https://opencagedata.com/api#no-results
    nores_df <- oc_forward_df("NOWHERE-INTERESTING")
    expect_s3_class(nores_df, c("tbl_df", "tbl", "data.frame"))
    expect_equal(nores_df[[1, "oc_lat"]], NA_real_)
  })
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
