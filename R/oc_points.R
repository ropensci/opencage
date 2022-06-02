#' List of points for OpenCage queries
#'
#' Create a list of points (latitude/longitude coordinate pairs) for OpenCage
#' queries.
#'
#' @param latitude,longitude Numeric vectors of latitude and longitude values.
#' @param data A `data.frame` containing at least 2 columns with `latitude` and
#'   `longitude` values.
#' @param ... Ignored.
#'
#' @return A list of points. Each point is a named vector of length 2 containing
#'   a latitude/longitude coordinate pair.
#' @export
#'
#' @examples
#' oc_points(-21.01404, 55.26077)
#'
#' xdf <-
#'   data.frame(
#'     place = c("Hamburg", "Los Angeles"),
#'     lat = c(53.5503, 34.0536),
#'     lon = c(10.0006, -118.2427)
#'   )
#' oc_points(
#'   data = xdf,
#'   latitude = lat,
#'   longitude = lon
#' )
#'
#' # create a list column with points with dplyr
#' library(dplyr)
#' xdf %>%
#'   mutate(
#'     points =
#'       oc_points(
#'         lat,
#'         lon
#'       )
#'   )
#'
oc_points <- function(...) UseMethod("oc_points")

# No @name so it does not show up in the docs.
#' @export
oc_points.default <- function(x, ...) {
  stop(
    "Can't create a list of points from an object of class `",
    class(x)[[1]], "`.",
    call. = FALSE
  )
}

#' @name oc_points
#' @export
oc_points.numeric <- function(latitude, longitude, ...) {
  pnts <- function(latitude, longitude) {
    oc_check_point(latitude = latitude, longitude = longitude)
    c(latitude = latitude, longitude = longitude)
  }
  purrr::pmap(list(latitude, longitude), pnts)
}

#' @name oc_points
#' @export
oc_points.data.frame <- function(data, latitude, longitude, ...) { # nolint - see lintr issue #223
  latitude <- rlang::enquo(latitude)
  longitude <- rlang::enquo(longitude)

  oc_points(
    latitude = rlang::eval_tidy(latitude, data = data),
    longitude = rlang::eval_tidy(longitude, data = data)
  )
}

# check points
oc_check_point <- function(latitude, longitude) {
  if (anyNA(c(latitude, longitude))) {
    stop("Every `point` element must be non-missing.", call. = FALSE)
  }
  oc_check_between(latitude, -90, 90)
  oc_check_between(longitude, -180, 180)
}
