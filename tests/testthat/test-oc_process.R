library("opencage")
context("oc_process")

fk <- "fakekey"

test_that("oc_process creates meaningful URLs for single query.", {
  res <-
    oc_process(placename = "Paris",
               return = "url_only",
               key = fk)
  expect_is(res, "list")
  expect_is(unlist(res), "character")
  expect_match(res[[1]], "q=Paris", fixed = TRUE)
  expect_match(res[[1]], "&key=fakekey", fixed = TRUE)

  res <-
    oc_process(placename = "Islington, London",
               return = "url_only",
               key = fk)
  expect_match(res[[1]], "q=Islington%2C%20London", fixed = TRUE)
  expect_match(res[[1]], "key=fakekey", fixed = TRUE)

  res <-
    oc_process(placename = "Triererstr 15, 99423 Weimar, Deutschland",
               return = "url_only",
               key = fk)
  expect_match(res[[1]],
               "q=Triererstr%2015%2C%2099423%20Weimar%2C%20Deutschland",
               fixed = TRUE)

  res <-
    oc_process(
      latitude = 41.40139,
      longitude = 2.12870,
      return = "url_only",
      key = fk
    )
  expect_is(res, "list")
  expect_is(unlist(res), "character")
  expect_match(res[[1]], "q=41.40139%2C2.1287", fixed = TRUE)
})

test_that("oc_process creates meaningful URLs for multiple queries.", {
  res <- oc_process(
    placename = c("Paris", "Hamburg"),
    return = "url_only",
    key = fk
  )
  expect_is(res, "list")
  expect_is(unlist(res), "character")
  expect_match(res[[1]], "q=Paris", fixed = TRUE)
  expect_match(res[[2]], "q=Hamburg", fixed = TRUE)
  expect_match(res[[1]], "&key=fakekey", fixed = TRUE)
  expect_match(res[[2]], "&key=fakekey", fixed = TRUE)


  res <- oc_process(
    latitude = c(48.87378, 37.83032),
    longitude = c(2.295037, -122.47975),
    return = "url_only",
    key = fk
  )
  expect_is(res, "list")
  expect_is(unlist(res), "character")
  expect_match(res[[1]], "q=48.87378%2C2.295037", fixed = TRUE)
  expect_match(res[[2]], "q=37.83032%2C-122.47975", fixed = TRUE)
})

test_that("oc_process deals well with res being NULL", {
  skip_on_cran()
    res <- oc_process(
    placename = "thiswillgetmenoreswhichisgood",
    key = Sys.getenv("OPENCAGE_KEY"),
    limit = 2,
    min_confidence = 5,
    language = "pt-BR",
    no_annotations = TRUE,
    return = "df_list"
  )
  expect_null(res[["res"]])
})


test_that("the bounds argument is well taken into account", {
  res <- oc_process(
    placename = "Sarzeau",
    key = fk,
    bounds = list(c(-5.5, 51.2, 0.2, 51.6)),
    return = "url_only"
  )
  expect_match(res[[1]], "&bounds=-5.5%2C51.2%2C0.2%2C51.6", fixed = TRUE)

  res <- oc_process(
    placename = "Sarzeau",
    key = fk,
    bounds = oc_bbox(-5.6, 51.2, 0.2, 51.6),
    return = "url_only"
  )
  expect_match(res[[1]], "&bounds=-5.6%2C51.2%2C0.2%2C51.6", fixed = TRUE)

  res <- oc_process(
    place = c("Hamburg", "Hamburg"),
    key = fk,
    bounds = oc_bbox(
      ymax = c(54.02, 42.73),
      xmax = c(10.32, -78.81),
      ymin = c(53.39, 42.70),
      xmin = c(8.10, -78.86)
    ),
    return = "url_only"
  )
  expect_match(res[[1]], "&bounds=8.1%2C53.39%2C10.32%2C54.02", fixed = TRUE)
  expect_match(res[[2]], "&bounds=-78.86%2C42.7%2C-78.81%2C42.73", fixed = TRUE)

  res1 <- oc_process(
    placename = "Berlin",
    key = Sys.getenv("OPENCAGE_KEY"),
    return = "df_list"
  )

  # res2 is empty with limit=1, 2 or 3 -> bug in OpenCage?! => vcrify
  res2 <- oc_process(
    placename = "Berlin",
    bounds = list(c(-90, 38, 0, 45)),
    key = Sys.getenv("OPENCAGE_KEY"),
    limit = 10,
    return = "df_list"
  )

  expect_equal(res1[[1]][["country"]], "Germany")
  expect_true(res2[[1]][[1, "country"]] != "Germany")
})

