#' Process OpenCage geocoding request
#'
#' This function processes all geocoding requests issued by
#' \code{\link{oc_forward}} and \code{\link{oc_reverse}} by calling the
#' respective functions (after the query arguments have been checked by
#' \code{\link{oc_check_query}}). It builds the URL, fetches the results,
#' checks the status of the returned results and finally parses them.
#'
#' @param placename A character vector with the placename(s) to be
#'   geocoded. See
#'   \href{https://github.com/OpenCageData/opencagedata-misc-docs/blob/master/query-formatting.md}{OpenCage's
#'   instructions} on how to format addresses for forward geocoding best.
#' @param latitude A numeric vector with the latitude.
#' @param longitude A numeric vector with the longitude.
#' @param key Your OpenCage API key as a character vector of length one. By
#'   default, \code{\link{oc_key}} will attempt to retrieve the key from the
#'   environment variable \code{OPENCAGE_KEY}.
#' @param output A character vector of length one indicating the return value of
#'   the function, either a list of tibbles (\code{df_list}, the default), a
#'   JSON list (\code{json_list}), a GeoJSON list (\code{geojson_list}), or the
#'   URL with which the API would be called (\code{url_only.}).
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
#'   per \code{placename} must be provided as a list.
#' @param language An
#'   \href{https://en.wikipedia.org/wiki/IETF_language_tag}{IETF language tag}
#'   (such as "es" for Spanish or "pt-BR" for Brazilian Portuguese). OpenCage
#'   will attempt to return results in that language. If it is not specified,
#'   "en" (English) will be assumed by the API.
#' @param limit The maximum number of results that should be returned.
#'   Integer values between 1 and 100 are allowed, the default is 10 for
#'   (placename or latitude/longitude) vectors, 1 for data frames.
#' @param min_confidence An integer value between 0 and 10 indicating the
#'   precision of the returned result as defined by it's geographical extent.
#'   See the \href{API documentation}{https://opencagedata.com/api#confidence}
#'   for details. Only results with at least the requested confidence will be
#'   returned.
#' @param no_annotations A logical vector indicating whether additional
#'   information about the result location should be returned. \code{TRUE} by
#'   default, which means that the output will not contain annotations.
#' @param no_dedupe A logical vector (default \code{FALSE}), when \code{TRUE}
#'   the output will not be deduplicated.
#' @param no_record A logical vector (default \code{FALSE}), when \code{TRUE} no
#'   log entry of the query is created and the forward geocoding request is not
#'   cached by OpenCage.
#' @param abbrv A logical vector (default \code{FALSE}), when \code{TRUE} addresses in
#'   the \code{formatted} field of the results are abbreviated (e.g. "Main St."
#'   instead of "Main Street").
#' @param add_request A logical vector (default \code{FALSE}), indicating
#'   whether the request is returned again with the results. If the output is a
#'   \code{"df_list"}, the query text is added as a column to the results.
#'   "json_list" results will contain all request parameters, including the API
#'   key used! For \code{"geojson_list"} this is currently ignored by OpenCage.
#' @param ... Ignored.
#'
#' @details
#' \strong{API key}
#' You will need an API key in order to geocode, for
#' which you will need to register with \url{https://opencagedata.com}. The
#' "Free Trial" plan provides up to 2,500 API requests a day. The geocoding
#' functions of the package will conveniently retrieve your API key with
#' \code{\link{oc_key}} if it is saved in the environment variable
#' \code{"OPENCAGE_KEY"}. For ease of use, save your API key in
#' \code{\link[base:Startup]{.Renviron}} as described at
#' \url{http://happygitwithr.com/api-tokens.html}.
#'
#' \strong{memoise}
#' The underlying data at OpenCage is updated about once a day.
#' Note that the package uses `memoise` with no timeout argument so that results
#' are cached inside an active R session.
#'
#' All coordinates sent to the OpenCage API must adhere to the
#' \href{https://en.wikipedia.org/wiki/World_Geodetic_System}{WGS 84}
#' (\href{http://epsg.io/4326}{EPSG:4326})
#' \href{https://en.wikipedia.org/wiki/Spatial_reference_system}{coordinate
#' reference system} in decimal format. There is usually no reason to send more
#' than six or seven digits past the decimal as that then gets down to the
#' \href{https://en.wikipedia.org/wiki/Decimal_degrees}{precision of a
#' centimeter}.
#'
#' This function typically returns multiple results due to placename ambiguity;
#' consider using the \code{bounds} parameter to limit the area searched.
#'
#' @return Depending on the \code{output} parameter, a list with either
#' \itemize{
#' \item the results as tibbles (\code{"df_list"}, the default),
#' \item the results as JSON lists (\code{"json_list"}),
#' \item the results as GeoJSON lists (\code{"geojson_list"}), or
#' \item the URL of the OpenCage API call for debugging purposes
#' (\code{"url_only"}).
#' }
#'
#' @seealso The \href{https://opencagedata.com/api}{OpenCage API documentation}
#'   for more information about the API.
#'
#' @keywords internal

