#' Configure settings
#'
#' Configures session settings for \pkg{opencage}.
#'
#' @param key Your OpenCage API key as a character vector of length one. Do not
#'   enter the key directly, though. See details.
#' @param rate_sec \code{numeric(1)} Sets the maximum number of requests sent to
#'   the OpenCage API per second. Defaults to the value set in the
#'   \code{oc_rate_sec} option, or, in case that does not exist, to 1.
#' @param ... Ignored.
#'
#' @section Configure your OpenCage API key:
#'
#' opencage uses the environment variable \code{OPENCAGE_KEY} internally to
#' retrieve your OpenCage key. \code{\link{oc_config}} will help to set that
#' environment variable. Do not set the key directly, though, as you risk
#' exposing the key via your skript or your history. Instead, if set to
#' \code{NULL}, the default, \code{\link{oc_config}} will check if the
#' environment variable \code{OPENCAGE_KEY} is already set, and prompt you to
#' enter the key in the console if it is not.
#'
#' If you use a package like keyring, you can safely set your key in a script
#' like this \code{oc_config(key = keyring::key_get("opencage"))}.
#'
#' Finally you can save your API key directly as an environment variable in
#' `.Renviron` as described in
#' \href{https://happygitwithr.com/github-pat.html#step-by-step}{Happy Git and
#' GitHub for the useR} or
#' \href{https://csgillespie.github.io/efficientR/set-up.html#renviron}{Efficient
#' R Programming} and skip \code{oc_config} for setting your API key altogether.
#'
#' @section Configure your OpenCage API rate limit:
#'
#' The rate limit allowed by the API depends on the OpenCage plan you
#' purchased and ranges from 1 request/sec for the "Free Trial" plan to 15
#' requests/sec for the "Medium" or "Large" plans, see
#' \url{https://opencagedata.com/pricing} for details and up-to-date
#' information. You can set the rate limit persistently across sessions by
#' setting the \code{oc_rate_sec} \link[base:options]{option} in your
#' \code{\link[base:Startup]{.Rprofile}}. If you have the \code{usethis}
#' package installed, you can edit your \code{\link[base:Startup]{.Rprofile}}
#' most easily with \code{usethis::edit_r_profile()}.
#'
#' @export
oc_config <-
  function(
    key = Sys.getenv("OPENCAGE_KEY"),
    rate_sec = getOption("oc_rate_sec", default = 1L),
    ...) {

    key_needed <-
      c(
        "Using the OpenCage Geocoder requires a valid API key.\n",
        "See <https://opencagedata.com/api#forward>\n",
        "\n"
      )

    if (!identical(key, "")) {
      pat <- key
    } else if (!interactive()) {
      stop(
        key_needed,
        "Please set the environment variable OPENCAGE_KEY to your OpenCage API key.", # nolint
        call. = FALSE
      )
    } else {
      message(key_needed, "Please enter your OpenCage API key and press enter:")
      pat <- readline(": ")
    }

    oc_check_key(pat)

    Sys.setenv(OPENCAGE_KEY = pat)

    # set rate limit
    ratelimitr::UPDATE_RATE(
      oc_get_limited,
      ratelimitr::rate(n = rate_sec, period = 1L)
    )
  }
