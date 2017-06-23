# status check
opencage_check <- function(req) {
  if (req$status_code < 400) return(invisible())
  message <- code_message$message[code_message$code == req$status_code]
  stop("HTTP failure: ", req$status_code, "\n", message, call. = FALSE)
}

# function for parsing the response
opencage_parse <- function(req) {
  text <- httr::content(req, as = "text")
  if (identical(text, "")) stop("No output to parse",
                                call. = FALSE)
  temp <- jsonlite::fromJSON(text,
                             simplifyVector = FALSE)

  no_results <- temp$total_results
  if(no_results > 0){
    results <- lapply(temp$results, unlist)
    results <- lapply(results, as.data.frame)
    results <- lapply(results, t)
    results <- lapply(results, as.data.frame)
    results <- suppressWarnings(dplyr::bind_rows(results))
    results$geometry.lat <- as.numeric(
      as.character(results$geometry.lat))
    results$geometry.lng <- as.numeric(
      as.character(results$geometry.lng))

      # if requests exists in the api response add the query to results
      if("request" %in% names(temp)) {
        results$query <- as.character(temp$request$query)
      }
  }
  else{
    results <- NULL
  }

  if(!is.null(temp$rate)){
    rate_info <- dplyr::tbl_df(data.frame(
      limit = temp$rate$limit,
      remaining = temp$rate$remaining,
      reset = as.POSIXct(temp$rate$reset, origin="1970-01-01")))
  }else{
    rate_info <- NULL
  }

  if(!is.null(results)){
    results <- dplyr::tbl_df(results)
  }

  list(results = results,
       total_results = no_results,
       time_stamp = as.POSIXct(temp$timestamp$created_unix,
                               origin="1970-01-01"),
       rate_info = rate_info
       )
}

# base URL for all queries
opencage_url <- function() {
  "http://api.opencagedata.com/geocode/v1/json/"
}

# get results
opencage_get <- function(query_par){
  query_par <- Filter(Negate(is.null), query_par) # nolint
  if(!is.null(query_par$bounds)){
    bounds <- query_par$bounds
    query_par$bounds <- paste(bounds[1],
          bounds[2],
          bounds[3],
          bounds[4],
          sep = ",")
  }
  httr::GET(url = opencage_url(),
            query = query_par)
}

# function that checks the query
opencage_query_check <- function(latitude = NULL,
                                 longitude = NULL,
                                 placename = NULL,
                                 key,
                                 abbrv,
                                 bounds,
                                 countrycode,
                                 language,
                                 limit,
                                 min_confidence,
                                 no_annotations,
                                 no_dedupe,
                                 no_record,
                                 add_request){
  # check latitude
  if(!is.null(latitude)){
    if (!dplyr::between(latitude, -90, 90)){
      stop(call. = FALSE, "Latitude should be between -90 and 90.")
      }
  }

  # check longitude
  if(!is.null(longitude)){
    if (!dplyr::between(longitude, -180, 180)){
      stop(call. = FALSE, "Longitude should be between -180 and 180.")
    }
  }
  # check placename
  if(!is.null(placename)){
    if(!is.character(placename)){
      stop(call. = FALSE, "Placename should be a character.")
    }
    }

  # check key
  if(!is.null(key)){
    if(!is.character(key)){
      stop(call. = FALSE, "Key should be a character.")
    }
  }

  # check boundss
  if(!is.null(bounds)){
    if(length(bounds) != 4){
      stop(call. = FALSE, "bounds should be a vector of 4 numeric values.")
    }
    if(!dplyr::between(bounds[1], -180, 180)){
      stop(call. = FALSE, "min long should be between -180 and 180.")
    }
    if(!dplyr::between(bounds[2], -90, 90)){
      stop(call. = FALSE, "min lat should be between -90 and 90.")
    }
    if(!dplyr::between(bounds[3], -180, 180)){
      stop(call. = FALSE, "max long should be between -180 and 180.")
    }
    if(!dplyr::between(bounds[4], -90, 90)){
      stop(call. = FALSE, "max lat should be between -90 and 90.")
    }
    if(bounds[1] > bounds[3]){
      stop(call. = FALSE, "min long has to be smaller than max long")
    }
    if(bounds[2] > bounds[4]){
      stop(call. = FALSE, "min lat has to be smaller than max lat")
    }
  }

  # check countrycode
  if(!is.null(countrycode)){
    if(!(countrycode %in% countrycodes$Code)){
      stop(call. = FALSE, "countrycode does not have a valid value.")
    }
  }

  # check language
  if(!is.null(language)){
  lang <- strsplit(language, "-")[[1]]
  if(!(lang[1] %in% languagecodes$alpha2)){
    stop(call. = FALSE, "The language code is not valid.")
  }
  if(length(lang) > 1){
    if(!(lang[2] %in% countrycodes$Code)){
      stop(call. = FALSE, "The country part of language is not valid.")
    }
  }
}

  # check limit
  if(!is.null(limit)){
    if(!(limit %in% c(1:100))){
      stop(call. = FALSE, "limit should be an integer between 1 and 100.") # nolint
    }
  }

  # check min_confidence
  if(!is.null(min_confidence)){
    if(!(min_confidence %in% c(1:10))){
      stop(call. = FALSE, "min_confidence should be an integer between 1 and 10.") # nolint
    }
  }

  # check abbrv
  if(!is.null(abbrv)){
    if(!is.logical(abbrv)){
      stop(call. = FALSE, "abbrv has to be a logical.")
    }
  }
  # check no_annotations
  if(!is.null(no_annotations)){
    if(!is.logical(no_annotations)){
      stop(call. = FALSE, "no_annotations has to be a logical.")
    }
  }

  # check no_record
  if(!is.null(no_record)){
    if(!is.logical(no_record)){
      stop(call. = FALSE, "no_record has to be a logical.")
    }
  }

  # check no_dedupe
  if(!is.null(no_dedupe)){
    if(!is.logical(no_dedupe)){
      stop(call. = FALSE, "no_dedupe has to be a logical.")
    }
  }

  # check add_request
  if(!is.null(add_request)){
    if(!is.logical(add_request)){
      stop(call. = FALSE, "add_request has to be a logical.")
    }
  }

}

#' Retrieve Opencage API key
#'
#' An Opencage API Key
#' Looks in env var \code{OPENCAGE_KEY}
#'
#' @keywords internal
#' @export
opencage_key <- function(quiet = TRUE) {
  pat <- Sys.getenv("OPENCAGE_KEY")
  if (identical(pat, ""))  {
    return(NULL)
  }
  if (!quiet) {
    message("Using Opencage API Key from envvar OPENCAGE_KEY")
  }
  return(pat)
}
