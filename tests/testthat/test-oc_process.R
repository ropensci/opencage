## Test oc_process ##

test_that("oc_process does not reveal key with non-interactive `url_only`.", {
  # This test (intentionally) fails in interactive mode.
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))
  expect_error(
    object =
      oc_process(
        placename = "Paris",
        return = "url_only",
        get_key = TRUE
      ),
    regexp = "'url_only' reveals your OpenCage key"
  )
})

test_that("oc_process creates meaningful URLs for single query.", {
  res <-
    oc_process(
      placename = "Paris",
      return = "url_only",
      get_key = FALSE
    )
  expect_type(res, "list")
  expect_type(unlist(res), "character")
  expect_match(res[[1]], "q=Paris", fixed = TRUE)

  res <-
    oc_process(
      placename = "Islington, London",
      return = "url_only",
      get_key = FALSE
    )
  expect_match(res[[1]], "q=Islington%2C%20London", fixed = TRUE)

  res <-
    oc_process(
      placename = "Triererstr 15, 99423 Weimar, Deutschland",
      return = "url_only",
      get_key = FALSE
    )
  expect_match(
    res[[1]],
    "q=Triererstr%2015%2C%2099423%20Weimar%2C%20Deutschland",
    fixed = TRUE
  )

  res <-
    oc_process(
      latitude = 41.40139,
      longitude = 2.12870,
      return = "url_only",
      get_key = FALSE
    )
  expect_type(res, "list")
  expect_type(unlist(res), "character")
  expect_match(res[[1]], "q=41.40139%2C2.1287", fixed = TRUE)
})

test_that("oc_process creates meaningful URLs with NAs.", {
  res <-
    oc_process(
      placename = NA_character_,
      return = "url_only",
      get_key = FALSE
    )
  expect_match(res[[1]], "q=&", fixed = TRUE)
  res <-
    oc_process(
      latitude = NA_real_,
      longitude = NA_real_,
      return = "url_only",
      get_key = FALSE
    )
  expect_match(res[[1]], "q=&", fixed = TRUE)
  res <-
    oc_process(
      latitude = 0,
      longitude = NA_real_,
      return = "url_only",
      get_key = FALSE
    )
  expect_match(res[[1]], "q=&", fixed = TRUE)
  res <-
    oc_process(
      latitude = NA_real_,
      longitude = 0,
      return = "url_only",
      get_key = FALSE
    )
  expect_match(res[[1]], "q=&", fixed = TRUE)
})

test_that("oc_process creates meaningful URLs for multiple queries.", {
  res <- oc_process(
    placename = c("Paris", "Hamburg"),
    return = "url_only",
    get_key = FALSE
  )
  expect_type(res, "list")
  expect_type(unlist(res), "character")
  expect_match(res[[1]], "q=Paris", fixed = TRUE)
  expect_match(res[[2]], "q=Hamburg", fixed = TRUE)

  res <- oc_process(
    latitude = c(48.87378, 37.83032),
    longitude = c(2.295037, -122.47975),
    return = "url_only",
    get_key = FALSE
  )
  expect_type(res, "list")
  expect_type(unlist(res), "character")
  expect_match(res[[1]], "q=48.87378%2C2.295037", fixed = TRUE)
  expect_match(res[[2]], "q=37.83032%2C-122.47975", fixed = TRUE)
})

test_that("oc_process deals well with res being NULL", {
  skip_on_cran()
  skip_if_offline()

  res <- oc_process(
    placename = "thiswillgetmenoreswhichisgood",
    limit = 2,
    min_confidence = 5,
    language = "pt-BR",
    no_annotations = TRUE,
    return = "tibble"
  )
  expect_null(res[["res"]])
})

