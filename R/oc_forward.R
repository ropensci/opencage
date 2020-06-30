#' Forward geocoding
#'
#' Forward geocoding from a character vector of placenames to latitude and
#' longitude tuple(s).
#'
# nolint start - link longer than 80 chars
#' @param placename A character vector with the placename(s) to be geocoded. If
#'   the placenames are addresses, see [OpenCage's
#'   instructions](https://github.com/OpenCageData/opencagedata-misc-docs/blob/master/query-formatting.md)
#'    on how to format addresses for best forward geocoding results.
# nolint end
#' @param return A character vector of length one indicating the return value of
#'   the function, either a tibble with nested columns (`tibble`, the default), a JSON
#'   list (`json_list`), a GeoJSON list (`geojson_list`), or the URL with which
#'   the API would be called (`url_only`).
#' @param bounds A list of bounding boxes of length one or `length(placename)`.
#'   Bounding boxes are named numeric vectors, each with four coordinates
#'   forming the south-west and north-east corners of the bounding box:
#'   `list(c(xmin, ymin, xmax, ymax))`. `bounds` restricts the possible results
#'   to the supplied region. It can be specified with the [oc_bbox()] helper.
#'   For example: `bounds = oc_bbox(-0.563160, 51.280430, 0.278970, 51.683979)`.
#'   Default is `NULL`.
#' @param proximity A list of points of length one or `length(placename)`. A
#'   point is a named numeric vector of a latitude, longitude coordinate pair in
#'   decimal format. `proximity` provides OpenCage with a hint to bias results
#'   in favour of those closer to the specified location. It can be specified
#'   with the [oc_points()] helper. For example: `proximity = oc_points(51.9526,
#'   7.6324)`. Default is `NULL`.
#' @param countrycode A two letter code as defined by the [ISO 3166-1 Alpha
#'   2](https://www.iso.org/obp/ui/#search/code) standard that restricts the
#'   results to the given country or countries. E.g. "AR" for Argentina, "FR"
#'   for France, "NZ" for the New Zealand. Multiple countrycodes per `placename`
#'   must be wrapped in a list. Default is `NULL`.
#' @param language An [IETF BCP 47 language
#'   tag](https://en.wikipedia.org/wiki/IETF_language_tag) (such as "es" for
#'   Spanish or "pt-BR" for Brazilian Portuguese). OpenCage will attempt to
#'   return results in that language. Alternatively you can specify the "native"
#'   tag, in which case OpenCage will attempt to return the response in the
#'   "official" language(s). In case the `language` parameter is set to `NULL`
#'   (which is the default), the tag is not recognized, or OpenCage does not
#'   have a record in that language, the results will be returned in English.
#' @param limit Numeric vector of integer values to determine the maximum number
#'   of results returned for each `placename`. Integer values between 1 and 100
#'   are allowed. Default is 10.
#' @param min_confidence Numeric vector of integer values between 0 and 10
#'   indicating the precision of the returned result as defined by its
#'   geographical extent, (i.e. by the extent of the result's bounding box). See
#'   the [API documentation](https://opencagedata.com/api#confidence) for
#'   details. Only results with at least the requested confidence will be
#'   returned. Default is `NULL`.
#' @param no_annotations Logical vector indicating whether additional
#'   information about the result location should be returned. `TRUE` by
#'   default, which means that the results will not contain annotations.
#' @param roadinfo Logical vector indicating whether the geocoder should attempt
#'   to match the nearest road (rather than an address) and provide additional
#'   road and driving information. Default is `FALSE`.
#' @param no_dedupe Logical vector (default `FALSE`), when `TRUE` the results
#'   will not be deduplicated.
#' @param abbrv Logical vector (default `FALSE`), when `TRUE` addresses in the
#'   `formatted` field of the results are abbreviated (e.g. "Main St." instead
#'   of "Main Street").
#' @param ... Ignored.
#'
#' @return Depending on the `return` argument, `oc_forward` returns a list with
#'   either
#'   \itemize{
#'   \item the results a tibble (`"tibble"`, the default),
#'   \item the results as JSON specified as a list (`"json_list"`),
#'   \item the results as GeoJSON specified as a list (`"geojson_list"`),
#'   or
#'   \item the URL of the OpenCage API call for debugging purposes
#'   (`"url_only"`).
#'   }
#'
#'   When the results are returned as (a list of) tibbles, the column names
#'   coming from the OpenCage API are prefixed with `"oc_"`.
#'
#' @seealso [oc_forward_df()] for inputs as a data frame, or [oc_reverse()] and
#'   [oc_reverse_df()] for reverse geocoding. For more information about the API
#'   and the various parameters, see the [OpenCage API
#'   documentation](https://opencagedata.com/api).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Geocode a single location, an address in this case
#' oc_forward(placename = "Triererstr 15, 99432, Weimar, Deutschland")
#'
#' # Geocode multiple locations
#' locations <- c("Nantes", "Hamburg", "Los Angeles")
#' oc_forward(placename = locations)
#'
#' # Use bounding box to help return accurate results
#' # for each placename
#' bounds <- oc_bbox(xmin = c(-2, 9, -119),
#'                   ymin = c(47, 53, 34),
#'                   xmax = c(0, 10, -117),
#'                   ymax = c(48, 54, 35))
#' oc_forward(placename = locations, bounds = bounds)
#'
#' # Another way to help specify the desired results
#' # is with country codes.
#' oc_forward(placename = locations,
#'            countrycode = c("ca", "us", "co"))
#'
#' # With multiple countrycodes per placename
#' oc_forward(placename = locations,
#'            countrycode = list(c("fr", "ca") , c("de", "us"), c("us", "co"))
#'            )
#'
#' # Return results in a preferred language if possible
#' oc_forward(placename = c("Brugge", "Mechelen", "Antwerp"),
#'            language = "fr")
#'
#' # Limit the number of results per placename and return json_list
#' oc_forward(placename = locations,
#'            bounds = bounds,
#'            limit = 1,
#'            return = "json_list")
#' }
#'
oc_forward <-
  function(placename,
           return = c("tibble", "json_list", "geojson_list", "url_only"),
           bounds = NULL,
           proximity = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 10L,
           min_confidence = NULL,
           no_annotations = TRUE,
           roadinfo = FALSE,
           no_dedupe = FALSE,
           abbrv = FALSE,
           ...) {

    # check a placename is provided
    if (missing(placename) || is.null(placename)) {
      stop(call. = FALSE, "`placename` must be provided.")
    }

    # check return
    return <- match.arg(return)

    # check arguments
    oc_check_query(
      placename = placename,
      bounds = bounds,
      proximity = proximity,
      countrycode = countrycode,
      language = language,
      limit = limit,
      min_confidence = min_confidence,
      no_annotations = no_annotations,
      roadinfo = roadinfo,
      no_dedupe = no_dedupe,
      abbrv = abbrv
    )
    # process request
    oc_process(
      placename = placename,
      return = return,
      bounds = bounds,
      proximity = proximity,
      countrycode = countrycode,
      language = language,
      limit = limit,
      min_confidence = min_confidence,
      no_annotations = no_annotations,
      roadinfo = roadinfo,
      no_dedupe = no_dedupe,
      abbrv = abbrv
    )
  }


