#' Configure settings
#'
#' Configures session settings for \pkg{opencage}.
#'
#' @param rate_sec \code{numeric(1)} Sets the maximum number of requests sent to
#'   the OpenCage API per second. Defaults to the value set in the
#'   \code{oc_rate_sec} option, or, in case that does not exist, to 1.
#' @param ... Ignored.
#'
#' @details The rate limit allowed by the API depends on the OpenCage plan you
#'   purchased and ranges from 1 request/sec for the "Free Trial" plan to 15
#'   requests/sec for the "Medium" or "Large plan, see
#'   \url{https://opencagedata.com/pricing} for details and up-to-date
#'   information. You can set the rate limit persistently across sessions by
#'   setting the \code{oc_rate_sec} \link[base:options]{option} in your
#'   \code{\link[base:Startup]{.Rprofile}}. If you have the \code{usethis}
#'   package installed, you can edit your \code{\link[base:Startup]{.Rprofile}}
#'   most easily with \code{usethis::edit_r_profile()}.
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