oc_process <-
  function(
    placename = NULL,
    latitude = NULL,
    longitude = NULL,
    key = oc_key(),
    output = "url_only",
    bounds = NULL,
    countrycode = NULL,
    language = NULL,
    limit = 1L,
    min_confidence = NULL,
    no_annotations = TRUE,
    no_dedupe = FALSE,
    no_record = FALSE,
    abbrv = FALSE,
    add_request = FALSE
  ) {
    if (length(placename) > 1) {
      pb <- oc_init_progress(placename) # nolint
    } else if (length(latitude) > 1) {
      pb <- oc_init_progress(latitude)
    } else {
      pb <- NULL
    }
    arglist <-
      purrr::compact(
        list(
          placename = placename,
          latitude = latitude,
          longitude = longitude,
          bounds = bounds,
          countrycode = countrycode,
          language = language,
          limit = limit,
          min_confidence = min_confidence,
          no_annotations = no_annotations,
          no_dedupe = no_dedupe,
          abbrv = abbrv,
          add_request = add_request
        )
      )

    # prevent obscure warning message from pwalk if length(arglist) == 0
    stopifnot(length(arglist) >= 1)

    purrr::pmap(.l = arglist,
                .f = .oc_process,
                output = output,
                key = key,
                no_record = no_record,
                pb = pb)
  }

.oc_process <-
  function(placename = NULL,
           latitude = NULL,
           longitude = NULL,
           key = oc_key(),
           output = "url_only",
           bounds = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 1L,
           min_confidence = NULL,
           no_annotations = TRUE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           add_request = FALSE,
           pb = NULL) {

    if (!is.null(pb))  pb$tick()

    # define endpoint
    if (output == "geojson_list") {
      endpoint <- "geojson"
    } else {
      endpoint <- "json"
    }

    # convert NA's to NULL to not return bogus results
    if (!is.null(placename) && is.na(placename)) placename <- NULL

    if (!is.null(placename)) query <- placename
    if (!is.null(latitude)) query <- paste(latitude, longitude, sep = ",")

    # build url
    oc_url <- oc_build_url(
      query_par = list(
        q = query,
        bounds = bounds,
        countrycode = countrycode,
        language = language,
        limit = limit,
        min_confidence = min_confidence,
        no_annotations = as.integer(no_annotations),
        no_dedupe = as.integer(no_dedupe),
        no_record = as.integer(no_record),
        abbrv = as.integer(abbrv),
        add_request = as.integer(add_request),
        key = key
      ),
      endpoint = endpoint
    )

    if (output == "url_only") {
      if (interactive() || is_testing()) {
        return(oc_url)
      } else {
        stop("'url_only' reveals your opencage key. \n
             It is therefore only available in interactive mode.")
      }
      }

    # get result
    res <- oc_get_memoise(oc_url)

    # check status message
    oc_check_status(res)

    # done!
    oc_parse(req = res, output = output, query = query)
    }