#' Forward geocoding with data frames
#'
#' Forward geocoding from a placename variable to latitude and longitude
#' tuple(s).
#'
#' @param data A data frame.
# nolint start - link longer than 80 chars
#' @param placename An unquoted variable name of a character vector with the
#'   placenames to be geocoded.
#'
#'   If the placenames are addresses, see [OpenCage's
#'   instructions](https://github.com/OpenCageData/opencagedata-misc-docs/blob/master/query-formatting.md)
#'   on how to format addresses for best forward geocoding results.
# nolint end
#' @param bind_cols When `bind_col = TRUE`, the default, the results are column
#'   bound to `data`. When `FALSE`, the results are returned as a new tibble.
#' @param output A character vector of length one indicating whether only
#'   latitude, longitude, and formatted address variables (`"short"`, the
#'   default), or all variables (`"all"`) variables should be returned.
#' @param bounds A list of length one, or an unquoted variable name of a list
#'   column of bounding boxes. Bounding boxes are named numeric vectors, each
#'   with 4 coordinates forming the south-west and north-east corners of the
#'   bounding box: `list(c(xmin, ymin, xmax, ymax))`. `bounds` restricts the
#'   possible results to the supplied region. It can be specified with the
#'   [oc_bbox()] helper. For example: `bounds = oc_bbox(-0.563160, 51.280430,
#'   0.278970, 51.683979)`. Default is `NULL`.
#' @param proximity A list of length one, or an unquoted variable name of a list
#'   column of points. Points are named numeric vectors with latitude, longitude
#'   coordinate pairs in decimal format. `proximity` provides OpenCage with a
#'   hint to bias results in favour of those closer to the specified location.
#'   It can be specified with the [oc_points()] helper. For example: `proximity
#'   = oc_points(41.40139, 2.12870)`. Default is `NULL`.
#' @param countrycode Character vector, or an unquoted variable name of such a
#'   vector, of two-letter codes as defined by the [ISO 3166-1 Alpha
#'   2](https://www.iso.org/obp/ui/#search/code) standard that restricts the
#'   results to the given country or countries. E.g. "AR" for Argentina, "FR"
#'   for France, "NZ" for the New Zealand. Multiple countrycodes per `placename`
#'   must be wrapped in a list. Default is `NULL`.
#' @param language Character vector, or an unquoted variable name of such a
#'   vector, of [IETF BCP 47 language
#'   tags](https://en.wikipedia.org/wiki/IETF_language_tag) (such as "es" for
#'   Spanish or "pt-BR" for Brazilian Portuguese). OpenCage will attempt to
#'   return results in that language. Alternatively you can specify the "native"
#'   tag, in which case OpenCage will attempt to return the response in the
#'   "official" language(s). In case the `language` parameter is set to `NULL`
#'   (which is the default), the tag is not recognized, or OpenCage does not
#'   have a record in that language, the results will be returned in English.
#' @param limit Numeric vector of integer values, or an unquoted variable name
#'   of such a vector, to determine the maximum number of results returned for
#'   each `placename`. Integer values between 1 and 100 are allowed. Default is
#'   1.
#' @param min_confidence Numeric vector of integer values, or an unquoted
#'   variable name of such a vector, between 0 and 10 indicating the precision
#'   of the returned result as defined by its geographical extent, (i.e. by the
#'   extent of the result's bounding box). See the [API
#'   documentation](https://opencagedata.com/api#confidence) for details. Only
#'   results with at least the requested confidence will be returned. Default is
#'   `NULL`).
#' @param no_annotations Logical vector, or an unquoted variable name of such a
#'   vector, indicating whether additional information about the result location
#'   should be returned. `TRUE` by default, which means that the results will
#'   not contain annotations.
#' @param roadinfo Logical vector, or an unquoted variable name of such a
#'   vector, indicating whether the geocoder should attempt to match the nearest
#'   road (rather than an address) and provide additional road and driving
#'   information. Default is `FALSE`.
#' @param no_dedupe Logical vector, or an unquoted variable name of such a
#'   vector. Default is `FALSE`. When `TRUE` the results will not be
#'   deduplicated.
#' @param abbrv Logical vector, or an unquoted variable name of such a vector.
#'   Default is `FALSE`. When `TRUE` addresses in the `oc_formatted` variable of
#'   the results are abbreviated (e.g. "Main St." instead of "Main Street").
#' @param ... Ignored.
#'
#' @return A tibble. Column names coming from the OpenCage API are prefixed with
#'   `"oc_"`.
#'
#' @seealso [oc_forward()] for inputs as vectors, or [oc_reverse()] and
#'   [oc_reverse_df()] for reverse geocoding. For more information about the API
#'   and the various parameters, see the [OpenCage API
#'   documentation](https://opencagedata.com/api).
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#' library(tibble)
#' df <- tibble(id = 1:3,
#'              locations = c("Nantes", "Hamburg", "Los Angeles"))
#'
#' # Return lat, lng, and formatted address
#' oc_forward_df(df, placename = locations)
#'
#' # Return more detailed information about the locations
#' oc_forward_df(df, placename = locations, output = "all")
#'
#' # Do not column bind results to input data frame
#' oc_forward_df(df, placename = locations, bind_cols = FALSE)
#'
#' # Add more results by changing the limit from the default of 1.
#' oc_forward_df(df, placename = locations, limit = 5)
#'
#' # Restrict results to a given bounding box
#' oc_forward_df(df, placename = locations,
#'               bounds = oc_bbox(-5, 45, 15, 55))
#'
#' # oc_forward_df accepts unquoted column names for all
#' # arguments except bind_cols and output.
#' # This makes it possible to build up more detailed queries
#' # through the data frame passed to the data argument.
#'
#' df2 <- add_column(df,
#'   bounds = oc_bbox(xmin = c(-2, 9, -119),
#'                    ymin = c(47, 53, 34),
#'                    xmax = c(0, 10, -117),
#'                    ymax = c(48, 54, 35)),
#'   limit = 1:3,
#'   countrycode = c("ca", "us", "co"),
#'   language = c("fr", "de", "en"))
#'
#' # Use the bounds column to help return accurate results and
#' # language column to specify preferred language of results
#' oc_forward_df(df2, placename = locations,
#'               bounds = bounds,
#'               language = language)
#'
#' # Different limit of results for each placename
#' oc_forward_df(df2, placename = locations,
#'               limit = limit)
#'
#' # Specify the desired results by the countrycode column
#' oc_forward_df(df2, placename = locations,
#'               countrycode = countrycode)
#' }
oc_forward_df <- function(...) UseMethod("oc_forward_df")

