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
  function(placename = NULL,
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
           address_only = NULL,
           add_request = NULL) {
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

    # ensure arguments are length one or match length of placename/latitude
    arglngths <- lengths(arglist)
    if (!all(arglngths == arglngths[1] | arglngths == 1, na.rm = TRUE)) {
      stop(
        call. = FALSE, "All arguments must be of length one \n",
        "or of the same length as `placename` or `latitude`."
      )
    }

    purrr::pwalk(
      .l = arglist,
      .f = .oc_check_query
    )
  }

.oc_check_query <-
  function(placename = NULL,
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
           address_only = NULL,
           add_request = NULL) {
    # check placename
    if (!is.null(placename) && !is.character(placename)) {
      stop("`placename` must be a character vector.", call. = FALSE)
    }

    # check latitude
    if (!is.null(latitude)) oc_check_between(latitude, -90, 90)

    # check longitude
    if (!is.null(longitude)) oc_check_between(longitude, -180, 180)

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
      if (!(limit %in% 1:100)) {
        stop(
          call. = FALSE,
          "Every `limit` must be an integer between 1 and 100."
        )
      }
    }

    # check min_confidence
    if (!is.null(min_confidence)) {
      if (!(min_confidence %in% 1:10)) {
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

    oc_check_logical(address_only)

    oc_check_logical(add_request)
  }


#' Check whether an argument is a boolean and (optionally) of length one
#'
#' @param variable argument to check
#' @param check_length_one boolean whether to check if the argument is of length
#'   one
#'
#' @noRd

oc_check_logical <- function(variable, check_length_one = FALSE) {
  if (!is.null(variable)) {
    if (!is.logical(variable)) {
      var_name <- deparse(substitute(variable)) # deparse only if check fails
      stop("`", var_name, "` must be a logical vector.", call. = FALSE)
    } else if (check_length_one && !identical(length(variable), 1L)) {
      var_name <- deparse(substitute(variable)) # deparse only if check fails
      stop("`", var_name, "` must be a vector of length one.", call. = FALSE)
    }
  }
}


#' Check whether a value is between two values
#'
#' @param x numeric value to check
#' @param left numeric lower bound
#' @param right numeric upper bound
#'
#' @noRd

oc_check_between <- function(x, left, right) {
  if (!is.numeric(x)) {
    stop("Every `", deparse(substitute(x)), "` must be numeric.", call. = FALSE)
  }
  if (isTRUE(x < left || x > right)) {
    stop(
      "Every `",
      deparse(substitute(x)),
      "` must be between ",
      left,
      " and ",
      right,
      ".",
      call. = FALSE
    )
  }
}
