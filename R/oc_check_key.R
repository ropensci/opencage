#' Check OpenCage API key
#'
#' This page documents tools for working with your OpenCage API keys. Use `oc_config()` to register your OpenCage API key.
#'
#' @param key OpenCage API key
#' @param string a url string to be scrubbed, the following values will be scrubbed from the url and replace with the `with` argument; key, client, signature
#' @param with a string to replace
#'
#' @details
#'
#' Use `oc_config()` to register your OpenCage API key. Your key will always be scrubbed in output, the only way to see your actual key is to run `oc_show_key()`
#'
#' @export
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
