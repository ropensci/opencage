#' @export
oc_reverse <-
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

    # res
    res <-
      oc_get(
        query_par =
          list(
            q = paste0(latitude, ",", longitude),
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
          ))
    # check message
    oc_check(res)

    # done!
    oc_parse(res)
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
