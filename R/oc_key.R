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
      call. = FALSE
    )
  } else if (!is.character(key)) {
    stop("The OpenCage API `key` must be a character vector.", call. = FALSE)
  } else if (length(key) > 1) {
    stop(
      "The OpenCage API `key` must be a vector of length one.",
      call. = FALSE
    )
  } else if (!identical(nchar(key), 32L)) {
    stop(
      "The OpenCage API key must be a 32 character long, alphanumeric string.\n", # nolint: line_length_linter.
      "See <https://opencagedata.com/api#forward>",
      call. = FALSE
    )
  }
}

#' Mask OpenCage API key
#'
#' Function that masks the OpenCage API key. It looks up the environment
#' variable `OPENCAGE_KEY` and replaces the key in a string with by replacing it
#' with "OPENCAGE_KEY".
#'
#' @param string Character string, which may contain an OpenCage API key
#'
#' @noRd

oc_mask_key <- function(string) {
  if (oc_key_present()) {
    gsub(
      x = string,
      pattern = Sys.getenv("OPENCAGE_KEY"),
      replacement = "OPENCAGE_KEY"
    )
  } else {
    return(string)
  }
}

#' Is an OpenCage API key present?
#'
#' Checks whether a potential OpenCage API key, i.e. a 32 character long,
#' alphanumeric string, is stored in the environment variable `OPENCAGE_KEY`.
#'
#' @return A single logical value, `TRUE` or `FALSE`.
#'
#' @export
#' @keywords internal

oc_key_present <- function() {
  identical(nchar(Sys.getenv("OPENCAGE_KEY")), 32L)
}
