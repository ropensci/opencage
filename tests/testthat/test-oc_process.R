library("opencage")
context("oc_process")

fk <- "fakekey"

test_that("oc_process creates meaningful URLs for single query.", {
  res <-
    oc_process(placename = "Paris",
               output = "url_only",
               key = fk)
  expect_is(res, "list")
  expect_is(unlist(res), "character")
  expect_match(res[[1]], "q=Paris")
  expect_match(res[[1]], "key=fakekey")

  res <-
    oc_process(placename = "Islington, London",
               output = "url_only",
               key = fk)
  expect_match(res[[1]], "q=Islington%2C%20London")

  res <-
    oc_process(placename = "Triererstr 15, 99423 Weimar, Deutschland",
               output = "url_only",
               key = fk)
  expect_match(res[[1]],
               "q=Triererstr%2015%2C%2099423%20Weimar%2C%20Deutschland")

  res <-
    oc_process(
      latitude = 41.40139,
      longitude = 2.12870,
      output = "url_only",
      key = fk
    )
  expect_is(res, "list")
  expect_is(unlist(res), "character")
  expect_match(res[[1]], "q=41.40139%2C2.1287")
})

test_that("oc_process creates meaningful URLs for multiple queries.", {
  res <- oc_process(
    placename = c("Paris", "Hamburg"),
    output = "url_only",
    key = fk
  )
  expect_is(res, "list")
  expect_is(unlist(res), "character")
  expect_match(res[[1]], "q=Paris")
  expect_match(res[[2]], "q=Hamburg")

  res <- oc_process(
    latitude = c(48.87378, 37.83032),
    longitude = c(2.295037, -122.47975),
    output = "url_only",
    key = fk
  )
  expect_is(res, "list")
  expect_is(unlist(res), "character")
  expect_match(res[[1]], "q=48.87378%2C2.295037")
  expect_match(res[[2]], "q=37.83032%2C-122.47975")
})

test_that("oc_process deals well with res being NULL", {
  skip_on_cran()
    res <- oc_process(
    placename = "thiswillgetmenoreswichisgood",
    key = Sys.getenv("OPENCAGE_KEY"),
    limit = 2,
    min_confidence = 5,
    language = "pt-BR",
    no_annotations = TRUE,
    output = "df_list"
  )
  expect_null(res[["res"]])
})


test_that("the bounds argument is well taken into account", {
  res <- oc_process(
    placename = "Sarzeau",
    key = fk,
    bounds = list(c(-5.5, 51.2, 0.2, 51.6)),
    output = "url_only"
  )
  expect_match(res[[1]], "bounds=-5.5%2C51.2%2C0.2%2C51.6")

  res <- oc_process(
    placename = "Sarzeau",
    key = fk,
    bounds = oc_bbox(-5.6, 51.2, 0.2, 51.6),
    output = "url_only"
  )
  expect_match(res[[1]], "bounds=-5.6%2C51.2%2C0.2%2C51.6")

  res <- oc_process(
    place = c("Hamburg", "Hamburg"),
    key = fk,
    bounds = oc_bbox(
      ymax = c(54.02, 42.73),
      xmax = c(10.32, -78.81),
      ymin = c(53.39, 42.70),
      xmin = c(8.10, -78.86)
    ),
    output = "url_only"
  )
  expect_match(res[[1]], "bounds=8.1%2C53.39%2C10.32%2C54.02")
  expect_match(res[[2]], "bounds=-78.86%2C42.7%2C-78.81%2C42.73")

  res1 <- oc_process(
    placename = "Berlin",
    key = Sys.getenv("OPENCAGE_KEY"),
    output = "df_list"
  )

  res2 <- oc_process(
    placename = "Berlin",
    bounds = list(c(-90, 38, 0, 45)),
    key = Sys.getenv("OPENCAGE_KEY"),
    output = "df_list"
  )

  expect_equal(res1[[1]][["country"]], "Germany")
  expect_true(res2[[1]][["country"]] != "Germany")
})

test_that("oc_process handles language argument.", {
  res1 <- oc_process(
    placename = c("New York", "Rio", "Tokyo"),
    language = "ja",
    output = "url_only",
    key = fk
  )
  expect_match(res1[[1]], "language=ja", fixed = TRUE)
  expect_match(res1[[2]], "language=ja", fixed = TRUE)

  res2 <- oc_process(
    placename = c("Paris", "Hamburg"),
    language = c("de", "fr"),
    output = "url_only",
    key = fk
  )
  expect_match(res2[[1]], "language=de", fixed = TRUE)
  expect_match(res2[[2]], "language=fr", fixed = TRUE)
})

test_that("oc_process handles countrycode argument.", {
  res1 <- oc_process(
    placename = c("Hamburg", "Paris"),
    countrycode = "DE",
    output = "url_only",
    key = fk
  )
  expect_match(res1[[1]], "countrycode=de", fixed = TRUE)
  expect_match(res1[[2]], "countrycode=de", fixed = TRUE)

  res2 <- oc_process(
    placename = c("Hamburg", "Paris"),
    countrycode = list(c("US", "FR"), "DE"),
    output = "url_only",
    key = fk
  )
  expect_match(res2[[1]], "countrycode=us%2Cfr", fixed = TRUE)
  expect_match(res2[[2]], "countrycode=de", fixed = TRUE)

  res3 <- oc_process(
    placename = c("Hamburg", "Paris"),
    countrycode = list("US", "DE"),
    output = "url_only",
    key = fk
  )
  expect_match(res3[[1]], "countrycode=us", fixed = TRUE)
  expect_match(res3[[2]], "countrycode=de", fixed = TRUE)
})

test_that("oc_process handles various other arguments.", {
  res1 <- oc_process(
    placename = "Hamburg",
    output = "url_only",
    key = NULL,
    limit = 1L,
    min_confidence = NULL,
    no_annotations = FALSE,
    no_dedupe = FALSE,
    no_record = FALSE,
    abbrv = FALSE,
    add_request = FALSE
  )
  expect_match(res1[[1]], "limit=1", fixed = TRUE)
  expect_false(grepl(pattern = "min_confidence", x = res1[[1]], fixed = TRUE))
  expect_match(res1[[1]], "no_annotations=0", fixed = TRUE)
  expect_match(res1[[1]], "no_dedupe=0", fixed = TRUE)
  expect_match(res1[[1]], "no_record=0", fixed = TRUE)
  expect_match(res1[[1]], "abbrv=0", fixed = TRUE)
  expect_match(res1[[1]], "add_request=0", fixed = TRUE)

  res2 <- oc_process(
    placename = "Hamburg",
    output = "url_only",
    key = NULL,
    limit = 10,
    min_confidence = 8,
    no_annotations = TRUE,
    no_dedupe = TRUE,
    no_record = TRUE,
    abbrv = TRUE,
    add_request = TRUE
  )
  expect_match(res2[[1]], "limit=10", fixed = TRUE)
  expect_match(res2[[1]], "min_confidence=8", fixed = TRUE)
  expect_match(res2[[1]], "no_annotations=1", fixed = TRUE)
  expect_match(res2[[1]], "no_dedupe=1", fixed = TRUE)
  expect_match(res2[[1]], "no_record=1", fixed = TRUE)
  expect_match(res2[[1]], "abbrv=1", fixed = TRUE)
  expect_match(res2[[1]], "add_request=1", fixed = TRUE)
})
