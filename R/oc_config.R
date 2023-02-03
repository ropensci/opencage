#' Configure settings
#'
#' Configure session settings for \pkg{opencage}.
#'
#' @param key Your OpenCage API key as a character vector of length one. Do not
#'   pass the key directly as a parameter, though. See details.
#' @param rate_sec Numeric vector of length one. Sets the maximum number of
#'   requests sent to the OpenCage API per second. Defaults to the value set in
#'   the `oc_rate_sec` option, or, in case that does not exist, to 1L.
#' @param no_record Logical vector of length one. When `TRUE`, OpenCage will not
#'   create log entries of the queries and will not cache the geocoding
#'   requests. Defaults to the value set in the `oc_no_record` option, or, in
#'   case that does not exist, to `TRUE`.
#' @param show_key Logical vector of length one. This is only relevant when
#'   debugging `oc_forward()` or `oc_reverse()` calls with the `return =
#'   "url_only"` argument. When `TRUE`, the result will show your OpenCage API
#'   key in the URL as stored in the `OPENCAGE_KEY` environment variable. When
#'   not `TRUE`, the API key will be replaced with the string `OPENCAGE_KEY`.
#'   `show_key` defaults to the value set in the `oc_show_key` option, or, in
#'   case that does not exist, to `FALSE`.
#' @param ... Ignored.
#'
#' @section Set your OpenCage API key:
#'
#' \pkg{opencage} will conveniently retrieve your API key if it is saved in the
#' environment variable `"OPENCAGE_KEY"`. [oc_config()] will help to set that
#' environment variable. Do not pass the key directly as a parameter to the
#' function, though, as you risk exposing it via your script or your history.
#' There are three safer ways to set your API key instead:
#'
#' 1. Save your API key as an environment variable in
#' [`.Renviron`][base::Startup] as described in [What They Forgot to Teach You
#' About R](https://rstats.wtf/r-startup.html#renviron) or [Efficient R
#' Programming](https://csgillespie.github.io/efficientR/set-up.html#renviron).
#' From there it will be fetched by all functions that call the OpenCage API.
#' You do not even have to call `oc_config()` to set your key; you can start
#' geocoding right away. If you have the \pkg{usethis} package installed, you
#' can edit your [`.Renviron`][base::Startup] with `usethis::edit_r_environ()`.
#' We strongly recommend storing your API key in the user-level .Renviron, as
#' opposed to the project-level. This makes it less likely you will share
#' sensitive information by mistake.
#'
#' 2. If you use a package like \pkg{keyring} to store your credentials, you can
#' safely pass your key in a script with a function call like this
#' `oc_config(key = keyring::key_get("opencage"))`.
#'
#' 3. If you call `oc_config()` in an [base::interactive()] session and the
#' `OPENCAGE_KEY` environment variable is not set, it will prompt you to enter
#' the key in the console.
#'
#' @section Set your OpenCage API rate limit:
#'
#' The rate limit allowed by the API depends on the OpenCage plan you purchased
#' and ranges from 1 request/sec for the "Free Trial" plan to 15 requests/sec
#' for the "Medium" or "Large" plans, see <https://opencagedata.com/pricing> for
#' details and up-to-date information. You can set the rate limit persistently
#' across sessions by setting an `oc_rate_sec` [option][base::options] in your
#' [`.Rprofile`][base::Startup]. If you have the \pkg{usethis} package
#' installed, you can edit your [`.Rprofile`][base::Startup] with
#' `usethis::edit_r_profile()`.
#'
#' @section Prevent query logging and caching:
#'
#' By default, OpenCage will store your queries in its server logs and will
#' cache the forward geocoding requests on their side. They do this in order to
#' speed up response times and to be able to debug errors and improve their
#' service. Logs are automatically deleted after six months according to
#' OpenCage's [page on data protection and GDPR](https://opencagedata.com/gdpr).
#'
#' If you set `no_record` to `TRUE`, the query contents are not logged nor
#' cached. OpenCage still records that you made a request, but not the specific
#' query you made. `oc_config(no_record = TRUE)` sets the `oc_no_record`
#' [option][base::options] for the active R session, so it will be used for all
#' subsequent OpenCage queries. You can set the `oc_no_record`
#' [option][base::options] persistently across sessions in your
#' [`.Rprofile`][base::Startup].
#'
#' For increased privacy \pkg{opencage} sets `no_record` to `TRUE`, by default.
#' Please note, however, that \pkg{opencage} always caches the data it receives
#' from the OpenCage API locally, but only for as long as your R session is
#' alive.
#'
# nolint start: line_length_linter.
#' For more information on OpenCage's policies on privacy and data protection
#' see [their FAQs](https://opencagedata.com/faq#legal), their [GDPR
#' page](https://opencagedata.com/gdpr), and, for the `no_record` parameter, see
#' the relevant [blog
#' post](https://blog.opencagedata.com/post/145602604628/more-privacy-with-norecord-parameter).
# nolint end
#'
#' @export
oc_config <-
  function(key = Sys.getenv("OPENCAGE_KEY"),
           no_record = getOption("oc_no_record", default = TRUE),
           show_key = getOption("oc_show_key", default = FALSE),
           ...) {
    key_needed <-
      c(
        "Using the OpenCage Geocoder requires a valid API key.\n",
        "See <https://opencagedata.com/api#forward> and help(oc_config)\n",
        "\n"
      )

    if (!identical(key, "")) {
      pat <- key
    } else if (!rlang::is_interactive()) {
      stop(
        key_needed,
        "Please set the environment variable OPENCAGE_KEY to your OpenCage API key.", # nolint: line_length_linter.
        call. = FALSE
      )
    } else {
      message(key_needed, "Please enter your OpenCage API key and press enter:")
      pat <- readline(": ")
    }

    oc_check_key(pat)

    Sys.setenv(OPENCAGE_KEY = pat)

    # set no_record
    oc_check_logical(no_record, check_length_one = TRUE)
    options("oc_no_record" = no_record)

    # set show_key
    options("oc_show_key" = show_key)
  }
