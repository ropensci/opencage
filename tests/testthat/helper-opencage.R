library("vcr")
invisible(
  vcr::vcr_configure(
    dir = "../vcr_cassettes",
    filter_sensitive_data = list("<<<oc_api_key>>>" = Sys.getenv('OPENCAGE_KEY'))
  )
)