#' @noRd
#' @export
oc_forward_df.default <- function(x, ...) {
  stop(
    "Can't geocode an object of class `",
    class(x)[[1]],
    "`.",
    call. = FALSE
  )
}

#' @rdname oc_forward_df
#' @export
oc_forward_df.data.frame <- # nolint - see lintr issue #223
  function(data,
           placename,
           bind_cols = TRUE,
           output = c("short", "all"),
           bounds = NULL,
           proximity = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 1L,
           min_confidence = NULL,
           no_annotations = TRUE,
           roadinfo = FALSE,
           no_dedupe = FALSE,
           abbrv = FALSE,
           ...) {

    # check a placename is provided
    if (missing(placename)) {
      stop(call. = FALSE, "`placename` must be provided.")
    }

    # Tidyeval to enable input from data frame columns
    placename <- rlang::enquo(placename)
    bounds <- rlang::enquo(bounds)
    proximity <- rlang::enquo(proximity)
    countrycode <- rlang::enquo(countrycode)
    language <- rlang::enquo(language)
    limit <- rlang::enquo(limit)
    min_confidence <- rlang::enquo(min_confidence)
    no_annotations <- rlang::enquo(no_annotations)
    roadinfo <- rlang::enquo(roadinfo)
    no_dedupe <- rlang::enquo(no_dedupe)
    abbrv <- rlang::enquo(abbrv)

    output <- rlang::arg_match(output)

    if (any(rlang::eval_tidy(no_annotations, data = data) == FALSE) ||
        any(rlang::eval_tidy(roadinfo, data = data) == TRUE)) {
      output <- "all"
    }

    if (bind_cols == FALSE) {
      results <- oc_forward(
        placename = rlang::eval_tidy(placename, data = data),
        return = "tibble",
        bounds = rlang::eval_tidy(bounds, data = data),
        proximity = rlang::eval_tidy(proximity, data = data),
        countrycode = rlang::eval_tidy(countrycode, data = data),
        language = rlang::eval_tidy(language, data = data),
        limit = rlang::eval_tidy(limit, data = data),
        min_confidence = rlang::eval_tidy(min_confidence, data = data),
        no_annotations = rlang::eval_tidy(no_annotations, data = data),
        roadinfo = rlang::eval_tidy(roadinfo, data = data),
        no_dedupe = rlang::eval_tidy(no_dedupe, data = data),
        abbrv = rlang::eval_tidy(abbrv, data = data)
      )
      # results <- tidyr::unnest(results, data)

      if (output == "short") {

        results <-
          dplyr::mutate(
            results,
            data = purrr::map(data, ~dplyr::select(.x, c("oc_lat", "oc_lng", "oc_formatted")))
          )

      } else {

        results <-
          dplyr::mutate(
            results,
            data = purrr::map(data, ~dplyr::select(.x, c("oc_lat", "oc_lng", "oc_formatted"), dplyr::everything()))
          )

      }
    } else {

      oc_results <- oc_forward(
        placename = rlang::eval_tidy(placename, data = data),
        return = "tibble",
        bounds = rlang::eval_tidy(bounds, data = data),
        proximity = rlang::eval_tidy(proximity, data = data),
        countrycode = rlang::eval_tidy(countrycode, data = data),
        language = rlang::eval_tidy(language, data = data),
        limit = rlang::eval_tidy(limit, data = data),
        min_confidence = rlang::eval_tidy(min_confidence, data = data),
        no_annotations = rlang::eval_tidy(no_annotations, data = data),
        roadinfo = rlang::eval_tidy(roadinfo, data = data),
        no_dedupe = rlang::eval_tidy(no_dedupe, data = data),
        abbrv = rlang::eval_tidy(abbrv, data = data)
      )

      results <- dplyr::bind_cols(data, oc_results)

      if (output == "short") {

        results <-
          dplyr::mutate(
            results,
            data = purrr::map(data, ~dplyr::select(.x, c("oc_lat", "oc_lng", "oc_formatted")))
          )

      } else {

        results <-
          dplyr::mutate(
            results,
            data = purrr::map(data, ~dplyr::select(.x, c("oc_lat", "oc_lng", "oc_formatted"), dplyr::everything()))
          )
      }
    }
    results
  }

#' @rdname oc_forward_df
#' @export
oc_forward_df.character <-
  function(placename,
           output = c("short", "all"),
           bounds = NULL,
           proximity = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 1L,
           min_confidence = NULL,
           no_annotations = TRUE,
           roadinfo = FALSE,
           no_dedupe = FALSE,
           abbrv = FALSE,
           ...) {
    xdf <- tibble::tibble(placename = placename)
    oc_forward_df(
      data = xdf,
      placename = placename,
      bind_cols = TRUE,
      output = output,
      bounds = bounds,
      proximity = proximity,
      countrycode = countrycode,
      language = language,
      limit = limit,
      min_confidence = min_confidence,
      no_annotations = no_annotations,
      no_dedupe = no_dedupe,
      abbrv = abbrv
    )
  }
