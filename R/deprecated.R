#' Deprecated functions in opencage
#'
#' These functions still work but will be removed (defunct) in the next version.
#'
#' \itemize{
#'  \item [opencage_forward()]
#'  \item [opencage_reverse()]
#'  \item [opencage_key()]
#' }
#'
#' @name opencage-deprecated
NULL

#' Forward geocoding
#'
#' @description
#'
#' `r lifecycle::badge("deprecated")`
#'
#' Deprecated: use `oc_forward` or `oc_forward_df` for forward geocoding.
#'
#' @param key Your OpenCage API key as a character vector of length one. By
#'   default, [opencage_key()] will attempt to retrieve the key from the
#'   environment variable `OPENCAGE_KEY`.
#' @param no_record Logical vector of length one (default `FALSE`), when `TRUE`
#'   no log entry of the query is created, and the geocoding request is not
#'   cached by OpenCage.
#' @inheritParams oc_forward
#'
#' @return A list with
#' \itemize{
#' \item results as a tibble with one line per result,
#' \item the number of results as an integer,
#' \item the timestamp as a POSIXct object,
#' \item rate_info tibble/data.frame with the maximal number of API calls  per
#' day for the used key, the number of remaining calls for the day and the time
#' at which the number of remaining calls will be reset.
#' }
#'
#' @export
#'
#' @examplesIf oc_key_present() && oc_api_ok()
#' opencage_forward(placename = "Sarzeau")
#' opencage_forward(placename = "Islington, London")
#' opencage_forward(placename = "Triererstr 15,
#'                               Weimar 99423,
#'                               Deutschland")
#'
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
    if (length(placename) > 1) {
      stop(
        call. = FALSE,
        "`opencage_forward` is not vectorised; use `oc_forward` instead."
      )
    }

    lifecycle::deprecate_warn("0.2.0", "opencage_forward()", "oc_forward()")

    # set key and no_record option locally,
    # i.e. go back to default after function is finished
    withr::local_envvar(list("OPENCAGE_KEY" = key))
    withr::local_options(list(oc_no_record = no_record))

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


#' Reverse geocoding
#'
#' @description
#'
#' `r lifecycle::badge("deprecated")`
#'
#' Deprecated: use `oc_reverse` or `oc_reverse_df` for reverse geocoding.
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
#' @examplesIf oc_key_present() && oc_api_ok()
#'
#' opencage_reverse(
#'   latitude = 0, longitude = 0,
#'   limit = 2
#' )
#'
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
    if (length(latitude) > 1) {
      stop(
        call. = FALSE,
        "`opencage_reverse` is not vectorised, use `oc_reverse` instead."
      )
    }

    lifecycle::deprecate_warn("0.2.0", "opencage_reverse()", "oc_reverse()")

    # set key and no_record option locally,
    # i.e. go back to default after function is finished
    withr::local_envvar(list("OPENCAGE_KEY" = key))
    withr::local_options(list(oc_no_record = no_record))

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

# format to "old" style (version <= 0.1.4)
# for opencage_forward, opencage_reverse
opencage_format <- function(lst) {
  no_results <- lst[["total_results"]]
  if (no_results > 0) {
    results <- lapply(lst[["results"]], unlist)
    results <- lapply(results, as.data.frame)
    results <- lapply(results, t)
    results <- lapply(results, as.data.frame, stringsAsFactors = FALSE)
    results <- suppressWarnings(dplyr::bind_rows(results))
    results$"geometry.lat" <- as.numeric(results$"geometry.lat")
    results$"geometry.lng" <- as.numeric(results$"geometry.lng")

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

#' Retrieve Opencage API key
#'
#' @description
#'
#' `r lifecycle::badge("deprecated")`
#'
#' Deprecated and will be removed from the package together with
#' `opencage_forward()` and `opencage_reverse()`.
#'
#' Retrieves the OpenCage API Key from the environment variable `OPENCAGE_KEY`.
#'
#' @param quiet Logical vector of length one indicating whether the key is
#'   returned quietly or whether a message is printed.
#' @keywords internal
#' @export
opencage_key <- function(quiet = TRUE) {
  lifecycle::deprecate_warn("0.2.0", "opencage_key()")

  pat <- Sys.getenv("OPENCAGE_KEY")

  if (identical(pat, "")) {
    return(NULL)
  }

  if (!quiet) {
    message("Using OpenCage API Key from envvar OPENCAGE_KEY")
  }

  invisible(pat)
}
