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
#' @noRd

oc_process <-
  function(
    placename = NULL,
    latitude = NULL,
    longitude = NULL,
    key = oc_key(),
    return = "url_only",
    bounds = NULL,
    proximity = NULL,
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
          proximity = proximity,
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

    purrr::pmap(
      .l = arglist,
      .f = .oc_process,
      return = return,
      key = key,
      no_record = no_record,
      pb = pb
    )
  }

.oc_process <-
  function(placename = NULL,
           latitude = NULL,
           longitude = NULL,
           key = oc_key(),
           return = "url_only",
           bounds = NULL,
           proximity = NULL,
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
        proximity = proximity,
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
      if (interactive() || is.null(key)) {
        return(oc_url)
      } else {
        stop(
          call. = FALSE,
          "'url_only' reveals your OpenCage key.
          It is therefore only available in interactive mode."
        )
      }
    }

    # get response
    res_env <- oc_get_memoise(oc_url)

    # parse response
    res_text <- oc_parse_text(res_env)

    # check status message
    oc_check_status(res_env, res_text)

    # format output
    oc_format(res_text = res_text, return = return, query = query)
    }
