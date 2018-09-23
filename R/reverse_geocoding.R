#' @export
oc_reverse <-
  function(latitude,
           longitude,
           output = c("df_list", "json_list", "geojson_list", "url_only"),
           key = oc_key(),
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
      latitude = latitude,
      longitude = longitude,
      key = key,
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
      latitude = latitude,
      longitude = longitude,
      output = output,
      key = key,
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
#' @export
oc_reverse_df <-
  function(data,
           latitude,
           longitude,
           bind_cols = TRUE,
           output = c("short", "all"),
           key = oc_key(),
           language = NULL,
           limit = 1L,
           min_confidence = NULL,
           no_annotations = TRUE,
           no_dedupe = FALSE,
           no_record = FALSE,
           abbrv = FALSE,
           ...) {
    latitude <- data[[substitute(latitude)]]
    longitude <- data[[substitute(longitude)]]

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
      results_list <- oc_reverse(
        latitude = latitude,
        longitude = longitude,
        key = key,
        output = "df_list",
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
          dplyr::select(results, query, formatted)
      } else {
        results <-
          dplyr::select(results, query, dplyr::everything())
      }
    } else {
      results_nest <-
        dplyr::mutate(
          data,
          op =
            oc_reverse(
              latitude = latitude,
              longitude = longitude,
              key = key,
              output = "df_list",
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
#' @param bounds Bounding box, ignored for reverse geocoding.
#' @param countrycode Country code, ignored for reverse geocoding.
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
