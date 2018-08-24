#' @export
oc_reverse <-
  function(latitude,
           longitude,
           output = c("df_list", "json_list", "geojson_list", "url_only"),
           key = oc_key(),
           countrycode = NULL,
           language = NULL,
           limit = 10L,
           min_confidence = NULL,
           no_annotations = TRUE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           add_request = FALSE) {

    # check output
    output <- match.arg(output)

    # check arguments
    oc_check_query(
      latitude = latitude,
      longitude = longitude,
      key = key,
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

    # define endpoint
    if (output == "geojson_list") {
      endpoint <- "geojson"
    } else {
      endpoint <- "json"
    }

    # build url
    oc_url <- oc_build_url(
      query_par =
        list(
          q = paste(latitude, longitude, sep = ","),
          key = key,
          bounds = bounds,
          countrycode = countrycode,
          language = language,
          limit = limit,
          min_confidence = min_confidence,
          no_annotations = as.integer(no_annotations),
          no_dedupe = as.integer(no_dedupe),
          no_record = as.integer(no_record),
          abbrv = as.integer(abbrv),
          add_request = as.integer(add_request)
        ),
      endpoint = endpoint
    )

    if (output == "url_only") return(oc_url)

    # get result
    res <- oc_get_memoise(oc_url)

    # check message
    oc_check(res)

    # done!
    oc_parse(res, output, query = paste(latitude, longitude, sep = ", "))
  }

#' @export
oc_reverse_df <-
  function(data,
             latitude,
             longitude,
             bind_cols = TRUE,
             output = c("short", "all"),
             key = oc_key(),
             bounds = NULL,
             countrycode = NULL,
             language = NULL,
             limit = 1,
             min_confidence = NULL,
             no_annotations = FALSE,
             no_dedupe = FALSE,
             no_record = FALSE,
             abbrv = FALSE) {
    latitude <- data[[substitute(latitude)]]
    longitude <- data[[substitute(longitude)]]
    output <- match.arg(output)
    add_request <- TRUE # Ensure that query column always exists
    if (output == "short") {
      no_annotations <- TRUE
    }

    if (bind_cols == FALSE) {
      results_list <- oc_reverse(
        latitude = latitude,
        longitude = longitude,
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
        results <- dplyr::select(results, query, formatted) # nolint
      } else {
        results <- dplyr::select(results, query, dplyr::everything()) # nolint
      }
    } else {
      results_nest <-
        dplyr::mutate(
          data,
          op = oc_reverse(
            latitude = latitude,
            longitude = longitude,
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
      }

    results <- tidyr::unnest(results_nest, op) # nolint
    # `op` is necessary, so that other list columns are not unnested
    # but lintr complains about `op` not being defined

    if (output == "short") {
      results <-
        dplyr::select(results, 1:query, formatted, -query)
    } else {
      results <-
        dplyr::select(results, 1:query, dplyr::everything(), -query)
    }
    results
  }

#' Reverse geocoding
#'
#' Reverse geocoding, from latitude and longitude to placename(s).
#'
#' @param latitude Latitude.
#' @param longitude Longitude.
#' @param key Your OpenCage key.
#' @inheritParams oc_check_query
#'
#' @inherit opencage_forward return details
#'
#' @export
#'
#' @examples
#' \dontrun{
#' opencage_reverse(latitude = 0, longitude = 0,
#' limit = 2)
#' }
opencage_reverse <-
  function(latitude,
           longitude,
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
    if (length(latitude) > 1) {
      stop(call. = FALSE,
           "`opencage_reverse` is not vectorised, use `oc_reverse` instead.")
      }
    lst <- oc_reverse(
      latitude = latitude,
      longitude = longitude,
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
    lst <- lst[[1]]
    opencage_format(lst)
  }
