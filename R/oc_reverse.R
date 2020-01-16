#' Reverse geocoding
#'
#' Reverse geocoding from numeric vectors of latitude and longitude to
#' placenames.
#'
#' @inheritParams oc_forward
#' @param latitude,longitude Numeric vectors of latitude and longitude values.
#'
#' @return Depending on the \code{return} argument, \code{oc_reverse} returns a
#'   list with either
#'   \itemize{
#'   \item the results as tibbles (\code{"df_list"}, the default),
#'   \item the results as JSON specified as a list (\code{"json_list"}),
#'   \item the results as GeoJSON specified as a list (\code{"geojson_list"}),
#'   or
#'   \item the URL of the OpenCage API call for debugging purposes
#'   (\code{"url_only"}).
#'   }
#'
#'   When the results are returned as (a list of) tibbles, the column names
#'   coming from the OpenCage API are prefixed with \code{"oc_"}.
#'
#' @seealso \code{\link{oc_reverse_df}} for inputs as a data frame, or
#'   \code{\link{oc_forward}} and \code{\link{oc_forward}} for forward
#'   geocoding. For more information about the API and the various parameters,
#'   see the \href{https://opencagedata.com/api}{OpenCage API documentation}.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Reverse geocode a single location
#' oc_reverse(latitude = -36.85007, longitude = 174.7706)
#'
#' # Reverse geocode multiple locations
#' lat <- c(47.21864, 53.55034, 34.05369)
#' lng <- c(-1.554136, 10.000654, -118.242767)
#'
#' oc_reverse(latitude = lat, longitude = lng)
#'
#' # Return results in a preferred language if possible
#' oc_reverse(latitude = lat, longitude = lng,
#'            language = "fr")
#'
#' # Return results as a json list
#' oc_reverse(latitude = lat, longitude = lng,
#'            return = "json_list")
#' }

oc_reverse <-
  function(latitude,
           longitude,
           return = c("df_list", "json_list", "geojson_list", "url_only"),
           language = NULL,
           min_confidence = NULL,
           no_annotations = TRUE,
           roadinfo = FALSE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           add_request = FALSE,
           ...) {

    # check latitude is provided
    if (missing(latitude) || is.null(latitude)) {
      stop(call. = FALSE, "`latitude` and `longitude` must be provided.")
    }
    # check longitude is provided
    if (missing(longitude) || is.null(longitude)) {
      stop(call. = FALSE, "`latitude` and `longitude` must be provided.")
    }

    # check return
    return <- match.arg(return)

    # get & check key
    key <- Sys.getenv("OPENCAGE_KEY")
    oc_check_key(key)

    # check arguments
    oc_check_query(
      latitude = latitude,
      longitude = longitude,
      language = language,
      min_confidence = min_confidence,
      no_annotations = no_annotations,
      roadinfo = roadinfo,
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
      roadinfo = roadinfo,
      no_dedupe = no_dedupe,
      no_record = no_record,
      abbrv = abbrv,
      add_request = add_request
    )
  }

#' Reverse geocoding with data frames
#'
#' Reverse geocoding from latitude and longitude variables to placenames.
#' @inheritParams oc_forward_df
#' @param latitude,longitude Unquoted variable names of numeric vectors of
#'   latitude and longitude values.
#' @param output A character vector of length one indicating whether only
#'   the formatted address (\code{"short"}, the default) should be returned or
#'   all variables (\code{"all"}) variables should be returned.
#'
#' @return A tibble. Column names coming from the OpenCage API are prefixed with
#'   \code{"oc_"}.
#'
#' @seealso \code{\link{oc_reverse}} for inputs as vectors, or
#'   \code{\link{oc_forward}} and \code{\link{oc_forward}} for forward
#'   geocoding. For more information about the API and the various parameters,
#'   see the \href{https://opencagedata.com/api}{OpenCage API documentation}.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(tibble)
#' df <- tibble(id = 1:4,
#'              lat = c(-36.85007, 47.21864, 53.55034, 34.05369),
#'              lng = c(174.7706, -1.554136, 10.000654, -118.242767))
#'
#' # Return formatted address of lat/lng values
#' oc_reverse_df(df, latitude = lat, longitude = lng)
#'
#' # Return more detailed information about the locations
#' oc_reverse_df(df, latitude = lat, longitude = lng,
#'               output = "all")
#'
#' # Return results in a preferred language if possible
#' oc_reverse_df(df, latitude = lat, longitude = lng,
#'               language = "fr")
#'
#' # oc_reverse_df accepts unquoted column names for all
#' # arguments except bind_cols, output, and no_record.
#' # This makes it possible to build up more detailed queries
#' # through the data frame passed to the data argument.
#'
#' df2 <- add_column(df,
#'                   language = c("en", "fr", "de", "en"),
#'                   confidence = c(8, 10, 10, 10))
#'
#' # Use language column to specify preferred language of results
#' # and confidence column to allow different confidence levels
#' oc_reverse_df(df2, latitude = lat, longitude = lng,
#'               language = language,
#'               min_confidence = confidence)
#' }

