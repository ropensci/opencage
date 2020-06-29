# status check
oc_check_status <- function(res_env, res_text) {
  if (res_env$success()) return(invisible())
  message <-
    jsonlite::fromJSON(
      res_text,
      simplifyVector = TRUE,
      flatten = TRUE
    )$status$message
  stop("HTTP failure: ", res_env$status_code, "\n", message, call. = FALSE)
}

# function for parsing the response
oc_parse_text <- function(res) {
  text <- res$parse(encoding = "UTF-8")
  if (identical(text, "")) {
    stop("OpenCage returned an empty response.", call. = FALSE)
  }
  text
}

oc_format <- function(res_text, return, query) {
  if (return == "tibble") {
    jsn <- jsonlite::fromJSON(res_text, simplifyVector = TRUE, flatten = TRUE)
    if (identical(jsn$total_results, 0L)) {
      results <- tibble::tibble(oc_formatted = NA_character_)
    } else {
      results <- tibble::as_tibble(jsn$results)
      # Make column names nicer
      colnames(results) <-
        sub(
          "^annotations\\.|^bounds\\.|^components\\.|^geometry\\.",
          "",
          colnames(results)
        )
      colnames(results) <- sub("^_", "", colnames(results)) # components:_type
      colnames(results) <- gsub("\\.|-", "_", colnames(results))
      results <-
        rlang::set_names(results, ~ tolower(paste0("oc_", .)))
    }

    if (identical(query, "")) query <- NA_character_
    tibble::add_column(results, oc_query = query, .after = 0)

  } else if (return == "json_list" || return == "geojson_list") {
    jsn <- jsonlite::fromJSON(res_text, simplifyVector = FALSE)
    if (return == "geojson_list") {
      structure(jsn, class = c("geo_list"))
    } else {
      jsn
    }
  }
}

# build url
oc_build_url <- function(query_par, endpoint) {
  query_par <- purrr::compact(query_par)
  query_par <- purrr::discard(query_par, .p = anyNA)

  if ("countrycode" %in% names(query_par)) {
    query_par$countrycode <-
      tolower(paste(query_par$countrycode, collapse = ","))
  }

  if (!is.null(query_par$bounds)) {
    bounds <- query_par$bounds
    query_par$bounds <- paste(
      bounds[1],
      bounds[2],
      bounds[3],
      bounds[4],
      sep = ","
    )
  }

  if (!is.null(query_par$proximity)) {
    proximity <- query_par$proximity
    query_par$proximity <- paste(
      proximity["latitude"],
      proximity["longitude"],
      sep = ","
    )
  }

  oc_path <- paste0("geocode/v1/", endpoint)

  crul::url_build(
    url = "https://api.opencagedata.com",
    path = oc_path,
    query = query_par
  )
}

# get results
oc_get <- function(oc_url) {
  client <- crul::HttpClient$new(
    url = oc_url,
    headers = list(`User-Agent` = "https://github.com/ropensci/opencage")
  )
  client$get()
}

# initialise progress bar
oc_init_progress <- function(vec) {
  progress::progress_bar$new(
    format =
      "Retrieving results from OpenCage [:spin] :percent ETA: :eta",
    total = length(vec),
    clear = FALSE,
    width = 60
  )
}
