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
  crul::ok(url, useragent = "https://github.com/ropensci/opencage")
}
