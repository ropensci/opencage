#' Configure settings
#'
#' Configure session settings for \pkg{opencage}.
#'
#' @param key Your OpenCage API key as a character vector of length one. Do not
#'   pass the key directly as a parameter, though. See details.
#' @param rate_sec Numeric vector of length one. Sets the maximum number of
#'   requests sent to the OpenCage API per second. Defaults to the value set in
#'   the \code{oc_rate_sec} option, or, in case that does not exist, to 1L.
#' @param ... Ignored.
#'
#' @section Set your OpenCage API key:
#'
#' \pkg{opencage} uses the environment variable \code{OPENCAGE_KEY} internally
#' to retrieve your OpenCage key. \code{\link{oc_config}} will help to set that
#' environment variable. Do not pass the key directly as a parameter to the
#' function, though, as you risk exposing it via your skript or your history.
#' There are three safer ways to set your API key instead:
#'
# nolint start - link longer than 80 chars
#' 1. Save your API key as an environment variable in
#' \code{\link[base:Startup]{.Renviron}} as described in
#' \href{https://rstats.wtf/r-startup.html#renviron}{What They Forgot to Teach
#' You About R} or
#' \href{https://csgillespie.github.io/efficientR/set-up.html#renviron}{Efficient
#' R Programming}. From there it will be fetched by all functions that call the
#' OpenCage API, so you do not even have to call \code{oc_config} to set your
#' key, but can start geocoding right away. If you have the \pkg{usethis}
#' package installed, you can edit your \code{\link[base:Startup]{.Renviron}}
#' most easily with \code{usethis::edit_r_environ()}.
# nolint end
#'
#' 2. If you use a package like \pkg{keyring} to store your credentials, you can
#' safely pass your key in a script with a function call like this
#' \code{oc_config(key = keyring::key_get("opencage"))}.
#'
#' 3. If you call \code{oc_config} in an \code{\link[base]{interactive}} session and the
#' \code{OPENCAGE_KEY} environment variable is not set, it will prompt you to
#' enter the key in the console.
#'
#' @section Set your OpenCage API rate limit:
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
        "See <https://opencagedata.com/api#forward> and help(oc_config)\n",
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

    # set no_record
    options("oc_no_record" = no_record)
  }
