#' Configure settings
#'
#' Configures settings for the opencage package.
#'
#' @param rate_sec \code{numeric(1)} Sets the maximum number of requests sent to
#'   the OpenCage API per second. Defaults to the value set in the
#'   \code{oc_rate_sec} option, or, in case that does not exist, to 1.
#' @param ... Not used.
#'
#' @details The rate limit allowed by the API depends on the OpenCage plan you
#'   purchased and ranges from 1 request/sec for the "Free Trial" plan to 15
#'   requests/sec for the "Medium" or "Large plan, see
#'   \url{https://opencagedata.com/pricing} for details. You can set the rate
#'   limit persistently across sessions by setting the \code{oc_rate_sec}
#'   \code{\link[base:options]{option}} in your \code{\link[base]{.Rprofile}}.
#'
#' @export
oc_config <-
  function(
    rate_sec =
      getOption("oc_rate_sec", default = 1L),
    ...
  ) {
  ratelimitr::UPDATE_RATE(
    oc_get_limited,
    ratelimitr::rate(n = rate_sec, period = 1L)
  )
}
