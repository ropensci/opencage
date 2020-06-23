#' Process OpenCage geocoding request
#'
#' This function processes all geocoding requests issued by [oc_forward()] and
#' [oc_reverse()] by calling the respective functions (after the query arguments
#' have been checked by [oc_check_query()]). It builds the URL, fetches the
#' results, checks the status of the returned results and finally parses them.
#'
#' @param limit The maximum number of results that should be returned. Integer
#'   values between 1 and 100 are allowed, the default is 1.
#' @inheritParams oc_forward
#'
#' @return `oc_forward` returns, depending on the `return` parameter, a list
#'   with either
#'   \itemize{
#'   \item the results as a tibble (`"tibble"`, the default),
#'   \item the results as JSON lists (`"json_list"`),
#'   \item the results as GeoJSON lists (`"geojson_list"`), or
#'   \item the URL of the OpenCage API call for debugging purposes
#'   (`"url_only"`).
#'   }
#'
#' @noRd

oc_process <-
  function(
    placename = NULL,
    latitude = NULL,
    longitude = NULL,
    return = "url_only",
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
    get_key = TRUE
  ) {

    if (get_key) {
      # get & check key
      key <- Sys.getenv("OPENCAGE_KEY")
      oc_check_key(key)
    } else {
      key <- NULL
    }

    # get & check no_record
    no_record <- getOption("oc_no_record", default = FALSE)
    oc_check_logical(no_record, check_length_one = TRUE)

    if (length(placename) > 1) {
      pb <- oc_init_progress(placename)
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
          roadinfo = roadinfo,
          no_dedupe = no_dedupe,
          abbrv = abbrv
        )
      )

    results <- purrr::pmap(
      .l = arglist,
      .f = .oc_process,
      return = return,
      key = key,
      no_record = no_record,
      pb = pb
    )

    if(return == "tibble"){
      results <- dplyr::bind_rows(results)
      tidyr::nest(results, data = 2:ncol(results))
    } else
      results
  }

.oc_process <-
  function(placename = NULL,
           latitude = NULL,
           longitude = NULL,
           key = NULL,
           return = NULL,
           bounds = NULL,
           proximity = NULL,
           countrycode = NULL,
           language = NULL,
           limit = NULL,
           min_confidence = NULL,
           no_annotations = NULL,
           roadinfo = FALSE,
           no_dedupe = NULL,
           no_record = NULL,
           abbrv = NULL,
           pb = NULL) {

    if (!is.null(pb)) pb$tick()

    # define endpoint
    if (return == "geojson_list") {
      endpoint <- "geojson"
    } else {
      endpoint <- "json"
    }

    # define query
    if (!is.null(placename)) {
      if (!is.na(placename)) {
        query <- placename
      } else {
        # convert NA's to an empty query to not return bogus results
        query <- ""
      }
    }
    if (!is.null(latitude)) {
      if (!is.na(latitude) && !is.na(longitude)) {
        query <- paste(latitude, longitude, sep = ",")
      } else {
        # convert NA's to an empty query to not return bogus results
        query <- ""
      }
    }

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
        roadinfo = as.integer(roadinfo),
        no_dedupe = as.integer(no_dedupe),
        no_record = as.integer(no_record),
        abbrv = as.integer(abbrv),
        key = key
      ),
      endpoint = endpoint
    )

    # return url only
    if (return == "url_only") {
      if (interactive() || is.null(key)) {
        return(oc_url)
      } else {
        stop(
          call. = FALSE,
          "'url_only' reveals your OpenCage key.\n",
          "It is therefore only available in interactive mode."
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
