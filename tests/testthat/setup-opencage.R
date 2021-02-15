# keys from https://opencagedata.com/api#codes or
# https://github.com/OpenCageData/opencagedata-misc-docs/blob/master/library-guidelines.md # nolint
key_200 <- "6d0e711d72d74daeb2b0bfd2a5cdfdba" # always returns a 200 response
key_402 <- "4372eff77b8343cebfc843eb4da4ddc4" # always returns a 402 responce
key_403 <- "2e10e5e828262eb243ec0b54681d699a" # always returns a 403 responce
key_429 <- "d6d0f0065f4348a4bdfe4587ba02714b" # always returns a 429 responce
key_401 <- "32charactersandnumbers1234567890" # invalid key returns 401 response

# setup vcr ----------------------------------------------------------------
library("vcr") # *Required* as vcr is set up on loading
invisible(
  vcr::vcr_configure(
    dir = vcr::vcr_test_path("vcr_cassettes"),
    match_requests_on = "uri", # method not necessary, we only make GET requests
    filter_sensitive_data =
      list(
        "<<<oc_api_key>>>" = Sys.getenv("OPENCAGE_KEY"),
        "<<<oc_200_key>>>" = key_200,
        "<<<oc_401_key>>>" = key_401,
        "<<<oc_402_key>>>" = key_402,
        "<<<oc_403_key>>>" = key_403,
        "<<<oc_429_key>>>" = key_429
      )
  )
)
vcr::check_cassette_names()

# skip if OpenCage API offline --------------------------------------------
skip_if_oc_offline <- function(host = "api.opencagedata.com") {
  testthat::skip_if_offline(host = host)
}

# skip if API key is missing ----------------------------------------------
skip_if_no_key <- function() {
  testthat::skip_if_not(
    condition = oc_key_present(),
    # re message see https://github.com/r-lib/testthat/issues/1247
    message = "OpenCage API key is missing"
  )
}
