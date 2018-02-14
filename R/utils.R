# status check
oc_check <- function(req) {
  if (req$status_code < 400) return(invisible())
  message <- code_message$message[code_message$code == req$status_code]
  stop("HTTP failure: ", req$status_code, "\n", message, call. = FALSE)
}

# function for parsing the response
oc_parse <- function(req) {
  text <- req$parse()
  if (identical(text, "")) {
    stop(
      "No output to parse",
      call. = FALSE
    )
  }
  jsn <- jsonlite::fromJSON(
    text,
    flatten = TRUE
  )
  jsn[["url"]] <- req[["url"]]
  jsn
}

# Get data frame of results
oc_parse_df <- function(jsn) {
  results_df <- jsn[["results"]]
  # Make column names nicer
  colnames(results_df) <- sub("annotations\\.", "", colnames(results_df))
  colnames(results_df) <- sub("bounds\\.", "", colnames(results_df))
  colnames(results_df) <- sub("components\\.", "", colnames(results_df))
  colnames(results_df) <- sub("geometry.", "", colnames(results_df))

  dplyr::select(results_df, lat, lng, dplyr::everything())
}

# base URL for all queries
oc_url <- function() {
  "https://api.opencagedata.com/geocode/v1/json/"
}


# get results
.oc_get <- function(query_par) {
  query_par <- purrr::compact(query_par) # nolint
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
  client <- crul::HttpClient$new(url = oc_url(),
                                 headers = list(`User-Agent` = "opencage-R"))
  client$get(query = query_par)
}

oc_get <- memoise::memoise(.oc_get)


# format to "old" style (version <= 0.1.4)
# for opencage_forward, opencage_reverse
opencage_format <- function(lst){
  no_results <- lst$total_results
  if (no_results > 0) {
    results <- lst[["results"]]

    # if requests exists in the api response add the query to results
    if ("request" %in% names(lst)) {
      results$query <- lst$request$query
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
