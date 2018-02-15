#' Query check
# function that checks the query
#' @param bounds Provides the geocoder with a hint to the region that
#' the query resides in. This value will restrict the possible results
#' to the supplied region. The bounds parameter should be specified as
#' 4 coordinate points forming the south-west and north-east corners of
#'  a bounding box.
#'  For example, \code{bounds = c(-0.563160, 51.280430, 0.278970, 51.683979)}
#'   (min long, min lat, max long, max lat).
#' @param countrycode Restricts the results to the given country.
#' The country code is a two letter code as defined by the ISO 3166-1 Alpha 2
#' standard. E.g. "GB" for the United Kingdom, "FR" for France,
#' "US" for United States.
#' @param language An IETF format language code
#' (such as "es" for Spanish or "pt-BR" for Brazilian Portuguese).
#'  If no language is explicitly specified, we will look for an HTTP
#'  Accept-Language header like those sent by a browser and use the
#'  first language specified and if none are specified "en" (English)
#'   will be assumed.
#' @param limit How many results should be returned (1-100). Default is 10.
#' @param min_confidence An integer from 1-10. Only results with at least
#' this confidence will be returned.
#' @param no_annotations Logical (default FALSE), when TRUE the output will
#' not contain annotations.
#' @param no_dedupe Logical (default FALSE), when TRUE the output will not be
#' deduplicated.
#' @param no_record Logical (default FALSE), when TRUE no log entry of
#'  the query is created at OpenCage.
#' @param abbrv Logical (default FALSE), when TRUE addresses are abbreviated
#'  (e.g. C. instead of Calle)
#' @param add_request Logical (default TRUE), when FALSE the query text
#' is removed from the results data frame.

oc_query_check <- function(latitude = NULL,
                           longitude = NULL,
                           placename = NULL,
                           key,
                           abbrv,
                           bounds,
                           countrycode,
                           language,
                           limit,
                           min_confidence,
                           no_annotations,
                           no_dedupe,
                           no_record,
                           add_request) {
  # check latitude
  if (!is.null(latitude)) {
    if (!dplyr::between(latitude, -90, 90)) {
      stop(call. = FALSE, "Latitude should be between -90 and 90.")
    }
  }

  # check longitude
  if (!is.null(longitude)) {
    if (!dplyr::between(longitude, -180, 180)) {
      stop(call. = FALSE, "Longitude should be between -180 and 180.")
    }
  }
  # check placename
  if (!is.null(placename)) {
    if (!is.character(placename)) {
      stop(call. = FALSE, "Placename should be a character.")
    }
  }

  # check key
  if (!is.null(key)) {
    if (!is.character(key)) {
      stop(call. = FALSE, "Key should be a character.")
    }
  }

  # check bounds
  if (!is.null(bounds)) {
    if (length(bounds) != 4) {
      stop(call. = FALSE, "bounds should be a vector of 4 numeric values.")
    }
    if (!dplyr::between(bounds[1], -180, 180)) {
      stop(call. = FALSE, "min long should be between -180 and 180.")
    }
    if (!dplyr::between(bounds[2], -90, 90)) {
      stop(call. = FALSE, "min lat should be between -90 and 90.")
    }
    if (!dplyr::between(bounds[3], -180, 180)) {
      stop(call. = FALSE, "max long should be between -180 and 180.")
    }
    if (!dplyr::between(bounds[4], -90, 90)) {
      stop(call. = FALSE, "max lat should be between -90 and 90.")
    }
    if (bounds[1] > bounds[3]) {
      stop(call. = FALSE, "min long has to be smaller than max long")
    }
    if (bounds[2] > bounds[4]) {
      stop(call. = FALSE, "min lat has to be smaller than max lat")
    }
  }

  # check countrycode
  if (!is.null(countrycode)) {
    if (!(all(countrycode %in% countrycodes$Code))) {
      stop(call. = FALSE, "countrycode does not have a valid value.")
    }
  }

  # check language
  if (!is.null(language)) {
    lang <- strsplit(language, "-")[[1]]
    if (!(lang[1] %in% languagecodes$alpha2)) {
      stop(call. = FALSE, "The language code is not valid.")
    }
    if (length(lang) > 1) {
      if (!(lang[2] %in% countrycodes$Code)) {
        stop(call. = FALSE, "The country part of language is not valid.")
      }
    }
  }

  # check limit
  if (!is.null(limit)) {
    if (!(limit %in% c(1:100))) {
      stop(call. = FALSE, "limit should be an integer between 1 and 100.") # nolint
    }
  }

  # check min_confidence
  if (!is.null(min_confidence)) {
    if (!(min_confidence %in% c(1:10))) {
      stop(call. = FALSE, "min_confidence should be an integer between 1 and 10.") # nolint
    }
  }

  # check abbrv
  if (!is.null(abbrv)) {
    if (!is.logical(abbrv)) {
      stop(call. = FALSE, "abbrv has to be a logical.")
    }
  }
  # check no_annotations
  if (!is.null(no_annotations)) {
    if (!is.logical(no_annotations)) {
      stop(call. = FALSE, "no_annotations has to be a logical.")
    }
  }

  # check no_record
  if (!is.null(no_record)) {
    if (!is.logical(no_record)) {
      stop(call. = FALSE, "no_record has to be a logical.")
    }
  }

  # check no_dedupe
  if (!is.null(no_dedupe)) {
    if (!is.logical(no_dedupe)) {
      stop(call. = FALSE, "no_dedupe has to be a logical.")
    }
  }

  # check add_request
  if (!is.null(add_request)) {
    if (!is.logical(add_request)) {
      stop(call. = FALSE, "add_request has to be a logical.")
    }
  }
}
