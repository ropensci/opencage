# Test oc_forward functions -----------------------------------------------

# oc_forward --------------------------------------------------------------

test_that("oc_forward works", {
  skip_if_no_key()
  skip_if_oc_offline()

  res1 <- oc_forward(oc_locs)
  expect_type(res1, "list")
  expect_length(res1, 3L)
  expect_s3_class(res1[[1]], c("tbl_df", "tbl", "data.frame"))
})

test_that("oc_forward returns correct type", {
  skip_if_no_key()
  skip_if_oc_offline()

  # json_list
  res2 <- oc_forward(oc_locs, return = "json_list")
  expect_type(res2, "list")
  expect_length(res2, 3L)
  expect_type(res2[[1]], "list")

  # geojson_list
  res3 <- oc_forward(oc_locs, return = "geojson_list")
  expect_type(res3, "list")
  expect_length(res3, 3L)
  expect_s3_class(res3[[1]], "geo_list")
})

test_that("oc_forward adds request with add_request", {
  skip_if_no_key()
  skip_if_oc_offline()

  # df_list
  res <- oc_forward("Hmbg", return = "df_list", add_request = TRUE)
  expect_identical(res[[1]][["oc_query"]], "Hmbg")

  # json_list
  res <- oc_forward("Hmbg", return = "json_list", add_request = TRUE)
  expect_identical(res[[1]][["request"]][["query"]], "Hmbg")
})

test_that("oc_forward masks key when add_request = TRUE", {
  skip_if_oc_offline()
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))

  # json_list
  res <- oc_forward("irrelevant", return = "json_list", add_request = TRUE)
  expect_identical(res[[1]][["request"]][["key"]], "OPENCAGE_KEY")
})

test_that("oc_forward handles response with no results", {
  skip_if_no_key()
  skip_if_oc_offline()

  # https://opencagedata.com/api#no-results
  nores <- oc_forward("NOWHERE-INTERESTING")
  expect_type(nores, "list")
  expect_length(nores, 1L)
  expect_s3_class(nores[[1]], c("tbl_df", "tbl", "data.frame"))
  expect_identical(nores[[1]][[1, "oc_lat"]], NA_real_)
})

test_that("oc_forward handles NAs", {
  skip_if_no_key()
  skip_if_oc_offline()

  # df_list
  res <- oc_forward(NA_character_)
  expect_identical(res[[1]][[1, "oc_lat"]], NA_real_)

  # json_list
  res2 <- oc_forward(NA_character_, return = "json_list")
  expect_identical(res2[[1]][["results"]], list())

  # geojson_list
  res3 <- oc_forward(NA_character_, return = "geojson_list")
  expect_identical(res3[[1]][["features"]], list())
})

test_that("oc_forward handles empty strings", {
  skip_if_no_key()
  skip_if_oc_offline()

  res <- oc_forward("")
  expect_type(res, "list")
  expect_length(res, 1L)
  expect_s3_class(res[[1]], c("tbl_df", "tbl", "data.frame"))
  expect_identical(res[[1]][[1, "oc_lat"]], NA_real_)
})

# oc_forward_df -----------------------------------------------------------

test_that("oc_forward_df works", {
  skip_if_no_key()
  skip_if_oc_offline()

  tbl1 <- oc_forward_df(oc_fw1, loc)
  expect_s3_class(tbl1, c("tbl_df", "tbl", "data.frame"))
  expect_identical(nrow(tbl1), 3L)

  tbl2 <- oc_forward_df(data.frame(loc = "Nantes"), loc)
  expect_s3_class(tbl2, c("tbl_df", "tbl", "data.frame"))
  expect_identical(nrow(tbl2), 1L)

  tbl3 <- oc_forward_df(oc_locs)
  expect_s3_class(tbl3, c("tbl_df", "tbl", "data.frame"))
  expect_identical(nrow(tbl3), 3L)
})

test_that("oc_forward_df works with NA and empty strings", {
  skip_if_no_key()
  skip_if_oc_offline()

  q <- c(NA_character_, "")

  tbl1 <- oc_forward_df(q)

  expect_identical(nrow(tbl1), 2L)
  expect_identical(tbl1$placename, q)
  expect_true(
    all(
      is.na(tbl1$oc_formatted),
      is.na(tbl1$oc_lat),
      is.na(tbl1$oc_lng)
    )
  )

  tbl2 <- oc_forward_df(data.frame(q_col = q), q_col)

  expect_identical(nrow(tbl2), 2L)
  expect_identical(tbl2$q_col, q)
  expect_true(
    all(
      is.na(tbl2$oc_formatted),
      is.na(tbl2$oc_lat),
      is.na(tbl2$oc_lng)
    )
  )

  tbl3 <- oc_forward_df(data.frame(q_col = q), q_col, bind_cols = FALSE)

  expect_identical(nrow(tbl3), 2L)
  expect_identical(tbl3$oc_query, q)
  expect_true(
    all(
      is.na(tbl3$oc_formatted),
      is.na(tbl3$oc_lat),
      is.na(tbl3$oc_lng)
    )
  )
})

test_that("oc_forward_df doesn't work for default class", {
  expect_error(
    oc_forward_df(53.6),
    "Can't geocode an object of class `numeric`."
  )
})

