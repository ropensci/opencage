#' Check OpenCage API key
#'
#' Function that checks the OpenCage API key
#'
#' @param key OpenCage API key
#'
#' @noRd

oc_check_key <- function(key) {
  if (is.null(key) || identical(key, "")) {
    stop(
      "An OpenCage API `key` must be provided.\n",
      "See help(oc_config)",
      call. = FALSE)
  } else if (!is.character(key)) {
    stop("The OpenCage API `key` must be a character vector.", call. = FALSE)
  } else if (length(key) > 1) {
    stop(
      "The OpenCage API `key` must be a vector of length one.",
      call. = FALSE
    )
  } else if (!identical(nchar(key), 32L)) {
    stop(
      "The OpenCage API key must be a 32 character long, alphanumeric string.\n", # nolint
      "See <https://opencagedata.com/api#forward>",
      call. = FALSE
    )
  }
}
