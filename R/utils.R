# status check
oc_check_status <- function(req) {
  if (req$status_code < 400) return(invisible())
  message <- code_message$message[code_message$code == req$status_code]
  stop("HTTP failure: ", req$status_code, "\n", message, call. = FALSE)
}

# function for parsing the response
oc_parse <- function(req, output, query) {
  text <- req$parse(encoding = "UTF-8")
  if (identical(text, "")) {
    stop(
      "No output to parse",
      call. = FALSE
    )
  }
  if (output == "df_list") {
    jsn <- jsonlite::fromJSON(text, simplifyVector = TRUE, flatten = TRUE)
    if (jsn$total_results == 0) {
      results <- tibble::tibble(lat = NA_real_, lng = NA_real_, formatted = NA)
    } else {
      results <- tibble::as.tibble(jsn$results)
    }
    if ("request" %in% names(jsn)) {
      results <- tibble::add_column(results, query = query, .before = 1)
    }
    # Make column names nicer
    colnames(results) <- sub("^annotations\\.", "", colnames(results))
    colnames(results) <- sub("^bounds\\.", "", colnames(results))
    colnames(results) <- sub("^components\\.", "", colnames(results))
    colnames(results) <- sub("^geometry\\.", "", colnames(results))
    colnames(results) <- sub("^_", "", colnames(results))
    colnames(results) <- gsub("\\.", "_", colnames(results))
    colnames(results) <- gsub("-", "_", colnames(results))
    results
  } else if (output == "json_list" || output == "geojson_list") {
    jsn <- jsonlite::fromJSON(text, simplifyVector = FALSE)
    if (output == "geojson_list") {
      structure(jsn, class = c("geo_list"))
    } else {
      jsn
    }
  }
}

# build url
oc_build_url <- function(query_par, endpoint) {
  query_par <- purrr::compact(query_par) # nolint

  if ("countrycode" %in% names(query_par)){
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

# limit requests per second
oc_get_limited <-
  ratelimitr::limit_rate(
    oc_get,
    ratelimitr::rate(
      n = getOption("oc_requests_per_second", default = 1),
      period = 1
    )
  )

oc_get_memoise <- memoise::memoise(oc_get_limited)

# initialise progress bar
oc_init_progress <- function(vec){
    progress::progress_bar$new(
      format =
        "Retrieving results from OpenCage [:spin] :percent ETA: :eta",
      total = length(vec),
      clear = FALSE,
      width = 60)
}


# format to "old" style (version <= 0.1.4)
# for opencage_forward, opencage_reverse
opencage_format <- function(lst){
  no_results <- lst[["total_results"]]
  if (no_results > 0) {
    results <- lapply(lst[["results"]], unlist)
    results <- lapply(results, as.data.frame)
    results <- lapply(results, t)
    results <- lapply(results, as.data.frame, stringsAsFactors = FALSE)
    results <- suppressWarnings(dplyr::bind_rows(results))
    results$"geometry.lat" <- as.numeric(results$"geometry.lat")
    results$"geometry.lng" <- as.numeric(results$"geometry.lng")

    # if requests exists in the api response add the query to results
    if ("request" %in% names(lst)) {
      results$query <- as.character(lst$request$query)
    }
  }
  else {
    results <- NULL
  }

  if (!is.null(lst$rate)) {
    rate_info <- dplyr::tbl_df(data.frame(
      limit = lst$rate$limit,
      remaining = lst$rate$remaining,
      reset = as.POSIXct(lst$rate$reset, origin = "1970-01-01")
    ))
  } else {
    rate_info <- NULL
  }

  if (!is.null(results)) {
    results <- dplyr::tbl_df(results)
  }

  list(
    results = results,
    total_results = no_results,
    time_stamp = as.POSIXct(
      lst$timestamp$created_unix,
      origin = "1970-01-01"
    ),
    rate_info = rate_info
  )
}

#' Retrieve Opencage API key
#'
#' An Opencage API Key
#' Looks in env var \code{OPENCAGE_KEY}
#'
#' @keywords internal
#' @export
oc_key <- function(quiet = TRUE) {
  pat <- Sys.getenv("OPENCAGE_KEY")
  if (identical(pat, "")) {
    return(NULL)
  }
  if (!quiet) {
    message("Using Opencage API Key from envvar OPENCAGE_KEY")
  }
  return(pat)
}