test_that("output arguments work", {
  skip_if_no_key()
  skip_if_oc_offline()

  expect_named(
    oc_forward_df(oc_fw1, loc, bind_cols = TRUE),
    c("id", "loc", "oc_lat", "oc_lng", "oc_formatted")
  )
  expect_named(
    oc_forward_df(oc_fw1, loc, bind_cols = FALSE),
    c("oc_query", "oc_lat", "oc_lng", "oc_formatted")
  )
  expect_gt(ncol(oc_forward_df(oc_fw1, loc, output = "all")), 5)
  expect_gt(
    ncol(oc_forward_df(oc_fw1, loc, bind_cols = FALSE, output = "all")),
    5
  )
})

test_that("tidyeval works for arguments", {
  skip_if_no_key()
  skip_if_oc_offline()

  noarg <- oc_forward_df(oc_fw2, loc, bind_cols = FALSE)

  ## bounds, proximity and countrycode
  bounds <- oc_forward_df(oc_fw2, loc, bounds = bounds, bind_cols = FALSE)
  prx <- oc_forward_df(oc_fw2, loc, proximity = proximity, bind_cols = FALSE)
  cc <- oc_forward_df(oc_fw2, loc, countrycode = countrycode, bind_cols = FALSE)
  expect_false(identical(bounds, noarg))
  expect_false(identical(prx, noarg))
  expect_false(identical(cc, noarg))
  expect_identical(bounds, prx)
  expect_identical(bounds, cc)

  # language
  lang <- oc_forward_df(oc_fw2, loc, language = language, output = "all")
  expect_identical(
    lang$oc_country,
    c("Frankreich", "Allemagne", "アメリカ合衆国")
  )

  # limit
  limit <- oc_forward_df(oc_fw2, loc, limit = limit)
  expect_identical(nrow(limit), 6L)
  expect_identical(limit$id, c(1L, 2L, 2L, 3L, 3L, 3L))

  # min_confidence
  confidence <- oc_forward_df(
    oc_fw2,
    loc,
    min_confidence = confidence,
    bind_cols = FALSE
  )

  # make sure we get actual results, not only NA
  expect_false(anyNA(confidence$oc_formatted))

  expect_false(identical(confidence[1, ], noarg[1, ]))
  expect_false(identical(confidence[2, ], noarg[2, ]))
  expect_false(identical(confidence[3, ], noarg[3, ]))

  # no_annotations
  ann <-
    oc_forward_df(
      oc_fw2,
      loc,
      bind_cols = FALSE,
      no_annotations = annotation
    )
  expect_gt(ncol(ann), 30)
  expect_identical(ann$oc_currency_name, c("Euro", NA, NA))

  # roadinfo
  ri <- oc_forward_df(
    oc_fw3,
    loc,
    roadinfo = roadinfo
  )
  expect_identical(ri$oc_roadinfo_speed_in, c(NA_character_, "km/h", "mph"))

  # abbrv
  abbrv <- oc_forward_df(
    oc_fw2,
    loc,
    abbrv = abbrv,
    bind_cols = FALSE
  )
  expect_identical(abbrv[[1, "oc_formatted"]], noarg[[1, "oc_formatted"]])
  expect_identical(abbrv[[2, "oc_formatted"]], noarg[[2, "oc_formatted"]])
  expect_false(identical(
    abbrv[[3, "oc_formatted"]],
    noarg[[3, "oc_formatted"]]
  ))

  # address_only
  city_halls <- c("Hôtel de ville de Nantes", "Los Angeles City Hall")
  address_full <- oc_forward_df(city_halls, address_only = FALSE)
  address_only <- oc_forward_df(city_halls, address_only = TRUE)
  expect_false(identical(
    address_full[[1, "oc_formatted"]],
    address_only[[1, "oc_formatted"]]
  ))
  expect_false(identical(
    address_full[[1, "oc_formatted"]],
    address_only[[1, "oc_formatted"]]
  ))
  expect_match(
    address_full[[1, "oc_formatted"]],
    address_only[[1, "oc_formatted"]],
    fixed = TRUE
  )
  expect_match(
    address_full[[1, "oc_formatted"]],
    address_only[[1, "oc_formatted"]],
    fixed = TRUE
  )
})

test_that("list columns are not dropped (by tidyr)", {
  skip_if_no_key()
  skip_if_oc_offline()

  bnds <- oc_forward_df(oc_fw2, loc, bounds = bounds, bind_cols = TRUE)
  expect_false(is.null(bnds[["bounds"]]))
})

test_that("oc_forward_df handles response with no results", {
  skip_if_no_key()
  skip_if_oc_offline()

  # https://opencagedata.com/api#no-results
  nores_df <- oc_forward_df("NOWHERE-INTERESTING")
  expect_s3_class(nores_df, c("tbl_df", "tbl", "data.frame"))
  expect_identical(nores_df[[1, "oc_lat"]], NA_real_)
})

# Checks ------------------------------------------------------------------

test_that("Check that placename is present", {
  # oc_forward
  expect_error(oc_forward(), "`placename` must be provided.")
  expect_error(oc_forward(placename = NULL), "`placename` must be provided.")

  # oc_forward_df
  expect_error(oc_forward_df(oc_fw1), "`placename` must be provided.")
  expect_error(oc_forward_df(oc_fw1, NULL), "`placename` must be provided.")
})
