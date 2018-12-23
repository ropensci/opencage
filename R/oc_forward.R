#' Forward geocoding
#'
#' Forward geocoding, from placename to latitude and longitude tuple(s).
#'
#' @param placename A character vector with the placename(s) to be geocoded.
#'   Required. See
#'   \href{https://github.com/OpenCageData/opencagedata-misc-docs/blob/master/query-formatting.md}{OpenCage's
#'    instructions} on how to format addresses for forward geocoding best.
#' @param return A character vector of length one indicating the return value of
#'   the function, either a list of tibbles (\code{df_list}, the default), a
#'   JSON list (\code{json_list}), a GeoJSON list (\code{geojson_list}), or the
#'   URL with which the API would be called (\code{url_only}).
#' @param key Your OpenCage API key as a character vector of length one.
#'   Required. By default, \code{\link{oc_key}} will attempt to retrieve the key
#'   from the environment variable \code{OPENCAGE_KEY}.
#' @param bounds A list of bounding boxes, i.e. numeric vectors, each with 4
#'   coordinates forming the south-west and north-east corners of a bounding box
#'   \code{list(c(xmin, ymin, xmax, ymax))}. The \code{bounds} parameter will
#'   restrict the possible results to the supplied region. It can easily be
#'   specified with the \code{\link{oc_bbox}} helper, for example like
#'   \code{bounds = oc_bbox(-0.563160, 51.280430, 0.278970, 51.683979)}.
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
#' @param limit The maximum number of results that should be returned. Integer
#'   values between 1 and 100 are allowed, the default is 10 (\code{oc_forward})
#'   or 1 (\code{oc_forward_df}), respectively.
#' @param min_confidence An integer value between 0 and 10 indicating the
#'   precision of the returned result as defined by it's geographical extent,
#'   (i.e. by the extent of the result's bounding box). See the
#'   \href{https://opencagedata.com/api#confidence}{API documentation} for
#'   details. Only results with at least the requested confidence will be
#'   returned.
#' @param no_annotations A logical vector indicating whether additional
#'   information about the result location should be returned. \code{TRUE} by
#'   default, which means that the output will not contain annotations.
#' @param no_dedupe A logical vector (default \code{FALSE}), when \code{TRUE}
#'   the output will not be deduplicated.
#' @param no_record A logical vector (default \code{FALSE}), when \code{TRUE} no
#'   log entry of the query is created and the geocoding request is not cached
#'   by OpenCage.
#' @param abbrv A logical vector (default \code{FALSE}), when \code{TRUE}
#'   addresses in the \code{formatted} field of the results are abbreviated
#'   (e.g. "Main St." instead of "Main Street").
#' @param add_request A logical vector (default \code{FALSE}) indicating whether
#'   the request is returned again with the results. If the \code{return} value
#'   is a \code{df_list}, the query text is added as a column to the results.
#'   \code{json_list} results will contain all request parameters, including the
#'   API key used! For \code{geojson_list} this is currently ignored by
#'   OpenCage.
#' @param ... Ignored.
#'
#' @return \code{oc_forward} returns, depending on the \code{return} parameter,
#'   a list with either
#'   \itemize{
#'   \item the results as tibbles (\code{"df_list"}, the default),
#'   \item the results as JSON lists (\code{"json_list"}),
#'   \item the results as GeoJSON lists (\code{"geojson_list"}), or
#'   \item the URL of the OpenCage API call for debugging purposes
#'   (\code{"url_only"}).
#'   }
#'   \code{oc_forward_df} returns a tibble.
#'
#' @seealso \code{\link{oc_reverse}} for reverse geocoding, and the
#'   \href{https://opencagedata.com/api}{OpenCage API documentation} for more
#'   information about the API.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' oc_forward(placename = "Sarzeau")
#' oc_forward(placename = "Islington, London")
#' oc_forward(placename = "Triererstr 15,
#'                         Weimar 99423,
#'                         Deutschland")
#' }
#'
oc_forward <-
  function(placename,
           return = c("df_list", "json_list", "geojson_list", "url_only"),
           key = oc_key(),
           bounds = NULL,
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
      stop(call. = FALSE, "You must provide a `placename`.")
    }

    # check return
    return <- match.arg(return)

    # check arguments
    oc_check_query(
      placename = placename,
      key = key,
      bounds = bounds,
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

#' @rdname oc_forward
#' @param data A data frame
#' @param bind_cols logical Bind source and results data frame?
#' @param output A character vector of length one indicating whether only
#'   latitude, longitude and formatted address (\code{short}) or whether all
#'   results (\code{all}) should be returned.
#'
#' @details
#' \code{oc_forward_df} also accepts unquoted column names for all arguments
#' except \code{key}, \code{return}, and \code{no_record}.
#'
#' @export
oc_forward_df <-
  function(data,
           placename,
           bind_cols = TRUE,
           output = c("short", "all"),
           key = oc_key(),
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

    placename <- data[[deparse(substitute(placename))]]

    countrycode <- eval(substitute(alist(countrycode)))[[1]]
    if (is.symbol(countrycode)) {
      countrycode <- data[[deparse(countrycode)]]
    } else if (is.call(countrycode)) {
      countrycode <- eval(countrycode)
    }
    if (!is.null(countrycode)) countrycode <- as.list(countrycode)

    language <- eval(substitute(alist(language)))[[1]]
    if (is.symbol(language)) {
      language <- data[[deparse(language)]]
    } else if (is.call(language)) {
      language <- eval(language)
    }
    if (!is.null(language)) language <- as.list(language)

    limit <- eval(substitute(alist(limit)))[[1]]
    if (is.symbol(limit)) {
      limit <- data[[deparse(limit)]]
    } else if (is.call(limit)) {
      limit <- eval(limit)
    }
    if (!is.null(language)) limit <- as.list(limit)

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
      results_list <- oc_forward(
        placename = placename,
        key = key,
        return = "df_list",
        bounds = bounds,
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
              placename = placename,
              key = key,
              return = "df_list",
              bounds = bounds,
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
