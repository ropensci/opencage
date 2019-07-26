#' Forward geocoding
#'
#' Forward geocoding from a character vector of placenames to latitude and
#' longitude tuple(s).
#'
# nolint start - link longer than 80 chars
#' @param placename A character vector with the placename(s) to be geocoded.
#'
#'   If the placenames are addresses, see
#'   \href{https://github.com/OpenCageData/opencagedata-misc-docs/blob/master/query-formatting.md}{OpenCage's
#'    instructions} on how to format addresses for best forward geocoding
#'    results.
# nolint end
#' @param return A character vector of length one indicating the return value of
#'   the function, either a list of tibbles (\code{df_list}, the default), a
#'   JSON list (\code{json_list}), a GeoJSON list (\code{geojson_list}), or the
#'   URL with which the API would be called (\code{url_only}).
#' @param key Your OpenCage API key as a character vector of length one. By
#'   default, \code{\link{oc_key}} will attempt to retrieve the key from the
#'   environment variable \code{OPENCAGE_KEY}.
#' @param bounds A list of bounding boxes, i.e. numeric vectors, each with 4
#'   coordinates forming the south-west and north-east corners of a bounding
#'   box: \code{list(c(xmin, ymin, xmax, ymax))}. \code{bounds} restricts the
#'   possible results to the supplied region. It can be specified with the
#'   \code{\link{oc_bbox}} helper. For example: \code{bounds =
#'   oc_bbox(-0.563160, 51.280430, 0.278970, 51.683979)}.
#' @param proximity A list of coordinate pairs, i.e. numeric vectors of length
#'   2, each with latitude, longitude coordinates in decimal format. They
#'   provide OpenCage with a hint to bias results in favour of those closer to
#'   the specified location. It can easily be specified with the
#'   \code{\link{oc_points}} helper, for example like \code{proximity =
#'   oc_points(41.40139, 2.12870)}.
#' @param countrycode A two letter code as defined by the
#'   \href{https://www.iso.org/obp/ui/#search/code}{ISO 3166-1 Alpha 2} standard
#'   that restricts the results to the given country or countries. E.g. "AR" for
#'   Argentina, "FR" for France, "NZ" for the New Zealand. Multiple countrycodes
#'   per \code{placename} must be wrapped in a list.
#' @param language An
#'   \href{https://en.wikipedia.org/wiki/IETF_language_tag}{IETF language tag}
#'   (such as "es" for Spanish or "pt-BR" for Brazilian Portuguese). OpenCage
#'   will attempt to return results in that language. If it is not specified,
#'   "en" (English) will be assumed by the API.
#' @param limit Numeric vector of integer values to determine the maximum
#'   number of results returned for each \code{placename}. Integer values
#'   between 1 and 100 are allowed. Default is 10.
#' @param min_confidence Numeric vector of integer values between 0 and 10
#'   indicating the precision of the returned result as defined by its
#'   geographical extent, (i.e. by the extent of the result's bounding box). See
#'   the \href{https://opencagedata.com/api#confidence}{API documentation} for
#'   details. Only results with at least the requested confidence will be
#'   returned. Default is \code{NULL}).
#' @param no_annotations Logical vector indicating whether additional
#'   information about the result location should be returned. \code{TRUE} by
#'   default, which means that the output will not contain annotations.
#' @param no_dedupe Logical vector (default \code{FALSE}), when \code{TRUE}
#'   the output will not be deduplicated.
#' @param no_record Logical vector of length one (default \code{FALSE}), when
#'   \code{TRUE} no log entry of the query is created, and the geocoding
#'   request is not cached by OpenCage.
#' @param abbrv Logical vector (default \code{FALSE}), when \code{TRUE}
#'   addresses in the \code{formatted} field of the results are abbreviated
#'   (e.g. "Main St." instead of "Main Street").
#' @param add_request Logical vector (default \code{FALSE}) indicating whether
#'   the request is returned again with the results. If the \code{return} value
#'   is a \code{df_list}, the query text is added as a column to the results.
#'   \code{json_list} results will contain all request parameters, including the
#'   API key used! This is currently ignored by OpenCage if return value is
#'   \code{geojson_list}.
#' @param ... Ignored.
#'
#' @return Depending on the \code{return} argument, \code{oc_forward} returns
#'   a list with either
#'   \itemize{
#'   \item the results as tibbles (\code{"df_list"}, the default),
#'   \item the results as JSON specified as a list (\code{"json_list"}),
#'   \item the results as GeoJSON specified as a list (\code{"geojson_list"}),
#'   or
#'   \item the URL of the OpenCage API call for debugging purposes
#'   (\code{"url_only"}).
#'   }
#'
#' @seealso \code{\link{oc_forward_df}} for inputs as a data frame, or
#'   \code{\link{oc_reverse}} and \code{\link{oc_reverse_df}} for reverse
#'   geocoding. For more information about the API and the various parameters,
#'   see the \href{https://opencagedata.com/api}{OpenCage API documentation}.
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
           return = c("df_list", "json_list", "geojson_list", "url_only"),
           key = oc_key(),
           bounds = NULL,
           proximity = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 10L,
           min_confidence = NULL,
           no_annotations = TRUE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           add_request = FALSE,
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
      key = key,
      bounds = bounds,
      proximity = proximity,
      countrycode = countrycode,
      language = language,
      limit = limit,
      min_confidence = min_confidence,
      no_annotations = no_annotations,
      no_dedupe = no_dedupe,
      no_record = no_record,
      abbrv = abbrv,
      add_request = add_request
    )
    # process request
    oc_process(
      placename = placename,
      return = return,
      key = key,
      bounds = bounds,
      proximity = proximity,
      countrycode = countrycode,
      language = language,
      limit = limit,
      min_confidence = min_confidence,
      no_annotations = no_annotations,
      no_dedupe = no_dedupe,
      no_record = no_record,
      abbrv = abbrv,
      add_request = add_request
    )
  }


