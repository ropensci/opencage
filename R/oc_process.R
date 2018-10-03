
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
          abbrv = abbrv,
          add_request = add_request
        )
      )

    # prevent obscure warning message from pwalk if length(arglist) == 0
    stopifnot(length(arglist) >= 1)

    purrr::pmap(.l = arglist,
                .f = .oc_process,
                output = output,
                key = key,
                no_record = no_record,
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
