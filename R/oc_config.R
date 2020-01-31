#' Configure settings
#'
#' Configure session settings for \pkg{opencage}.
#'
#' @param key Your OpenCage API key as a character vector of length one. Do not
#'   pass the key directly as a parameter, though. See details.
#' @param rate_sec Numeric vector of length one. Sets the maximum number of
#'   requests sent to the OpenCage API per second. Defaults to the value set in
#'   the `oc_rate_sec` option, or, in case that does not exist, to 1L.
#' @param no_record Logical vector of length one. When `TRUE` OpenCage will not
#'   create log entries of the queries and will not cache the geocoding
#'   requests. Defaults to the value set in the `oc_no_record` option, or, in
#'   case that does not exist, to FALSE.
#' @param ... Ignored.
#'
#' @section Set your OpenCage API key:
#'
#' \pkg{opencage} uses the environment variable `OPENCAGE_KEY` internally to
#' retrieve your OpenCage key. [oc_config()] will help to set that environment
#' variable. Do not pass the key directly as a parameter to the function,
#' though, as you risk exposing it via your script or your history. There are
#' three safer ways to set your API key instead:
#'
#' 1. Save your API key as an environment variable in
#' [`.Renviron()`][base::Startup] as described in [What They Forgot to Teach You
#' About R](https://rstats.wtf/r-startup.html#renviron) or [Efficient R
#' Programming](https://csgillespie.github.io/efficientR/set-up.html#renviron).
#' From there it will be fetched by all functions that call the OpenCage API, so
#' you do not even have to call `oc_config` to set your key, but can start
#' geocoding right away. If you have the \pkg{usethis} package installed, you
#' can edit your [`.Renviron()`][base::Startup] most easily with
#' `usethis::edit_r_environ()`. We strongly recommend storing your API key in
#' the user-level .Renviron, as opposed to the project-level, because this makes
#' it less likely you will share sensitive information by mistake.
#'
#' 2. If you use a package like \pkg{keyring} to store your credentials, you can
#' safely pass your key in a script with a function call like this
#' `oc_config(key = keyring::key_get("opencage"))`.
#'
#' 3. If you call `oc_config` in an [base::interactive()] session and the
#' `OPENCAGE_KEY` environment variable is not set, it will prompt you to enter
#' the key in the console.
#'
#' @section Set your OpenCage API rate limit:
#'
#' The rate limit allowed by the API depends on the OpenCage plan you purchased
#' and ranges from 1 request/sec for the "Free Trial" plan to 15 requests/sec
#' for the "Medium" or "Large" plans, see <https://opencagedata.com/pricing> for
#' details and up-to-date information. You can set the rate limit persistently
#' across sessions by setting the `oc_rate_sec` [option][base::options] in your
#' [`.Rprofile()`][base::Startup]. If you have the `usethis` package installed,
#' you can edit your [`.Rprofile()`][base::Startup] most easily with
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
#' query you made. Please set `no_record` to `TRUE` if you have concerns about
#' privacy and want OpenCage to have no record of your query.
#'
#' `oc_config` sets the `oc_no_record` [option][base::options] for the active R
#' session, so it will be used for all subsequent OpenCage queries. You can set
#' the `oc_no_record` [option][base::options] persistently across sessions in
#' your [`.Rprofile()`][base::Startup].
#'
#' Please note that the \pkg{opencage} package always caches the data it
#' receives from the OpenCage API, but only for as long as your R session is
#' alive.
#'
# nolint start - link longer than 80 chars
#' For more information on OpenCage's policies on privacy and data protection
#' see [their FAQs](https://opencagedata.com/faq#legal), their [GDPR
#' page](https://opencagedata.com/gdpr), and, for the `no_record` parameter, see
#' the relevant [blog
#' post](https://blog.opencagedata.com/post/145602604628/more-privacy-with-norecord-parameter).
# nolint end
#'
#' @export
oc_config <-
  function(
    key = Sys.getenv("OPENCAGE_KEY"),
    rate_sec = getOption("oc_rate_sec", default = 1L),
    no_record = getOption("oc_no_record", default = FALSE),
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
    oc_check_logical(no_record, check_length_one = TRUE)
    options("oc_no_record" = no_record)
  }
