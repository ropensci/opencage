#' Forward geocoding
#'
#' Forward geocoding, from placename to latitude and longitude tuplet(s).
#'
#' @inheritParams oc_process
#' @inherit oc_process details return seealso
#' @export
#'
#' @examples
#' \dontrun{
#' oc_forward(placename = "Sarzeau")
#' oc_forward(placename = "Islington, London")
#' oc_forward(placename = "Triererstr 15,
#'                         Weimar 99423,
#'                         Deutschland")
#' }
#'
oc_forward <-
  function(placename,
           return = c("df_list", "json_list", "geojson_list", "url_only"),
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

    # check a placename is provided
    if (missing(placename) || is.null(placename)) {
      stop(call. = FALSE, "You must provide a `placename`.")
    }

    # check return
    return <- match.arg(return)

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
      return = return,
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

#' @rdname oc_forward
#' @param data A data frame
#' @param bind_cols logical Bind source and results data frame?
#' @param output A character vector of length one indicating whether only
#'   latitude, longitude and formatted address (\code{short}) or whether all
#'   results (\code{all}) should be returned.
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
        return = "df_list",
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
              return = "df_list",
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