test_that("oc_process handles bounds argument.", {
  res <- oc_process(
    placename = "Sarzeau",
    get_key = FALSE,
    bounds = list(c(-5.5, 51.2, 0.2, 51.6)),
    return = "url_only"
  )
  expect_match(res[[1]], "&bounds=-5.5%2C51.2%2C0.2%2C51.6", fixed = TRUE)

  res <- oc_process(
    placename = "Sarzeau",
    get_key = FALSE,
    bounds = oc_bbox(-5.6, 51.2, 0.2, 51.6),
    return = "url_only"
  )
  expect_match(res[[1]], "&bounds=-5.6%2C51.2%2C0.2%2C51.6", fixed = TRUE)

  res <- oc_process(
    place = c("Hamburg", "Hamburg"),
    get_key = FALSE,
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
})

test_that("bounds argument is well taken into account with tibble", {
  skip_on_cran()
  skip_if_offline()

  res1 <- oc_process(
    placename = "Berlin",
    return = "tibble"
  )

  res2 <- oc_process(
    placename = "Berlin",
    bounds = list(c(-90, 38, 0, 45)),
    limit = 10,
    return = "tibble"
  )

  expect_equal(unnest(res1, data)$oc_country, "Germany")
  expect_false("Germany" %in% unnest(res2, data)$oc_country)
})

test_that("oc_process handles proximity argument.", {
  res <- oc_process(
    placename = "Warsaw",
    get_key = FALSE,
    proximity = list(c(latitude = 41.2, longitude = -85.8)),
    return = "url_only"
  )
  expect_match(res[[1]], "&proximity=41.2%2C-85.8", fixed = TRUE)

  res <- oc_process(
    placename = "Warsaw",
    get_key = FALSE,
    proximity = oc_points(latitude = 41.2, longitude = -85.8),
    return = "url_only"
  )
  expect_match(res[[1]], "&proximity=41.2%2C-85.8", fixed = TRUE)

  res <- oc_process(
    place = c("Warsaw", "Warsaw"),
    get_key = FALSE,
    proximity = oc_points(
      longitude = c(-85.8, 19.0),
      latitude = c(41.2, 52.0)
    ),
    return = "url_only"
  )
  expect_match(res[[1]], "&proximity=41.2%2C-85.8", fixed = TRUE)
  expect_match(res[[2]], "&proximity=52%2C19", fixed = TRUE)
})

test_that("oc_process handles language argument.", {
  res1 <- oc_process(
    placename = c("New York", "Rio", "Tokyo"),
    language = "ja",
    return = "url_only",
    get_key = FALSE
  )
  expect_match(res1[[1]], "&language=ja", fixed = TRUE)
  expect_match(res1[[2]], "&language=ja", fixed = TRUE)

  res2 <- oc_process(
    placename = c("Paris", "Hamburg"),
    language = c("de", "fr"),
    return = "url_only",
    get_key = FALSE
  )
  expect_match(res2[[1]], "&language=de", fixed = TRUE)
  expect_match(res2[[2]], "&language=fr", fixed = TRUE)
})

test_that("oc_process handles countrycode argument.", {
  res1 <- oc_process(
    placename = c("Hamburg", "Paris"),
    countrycode = "DE",
    return = "url_only",
    get_key = FALSE
  )
  expect_match(res1[[1]], "&countrycode=de", fixed = TRUE)
  expect_match(res1[[2]], "&countrycode=de", fixed = TRUE)

  res2 <- oc_process(
    placename = c("Hamburg", "Paris"),
    countrycode = list(c("US", "FR"), "DE"),
    return = "url_only",
    get_key = FALSE
  )
  expect_match(res2[[1]], "&countrycode=us%2Cfr", fixed = TRUE)
  expect_match(res2[[2]], "&countrycode=de", fixed = TRUE)

  res3 <- oc_process(
    placename = c("Hamburg", "Paris"),
    countrycode = list("US", "DE"),
    return = "url_only",
    get_key = FALSE
  )
  expect_match(res3[[1]], "&countrycode=us", fixed = TRUE)
  expect_match(res3[[2]], "&countrycode=de", fixed = TRUE)
})

test_that("oc_process handles various other arguments.", {
  res1 <- oc_process(
    placename = "Hamburg",
    return = "url_only",
    get_key = FALSE,
    limit = 1L,
    min_confidence = NULL,
    no_annotations = FALSE,
    roadinfo = FALSE,
    no_dedupe = FALSE,
    abbrv = FALSE
  )
  expect_match(res1[[1]], "&limit=1", fixed = TRUE)
  expect_false(grepl(pattern = "min_confidence", x = res1[[1]], fixed = TRUE))
  expect_match(res1[[1]], "&no_annotations=0", fixed = TRUE)
  expect_match(res1[[1]], "&roadinfo=0", fixed = TRUE)
  expect_match(res1[[1]], "&no_dedupe=0", fixed = TRUE)
  expect_match(res1[[1]], "&abbrv=0", fixed = TRUE)

  res2 <- oc_process(
    placename = "Hamburg",
    return = "url_only",
    get_key = FALSE,
    limit = 10,
    min_confidence = 8,
    no_annotations = TRUE,
    roadinfo = TRUE,
    no_dedupe = TRUE,
    abbrv = TRUE
  )
  expect_match(res2[[1]], "&limit=10", fixed = TRUE)
  expect_match(res2[[1]], "&min_confidence=8", fixed = TRUE)
  expect_match(res2[[1]], "&no_annotations=1", fixed = TRUE)
  expect_match(res2[[1]], "&roadinfo=1", fixed = TRUE)
  expect_match(res2[[1]], "&no_dedupe=1", fixed = TRUE)
  expect_match(res2[[1]], "&abbrv=1", fixed = TRUE)

  res3 <- oc_process(
    placename = c("Hamburg", "Hamburg"),
    return = "url_only",
    get_key = FALSE,
    limit = c(10L, 5L),
    min_confidence = c(8L, 5L),
    no_annotations = c(TRUE, FALSE),
    roadinfo = c(TRUE, FALSE),
    no_dedupe = c(TRUE, FALSE),
    abbrv = c(TRUE, FALSE)
  )
  expect_match(res3[[1]], "&limit=10", fixed = TRUE)
  expect_match(res3[[2]], "&limit=5", fixed = TRUE)
  expect_match(res3[[1]], "&min_confidence=8", fixed = TRUE)
  expect_match(res3[[2]], "&min_confidence=5", fixed = TRUE)
  expect_match(res3[[1]], "&no_annotations=1", fixed = TRUE)
  expect_match(res3[[2]], "&no_annotations=0", fixed = TRUE)
  expect_match(res3[[1]], "&roadinfo=1", fixed = TRUE)
  expect_match(res3[[2]], "&roadinfo=0", fixed = TRUE)
  expect_match(res3[[1]], "&no_dedupe=1", fixed = TRUE)
  expect_match(res3[[2]], "&no_dedupe=0", fixed = TRUE)
  expect_match(res3[[1]], "&abbrv=1", fixed = TRUE)
  expect_match(res3[[2]], "&abbrv=0", fixed = TRUE)
})

test_that("arguments that are NULL or NA don't show up in url.", {
  res_null <- oc_process(
    placename = "Hamburg",
    return = "url_only",
    get_key = FALSE,
    limit = NULL,
    bounds = NULL,
    proximity = NULL,
    language = NULL,
    countrycode = NULL,
    min_confidence = NULL,
    no_annotations = NULL,
    no_dedupe = NULL,
    abbrv = NULL
  )
  expect_match(res_null[[1]], "^((?!key=).)*$", perl = TRUE)
  expect_match(res_null[[1]], "^((?!limit=).)*$", perl = TRUE)
  expect_match(res_null[[1]], "^((?!bounds=).)*$", perl = TRUE)
  expect_match(res_null[[1]], "^((?!proximity=).)*$", perl = TRUE)
  expect_match(res_null[[1]], "^((?!language=).)*$", perl = TRUE)
  expect_match(res_null[[1]], "^((?!countrycode=).)*$", perl = TRUE)
  expect_match(res_null[[1]], "^((?!min_confidence=).)*$", perl = TRUE)
  expect_match(res_null[[1]], "^((?!no_annotations=).)*$", perl = TRUE)
  expect_match(res_null[[1]], "^((?!no_dedupe=).)*$", perl = TRUE)
  expect_match(res_null[[1]], "^((?!abbrv=).)*$", perl = TRUE)
  expect_match(res_null[[1]], "^((?!add_request=).)*$", perl = TRUE)

  res_na <- oc_process(
    placename = "Hamburg",
    return = "url_only",
    get_key = FALSE,
    limit = NA_real_,
    bounds = list(),
    proximity = list(),
    language = NA_character_,
    countrycode = NA_character_,
    min_confidence = NA,
    no_annotations = NA,
    no_dedupe = NA,
    abbrv = NA
  )
  expect_match(res_na[[1]], "^((?!key=).)*$", perl = TRUE)
  expect_match(res_na[[1]], "^((?!limit=).)*$", perl = TRUE)
  expect_match(res_na[[1]], "^((?!bounds=).)*$", perl = TRUE)
  expect_match(res_na[[1]], "^((?!proximity=).)*$", perl = TRUE)
  expect_match(res_na[[1]], "^((?!language=).)*$", perl = TRUE)
  expect_match(res_na[[1]], "^((?!countrycode=).)*$", perl = TRUE)
  expect_match(res_na[[1]], "^((?!min_confidence=).)*$", perl = TRUE)
  expect_match(res_na[[1]], "^((?!no_annotations=).)*$", perl = TRUE)
  expect_match(res_na[[1]], "^((?!no_dedupe=).)*$", perl = TRUE)
  expect_match(res_na[[1]], "^((?!abbrv=).)*$", perl = TRUE)
  expect_match(res_na[[1]], "^((?!add_request=).)*$", perl = TRUE)
})
