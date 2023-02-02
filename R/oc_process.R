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
  function(placename = NULL,
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
           address_only = FALSE,
           add_request = FALSE) {
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
          address_only = address_only,
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
           address_only = NULL,
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
        address_only = as.integer(address_only),
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
      # Fake 0 results response

      if (identical(return, "geojson_list")) {
        res_text <-
          "{\"features\":[],\"total_results\":0,\"type\":\"FeatureCollection\"}"
      } else {
        request_json <-
          if (add_request) {
            "\"request\":{\"add_request\":1,\"query\":[]}, "
          } else {
            ""
          }

        res_text <-
          paste0("{", request_json, "\"results\":[],\"total_results\":0}")
      }
    }

    # format output
    oc_format(res_text = res_text, return = return, query = query)
  }


#' Build query URL
#'
#' @param query_par A list of query parameters
#' @param endpoint The endpoint to query ("json" or "geojson")
#'
#' @return A character string URL
#' @noRd

oc_build_url <- function(query_par, endpoint) {
  query_par <- purrr::compact(query_par)
  query_par <- purrr::discard(query_par, .p = anyNA)

  if ("countrycode" %in% names(query_par)) {
    query_par$countrycode <-
      tolower(paste(query_par$countrycode, collapse = ","))
  }

  if (!is.null(query_par$bounds)) {
    bounds <- query_par$bounds
    query_par$bounds <- paste(
      bounds[1],
      bounds[2],
      bounds[3],
      bounds[4],
      sep = ","
    )
  }

  if (!is.null(query_par$proximity)) {
    proximity <- query_par$proximity
    query_par$proximity <- paste(
      proximity["latitude"],
      proximity["longitude"],
      sep = ","
    )
  }

  oc_path <- paste0("geocode/v1/", endpoint)

  list(
    path = oc_path,
    query = query_par
  )
}


#' GET request from OpenCage
#'
#' @param oc_url_parts list with path and query, built with
#'   `oc_build_url()`
#'
#' @return httr2 response
#' @noRd

oc_get <- function(oc_url_parts) {

  httr2::request("https://api.opencagedata.com") %>%
    httr2::req_url_path(oc_url[["path"]]) %>%
    httr2::req_url_query(oc_url[["query"]]) %>%
    httr2::req_user_agent(oc_ua_string) %>%
    httr2::req_perform()
}

# user-agent string: this is set at build-time, but that should be okay,
# since the version number is too.
oc_ua_string <-
  paste0(
    "<https://github.com/ropensci/opencage>, version ",
    utils::packageVersion("opencage")
  )


#' Parse HttpResponse object to character string
#'
#' @param res crul::HttpResponse object
#'
#' @return character string (depending on queried endpoint, json or geojson)
#' @noRd

oc_parse_text <- function(res) {
  text <- res$parse(encoding = "UTF-8")
  if (identical(text, "")) {
    stop("OpenCage returned an empty response.", call. = FALSE)
  }
  text
}


#' Check the status of the HttpResponse
#'
#' @param res_env crul::HttpResponse object
#' @param res_text parsed HttpResponse
#'
#' @return NULL if status code less than or equal to 201, else `stop()`
#' @noRd

oc_check_status <- function(res_env, res_text) {
  if (res_env$success()) {
    return(invisible())
  }
  message <-
    jsonlite::fromJSON(
      res_text,
      simplifyVector = TRUE,
      flatten = TRUE
    )$status$message
  stop("HTTP failure: ", res_env$status_code, "\n", message, call. = FALSE)
}


#' Format the result string
#'
#' @param res_text parsed HttpResponse
#' @param return character, which type of object to return (`df_list`,
#'   `json_list`, `geojson_list`)
#' @param query query string ("placename" or "latitude,longitude")
#'
#' @return A list of tibbles, json lists or geojson_lists
#' @noRd

oc_format <- function(res_text, return, query) {
  if (return == "df_list") {
    jsn <- jsonlite::fromJSON(res_text, simplifyVector = TRUE, flatten = TRUE)
    if (identical(jsn$total_results, 0L)) {
      # in oc_forward_df we rely on oc_lat, oc_lng, oc_formatted to be present
      results <-
        tibble::tibble(
          oc_lat = NA_real_,
          oc_lng = NA_real_,
          oc_formatted = NA_character_
        )
    } else {
      results <- tibble::as_tibble(jsn$results)
      # Make column names nicer
      colnames(results) <-
        sub(
          "^annotations\\.|^bounds\\.|^components\\.|^geometry\\.",
          "",
          colnames(results)
        )
      colnames(results) <- sub("^_", "", colnames(results)) # components:_type
      colnames(results) <- gsub("\\.|-", "_", colnames(results))
      results <-
        rlang::set_names(results, ~ tolower(paste0("oc_", .)))
    }
    if ("request" %in% names(jsn)) {
      # add request directly, not from OpenCage roundtrip
      tibble::add_column(results, oc_query = query, .before = 1)
    } else {
      results
    }
  } else if (return == "json_list" || return == "geojson_list") {
    res_text_masked <- oc_mask_key(res_text)
    jsn <- jsonlite::fromJSON(res_text_masked, simplifyVector = FALSE)
    if (return == "geojson_list") {
      structure(jsn, class = "geo_list")
    } else {
      jsn
    }
  }
}
