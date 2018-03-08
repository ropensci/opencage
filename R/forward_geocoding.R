#' @export
oc_forward <-
  function(placename,
           key = oc_key(),
           output = c("df_list", "json_list", "geojson_list", "url_only"),
           bounds = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 10,
           min_confidence = NULL,
           no_annotations = FALSE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           add_request = TRUE) {

    # check arguments
    oc_query_check(
      placename = placename,
      key = key,
      bounds = bounds,
      countrycode = countrycode,
      language = language,
      limit = limit,
      min_confidence = min_confidence,
      no_annotations = no_annotations,
      no_dedupe = no_dedupe,
      no_record = no_record,
      abbrv = abbrv,
      add_request = add_request
    )

    output <- match.arg(output) # move to oc_query_check?

    # vectorise
    if (length(placename) > 1) {
      pb <- oc_init_progress(placename)
      return(purrr::map(placename,
                        ~ {
                          pb$tick()
                          oc_forward(
                            placename = .x,
                            key = key,
                            output = output,
                            bounds = bounds,
                            countrycode = countrycode,
                            language = language,
                            limit = limit,
                            min_confidence = min_confidence,
                            no_annotations = no_annotations,
                            no_dedupe = no_dedupe,
                            no_record = no_record,
                            abbrv = abbrv,
                            add_request = add_request
                          )
                        })
             )
    }

    # convert NA's to NULL to not return bogus results
    if (is.na(placename)) placename <- NULL

    # define endpoint
    if (output == "geojson_list") {
      endpoint <- "geojson"
    } else {
      endpoint <- "json"
    }

    # build url
    oc_url <- oc_build_url(
      query_par = list(
        q = placename,
        bounds = bounds,
        countrycode = countrycode,
        language = language,
        limit = limit,
        min_confidence = min_confidence,
        no_annotations = as.integer(no_annotations),
        no_dedupe = as.integer(no_dedupe),
        no_record = as.integer(no_record),
        abbrv = as.integer(abbrv),
        add_request = as.integer(add_request),
        key = key
      ),
      endpoint = endpoint
    )

    if (output == "url_only") {
      if (interactive()) {
        return(oc_url)
      } else {
        stop("'url_only' reveals your opencage key. \n
             It is therefore only available in interactive mode.")
      }
    }

    # get result
    res <- oc_get_memoise(oc_url)

    # check message
    oc_check(res)

    # done!
    oc_parse(res, output)
  }

#' Forward geocoding
#'
#' Forward geocoding, from placename to latitude and longitude tuplet(s).
#'
#' @inheritParams oc_query_check
#' @param key Your OpenCage key.
#' @param placename Placename.
#' @details
#' \strong{API key}
#' To get an API key to access OpenCage geocoding,
#' register at \url{https://geocoder.opencagedata.com/pricing}.
#' The free API key provides up to 2,500 calls a day. For ease of use,
#'  save your API key as an environment variable as described at
#'   \url{https://stat545-ubc.github.io/bit003_api-key-env-var.html}.
#' Both functions of the package will conveniently look for your API key
#' using \code{Sys.getenv("OPENCAGE_KEY")} so if your API key is an environment
#'  variable called "OPENCAGE_KEY" you don't need to input it manually.
#'
#'
#' \strong{memoise}
#' The underlying data at OpenCage is updated about once a day.
#' Note that the package uses `memoise` with no timeout argument so that results
#'  are cached inside an active R session.
#'
#' This function typically returns multiple results due to placename ambiguity;
#'  consider using the \code{bounds} parameter to limit the area searched.
#'
#' @return A list with
#' \itemize{
#' \item results as a data.frame (`dplyr` `tbl_df`) called results with one line
#'  per results,
#' \item the number of results as an integer,
#' \item the timestamp as a POSIXct object,
#' \item rate_info data.frame (`dplyr` `tbl_df`) with the maximal number
#' of API calls  per day for the used key, the number of remaining calls
#' for the day and the time at which the number of remaining calls will
#'  be reset.
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' opencage_forward(placename = "Sarzeau")
#' opencage_forward(placename = "Islington, London")
#' opencage_forward(placename = "Triererstr 15,
#'                               Weimar 99423,
#'                               Deutschland")
#' }
#'
opencage_forward <-
  function(placename,
           key = oc_key(),
           bounds = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 10,
           min_confidence = NULL,
           no_annotations = FALSE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           add_request = TRUE) {
    lst <- oc_forward(
      placename = placename,
      key = key,
      output = c("json_list"),
      bounds = bounds,
      countrycode = countrycode,
      language = language,
      limit = limit,
      min_confidence = min_confidence,
      no_annotations = no_annotations,
      no_dedupe = no_dedupe,
      no_record = no_record,
      abbrv = abbrv,
      add_request = add_request
    )
    opencage_format(lst)
}
