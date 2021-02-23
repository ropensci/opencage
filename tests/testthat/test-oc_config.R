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
  expect_equal(Sys.getenv("OPENCAGE_KEY"), key_402)
  oc_config(key = key_200)
  expect_equal(Sys.getenv("OPENCAGE_KEY"), key_200)
})

test_that("oc_config requests key from terminal", {
  skip_if_not_installed("mockery")
  rlang::local_interactive(TRUE)
  withr::local_envvar(c("OPENCAGE_KEY" = ""))
  mockery::stub(
    oc_config,
    "readline",
    key_200,
  )
  expect_message(
    oc_config(key = ""),
    "Please enter your OpenCage API key and press enter:"
  )
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

test_that("oc_config updates rate limit of oc_get_limit", {
  # make sure there is a key present
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))

  rps <- 5L
  oc_config(rate_sec = rps)
  expect_equal(ratelimitr::get_rates(oc_get_limited)[[1]][["n"]], rps)

  rps <- 3L
  oc_config(rate_sec = rps)
  expect_equal(ratelimitr::get_rates(oc_get_limited)[[1]][["n"]], rps)

  # set rate_sec back to default
  oc_config()
  expect_equal(
    ratelimitr::get_rates(oc_get_limited)[[1]][["n"]],
    getOption("oc_rate_sec", default = 1L)
  )
})

# test no_record argument -------------------------------------------------

test_that("oc_config sets no_record option", {
  # make sure there is a key present
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))

  # Default without envvar
  withr::local_options(list(oc_no_record = NULL))
  res <- oc_process("Hamburg", return = "url_only")
  expect_match(res[[1]], "&no_record=1", fixed = TRUE)

  # Default with oc_config(no_record = TRUE)
  oc_config()
  expect_equal(getOption("oc_no_record"), TRUE)
  res <- oc_process("Hamburg", return = "url_only")
  expect_match(res[[1]], "&no_record=1", fixed = TRUE)

  # Set oc_config(no_record = FALSE)
  oc_config(no_record = FALSE)
  expect_equal(getOption("oc_no_record"), FALSE)
  res <- oc_process("Hamburg", return = "url_only")
  expect_match(res[[1]], "&no_record=0", fixed = TRUE)

  # Set oc_config(no_record = TRUE)
  oc_config(no_record = TRUE)
  expect_equal(getOption("oc_no_record"), TRUE)
  res <- oc_process("Hamburg", return = "url_only")
  expect_match(res[[1]], "&no_record=1", fixed = TRUE)
})

# test show_key argument --------------------------------------------------

test_that("oc_config sets show_key option", {
  # make sure there is a key present
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))

  # Default with oc_config(show_key = FALSE)
  oc_config()
  expect_equal(getOption("oc_show_key"), FALSE)

  # Set oc_config(show_key = TRUE)
  withr::local_envvar(c("OPENCAGE_KEY" = key_200))
  oc_config(show_key = TRUE)
  expect_equal(getOption("oc_show_key"), TRUE)
})