#' Forward geocoding with data frames
#'
#' Forward geocoding from a placename variable to latitude and longitude
#'   tuple(s).
#'
#' @inheritParams oc_forward
#' @param data A data frame.
# nolint start - link longer than 80 chars
#' @param placename An unquoted variable name of a character vector with the
#'   placenames to be geocoded.
#'
#'   If the placenames are addresses, see
#'   \href{https://github.com/OpenCageData/opencagedata-misc-docs/blob/master/query-formatting.md}{OpenCage's
#'    instructions} on how to format addresses for best forward geocoding
#'    results.
# nolint end
#' @param bind_cols When \code{bind_col = TRUE}, the default, the results are
#'   column bound to \code{data}. When \code{FALSE}, the results are returned as
#'   a new tibble.
#' @param output A character vector of length one indicating whether only
#'   latitude, longitude, and formatted address variables (\code{"short"}, the
#'   default) should be returned or all variables (\code{"all"}) variables
#'   should be returned.
#' @param bounds A list, or an unquoted variable name of a list column of
#'   bounding boxes, i.e. a list of numeric vectors, each with 4 coordinates
#'   forming the south-west and north-east corners of a bounding box:
#'   \code{list(c(xmin, ymin, xmax, ymax))}. \code{bounds} restricts the
#'   possible results to the supplied region. It can be specified with the
#'   \code{\link{oc_bbox}} helper. For example: \code{bounds =
#'   oc_bbox(-0.563160, 51.280430, 0.278970, 51.683979)}. Default is
#'   \code{NULL}.
#' @param proximity A list, or an unquoted variable name of a list column of
#'   coordinate pairs, i.e. numeric vectors of length 2, each with latitude,
#'   longitude coordinates in decimal format. They provide OpenCage with a hint
#'   to bias results in favour of those closer to the specified location. It can
#'   easily be specified with the \code{\link{oc_points}} helper, for example
#'   like \code{proximity = oc_points(41.40139, 2.12870)}.
#' @param countrycode Character vector, or an unquoted variable name of such a
#'   vector, of two-letter codes as defined by the
#'   \href{https://www.iso.org/obp/ui/#search/code}{ISO 3166-1 Alpha 2} standard
#'   that restricts the results to the given country or countries. E.g. "AR" for
#'   Argentina, "FR" for France, "NZ" for the New Zealand. Multiple countrycodes
#'   per \code{placename} must be wrapped in a list. Default is \code{NULL}.
#' @param language Character vector, or an unquoted variable name of such a
#'   vector, of
#'   \href{https://en.wikipedia.org/wiki/IETF_language_tag}{IETF language tags}
#'   (such as "es" for Spanish or "pt-BR" for Brazilian Portuguese). OpenCage
#'   will attempt to return results in that language. If it is not specified,
#'   "en" (English) will be assumed by the API.
#' @param limit Numeric vector of integer values, or an unquoted variable name
#'   of such a vector, to determine the maximum number of results returned for
#'   each \code{placename}. Integer values between 1 and 100 are allowed.
#'   Default is 1.
#' @param min_confidence Numeric vector of integer values, or an unquoted
#'   variable name of such a vector, between 0 and 10 indicating the precision
#'   of the returned result as defined by its geographical extent, (i.e. by the
#'   extent of the result's bounding box). See the
#'   \href{https://opencagedata.com/api#confidence}{API documentation} for
#'   details. Only results with at least the requested confidence will be
#'   returned. Default is \code{NULL}).
#' @param no_annotations Logical vector, or an unquoted variable name of such a
#'   vector, indicating whether additional information about the result location
#'   should be returned. Default is \code{TRUE}, which means that the output
#'   will not contain annotations.
#' @param no_dedupe Logical vector, or an unquoted variable name of such a
#'   vector. Default is \code{FALSE}. When \code{TRUE} the output will not be
#'   deduplicated.
#' @param abbrv Logical vector, or an unquoted variable name of such a
#'   vector. Default is \code{FALSE}. When \code{TRUE} addresses in the
#'   \code{formatted} variable of the results are abbreviated (e.g. "Main St."
#'   instead of "Main Street").
#' @param ... Ignored.
#'
#' @return A tibble.
#'
#' @seealso \code{\link{oc_forward}} for inputs as vectors, or
#'   \code{\link{oc_reverse}} and \code{\link{oc_reverse_df}} for reverse
#'   geocoding. For more information about the API and the various parameters,
#'   see the \href{https://opencagedata.com/api}{OpenCage API documentation}.
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
#' # arguments except bind_cols, output, key, and no_record.
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

