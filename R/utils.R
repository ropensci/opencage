# status check
opencage_check <- function(req) {
  if (req$status_code < 400) return(invisible())

  message <- opencage_parse(req)$message
  stop("HTTP failure: ", req$status_code, "\n", message, call. = FALSE)
}

# function for parsing
opencage_parse <- function(req) {
  text <- httr::content(req, as = "text")
  if (identical(text, "")) stop("No output to parse", call. = FALSE)

  temp <- jsonlite::fromJSON(text,
                             simplifyVector = FALSE)
  res <- lapply(temp$results, as.data.frame)

  # check that same class if same name
  names <- lapply( res, names)
  common_names <- Reduce(intersect, names)
  common_dataframes <- lapply(res, "[", common_names)

  class_of_common <- lapply(common_dataframes, functionClass)
  class_of_common <- lapply(class_of_common, as.data.frame)

  class_of_common <- dplyr::bind_cols(class_of_common)
  unique_class <- apply(class_of_common, 1, unique)
  length_class <- lapply(unique_class, length)
  if(any(length_class > 1)){
    not_same_class <- common_names[length_class > 1]
    # force to character
    for(name in not_same_class){
      for (i in 1:length(res)){
        res[[i]][[name]] <- as.character(res[[i]][[name]] )
      }
    }
  }


  list(results = suppressWarnings(do.call(dplyr::bind_rows,
                           res)),
       total_results = temp$total_results,
       time_stamp = temp$timestamp$created_http)
}

# base URL for all queries
opencage_url <- function() {
  "http://api.opencagedata.com/geocode/v1/json/"
}

# get resultrs
opencage_get <- function(queryPar){
  queryPar <- Filter(Negate(is.null), queryPar)
  httr::GET(url = opencage_url(),
            query = queryPar)
}

# function that checks the query
opencage_query_check <- function(latitude = NULL,
                                 longitude = NULL,
                                 placename = NULL,
                                 key,
                                 bound,
                                 countrycode,
                                 language,
                                 limit,
                                 min_confidence,
                                 no_annotation,
                                 no_dedupe,
                                 pretty){
  # check latitude
  if(!is.null(latitude)){
    if (!dplyr::between(latitude, -90, 90)){
      stop("Latitude should be between -90 and 90.")
      }
  }

  # check longitude
  if(!is.null(longitude)){
    if (!dplyr::between(longitude, -180, 180)){
      stop("Longitude should be between -180 and 180.")
    }
  }
  # check placename
  if(!is.null(placename)){
    if(!is.character(placename)){
      stop("Placename should be a character.")
    }
    }

  # check key
  if(!is.null(key)){
    if(!is.character(key)){
      stop("Key should be a character.")
    }
  }

  # check bounds
  if(!is.null(bound)){
    if(length(bound) != 4){
      stop("Bound should be a vector of 4 numeric values.")
    }
    if(bound[1]>bound[3]){
      stop("min long has to be smaller than max long")
    }
    if(bound[2]>bound[4]){
      stop("min lat has to be smaller than max lat")
    }
    if(!dplyr::between(bound[1], -180, 180)){
      stop("min long should be between -180 and 180.")
    }
    if(!dplyr::between(bound[2], -90, 90)){
      stop("min lat should be between -90 and 90.")
    }
    if(!dplyr::between(bound[3], -180, 180)){
      stop("max long should be between -180 and 180.")
    }
    if(!dplyr::between(bound[4], -90, 90)){
      stop("max lat should be between -90 and 90.")
    }
  }

  # check countrycode
  if(!is.null(countrycode)){
    data("countrycodes")
    if(!(countrycode %in% countrycodes$Code)){
      stop("countrycode does not have a valid value.")
    }
  }

  # check language
  if(!is.null(language)){
  data("languagecodes")
  lang <- strsplit(language, "-")[[1]]
  if(!(lang[1] %in% languagecodes$alpha2)){
    stop("The language code is not valid.")
  }
  if(length(lang)>1){
    data("countrycodes")
    if(!(lang[2] %in% countrycodes$code)){
      stop("The country part of language is not valid.")
    }
  }
}

  # check limit
 # no max?

  # check min_confidence
  if(!is.null(min_confidence)){
    if(!(min_confidence %in% c(1:10))){
      stop("min_confidence should be an integer between 1 and 10.")
    }
  }

  # check no_annotations
  if(!is.null(no_annotation)){
    if(!is.logical(no_annotation)){
      stop("no_location has to be a logical.")
    }
  }

  # check no_dedupe
  if(!is.null(no_dedupe)){
    if(!is.logical(no_dedupe)){
      stop("no_dedupe has to be a logical.")
    }
  }

  # check pretty
  if(!is.null(pretty)){
    if(!is.logical(pretty)){
      stop("pretty has to be a logical.")
    }
  }
}

# function get class of data.frame
functionClass <- function(x){
  unlist(lapply(x, class))
}

# function for coercing to character
functionCol <- function(x, col){
  x[, col] <- as.character(x[, col])
}
