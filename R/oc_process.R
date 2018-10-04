#' Process OpenCage geocoding request
#'
#' This function processes all OpenCage geocoding requests by calling the
#' respective functions (once the query arguments have been checked by
#' oc_check_query). It builds the URL, fetches the results, checks the status of
#' the returned results and finally parses them.
#'
#' @param placename Placename.
#' @param latitude Latitude.
#' @param longitude Longitude.
#' @param key Your OpenCage key.
#' @param output
#' @param bounds Provides the geocoder with a hint to the region that the query
#'   resides in. This value will restrict the possible results to the supplied
#'   region. The bounds parameter should be specified as 4 coordinate points
#'   forming the south-west and north-east corners of a bounding box. For
#'   example, \code{bounds = c(-0.563160, 51.280430, 0.278970, 51.683979)}
#'   (xmin, ymin, xmax, ymax).
#' @param countrycode Restricts the results to the given country. The country
#'   code is a two letter code as defined by the ISO 3166-1 Alpha 2 standard.
#'   E.g. "GB" for the United Kingdom, "FR" for France, "US" for United States.
#' @param language An IETF format language code (such as "es" for Spanish or
#'   "pt-BR" for Brazilian Portuguese). If no language is explicitly specified,
#'   we will look for an HTTP Accept-Language header like those sent by a
#'   browser and use the first language specified and if none are specified "en"
#'   (English) will be assumed.
#' @param limit How many results should be returned (1-100)? Default is 10.
#' @param min_confidence An integer from 1-10. Only results with at least this
#'   confidence will be returned.
#' @param no_annotations Logical (default FALSE), when TRUE the output will not
#'   contain annotations.
#' @param no_dedupe Logical (default FALSE), when TRUE the output will not be
#'   deduplicated.
#' @param no_record Logical (default FALSE), when TRUE no log entry of the query
#'   is created at OpenCage.
#' @param abbrv Logical (default FALSE), when TRUE addresses are abbreviated
#'   (e.g. C. instead of Calle)
#' @param add_request Logical (default TRUE), when FALSE the query text is
#'   removed from the results data frame.
#' @param ... Currently not used.
#'
#' @details
#' \strong{API key}
#' To get an API key to access OpenCage geocoding,
#' register at \url{https://geocoder.opencagedata.com/pricing}.
#' The free API key provides up to 2,500 calls a day. For ease of use,
#'  save your API key as an environment variable as described at
#'   \url{https://stat545-ubc.github.io/bit003_api-key-env-var.html}.
#' Both functions of the package will conveniently look for your API key
#' using \code{Sys.getenv("OPENCAGE_KEY")} so if your API key is an environment
#'  variable called "OPENCAGE_KEY" you don't need to input it manually.
#'
#' \strong{memoise}
#' The underlying data at OpenCage is updated about once a day.
#' Note that the package uses `memoise` with no timeout argument so that results
#'  are cached inside an active R session.
#'
#' This function typically returns multiple results due to placename ambiguity;
#'  consider using the \code{bounds} parameter to limit the area searched.
#'
#' @return Depending on the \code{output} argument list of data.frame(s) (\code{df_list})

oc_process <-
  function(
    placename = NULL,
    latitude = NULL,
    longitude = NULL,
    key = NULL,
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
      if (interactive() || is.null(key)) {
        return(oc_url)
      } else {
        stop(
          call. = FALSE,
          "'url_only' reveals your opencage key.
          It is therefore only available in interactive mode."
        )
      }
    }

    # get result
    res <- oc_get_memoise(oc_url)

    # check status message
    oc_check_status(res)

    # done!
    oc_parse(req = res, output = output, query = query)
    }
