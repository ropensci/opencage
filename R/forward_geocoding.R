.opencage_forward <- function(placename, key=opencage_key(),
                             bounds = NULL,
                             countrycode = NULL,
                             language = NULL,
                             limit = 10,
                             min_confidence = NULL,
                             no_annotations = NULL,
                             no_dedupe = NULL){
  # check arguments
  opencage_query_check(placename = placename,
                       key = key,
                       bounds = bounds,
                       countrycode = countrycode,
                       language = language,
                       limit = limit,
                       min_confidence = min_confidence,
                       no_annotations = no_annotations,
                       no_dedupe = no_dedupe)

  no_annotations <- ifelse(is.null(no_annotations), FALSE, TRUE)
  no_dedupe <- ifelse(is.null(no_dedupe), FALSE, TRUE)

  # res
  temp <- opencage_get(query_par = list(q = placename,
                                        bounds = bounds,
                                        countrycode = countrycode,
                                        language = language,
                                        limit = limit,
                                        min_confidence = min_confidence,
                                        no_annotations =
                                          ifelse(no_annotations == TRUE, 1, 0),
                                        no_dedupe = ifelse(no_dedupe == TRUE, 1, 0),
                                        key = key))

  # check message
  opencage_check(temp)

  # done!
  opencage_parse(temp)
}

#' Forward geocoding
#'
#' Forward geocoding, from placename to latitude and longitude tuplet(s).
#'
#' @param placename Placename
#' @param key Your OpenCage key
#' @param bounds Provides the geocoder with a hint to the region that the query resides in. This value will restrict the possible results to the supplied region. The bounds parameter should be specified as 4 coordinate points forming the south-west and north-east corners of a boundsing box. For example \code{bounds = c(-0.563160, 51.280430, 0.278970, 51.683979)} (min long, min lat, max long, max lat).
#' @param countrycode Restricts the results to the given country. The country code is a two letter code as defined by the ISO 3166-1 Alpha 2 standard. E.g. 'GB' for the United Kingdom, 'FR' for France, 'US' for United States.
#' @param language An IETF format language code (such as es for Spanish or pt-BR for Brazilian Portuguese). If no language is explicitly specified, we will look for an HTTP Accept-Language header like those sent by a brower and use the first language specified and if none are specified en (English) will be assumed
#' @param limit How many results should be returned (1-100). Default is 10.
#' @param min_confidence An integer from 1-10. Only results with at least this confidence will be returned.
#' @param no_annotations Logical (default FALSE), when TRUE the output will not contain annotations.
#' @param no_dedupe Logical (default FALSE), when TRUE the output will not be deduplicated
#'
#' @details To get an API key to access OpenCage geocoding, register at https://geocoder.opencagedata.com/pricing. The free API key provides up to 2,500 calls a day. For ease of use, save your API key as an environment variable as described at https://stat545-ubc.github.io/bit003_api-key-env-var.html
#' It is recommended you save your API key as an environment variable. See https://stat545-ubc.github.io/bit003_api-key-env-var.html Both functions of the package will conveniently look for your API key using Sys.getenv("OPENCAGE_KEY") so if your API key is an environment variable called "OPENCAGE_KEY" you don't need to input it.
#'
#' The underlying data at OpenCage is updated about once a day. Note that the package uses `memoise` with no timeout argument so that results are cached inside an active R session.
#'
#' Regarding multiple results, the API doc states that "In cases where the geocoder is able to find multiple matches, the geocoder will return multiple results. The confidence or coordinates for each result should be examined to determine whether each result from an ambiguous query is sufficiently high to warrant using a result or not. A good strategy to reduce ambiguity is to use the optional `bounds` parameter described below to limit the area searched." Multiple results might mean you get a result for the airport and a road when querying a city name, or results for cities with the same name in different countries.
#'
#' @return A list with
#' \itemize{
#' \item results as a data.frame (`dplyr` `tbl_df`) called results with one line per results,
#' \item the number of results as an integer
#' \item the timestamp as a POSIXct object
#' \item rate_info data.frame (`dplyr` `tbl_df`) with the maximal number of API calls per day for the used key, the number of remaining calls for the day and the time at which the number of remaining calls with be reset.
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' opencage_forward(placename = "Sarzeau")
#' opencage_forward(placename = "Islington, London")
#' opencage_forward(placename = "Triererstr 15,
#'                               Weimar 99423,
#'                               Deutschland")
#'}
#'
opencage_forward <- memoise::memoise(.opencage_forward)