oc_forward_df <-
  function(data,
           placename,
           bind_cols = TRUE,
           output = c("short", "all"),
           key = oc_key(),
           proximity = NULL,
           bounds = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 1L,
           min_confidence = NULL,
           no_annotations = TRUE,
           no_dedupe = FALSE,
           no_record = FALSE,
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
    no_dedupe <- rlang::enquo(no_dedupe)
    abbrv <- rlang::enquo(abbrv)

    output <- rlang::arg_match(output)

    # Ensure that query column always exists
    add_request <- TRUE

    if (output == "short") {
      no_annotations <- TRUE
    }

    if (bind_cols == FALSE) {
      results_list <- oc_forward(
        placename = rlang::eval_tidy(placename, data = data),
        key = key,
        return = "df_list",
        bounds = rlang::eval_tidy(bounds, data = data),
        proximity = rlang::eval_tidy(proximity, data = data),
        countrycode = rlang::eval_tidy(countrycode, data = data),
        language = rlang::eval_tidy(language, data = data),
        limit = rlang::eval_tidy(limit, data = data),
        min_confidence = rlang::eval_tidy(min_confidence, data = data),
        no_annotations = rlang::eval_tidy(no_annotations, data = data),
        no_dedupe = rlang::eval_tidy(no_dedupe, data = data),
        no_record = no_record,
        abbrv = rlang::eval_tidy(abbrv, data = data),
        add_request = add_request
      )
      results <- dplyr::bind_rows(results_list)
      if (output == "short") {
        results <-
          dplyr::select(results, query, lat, lng, formatted)
      } else {
        results <-
          dplyr::select(results, query, lat, lng, dplyr::everything())
      }
    } else {
      results_nest <-
        dplyr::mutate(
          data,
          op =
            oc_forward(
              placename = !!placename,
              key = key,
              return = "df_list",
              bounds = !!bounds,
              proximity = !!proximity,
              countrycode = !!countrycode,
              language = !!language,
              limit = !!limit,
              min_confidence = !!min_confidence,
              no_annotations = !!no_annotations,
              no_dedupe = !!no_dedupe,
              no_record = no_record,
              abbrv = !!abbrv,
              add_request = add_request
            )
        )

      results <- tidyr::unnest(results_nest, op) # nolint
      # `op` is necessary, so that other list columns are not unnested
      # but lintr complains about `op` not being defined

      if (output == "short") {
        results <-
          dplyr::select(
            results,
            1:query,
            lat,
            lng,
            formatted,
            -query
          )
      } else {
        results <-
          dplyr::select(
            results,
            1:query,
            lat,
            lng,
            dplyr::everything(),
            -query
          )
      }
    }
    results
  }
