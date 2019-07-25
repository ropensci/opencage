## Test deprecated opencage_forward ##

test_that("opencage_forward/opencage_reverse return what they should.", {
  skip_on_cran()
  skip_if_offline()

  results <- opencage_forward(placename = "Sarzeau")
  expect_is(results, "list")
  expect_is(results[["results"]], "tbl_df")
  expect_is(results[["total_results"]], "integer")
  expect_is(results[["time_stamp"]], "POSIXct")
  expect_equal(length(results), 4)


  results <- opencage_forward(placename = "Islington, London")
  expect_is(results, "list")
  expect_is(results[["results"]], "tbl_df")
  expect_is(results[["total_results"]], "integer")
  expect_is(results[["time_stamp"]], "POSIXct")
  expect_equal(length(results), 4)

  placename <- "Triererstr 15, Weimar 99423, Deutschland"
  results <- opencage_forward(placename = placename)
  expect_is(results, "list")
  expect_is(results[["results"]], "tbl_df")
  expect_is(results[["total_results"]], "integer")
  expect_is(results[["time_stamp"]], "POSIXct")
  expect_equal(length(results), 4)

  results <- opencage_reverse(
    longitude = 0, latitude = 0,
    limit = 2, key = Sys.getenv("OPENCAGE_KEY")
  )
  expect_is(results, "list")
  expect_is(results[["results"]], "tbl_df")
  expect_is(results[["total_results"]], "integer")
  expect_is(results[["time_stamp"]], "POSIXct")
  expect_equal(length(results), 4)
})

test_that("opencage_forward/opencage_reverse return what they should
          with several parameters.", {
  skip_on_cran()
  skip_if_offline()

  results <- opencage_forward(
    placename = "Paris",
    key = Sys.getenv("OPENCAGE_KEY"),
    limit = 2,
    min_confidence = 5,
    language = "fr",
    no_annotations = TRUE
  )
  expect_is(results, "list")
  expect_is(results[["results"]], "tbl_df")
  expect_is(results[["total_results"]], "integer")
  expect_is(results[["time_stamp"]], "POSIXct")
  expect_equal(length(results), 4)
  expect_equal(sum(grepl(
    "annotation",
    names(results[["results"]])
  )), 0)
  expect_true(dplyr::between(nrow(results[["results"]]), 1, 2))

  results <- opencage_reverse(
    latitude = 44,
    longitude = 44,
    key = Sys.getenv("OPENCAGE_KEY"),
    limit = 2,
    min_confidence = 5,
    language = "pt-BR",
    no_annotations = TRUE
  )
  expect_is(results, "list")
  expect_is(results[["results"]], "tbl_df")
  expect_is(results[["total_results"]], "integer")
  expect_is(results[["time_stamp"]], "POSIXct")
  expect_equal(length(results), 4)
  expect_equal(sum(grepl(
    "annotation",
    names(results[["results"]])
  )), 0)
  expect_true(dplyr::between(nrow(results[["results"]]), 1, 2))
})

test_that("opencage_forward deals well with results being NULL", {
  skip_on_cran()
  skip_if_offline()

  results <- opencage_forward(
    placename = "thiswillgetmenoresultswichisgood",
    key = Sys.getenv("OPENCAGE_KEY"),
    limit = 2,
    min_confidence = 5,
    language = "pt-BR",
    no_annotations = TRUE
  )
  expect_is(results, "list")
  expect_null(results[["results"]])
  expect_is(results[["total_results"]], "integer")
  expect_is(results[["time_stamp"]], "POSIXct")
})


test_that("the bounds argument is well taken into account", {
  skip_on_cran()
  skip_if_offline()

  results1 <- opencage_forward(
    placename = "Berlin",
    key = Sys.getenv("OPENCAGE_KEY")
  )

  results2 <- opencage_forward(
    placename = "Berlin",
    bounds = c(-90, 38, 0, 45),
    key = Sys.getenv("OPENCAGE_KEY")
  )

  expect_true(!("Germany" %in% results2$results$components.country))
  expect_true("Germany" %in% results1$results$components.country)
})

test_that("opencage_forward & opencage_reverse are not vectorised.", {
  expect_error(
    object = opencage_forward(c("Trier", "Ulm")),
    regexp = "`opencage_forward` is not vectorised"
  )
  expect_error(
    opencage_reverse(latitude = c(47,53), longitude = c(-1.5, 10)),
    regexp = "`opencage_reverse` is not vectorised"
  )
})
