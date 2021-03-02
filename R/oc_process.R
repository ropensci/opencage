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
#'   \item the results as tibbles (`"df_list"`, the default),
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
    add_request = FALSE
  ) {

    # get key
    key <- Sys.getenv("OPENCAGE_KEY")
    oc_check_key(key)

    # get & check no_record
    no_record <- getOption("oc_no_record", default = TRUE)
    oc_check_logical(no_record, check_length_one = TRUE)

    # show progress?
    if (length(placename) > 1 && oc_show_progress()) {
      pb <- oc_init_progress(placename)
    } else if (length(latitude) > 1 && oc_show_progress()) {
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
          abbrv = abbrv,
          add_request = add_request
        )
      )

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
           key = NULL,
           return = NULL,
           bounds = NULL,
           proximity = NULL,
           countrycode = NULL,
           language = NULL,
           limit = NULL,
           min_confidence = NULL,
           no_annotations = NULL,
           roadinfo = NULL,
           no_dedupe = NULL,
           no_record = NULL,
           abbrv = NULL,
           add_request = NULL,
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
      query <- placename
    }
    if (!is.null(latitude)) {
      if (!is.na(latitude) && !is.na(longitude)) {
        query <- paste(latitude, longitude, sep = ",")
      } else {
        # set query to NA (and do not send it to the API)
        # if either latitude or longitude is NA
        query <- NA_character_
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
        add_request = as.integer(add_request),
        key = key
      ),
      endpoint = endpoint
    )

    # return url only
    if (return == "url_only") {
      if (
        is.null(key) ||
        (rlang::is_interactive() && isTRUE(getOption("oc_show_key", FALSE)))
      ) {
        return(oc_url)
      } else {
        return(oc_mask_key(oc_url))
      }
    }

    # send query to API if not NA, else return (fake) empty res_text
    if (!is.na(query) && nchar(query) >= 2) {

      # get response
      res_env <- oc_get_memoise(oc_url)

      # parse response
      res_text <- oc_parse_text(res_env)

      # check status message
      oc_check_status(res_env, res_text)

    } else {

      if (identical(return, "geojson_list")) {
        res_text <-
          "{\"features\":[],\"total_results\":0,\"type\":\"FeatureCollection\"}"
      } else {
        if (add_request) {
          request_json <- "\"request\":{\"add_request\":1,\"query\":[]}, "
        } else request_json <- ""
        res_text <-
          paste0("{", request_json, "\"results\":[],\"total_results\":0}")
      }

    }

    # format output
    oc_format(res_text = res_text, return = return, query = query)

  }
