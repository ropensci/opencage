# test-keys ----------------------------------------------------------------
# keys from https://opencagedata.com/api#codes or
# https://github.com/OpenCageData/opencagedata-misc-docs/blob/master/library-guidelines.md # nolint
key_200 <- "6d0e711d72d74daeb2b0bfd2a5cdfdba" # always returns a 200 response
key_402 <- "4372eff77b8343cebfc843eb4da4ddc4" # always returns a 402 responce
key_403 <- "2e10e5e828262eb243ec0b54681d699a" # always returns a 403 responce
key_429 <- "d6d0f0065f4348a4bdfe4587ba02714b" # always returns a 429 responce
key_401 <- "32charactersandnumbers1234567890" # invalid key returns 401 response


# clear cache before running tests ----------------------------------------
oc_clear_cache()

# setup vcr ----------------------------------------------------------------
library("vcr") # *Required* as vcr is set up on loading

# where are cassettes stored (and what does "fixtures" even mean)?
vcr_dir <- vcr::vcr_test_path("vcr_cassettes")

# check for key and configure rate limit
if (dir.exists(vcr_dir)) {

  if (!nzchar(Sys.getenv("OPENCAGE_KEY"))) {
    # Set fake API key, so key checks do not throw an error
    Sys.setenv("OPENCAGE_KEY" = "fakekey01fakekey10fakekey01fake0")
  }

  # reduce rate-limit for faster tests when using vcr
  # set rate-limit via option, so default stays the same after oc_config tests
  options(oc_rate_sec = 15L)
  oc_config() # set rate limit from option per default

}

# configure vcr
invisible(
  vcr::vcr_configure(
    dir = vcr_dir,
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
vcr::check_cassette_names(
  allowed_duplicates =
    c(
      "oc_forward_type_df_list",
      "oc_forward_df_bounds",
      "oc_forward_df_works",
      "oc_reverse_df_lat_lon"
    )
)
