#' Clear the opencage cache
#'
#' Forget past results and resets the \pkg{opencage} cache.
#'
#' @examples
#' \dontrun{
#' system.time(oc_reverse(latitude = 10, longitude = 10))
#' system.time(oc_reverse(latitude = 10, longitude = 10))
#' oc_clear_cache()
#' system.time(oc_reverse(latitude = 10, longitude = 10))
#' }
#' @export
oc_clear_cache <- function() {
  memoise::forget(oc_get_memoise)
}
