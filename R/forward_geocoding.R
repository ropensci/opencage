#' Forward Geocoding
#'
#' @param placename placename
#' @param key your OpenCage key
#' @param bound Provides the geocoder with a hint to the region that the query resides in. This value will restrict the possible results to the supplied region. The bound parameter should be specified as 4 coordinate points forming the south-west and north-east corners of a bounding box. For example bound=-0.563160,51.280430,0.278970,51.683979 (min long, min lat, max long, max lat).
#' @param countrycode Restricts the results to the given country. The country code is a two letter code as defined by the ISO 3166-1 Alpha 2 standard. E.g. 'gb' for the United Kingdom, 'fr' for France, 'us' for United States. Non-two letter countrycodes are ignored.
#' @param language an IETF format language code (such as es for Spanish or pt-BR for Brazilian Portuguese). If no language is explicitly specified, we will look for an HTTP Accept-Language header like those sent by a brower and use the first language specified and if none are specified en (English) will be assumed
#' @param limit How many results should be returned. Default is 10.
#' @param min_confidence an integer from 1-10. Only results with at least this confidence will be returned.
#' @param no_annotations Logical, when TRUE the output will not contain annotations.
#' @param no_dedupe Logical, when TRUE the output will not be deduplicated
#' @param pretty if TRUE enables pretty printing of the response payload
#'
#' @details For getting your API key register at https://geocoder.opencagedata.com/pricing. The free API key provides up to 2,500 calls a day.
#'
#' @return A list with results as a data.frame (`dplyr` `tbl_df`)
#' @export
#'
#' @examples
opencage_forward <- function(placename, key,
                             bound = NULL,
                             countrycode = NULL,
                             language = NULL,
                             limit = 10,
                             min_confidence = NULL,
                             no_annotation = NULL,
                             no_dedupe = NULL,
                             pretty = NULL){
  # check arguments
  opencage_query_check(placename = placename,
                       key = key,
                       bound = bound,
                       countrycode = countrycode,
                       language = language,
                       limit = limit,
                       min_confidence = min_confidence,
                       no_annotation = no_annotation,
                       no_dedupe = no_dedupe,
                       pretty = pretty)

  # res
  temp <- opencage_get(queryPar = list(q = placename,
                           bound = bound,
                           countrycode = countrycode,
                           language = language,
                           limit = limit,
                           min_confidence = min_confidence,
                           no_annotation = no_annotation,
                           no_dedupe = no_dedupe,
                           pretty = pretty,
                           key = key))

  # done!
  opencage_parse(temp)
}
