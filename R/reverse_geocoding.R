#' @export
oc_reverse <-
  function(latitude,
           longitude,
           key = oc_key(),
           output = c("df_list", "json_list", "geojson_list", "url_only"),
           bounds = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 10,
           min_confidence = NULL,
           no_annotations = FALSE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           add_request = TRUE) {

    if (length(latitude) != length(longitude))
      stop("The number of values for latitude and longitude are not equal.",
           call. = FALSE)

    output <- match.arg(output)

    # vectorise
    if (length(latitude) > 1){
      pb <- oc_init_progress(latitude) # nolint
      return(purrr::map2(latitude,
                         longitude,
                         ~ {
                           pb$tick()
                           oc_reverse(
                             latitude = .x,
                             longitude = .y,
                             key = key,
                             output = output,
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
                         )
      )
    }
    # check arguments
    oc_query_check(
      latitude = latitude,
      longitude = longitude,
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

    # define endpoint
    if (output == "geojson_list") {
      endpoint <- "geojson"
    } else {
      endpoint <- "json"
    }

    # build url
    oc_url <- oc_build_url(
      query_par =
        list(
          q = paste(latitude, longitude, sep = ","),
          key = key,
          bounds = bounds,
          countrycode = countrycode,
          language = language,
          limit = limit,
          min_confidence = min_confidence,
          no_annotations = as.integer(no_annotations),
          no_dedupe = as.integer(no_dedupe),
          no_record = as.integer(no_record),
          abbrv = as.integer(abbrv),
          add_request = as.integer(add_request)
        ),
      endpoint = endpoint
    )

    if (output == "url_only") return(oc_url)

    # get result
    res <- oc_get_memoise(oc_url)

    # check message
    oc_check(res)

    # done!
    oc_parse(res, output, query = paste(latitude, longitude, sep = ", "))
  }

#' @export
oc_reverse_df <-
  function(data,
           latitude,
           longitude,
           bind_cols = TRUE,
           output = c("short", "all"),
           key = oc_key(),
           bounds = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 1,
           min_confidence = NULL,
           no_annotations = FALSE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE) {

    latitude <- data[[substitute(latitude)]]
    longitude <- data[[substitute(longitude)]]
    output <- match.arg(output)
    add_request <- TRUE # Ensure that query column always exists
    if (output == "short") {
      no_annotations <- TRUE
    }

    if (bind_cols == FALSE) {
      results_list <- oc_reverse(latitude = latitude,
                                 longitude = longitude,
                                 key = key,
                                 output = "df_list",
                                 bounds = bounds,
                                 countrycode = countrycode,
                                 language = language,
                                 limit = limit,
                                 min_confidence = min_confidence,
                                 no_annotations = no_annotations,
                                 no_dedupe = no_dedupe,
                                 no_record = no_record,
                                 abbrv = abbrv,
                                 add_request = add_request)
      results <- dplyr::bind_rows(results_list)
      if (output == "short") {
        results <- dplyr::select(results, query, formatted)
      } else {
        results <- dplyr::select(results, query, dplyr::everything())
      }
    } else {
      if (nrow(data) == 1) {
        results_nest <- dplyr::mutate(data,
                                      op = list(oc_reverse(latitude = latitude,
                                                           longitude = longitude,
                                                           key = key,
                                                           output = "df_list",
                                                           bounds = bounds,
                                                           countrycode = countrycode,
                                                           language = language,
                                                           limit = limit,
                                                           min_confidence = min_confidence,
                                                           no_annotations = no_annotations,
                                                           no_dedupe = no_dedupe,
                                                           no_record = no_record,
                                                           abbrv = abbrv,
                                                           add_request = add_request)))
      } else {
        results_nest <- dplyr::mutate(data,
                                      op = oc_reverse(latitude = latitude,
                                                      longitude = longitude,
                                                      key = key,
                                                      output = "df_list",
                                                      bounds = bounds,
                                                      countrycode = countrycode,
                                                      language = language,
                                                      limit = limit,
                                                      min_confidence = min_confidence,
                                                      no_annotations = no_annotations,
                                                      no_dedupe = no_dedupe,
                                                      no_record = no_record,
                                                      abbrv = abbrv,
                                                      add_request = add_request))
      }
      results <- tidyr::unnest(results_nest)

      if (output == "short") {
        results <- dplyr::select(results, 1:query, formatted, -query)
      } else {
        results <- dplyr::select(results, 1:query, dplyr::everything(), -query)
      }
      results
    }
  }

#' Reverse geocoding
#'
#' Reverse geocoding, from latitude and longitude to placename(s).
#'
#' @param latitude Latitude.
#' @param longitude Longitude.
#' @param key Your OpenCage key.
#' @inheritParams oc_query_check
#'
#' @inherit opencage_forward return details
#'
#' @export
#'
#' @examples
#' \dontrun{
#' opencage_reverse(latitude = 0, longitude = 0,
#' limit = 2)
#' }
opencage_reverse <-
  function(latitude,
           longitude,
           key = oc_key(),
           bounds = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 10,
           min_confidence = NULL,
           no_annotations = FALSE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           add_request = TRUE) {
    lst <- oc_reverse(
      latitude = latitude,
      longitude = longitude,
      key = key,
      output = c("json_list"),
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
    opencage_format(lst)
  }
