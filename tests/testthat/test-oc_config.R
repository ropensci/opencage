## Test oc_config ##

test_that("oc_config sets OPENCAGE_KEY environment variable", {

  # default envvar
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))
  oc_config()
  expect_equal(Sys.getenv("OPENCAGE_KEY"), key_200)

  # set key directly (or via keyring etc.)
  withr::local_envvar(c("OPENCAGE_KEY" = ""))
  oc_config(key = key_200)
  expect_equal(Sys.getenv("OPENCAGE_KEY"), key_200)

  # override previously set key
  withr::local_envvar(c("OPENCAGE_KEY" = key_402))
  oc_config(key = key_200)
  expect_equal(Sys.getenv("OPENCAGE_KEY"), key_200)
})

test_that("oc_config throws error with faulty OpenCage key", {

  # unset key
  withr::local_envvar(c("OPENCAGE_KEY" = ""))
  expect_equal(Sys.getenv("OPENCAGE_KEY"), "")

  # error without key in non-interactive mode
  expect_error(oc_config(key = ""), "set the environment variable OPENCAGE_KEY")

  # error with key that is not 32 characters long
  expect_error(
    oc_config(key = "incomplete_key"),
    "(OpenCage API key must be a )*.( string.)"
  )
})


# test rate_sec argument --------------------------------------------------

timer <- function(expr) {
  system.time(expr)[["elapsed"]]
}

oc_get_limited_test <- function(reps) {
  replicate(
    reps,
    oc_get_limited("https://httpbin.org/get")
  )
}

test_that("oc_config updates rate limit of oc_get_limit", {
  skip_on_cran()
  skip_if_offline()

  rps <- 5L
  oc_config(rate_sec = rps)
  t <- timer(oc_get_limited_test(rps + 1))
  expect_gt(t, 1)
  expect_lt(t, 2)


  rps <- 3L
  oc_config(rate_sec = rps)
  t <- timer(oc_get_limited_test(rps + 1))
  expect_gt(t, 1)
  expect_lt(t, 2)
})


# test no_record argument -------------------------------------------------

test_that("oc_config sets no_record", {

  # Default without envvar and oc_config: no_record = FALSE
  withr::local_options(list(oc_no_record = NULL))
  res <- oc_process("Hamburg", return = "url_only", get_key = FALSE)
  expect_match(res[[1]], "&no_record=0", fixed = TRUE)

  # Default with oc_config: no_record = FALSE
  oc_config()
  expect_equal(getOption("oc_no_record"), FALSE)
  res <- oc_process("Hamburg", return = "url_only", get_key = FALSE)
  expect_match(res[[1]], "&no_record=0", fixed = TRUE)

  # oc_config sets no_record = TRUE
  oc_config(no_record = TRUE)
  expect_equal(getOption("oc_no_record"), TRUE)
  res <- oc_process("Hamburg", return = "url_only", get_key = FALSE)
  expect_match(res[[1]], "&no_record=1", fixed = TRUE)

})
