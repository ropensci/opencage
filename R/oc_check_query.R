#' Check OpenCage query arguments
#'
#' Function that checks the query arguments passed to OpenCage
#'
#' @param limit The maximum number of results that should be returned. Integer
#'   values between 1 and 100 are allowed.
#' @inheritParams oc_forward
#'
#' @keywords internal


oc_check_query <-
  function(
    placename = NULL,
    latitude = NULL,
    longitude = NULL,
    key = NULL,
    bounds = NULL,
    countrycode = NULL,
    language = NULL,
    limit = NULL,
    min_confidence = NULL,
    no_annotations = NULL,
    no_dedupe = NULL,
    no_record = NULL,
    abbrv = NULL,
    add_request = NULL
  ) {
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

    purrr::pwalk(
      .l = arglist,
      .f = .oc_check_query,
      key = key,
      no_record = no_record
    )
  }

.oc_check_query <-
  function(
    placename = NULL,
    latitude = NULL,
    longitude = NULL,
    key = NULL,
    bounds = NULL,
    countrycode = NULL,
    language = NULL,
    limit = NULL,
    min_confidence = NULL,
    no_annotations = NULL,
    no_dedupe = NULL,
    no_record = NULL,
    abbrv = NULL,
    add_request = NULL
  ) {
    # check placename
    if (!is.null(placename)) {
      if (!is.character(placename)) {
        stop(call. = FALSE, "`placename` must be a character vector.")
      }
    }

    # check latitude
    if (!is.null(latitude)) {
      if (!(dplyr::between(latitude, -90, 90))) {
        stop("Every `latitude` must be numeric and between -90 and 90.",
             call. = FALSE)
      }
    }

    # check longitude
    if (!is.null(longitude)) {
      if (!(dplyr::between(longitude, -180, 180))) {
        stop("Every `longitude` must be numeric and between -180 and 180.",
             call. = FALSE)
      }
    }

    # check key
    if (is.null(key)) {
      stop(call. = FALSE, "A `key` must be provided.")
    } else if (!is.character(key)) {
      stop(call. = FALSE, "`key` must be a character vector.")
    } else if (length(key) > 1) {
      stop(call. = FALSE, "`key` must be a vector of length one.")
    }

    # check bounds
    if (!is.null(bounds)) {
      if (length(bounds) != 4) {
        stop(
          call. = FALSE,
          "Every `bbox` must be a numeric vector of length 4."
        )
      }
      oc_check_bbox(bounds[[1]], bounds[[2]], bounds[[3]], bounds[[4]])
    }

    # check countrycode
    if (!is.null(countrycode)) {
      if (!(all(toupper(unlist(countrycode)) %in% countrycodes$code))) {
        stop("Every `countrycode` must be valid.",
             "See `data('countrycodes')` for valid values.",
             call. = FALSE)
      }
    }

    # check language
    if (!is.null(language)) {
      lang <- strsplit(language, "-")[[1]]
      if (!(lang[1] %in% languagecodes$code)) {
        stop("Every `language` abbreviation must be valid.",
             "The first part, the languagecode, is incorrect.",
             "See `data('languagecodes')` for valid values.",
             call. = FALSE)
      }
      if (length(lang) > 1) {
        if (!(lang[2] %in% countrycodes$code)) {
          stop("Every `language` abbreviation must be valid.",
               "The second part, the countrycode, is incorrect.",
               "See `data('countrycodes')` for valid values.",
               call. = FALSE)
        }
      }
    }

    # check limit
    if (!is.null(limit)) {
      if (!(limit %in% c(1:100))) {
        stop(
          call. = FALSE,
          "Every `limit` must be an integer between 1 and 100."
        )
      }
    }

    # check min_confidence
    if (!is.null(min_confidence)) {
      if (!(min_confidence %in% c(1:10))) {
        stop(
          call. = FALSE,
          "Every `min_confidence` must be an integer between 1 and 10."
        )
      }
    }

    # check no_annotations
    if (!is.null(no_annotations)) {
      if (!is.logical(no_annotations)) {
        stop(call. = FALSE, "`no_annotations` must be a logical vector.")
      }
    }

    # check no_dedupe
    if (!is.null(no_dedupe)) {
      if (!is.logical(no_dedupe)) {
        stop(call. = FALSE, "`no_dedupe` must be a logical vector.")
      }
    }

    # check no_record
    if (!is.null(no_record)) {
      if (!is.logical(no_record)) {
        stop(call. = FALSE, "`no_record` must be a logical vector.")
      } else if (length(no_record) > 1) {
        stop(call. = FALSE, "`no_record` must be a vector of length one.")
      }
    }

    # check abbrv
    if (!is.null(abbrv)) {
      if (!is.logical(abbrv)) {
        stop(call. = FALSE, "`abbrv` must be a logical vector.")
      }
    }

    # check add_request
    if (!is.null(add_request)) {
      if (!is.logical(add_request)) {
        stop(call. = FALSE, "`add_request` must be a logical vector.")
      }
    }
  }
