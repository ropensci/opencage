# status check
oc_check <- function(req) {
  if (req$status_code < 400) return(invisible())
  message <- code_message$message[code_message$code == req$status_code]
  stop("HTTP failure: ", req$status_code, "\n", message, call. = FALSE)
}

#' @importFrom httr content
#' @importFrom jsonlite fromJSON
# function for parsing the response
oc_parse <- function(req) {
  text <- httr::content(req, as = "text")
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

# base URL for all queries
oc_url <- function() {
  "https://api.opencagedata.com/geocode/v1/json/"
}

# set user agent
#' @importFrom httr user_agent
oc_user_agent <- function() {
  httr::user_agent("http://github.com/ropensci/opencage")
}

# get results
#' @importFrom purrr compact
#' @importFrom httr GET
.oc_get <- function(query_par, usr_agnt) {
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
  httr::GET(
    url = oc_url(),
    config = oc_user_agent(),
    query = query_par
  )
}

#' @importFrom memoise memoise
oc_get <- memoise::memoise(.oc_get)


# format to "old" style (version <= 0.1.4)
# for opencage_forward, opencage_reverse
#' @importFrom dplyr bind_rows tbl_df
opencage_format <- function(lst){
  no_results <- lst$total_results
  if (no_results > 0) {
    results <- lapply(lst$results, unlist)
    results <- lapply(results, as.data.frame)
    results <- lapply(results, t)
    results <- lapply(results, as.data.frame)
    results <- suppressWarnings(dplyr::bind_rows(results))
    results$"geometry.lat" <- as.numeric(
      as.character(results$"geometry.lat")
    )
    results$"geometry.lng" <- as.numeric(
      as.character(results$"geometry.lng")
    )

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
