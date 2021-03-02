oc_check_logical <- function(variable, check_length_one = FALSE) {
  if (!is.null(variable)) {
    if (!is.logical(variable)) {
      var_name <- deparse(substitute(variable)) # deparse only if check fails
      stop(
        paste0("`", var_name, "` must be a logical vector."),
        call. = FALSE
      )
    } else if (check_length_one && !identical(length(variable), 1L)) {
      var_name <- deparse(substitute(variable)) # deparse only if check fails
      stop(
        paste0("`", var_name, "` must be a vector of length one."),
        call. = FALSE
      )
    }
  }
}

#' Check OpenCage query arguments
#'
#' Function that checks the query arguments passed to OpenCage
#'
#' @param limit The maximum number of results that should be returned. Integer
#'   values between 1 and 100 are allowed.
#' @inheritParams oc_forward
#'
#' @noRd

oc_check_query <-
  function(
    placename = NULL,
    latitude = NULL,
    longitude = NULL,
    bounds = NULL,
    proximity = NULL,
    countrycode = NULL,
    language = NULL,
    limit = NULL,
    min_confidence = NULL,
    no_annotations = NULL,
    roadinfo = NULL,
    no_dedupe = NULL,
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

    # ensure arguments are length one or match length of placename/latitude
    arglngths <- lengths(arglist)
    if (!all(arglngths == arglngths[1] | arglngths == 1, na.rm = TRUE)) {
      stop(call. = FALSE, "All arguments must be of length one \n",
      "or of the same length as `placename` or `latitude`.")
    }

    purrr::pwalk(
      .l = arglist,
      .f = .oc_check_query
    )
  }

.oc_check_query <-
  function(
    placename = NULL,
    latitude = NULL,
    longitude = NULL,
    bounds = NULL,
    proximity = NULL,
    countrycode = NULL,
    language = NULL,
    limit = NULL,
    min_confidence = NULL,
    no_annotations = NULL,
    roadinfo = NULL,
    no_dedupe = NULL,
    abbrv = NULL,
    add_request = NULL
  ) {
    # check placename
    if (!is.null(placename)) {
      if (!is.character(placename)) {
        stop("`placename` must be a character vector.", call. = FALSE)
      }
    }

    # check latitude
    if (!is.null(latitude)) {
      if (!is.numeric(latitude)) {
        stop("Every `latitude` must be numeric.", call. = FALSE)
      } else if (isTRUE(!dplyr::between(latitude, -90, 90))) {
        stop("Every `latitude` must be between -90 and 90.", call. = FALSE)
      }
    }

    # check longitude
    if (!is.null(longitude)) {
      if (!is.numeric(longitude)) {
        stop("Every `longitude` must be numeric.", call. = FALSE)
      } else if (isTRUE(!dplyr::between(longitude, -180, 180))) {
        stop("Every `longitude` must be between -180 and 180.", call. = FALSE)
      }
    }

    # check bounds
    if (!is.null(bounds)) {
      if (length(bounds) != 4) {
        stop(
          call. = FALSE,
          "Every `bbox` must be a numeric vector of length 4.\n",
          "Did you forget to wrap the vector(s) in a list?"
        )
      }
      oc_check_bbox(bounds[[1]], bounds[[2]], bounds[[3]], bounds[[4]])
    }

    # check proximity
    if (!is.null(proximity)) {
      if (length(proximity) != 2) {
        stop(
          call. = FALSE,
          "Every `proximity` point must be a numeric vector of length 2.\n",
          "Did you forget to wrap the vector(s) in a list?"
        )
      }
      if (!utils::hasName(proximity, "latitude") ||
          !utils::hasName(proximity, "longitude")) {
        stop(
          call. = FALSE,
          "The coordinates of every `proximity` point must be named ",
          "'latitude' and 'longitude'."
        )
      }
      oc_check_point(
        latitude = proximity[["latitude"]],
        longitude = proximity[["longitude"]]
      )
    }

    # check countrycode
    if (!is.null(countrycode)) {
      if (!(all(toupper(unlist(countrycode)) %in% countrycodes$code))) {
        stop("Every `countrycode` must be valid. ",
          "See `data('countrycodes')` for valid values.",
          call. = FALSE
        )
      }
    }

    # check language
    if (!is.null(language)) {
      if (!is.character(language)) {
        stop(call. = FALSE, "`language` must be a character vector.")
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

    oc_check_logical(no_annotations)

    oc_check_logical(roadinfo)

    oc_check_logical(no_dedupe)

    oc_check_logical(abbrv)

    oc_check_logical(add_request)

  }
