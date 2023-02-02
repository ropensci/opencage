#' Is the OpenCage API available?
#'
#' Checks whether the OpenCage API can be reached.
#'
#' @param url The URL of the OpenCage API, <https://api.opencagedata.com>.
#'
#' @return A single logical value, `TRUE` or `FALSE`.
#'
#' @export
#' @keywords internal

oc_api_ok <- function(url = "https://api.opencagedata.com") {
  resp <- httr2::request("https://api.opencagedata.com") %>%
    httr2::req_method("HEAD") %>%
    httr2::req_user_agent("https://github.com/ropensci/opencage") %>%
    httr2::req_perform()

  !httr2::resp_is_error(resp)
}
