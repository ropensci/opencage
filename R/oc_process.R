#' Process OpenCage geocoding request
#'
#' This function processes all geocoding requests issued by
#' \code{\link{oc_forward}} and \code{\link{oc_reverse}} by calling the
#' respective functions (after the query arguments have been checked by
#' \code{\link{oc_check_query}}). It builds the URL, fetches the results,
#' checks the status of the returned results and finally parses them.
#'
#' @param limit The maximum number of results that should be returned. Integer
#'   values between 1 and 100 are allowed, the default is 1.
#' @inheritParams oc_forward
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
#' centimetre}.
#'
#' This function typically returns multiple results due to placename ambiguity;
#' consider using the \code{bounds} parameter to limit the area searched.
#'
#' @keywords internal

oc_process <-
  function(
    placename = NULL,
    latitude = NULL,
    longitude = NULL,
    key = oc_key(),
    return = "url_only",
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
                return = return,
                key = key,
                no_record = no_record,
                pb = pb)
  }

.oc_process <-
  function(placename = NULL,
           latitude = NULL,
           longitude = NULL,
           key = oc_key(),
           return = "url_only",
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
    if (return == "geojson_list") {
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

    if (return == "url_only") {
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
    oc_parse(req = res, return = return, query = query)
    }
