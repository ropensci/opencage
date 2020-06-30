#' Deprecated functions in opencage
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Use `oc_forward()` instead of `opencage_forward()`.
#'
#' @param placename Placename
#' @param key Your OpenCage API key as a character vector of length one. By
#'   default, [opencage_key()] will attempt to retrieve the key from the
#'   environment variable `OPENCAGE_KEY`.
#' @param no_record Logical vector of length one (default `FALSE`), when `TRUE`
#'   no log entry of the query is created, and the geocoding request is not
#'   cached by OpenCage.
#' @inheritParams oc_forward
#'
#' @export
#' @keywords internal
#' @name deprecated
opencage_forward <-
  function(placename,
           key = opencage_key(),
           bounds = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 10L,
           min_confidence = NULL,
           no_annotations = FALSE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           add_request = TRUE) {

    lifecycle::deprecate_warn("0.2.0", "opencage_forward()", "oc_forward()")

    if (length(placename) > 1) {
      stop(
        call. = FALSE,
        "`opencage_forward` is not vectorised; use `oc_forward` instead."
      )
    }

    oc_config(key = key, no_record = no_record)

    lst <- oc_forward(
      placename = placename,
      return = "json_list",
      bounds = list(bounds),
      countrycode = countrycode,
      language = language,
      limit = limit,
      min_confidence = min_confidence,
      no_annotations = no_annotations,
      no_dedupe = no_dedupe,
      abbrv = abbrv,
      add_request = add_request
    )
    lst <- lst[[1]]
    opencage_format(lst)
  }

#' @description
#' Use `oc_reverse()` instead of `opencage_reverse()`.
#'
#' @param bounds Bounding box, ignored for reverse geocoding.
#' @param countrycode Country code, ignored for reverse geocoding.
#' @param limit How many results should be returned (1-100), ignored for reverse
#'   geocoding.
#' @inheritParams oc_reverse
#' @inheritParams opencage_forward
#' @inherit opencage_forward return
#'
#' @export
#'
#' @examples
#' \dontrun{
#' opencage_forward(placename = "Sarzeau")
#' opencage_forward(placename = "Islington, London")
#' opencage_forward(placename = "Triererstr 15,
#'                               Weimar 99423,
#'                               Deutschland")
#'
#' opencage_reverse(
#'   latitude = 0, longitude = 0,
#'   limit = 2
#' )
#' }
#'
#' @export
#' @keywords internal
#' @rdname deprecated
opencage_reverse <-
  function(latitude,
           longitude,
           key = opencage_key(),
           bounds = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 10,
           min_confidence = NULL,
           no_annotations = FALSE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           add_request = TRUE) {

    lifecycle::deprecate_warn("0.2.0", "opencage_reverse()", "oc_reverse()")

    if (length(latitude) > 1) {
      stop(
        call. = FALSE,
        "`opencage_reverse` is not vectorised, use `oc_reverse` instead."
      )
    }

    oc_config(key = key, no_record = no_record)

    lst <- oc_reverse(
      latitude = latitude,
      longitude = longitude,
      return = "json_list",
      language = language,
      limit = limit,
      min_confidence = min_confidence,
      no_annotations = no_annotations,
      no_dedupe = no_dedupe,
      abbrv = abbrv,
      add_request = add_request
    )
    lst <- lst[[1]]
    opencage_format(lst)
  }

#' Defunct functions
#'
#' \Sexpr[results=rd, stage=render]{lifecycle::badge("defunct")}
#' Executing these functions will tell you which function replaces them.
#' @description
#' Use `oc_config()` instead of `opencage_key()`.
#'
#' @keywords internal
#' @name defunct
NULL

#' @export
#' @rdname defunct
#' @keywords internal
#' @rdname deprecated
opencage_key <- function(quiet = TRUE) {
  lifecycle::deprecate_warn("0.2.0", "opencage_key()", "oc_config()")

  pat <- Sys.getenv("OPENCAGE_KEY")

  if (identical(pat, "")) {
    return(NULL)
  }

  if (!quiet) {
    message("Using OpenCage API Key from envvar OPENCAGE_KEY")
  }

  return(pat)
#' @description
#' `opencage_format()` is no longer necessary.
#'
#' @export
#' @keywords internal
#' @rdname
opencage_format <- function(lst) {
  lifecycle::deprecate_warn("0.2.0", "opencage_format()")

  no_results <- lst[["total_results"]]
  if (no_results > 0) {
    results <- lapply(lst[["results"]], unlist)
    results <- lapply(results, as.data.frame)
    results <- lapply(results, t)
    results <- lapply(results, as.data.frame, stringsAsFactors = FALSE)
    results <- suppressWarnings(dplyr::bind_rows(results))
    results$"geometry.lat" <- as.numeric(results$"geometry.lat") # nolint snake_case not backward compatible
    results$"geometry.lng" <- as.numeric(results$"geometry.lng") # nolint snake_case not backward compatible

    # if requests exists in the api response add the query to results
    if ("request" %in% names(lst)) {
      results$query <- as.character(lst$request$query)
    }
  }
  else {
    results <- NULL
  }

  if (!is.null(lst$rate)) {
    rate_info <- tibble::as_tibble(data.frame(
      limit = lst$rate$limit,
      remaining = lst$rate$remaining,
      reset = as.POSIXct(lst$rate$reset, origin = "1970-01-01")
    ))
  } else {
    rate_info <- NULL
  }

  if (!is.null(results)) {
    results <- tibble::as_tibble(results)
  }

  list(
    results = results,
    total_results = no_results,
    time_stamp = as.POSIXct(
      lst$timestamp$created_unix,
      origin = "1970-01-01"
    ),
    rate_info = rate_info
  )
}
