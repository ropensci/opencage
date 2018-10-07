#' Set default options
#'
#' @param max_rate_per_sec maximum number of requests per second
#' @param ... not used
#'
#' @export
oc_config <-
  function(
    max_rate_per_sec =
      getOption("oc_max_rate_per_sec", default = 1L),
    ...
  ) {
  ratelimitr::UPDATE_RATE(
    oc_get_limited,
    ratelimitr::rate(n = max_rate_per_sec, period = 1L)
  )
}