test_that("oc_process handles language argument.", {
  res1 <- oc_process(
    placename = c("New York", "Rio", "Tokyo"),
    language = "ja",
    return = "url_only",
    key = fk
  )
  expect_match(res1[[1]], "&language=ja", fixed = TRUE)
  expect_match(res1[[2]], "&language=ja", fixed = TRUE)

  res2 <- oc_process(
    placename = c("Paris", "Hamburg"),
    language = c("de", "fr"),
    return = "url_only",
    key = fk
  )
  expect_match(res2[[1]], "&language=de", fixed = TRUE)
  expect_match(res2[[2]], "&language=fr", fixed = TRUE)
})

test_that("oc_process handles countrycode argument.", {
  res1 <- oc_process(
    placename = c("Hamburg", "Paris"),
    countrycode = "DE",
    return = "url_only",
    key = fk
  )
  expect_match(res1[[1]], "&countrycode=de", fixed = TRUE)
  expect_match(res1[[2]], "&countrycode=de", fixed = TRUE)

  res2 <- oc_process(
    placename = c("Hamburg", "Paris"),
    countrycode = list(c("US", "FR"), "DE"),
    return = "url_only",
    key = fk
  )
  expect_match(res2[[1]], "&countrycode=us%2Cfr", fixed = TRUE)
  expect_match(res2[[2]], "&countrycode=de", fixed = TRUE)

  res3 <- oc_process(
    placename = c("Hamburg", "Paris"),
    countrycode = list("US", "DE"),
    return = "url_only",
    key = fk
  )
  expect_match(res3[[1]], "&countrycode=us", fixed = TRUE)
  expect_match(res3[[2]], "&countrycode=de", fixed = TRUE)
})

test_that("oc_process handles various other arguments.", {
  res1 <- oc_process(
    placename = "Hamburg",
    return = "url_only",
    key = NULL,
    limit = 1L,
    min_confidence = NULL,
    no_annotations = FALSE,
    no_dedupe = FALSE,
    no_record = FALSE,
    abbrv = FALSE,
    add_request = FALSE
  )
  expect_match(res1[[1]], "&limit=1", fixed = TRUE)
  expect_false(grepl(pattern = "min_confidence", x = res1[[1]], fixed = TRUE))
  expect_match(res1[[1]], "&no_annotations=0", fixed = TRUE)
  expect_match(res1[[1]], "&no_dedupe=0", fixed = TRUE)
  expect_match(res1[[1]], "&no_record=0", fixed = TRUE)
  expect_match(res1[[1]], "&abbrv=0", fixed = TRUE)
  expect_match(res1[[1]], "&add_request=0", fixed = TRUE)

  res2 <- oc_process(
    placename = "Hamburg",
    return = "url_only",
    key = NULL,
    limit = 10,
    min_confidence = 8,
    no_annotations = TRUE,
    no_dedupe = TRUE,
    no_record = TRUE,
    abbrv = TRUE,
    add_request = TRUE
  )
  expect_match(res2[[1]], "&limit=10", fixed = TRUE)
  expect_match(res2[[1]], "&min_confidence=8", fixed = TRUE)
  expect_match(res2[[1]], "&no_annotations=1", fixed = TRUE)
  expect_match(res2[[1]], "&no_dedupe=1", fixed = TRUE)
  expect_match(res2[[1]], "&no_record=1", fixed = TRUE)
  expect_match(res2[[1]], "&abbrv=1", fixed = TRUE)
  expect_match(res2[[1]], "&add_request=1", fixed = TRUE)

  res3 <- oc_process(
    placename = c("Hamburg", "Hamburg"),
    return = "url_only",
    key = NULL,
    limit = c(10L, 5L),
    min_confidence = c(8L, 5L),
    no_annotations = c(TRUE, FALSE),
    no_dedupe = c(TRUE, FALSE),
    abbrv = c(TRUE, FALSE),
    add_request = c(TRUE, FALSE)
  )
  expect_match(res3[[1]], "&limit=10", fixed = TRUE)
  expect_match(res3[[2]], "&limit=5", fixed = TRUE)
  expect_match(res3[[1]], "&min_confidence=8", fixed = TRUE)
  expect_match(res3[[2]], "&min_confidence=5", fixed = TRUE)
  expect_match(res3[[1]], "&no_annotations=1", fixed = TRUE)
  expect_match(res3[[2]], "&no_annotations=0", fixed = TRUE)
  expect_match(res3[[1]], "&no_dedupe=1", fixed = TRUE)
  expect_match(res3[[2]], "&no_dedupe=0", fixed = TRUE)
  expect_match(res3[[1]], "&abbrv=1", fixed = TRUE)
  expect_match(res3[[2]], "&abbrv=0", fixed = TRUE)
  expect_match(res3[[1]], "&add_request=1", fixed = TRUE)
  expect_match(res3[[2]], "&add_request=0", fixed = TRUE)
})
