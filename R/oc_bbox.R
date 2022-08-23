#' List of bounding boxes for OpenCage queries
#'
#' Create a list of bounding boxes for OpenCage queries.
#'
#' @param xmin Minimum longitude (also known as `min_lon`, `southwest_lng`,
#'   `west`, or `left`).
#' @param ymin Minimum latitude (also known as `min_lat`, `southwest_lat`,
#'   `south`, or `bottom`).
#' @param xmax Maximum longitude (also known as `max_lon`, `northeast_lng`,
#'   `east`, or `right`).
#' @param ymax Maximum latitude (also known as `max_lat`, `northeast_lat`,
#'   `north`, or `top`).
#' @param data A `data.frame` containing at least 4 columns with `xmin`, `ymin`,
#'   `xmax`, and `ymax` values, respectively.
#' @param bbox A `bbox` object, see `sf::st_bbox`.
#' @param ... Ignored.
#'
#' @return A list of bounding boxes, each of class `bbox`.
#' @export
#'
#' @examples
#' oc_bbox(-5.63160, 51.280430, 0.278970, 51.683979)
#'
#' xdf <-
#'   data.frame(
#'     place = c("Hamburg", "Hamburg"),
#'     northeast_lat = c(54.0276817, 42.7397729),
#'     northeast_lng = c(10.3252805, -78.812825),
#'     southwest_lat = c(53.3951118, 42.7091669),
#'     southwest_lng = c(8.1053284, -78.860521)
#'   )
#' oc_bbox(
#'   xdf,
#'   southwest_lng,
#'   southwest_lat,
#'   northeast_lng,
#'   northeast_lat
#' )
#'
#' # create bbox list column with dplyr
#' library(dplyr)
#' xdf %>%
#'   mutate(
#'     bbox =
#'       oc_bbox(
#'         southwest_lng,
#'         southwest_lat,
#'         northeast_lng,
#'         northeast_lat
#'       )
#'   )
#'
#' # create bbox list from a simple features bbox
#' if (requireNamespace("sf", quietly = TRUE)) {
#'   library(sf)
#'   bbox <- st_bbox(c(xmin = 16.1, xmax = 16.6, ymax = 48.6, ymin = 47.9),
#'     crs = 4326
#'   )
#'   oc_bbox(bbox)
#' }
#'
oc_bbox <- function(...) UseMethod("oc_bbox")

# No @name so it does not show up in the docs.
#' @export
oc_bbox.default <- function(x, ...) {
  stop(
    "Can't create a list of bounding boxes from an object of class `",
    class(x)[[1]],
    "`.",
    call. = FALSE
  )
}

#' @name oc_bbox
#' @export
oc_bbox.numeric <- function(xmin, ymin, xmax, ymax, ...) {
  bbox <- function(xmin, ymin, xmax, ymax) {
    oc_check_bbox(xmin = xmin, ymin = ymin, xmax = xmax, ymax = ymax)
    structure(
      c(xmin = xmin, ymin = ymin, xmax = xmax, ymax = ymax),
      crs =
        structure(
          list(
            epsg = 4326L,
            proj4string = "+proj=longlat +datum=WGS84 +no_defs"
          ),
          class = "crs"
        ),
      class = "bbox"
    )
  }
  purrr::pmap(list(xmin, ymin, xmax, ymax), bbox)
}

#' @name oc_bbox
#' @export
oc_bbox.data.frame <- function(data, xmin, ymin, xmax, ymax, ...) {
  xmin <- rlang::enquo(xmin)
  ymin <- rlang::enquo(ymin)
  xmax <- rlang::enquo(xmax)
  ymax <- rlang::enquo(ymax)

  oc_bbox(xmin = rlang::eval_tidy(xmin, data = data),
          ymin = rlang::eval_tidy(ymin, data = data),
          xmax = rlang::eval_tidy(xmax, data = data),
          ymax = rlang::eval_tidy(ymax, data = data))
}

#' @name oc_bbox
#' @export
oc_bbox.bbox <- function(bbox, ...) {
  # check coordinate reference system (and be lenient if NA_crs_)
  crs <- attr(bbox, "crs")[["input"]]
  if (!is.na(crs) && !identical(crs, "EPSG:4326")) {
    stop(
      call. = FALSE,
      "The coordinate reference system of `bbox` must be EPSG 4326."
    )
  }
  oc_check_bbox(bbox[[1]], bbox[[2]], bbox[[3]], bbox[[4]])
  list(bbox)
}

# check bbox
oc_check_bbox <- function(xmin, ymin, xmax, ymax) {
  if (anyNA(c(xmin, ymin, xmax, ymax))) {
    stop("Every `bbox` element must be non-missing.", call. = FALSE)
  }

  oc_check_between(xmin, -180, 180)
  oc_check_between(xmax, -180, 180)
  oc_check_between(ymin, -90, 90)
  oc_check_between(ymax, -90, 90)

  if (xmin > xmax) {
    stop("`xmin` must always be smaller than `xmax`", call. = FALSE)
  }
  if (ymin > ymax) {
    stop("`ymin` must always be smaller than `ymax`", call. = FALSE)
  }
}
