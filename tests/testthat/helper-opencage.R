# skip if API key missing or OpenCage is offline --------------------------

skip_if_no_key <- function() {
  testthat::skip_if(
    condition = is.null(oc_key()),
    message = "No OpenCage API key available; skipping test."
  )
}

# configure vcr -----------------------------------------------------------

library("vcr")
invisible(
  vcr::vcr_configure(
    dir = "../vcr_cassettes",
    match_requests_on = "uri", # method not necessary, we only make GET requests
    filter_sensitive_data =
      list("<<<oc_api_key>>>" = Sys.getenv("OPENCAGE_KEY"))
  )
)
