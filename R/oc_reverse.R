#' Reverse geocoding
#'
#' Reverse geocoding, from latitude and longitude to placename(s).
#'
#' @param latitude A numeric vector with the latitude. Required.
#' @param longitude A numeric vector with the longitude. Required.
#' @inheritParams oc_forward
#'
#' @return \code{oc_reverse} returns, depending on the \code{return} parameter,
#'   a list with either
#'   \itemize{
#'   \item the results as tibbles (\code{"df_list"}, the default),
#'   \item the results as JSON lists (\code{"json_list"}),
#'   \item the results as GeoJSON lists (\code{"geojson_list"}), or
#'   \item the URL of the OpenCage API call for debugging purposes
#'   (\code{"url_only"}).
#'   }
#'   \code{oc_reverse_df} returns a tibble.
#'
#' @seealso \code{\link{oc_forward}} for reverse geocoding, and the
#'   \href{https://opencagedata.com/api}{OpenCage API documentation} for more
#'   information about the API.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' oc_reverse(latitude = 0, longitude = 0)
#' }

oc_reverse <-
  function(latitude,
           longitude,
           return = c("df_list", "json_list", "geojson_list", "url_only"),
           key = oc_key(),
           language = NULL,
           min_confidence = NULL,
           no_annotations = TRUE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           add_request = FALSE,
           ...) {

    # check latitude is provided
    if (missing(latitude) || is.null(latitude)) {
      stop(call. = FALSE, "You must provide `latitude` and `longitude`.")
    }
    # check longitude is provided
    if (missing(longitude) || is.null(longitude)) {
      stop(call. = FALSE, "You must provide `latitude` and `longitude`.")
    }

    # check return
    return <- match.arg(return)

    # check arguments
    oc_check_query(
      latitude = latitude,
      longitude = longitude,
      key = key,
      language = language,
      min_confidence = min_confidence,
      no_annotations = no_annotations,
      no_dedupe = no_dedupe,
      no_record = no_record,
      abbrv = abbrv,
      add_request = add_request
    )
    # process request
    oc_process(
      latitude = latitude,
      longitude = longitude,
      return = return,
      key = key,
      language = language,
      min_confidence = min_confidence,
      no_annotations = no_annotations,
      no_dedupe = no_dedupe,
      no_record = no_record,
      abbrv = abbrv,
      add_request = add_request
    )
  }

#' @rdname oc_reverse
#' @param data A data frame.
#' @param bind_cols logical Bind source and results data frame?
#' @param output A character vector of length one indicating whether only the
#'   formatted address (\code{short}) or whether all results (\code{all}) should
#'   be returned.
#'
#' @details
#' \code{oc_reverse_df} also accepts unquoted column names for all arguments
#' except \code{key}, \code{return}, and \code{no_record}.
#'
#' @export
oc_reverse_df <-
  function(data,
           latitude,
           longitude,
           bind_cols = TRUE,
           output = c("short", "all"),
           key = oc_key(),
           language = NULL,
           min_confidence = NULL,
           no_annotations = TRUE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           ...) {
    latitude <- data[[substitute(latitude)]]
    longitude <- data[[substitute(longitude)]]

    language <- eval(substitute(alist(language)))[[1]]
    if (is.symbol(language)) {
      language <- data[[deparse(language)]]
    } else if (is.call(language)) {
      language <- eval(language)
    }
    if (!is.null(language)) language <- as.list(language)

    min_confidence <- eval(substitute(alist(min_confidence)))[[1]]
    if (is.symbol(min_confidence)) {
      min_confidence <- data[[deparse(min_confidence)]]
    } else if (is.call(min_confidence)) {
      min_confidence <- eval(min_confidence)
    }
    if (!is.null(min_confidence)) min_confidence <- as.list(min_confidence)

    no_annotations <- eval(substitute(alist(no_annotations)))[[1]]
    if (is.symbol(no_annotations)) {
      no_annotations <- data[[deparse(no_annotations)]]
    } else if (is.call(no_annotations)) {
      no_annotations <- eval(no_annotations)
    }
    if (!is.null(no_annotations)) no_annotations <- as.list(no_annotations)

    no_dedupe <- eval(substitute(alist(no_dedupe)))[[1]]
    if (is.symbol(no_dedupe)) {
      no_dedupe <- data[[deparse(no_dedupe)]]
    } else if (is.call(no_dedupe)) {
      no_dedupe <- eval(no_dedupe)
    }
    if (!is.null(no_dedupe)) no_dedupe <- as.list(no_dedupe)

    abbrev <- eval(substitute(alist(abbrev)))[[1]]
    if (is.symbol(abbrev)) {
      abbrev <- data[[deparse(abbrev)]]
    } else if (is.call(abbrev)) {
      abbrev <- eval(abbrev)
    }
    if (!is.null(abbrev)) abbrev <- as.list(abbrev)

    output <- match.arg(output)

    # Ensure that query column always exists
    add_request <- TRUE
    if (output == "short") {
      no_annotations <- TRUE
    }

    if (bind_cols == FALSE) {
      results_list <- oc_reverse(
        latitude = latitude,
        longitude = longitude,
        key = key,
        return = "df_list",
        language = language,
        min_confidence = min_confidence,
        no_annotations = no_annotations,
        no_dedupe = no_dedupe,
        no_record = no_record,
        abbrv = abbrv,
        add_request = add_request
      )
      results <- dplyr::bind_rows(results_list)
      if (output == "short") {
        results <-
          dplyr::select(results, query, formatted)
      } else {
        results <-
          dplyr::select(results, query, dplyr::everything())
      }
    } else {
      results_nest <-
        dplyr::mutate(
          data,
          op =
            oc_reverse(
              latitude = latitude,
              longitude = longitude,
              key = key,
              return = "df_list",
              language = language,
              min_confidence = min_confidence,
              no_annotations = no_annotations,
              no_dedupe = no_dedupe,
              no_record = no_record,
              abbrv = abbrv,
              add_request = add_request
            )
        )
    }

    results <- tidyr::unnest(results_nest, op) # nolint
    # `op` is necessary, so that other list columns are not unnested
    # but lintr complains about `op` not being defined

    if (output == "short") {
      results <-
        dplyr::select(results, 1:query, formatted, -query)
    } else {
      results <-
        dplyr::select(results, 1:query, dplyr::everything(), -query)
    }
    results
  }
