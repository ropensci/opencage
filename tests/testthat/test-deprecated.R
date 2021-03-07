## Test deprecated opencage_forward ##

test_that("opencage_forward/opencage_reverse return what they should.", {
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))

  lifecycle::expect_deprecated(
    vcr::use_cassette("opencage_forward_Sarzeau_200", {
      results <- opencage_forward(placename = "Sarzeau", key = key_200)
    })
  )
  expect_type(results, "list")
  expect_s3_class(results[["results"]], "tbl_df")
  expect_type(results[["total_results"]], "integer")
  expect_s3_class(results[["time_stamp"]], "POSIXct")
  expect_equal(length(results), 4)

  lifecycle::expect_deprecated(
    vcr::use_cassette("opencage_reverse_nullisland_200", {
      results <- opencage_reverse(longitude = 0, latitude = 0, key = key_200)
    })
  )
  expect_type(results, "list")
  expect_s3_class(results[["results"]], "tbl_df")
  expect_type(results[["total_results"]], "integer")
  expect_s3_class(results[["time_stamp"]], "POSIXct")
  expect_equal(length(results), 4)
})

vcr::use_cassette("opencage_forward_parameters", {
  test_that("opencage_forward/opencage_reverse return what they should
            with several parameters.", {
    withr::local_envvar(c("OPENCAGE_KEY" = key_200))
    withr::local_options(lifecycle_verbosity = "quiet")

    results <- opencage_forward(
      placename = "Paris",
      limit = 2,
      min_confidence = 5,
      language = "fr",
      no_annotations = TRUE
    )
    expect_type(results, "list")
    expect_s3_class(results[["results"]], "tbl_df")
    expect_type(results[["total_results"]], "integer")
    expect_s3_class(results[["time_stamp"]], "POSIXct")
    expect_equal(length(results), 4)
    expect_equal(sum(grepl(
      "annotation",
      names(results[["results"]])
    )), 0)
    expect_true(dplyr::between(nrow(results[["results"]]), 1, 2))

    results <- opencage_reverse(
      latitude = 44,
      longitude = 44,
      min_confidence = 5,
      language = "pt-BR",
      no_annotations = TRUE
    )
    expect_type(results, "list")
    expect_s3_class(results[["results"]], "tbl_df")
    expect_type(results[["total_results"]], "integer")
    expect_s3_class(results[["time_stamp"]], "POSIXct")
    expect_equal(length(results), 4)
    expect_equal(sum(grepl(
      "annotation",
      names(results[["results"]])
    )), 0)
    expect_true(dplyr::between(nrow(results[["results"]]), 1, 2))
  })
})

test_that("opencage_forward deals well with results being NULL", {
  # the query NOWHERE-INTERESTING will return a valid response with 0 results
  # https://opencagedata.com/api#no-results
  withr::local_options(lifecycle_verbosity = "quiet")

  vcr::use_cassette("opencage_forward_NULL", {
    results <- opencage_forward(
      placename = "NOWHERE-INTERESTING",
      key = Sys.getenv("OPENCAGE_KEY"),
      limit = 2,
      min_confidence = 5,
      language = "pt-BR",
      no_annotations = TRUE
    )
  })
  expect_type(results, "list")
  expect_null(results[["results"]])
  expect_type(results[["total_results"]], "integer")
  expect_s3_class(results[["time_stamp"]], "POSIXct")
})

test_that("the bounds argument is well taken into account", {
  withr::local_options(lifecycle_verbosity = "quiet")

  vcr::use_cassette("opencage_forward_bounds", {
    results1 <- opencage_forward(
      placename = "Berlin",
      key = Sys.getenv("OPENCAGE_KEY")
    )
    results2 <- opencage_forward(
      placename = "Berlin",
      bounds = c(-90, 38, 0, 45),
      key = Sys.getenv("OPENCAGE_KEY")
    )
  })

  expect_true(!("Germany" %in% results2$results$components.country))
  expect_true("Germany" %in% results1$results$components.country)
})

test_that("Errors with multiple inputs", {
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))

  expect_error(opencage_forward(c("Hamburg", "Los Angeles")),
    "`opencage_forward` is not vectorised; use `oc_forward` instead.")
  expect_error(opencage_reverse(c(5, 20), c(6, 21)),
    "`opencage_reverse` is not vectorised, use `oc_reverse` instead.")
})

# Test opencage_key -------------------------------------------------------

test_that("`opencage_key()` returns NULL if OPENCAGE_KEY envvar not found", {
  withr::local_envvar(c("OPENCAGE_KEY" = ""))
  withr::local_options(lifecycle_verbosity = "quiet")
  expect_null(opencage_key())
})

test_that("`opencage_key(quiet = FALSE)` messages", {
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))
  withr::local_options(lifecycle_verbosity = "quiet")
  expect_message(
    object = opencage_key(quiet = FALSE),
    regexp = "Using OpenCage API Key from envvar OPENCAGE_KEY"
  )
})
