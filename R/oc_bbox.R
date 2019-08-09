#' List of bounding boxes for OpenCage queries
#'
#' Create a list of bounding boxes for OpenCage queries.
#'
#' @param xmin Minimum longitude (also known as \code{min lon},
#'   \code{southwest_lng}, \code{west}, or \code{left}).
#' @param ymin Minimum latitude (also known as \code{min lat},
#'   \code{southwest_lat}, \code{south}, or \code{bottom}).
#' @param xmax Maximum longitude (also known as \code{max lon},
#'   \code{northeast_lng}, \code{east}, or \code{right}).
#' @param ymax Maximum latitude (also known as \code{max lat},
#'   \code{northeast_lat}, \code{north}, or \code{top}).
#' @param data A \code{data.frame} containing at least 4 columns with
#'   \code{xmin}, \code{ymin}, \code{xmax}, and \code{ymax} values,
#'   respectively.
#' @param bbox A \code{bbox} object, see \code{sf::st_bbox}.
#' @param ... Ignored.
#'
#' @return A \code{bbox_list}, i.e. a list of bounding boxes, each of class
#'   \code{bbox}.
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
#' \dontrun{
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
#' }
#'
oc_bbox <- function(...) UseMethod("oc_bbox")

# No @name so it does not show up in the docs.
#' @export
oc_bbox.default <- function(x, ...) { # nolint - see lintr issue #223
  stop(
    "Can't create a `bbox_list` from an object of class `", class(x)[[1]], "`.",
    call. = FALSE
  )
}

#' @name oc_bbox
#' @export
oc_bbox.numeric <- function(xmin, ymin, xmax, ymax, ...) { # nolint - see lintr issue #223
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
  bbox_list <- purrr::pmap(list(xmin, ymin, xmax, ymax), bbox)
  structure(
    bbox_list,
    class = c("bbox_list", "list")
  )
}

#' @name oc_bbox
#' @export
oc_bbox.data.frame <- function(data, xmin, ymin, xmax, ymax, ...) { # nolint - see lintr issue #223
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
oc_bbox.bbox <- function(bbox, ...) { # nolint - see lintr issue #223
  # check coordinate reference system (and be lenient if NA_crs_)
  crs <- attr(bbox, "crs")[["epsg"]]
  if (!is.na(crs) && crs != 4326L) {
    stop(
      call. = FALSE,
      "The coordinate reference system of `bbox` must be EPSG 4326."
    )
  }
  oc_check_bbox(bbox[[1]], bbox[[2]], bbox[[3]], bbox[[4]])
  structure(
    list(bbox),
    class = c("bbox_list", "list")
  )
}

#' @export
print.bbox_list <- function(x, ...) {
  print(purrr::map(x, ~ structure(., crs = NULL, class = NULL)))
}

# check bbox
oc_check_bbox <- function(xmin, ymin, xmax, ymax) {
  bnds <- c(xmin, ymin, xmax, ymax)
  if (anyNA(bnds)) {
    stop("Every `bbox` element must be non-missing.", call. = FALSE)
  }
  if (!all(is.numeric(bnds))) {
    stop("Every `bbox` must be a numeric vector.", call. = FALSE)
  }
  if (!dplyr::between(xmin, -180, 180)) {
    stop("Every `xmin` must be between -180 and 180.", call. = FALSE)
  }
  if (!dplyr::between(ymin, -90, 90)) {
    stop("Every `ymin` must be between -90 and 90.", call. = FALSE)
  }
  if (!dplyr::between(xmax, -180, 180)) {
    stop("Every `xmax` must be between -180 and 180.", call. = FALSE)
  }
  if (!dplyr::between(ymax, -90, 90)) {
    stop("Every `ymax` must be between -90 and 90.", call. = FALSE)
  }
  if (xmin > xmax) {
    stop("`xmin` must always be smaller than `xmax`", call. = FALSE)
  }
  if (ymin > ymax) {
    stop("`ymin` must always be smaller than `ymax`", call. = FALSE)
  }
}