oc_reverse_df <- function(...) UseMethod("oc_reverse_df")

#' @noRd
#' @export
oc_reverse_df.default <- function(x, ...) {
  stop(
    "Can't geocode an object of class `",
    class(x)[[1]],
    "`.",
    call. = FALSE
  )
}

#' @rdname oc_reverse_df
#' @export
oc_reverse_df.data.frame <- # nolint - see lintr issue #223
  function(data,
           latitude,
           longitude,
           bind_cols = TRUE,
           output = c("short", "all"),
           language = NULL,
           min_confidence = NULL,
           roadinfo = FALSE,
           no_annotations = TRUE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           ...) {

    # check latitude & longitude is provided
    if (missing(latitude) || missing(longitude)) {
      stop(call. = FALSE, "`latitude` and `longitude` must be provided.")
    }

    # Tidyeval to enable input from data frame columns
    latitude <- rlang::enquo(latitude)
    longitude <- rlang::enquo(longitude)
    language <- rlang::enquo(language)
    min_confidence <- rlang::enquo(min_confidence)
    no_annotations <- rlang::enquo(no_annotations)
    roadinfo <- rlang::enquo(roadinfo)
    no_dedupe <- rlang::enquo(no_dedupe)
    abbrv <- rlang::enquo(abbrv)

    output <- rlang::arg_match(output)

    # Ensure that query column always exists
    add_request <- TRUE

    if (any(rlang::eval_tidy(no_annotations, data = data) == FALSE) ||
        any(rlang::eval_tidy(roadinfo, data = data) == TRUE)) {
      output <- "all"
    }

    if (bind_cols == FALSE) {
      results_list <- oc_reverse(
        latitude = rlang::eval_tidy(latitude, data = data),
        longitude = rlang::eval_tidy(longitude, data = data),
        return = "df_list",
        language = rlang::eval_tidy(language, data = data),
        min_confidence = rlang::eval_tidy(min_confidence, data = data),
        no_annotations = rlang::eval_tidy(no_annotations, data = data),
        roadinfo = rlang::eval_tidy(roadinfo, data = data),
        no_dedupe = rlang::eval_tidy(no_dedupe, data = data),
        no_record = no_record,
        abbrv = rlang::eval_tidy(abbrv, data = data),
        add_request = add_request
      )
      results <- dplyr::bind_rows(results_list)
      if (output == "short") {
        results <-
          dplyr::select(results, .data$oc_query, .data$oc_formatted)
      } else {
        results <-
          dplyr::select(results, .data$oc_query, dplyr::everything())
      }
    } else {
      results_nest <-
        dplyr::mutate(
          data,
          op =
            oc_reverse(
              latitude = !!latitude,
              longitude = !!longitude,
              return = "df_list",
              language = !!language,
              min_confidence = !!min_confidence,
              no_annotations = !!no_annotations,
              roadinfo = !!roadinfo,
              no_dedupe = !!no_dedupe,
              no_record = no_record,
              abbrv = !!abbrv,
              add_request = add_request
            )
        )

      if (utils::packageVersion("tidyr") > "0.8.99") {
        results <-
          tidyr::unnest(results_nest, .data$op, names_repair = "unique")
      } else {
        results <- tidyr::unnest(results_nest, .data$op, .drop = FALSE)
        # .drop = FALSE so other list columns are not dropped. Deprecated as of
        # v1.0.0
      }

      if (output == "short") {
        results <-
          dplyr::select(
            results,
            1:.data$oc_query,
            .data$oc_formatted,
            -.data$oc_query
          )
      } else {
        results <-
          dplyr::select(
            results,
            1:.data$oc_query,
            dplyr::everything(),
            -.data$oc_query
          )
      }
    }
    results
  }

#' @rdname oc_reverse_df
#' @export
oc_reverse_df.numeric <-
  function(latitude,
           longitude,
           output = c("short", "all"),
           language = NULL,
           min_confidence = NULL,
           no_annotations = TRUE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           ...) {
    xdf <- tibble::tibble(latitude = latitude, longitude = longitude)
    oc_reverse_df(
      data = xdf,
      latitude = latitude,
      longitude = longitude,
      bind_cols = TRUE,
      output = output,
      language = language,
      min_confidence = min_confidence,
      no_annotations = no_annotations,
      no_dedupe = no_dedupe,
      no_record = no_record,
      abbrv = abbrv
    )
  }
