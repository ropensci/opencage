#' @export
oc_forward <-
  function(placename,
           output = c("df_list", "json_list", "geojson_list", "url_only"),
           key = oc_key(),
           bounds = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 10L,
           min_confidence = NULL,
           no_annotations = TRUE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           add_request = FALSE,
           ...) {

    # check output
    output <- match.arg(output)

    # check arguments
    oc_check_query(
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
    # process request
    oc_process(
      placename = placename,
      output = output,
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
  }

oc_process <-
  function(
    placename = NULL,
    latitude = NULL,
    longitude = NULL,
    key = oc_key(),
    output = "url_only",
    bounds = NULL,
    countrycode = NULL,
    language = NULL,
    limit = 1L,
    min_confidence = NULL,
    no_annotations = TRUE,
    no_dedupe = FALSE,
    no_record = FALSE,
    abbrv = FALSE,
    add_request = FALSE
    ) {
    if (length(placename) > 1) {
      pb <- oc_init_progress(placename) # nolint
    } else if (length(latitude) > 1) {
      pb <- oc_init_progress(latitude)
    } else {
      pb <- NULL
    }
    arglist <-
      purrr::compact(
        list(
          placename = placename,
          latitude = latitude,
          longitude = longitude,
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
      )
    purrr::pmap(.l = arglist,
                .f = .oc_process,
                output = output,
                key = key,
                pb = pb)
  }

.oc_process <-
      function(placename = NULL,
               latitude = NULL,
               longitude = NULL,
               key = oc_key(),
               output = "url_only",
               bounds = NULL,
               countrycode = NULL,
               language = NULL,
               limit = 1L,
               min_confidence = NULL,
               no_annotations = TRUE,
               no_dedupe = FALSE,
               no_record = FALSE,
               abbrv = FALSE,
               add_request = FALSE,
               pb = NULL) {

    if (!is.null(pb))  pb$tick()

    # define endpoint
    if (output == "geojson_list") {
      endpoint <- "geojson"
    } else {
      endpoint <- "json"
    }

    # convert NA's to NULL to not return bogus results
    if (!is.null(placename) && is.na(placename)) placename <- NULL

    if (!is.null(placename)) query <- placename
    if (!is.null(latitude)) query <- paste(latitude, longitude, sep = ",")

    # build url
    oc_url <- oc_build_url(
      query_par = list(
        q = query,
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
      if (interactive() || is_testing()) {
        return(oc_url)
      } else {
        stop("'url_only' reveals your opencage key. \n
             It is therefore only available in interactive mode.")
      }
    }

    # get result
    res <- oc_get_memoise(oc_url)

    # check message
    oc_check_status(res)

    # done!
    oc_parse(req = res, output = output, query = query)
  }

#' @export
oc_forward_df <-
  function(data,
           placename,
           bind_cols = TRUE,
           output = c("short", "all"),
           key = oc_key(),
           bounds = NULL,
           countrycode = NULL,
           language = NULL,
           limit = 1L,
           min_confidence = NULL,
           no_annotations = TRUE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           ...) {

    placename <- data[[deparse(substitute(placename))]]

    countrycode <- eval(substitute(alist(countrycode)))[[1]]
    if (is.symbol(countrycode)) {
      countrycode <- data[[deparse(countrycode)]]
    } else if (is.call(countrycode)) {
      countrycode <- eval(countrycode)
    }
    if (!is.null(countrycode)) countrycode <- as.list(countrycode)

    language <- eval(substitute(alist(language)))[[1]]
    if (is.symbol(language)) {
      language <- data[[deparse(language)]]
    } else if (is.call(language)) {
      language <- eval(language)
    }
    if (!is.null(language)) language <- as.list(language)

    limit <- eval(substitute(alist(limit)))[[1]]
    if (is.symbol(limit)) {
      limit <- data[[deparse(limit)]]
    } else if (is.call(limit)) {
      limit <- eval(limit)
    }
    if (!is.null(language)) limit <- as.list(limit)

    min_confidence <- eval(substitute(alist(min_confidence)))[[1]]
    if (is.symbol(min_confidence)) {
      min_confidence <- data[[deparse(min_confidence)]]
    } else if (is.call(min_confidence)) {
      min_confidence <- eval(min_confidence)
    }
    if (!is.null(min_confidence)) min_confidence <- as.list(min_confidence)

    no_annotations <- eval(substitute(alist(no_annotations)))[[1]]
    if (is.symbol(no_annotations)) {
      no_annotations <- data[[deparse(no_annotations)]]
    } else if (is.call(no_annotations)) {
      no_annotations <- eval(no_annotations)
    }
    if (!is.null(no_annotations)) no_annotations <- as.list(no_annotations)

    no_dedupe <- eval(substitute(alist(no_dedupe)))[[1]]
    if (is.symbol(no_dedupe)) {
      no_dedupe <- data[[deparse(no_dedupe)]]
    } else if (is.call(no_dedupe)) {
      no_dedupe <- eval(no_dedupe)
    }
    if (!is.null(no_dedupe)) no_dedupe <- as.list(no_dedupe)

    abbrev <- eval(substitute(alist(abbrev)))[[1]]
    if (is.symbol(abbrev)) {
      abbrev <- data[[deparse(abbrev)]]
    } else if (is.call(abbrev)) {
      abbrev <- eval(abbrev)
    }
    if (!is.null(abbrev)) abbrev <- as.list(abbrev)

    output <- match.arg(output)

    # Ensure that query column always exists
    add_request <- TRUE

    if (output == "short") {
      no_annotations <- TRUE
    }

    if (bind_cols == FALSE) {
      results_list <- oc_forward(
        placename = placename,
        key = key,
        output = "df_list",
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
      results <- dplyr::bind_rows(results_list)
      if (output == "short") {
        results <-
          dplyr::select(results, query, lat, lng, formatted)
      } else {
        results <-
          dplyr::select(results, query, lat, lng, dplyr::everything())
      }
    } else {
      results_nest <-
        dplyr::mutate(
          data,
          op =
            oc_forward(
              placename = placename,
              key = key,
              output = "df_list",
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
        )

      results <- tidyr::unnest(results_nest, op) # nolint
      # `op` is necessary, so that other list columns are not unnested
      # but lintr complains about `op` not being defined

      if (output == "short") {
        results <-
          dplyr::select(
            results,
            1:query,
            lat,
            lng,
            formatted,
            -query
          )
      } else {
        results <-
          dplyr::select(
            results,
            1:query,
            lat,
            lng,
            dplyr::everything(),
            -query
          )
      }
    }
    results
  }

#' Forward geocoding
#'
#' Forward geocoding, from placename to latitude and longitude tuplet(s).
#'
#' @inheritParams oc_check_query
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
           limit = 10L,
           min_confidence = NULL,
           no_annotations = FALSE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           add_request = TRUE) {
    if (length(placename) > 1) {
      stop(call. = FALSE,
           "`opencage_forward` is not vectorised, use `oc_forward` instead.")
    }
    lst <- oc_forward(
      placename = placename,
      key = key,
      output = c("json_list"),
      bounds = list(bounds),
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
    lst <- lst[[1]]
    opencage_format(lst)
  }
