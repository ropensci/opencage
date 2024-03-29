% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/oc_forward.R
\name{oc_forward_df}
\alias{oc_forward_df}
\alias{oc_forward_df.data.frame}
\alias{oc_forward_df.character}
\title{Forward geocoding with data frames}
\usage{
oc_forward_df(...)

\method{oc_forward_df}{data.frame}(
  data,
  placename,
  bind_cols = TRUE,
  output = c("short", "all"),
  bounds = NULL,
  proximity = NULL,
  countrycode = NULL,
  language = NULL,
  limit = 1L,
  min_confidence = NULL,
  no_annotations = TRUE,
  roadinfo = FALSE,
  no_dedupe = FALSE,
  abbrv = FALSE,
  address_only = FALSE,
  ...
)

\method{oc_forward_df}{character}(
  placename,
  output = c("short", "all"),
  bounds = NULL,
  proximity = NULL,
  countrycode = NULL,
  language = NULL,
  limit = 1L,
  min_confidence = NULL,
  no_annotations = TRUE,
  roadinfo = FALSE,
  no_dedupe = FALSE,
  abbrv = FALSE,
  address_only = FALSE,
  ...
)
}
\arguments{
\item{...}{Ignored.}

\item{data}{A data frame.}

\item{placename}{An unquoted variable name of a character column or vector
with the location names or addresses to be geocoded.

If the locations are addresses, see \href{https://github.com/OpenCageData/opencagedata-misc-docs/blob/master/query-formatting.md}{OpenCage's instructions}
on how to format addresses for best forward geocoding results.}

\item{bind_cols}{When \code{bind_col = TRUE}, the default, the results are column
bound to \code{data}. When \code{FALSE}, the results are returned as a new tibble.}

\item{output}{A character vector of length one indicating whether only
latitude, longitude, and formatted address variables (\code{"short"}, the
default), or all variables (\code{"all"}) variables should be returned.}

\item{bounds}{A list of length one, or an unquoted variable name of a list
column of bounding boxes. Bounding boxes are named numeric vectors, each
with 4 coordinates forming the south-west and north-east corners of the
bounding box: \code{list(c(xmin, ymin, xmax, ymax))}. \code{bounds} restricts the
possible results to the supplied region. It can be specified with the
\code{\link[=oc_bbox]{oc_bbox()}} helper. For example: \code{bounds = oc_bbox(-0.563160, 51.280430, 0.278970, 51.683979)}. Default is \code{NULL}.}

\item{proximity}{A list of length one, or an unquoted variable name of a list
column of points. Points are named numeric vectors with latitude, longitude
coordinate pairs in decimal format. \code{proximity} provides OpenCage with a
hint to bias results in favour of those closer to the specified location.
It can be specified with the \code{\link[=oc_points]{oc_points()}} helper. For example: \code{proximity = oc_points(41.40139, 2.12870)}. Default is \code{NULL}.}

\item{countrycode}{Character vector, or an unquoted variable name of such a
vector, of two-letter codes as defined by the \href{https://www.iso.org/obp/ui/#search/code}{ISO 3166-1 Alpha 2} standard that restricts the
results to the given country or countries. E.g. "AR" for Argentina, "FR"
for France, "NZ" for the New Zealand. Multiple countrycodes per \code{placename}
must be wrapped in a list. Default is \code{NULL}.}

\item{language}{Character vector, or an unquoted variable name of such a
vector, of \href{https://en.wikipedia.org/wiki/IETF_language_tag}{IETF BCP 47 language tags} (such as "es" for
Spanish or "pt-BR" for Brazilian Portuguese). OpenCage will attempt to
return results in that language. Alternatively you can specify the "native"
tag, in which case OpenCage will attempt to return the response in the
"official" language(s). In case the \code{language} parameter is set to \code{NULL}
(which is the default), the tag is not recognized, or OpenCage does not
have a record in that language, the results will be returned in English.}

\item{limit}{Numeric vector of integer values, or an unquoted variable name
of such a vector, to determine the maximum number of results returned for
each \code{placename}. Integer values between 1 and 100 are allowed. Default is
1.}

\item{min_confidence}{Numeric vector of integer values, or an unquoted
variable name of such a vector, between 0 and 10 indicating the precision
of the returned result as defined by its geographical extent, (i.e. by the
extent of the result's bounding box). See the \href{https://opencagedata.com/api#confidence}{API documentation} for details. Only
results with at least the requested confidence will be returned. Default is
\code{NULL}).}

\item{no_annotations}{Logical vector, or an unquoted variable name of such a
vector, indicating whether additional information about the result location
should be returned. \code{TRUE} by default, which means that the results will
not contain annotations.}

\item{roadinfo}{Logical vector, or an unquoted variable name of such a
vector, indicating whether the geocoder should attempt to match the nearest
road (rather than an address) and provide additional road and driving
information. Default is \code{FALSE}.}

\item{no_dedupe}{Logical vector, or an unquoted variable name of such a
vector. Default is \code{FALSE}. When \code{TRUE} the results will not be
deduplicated.}

\item{abbrv}{Logical vector, or an unquoted variable name of such a vector.
Default is \code{FALSE}. When \code{TRUE} addresses in the \code{oc_formatted} variable of
the results are abbreviated (e.g. "Main St." instead of "Main Street").}

\item{address_only}{Logical vector, or an unquoted variable name of such a
vector. Default is \code{FALSE}. When \code{TRUE} only the address details are
returned in the \code{oc_formatted} variable of the results, not the name of a
point-of-interest should there be one at this address.}
}
\value{
A tibble. Column names coming from the OpenCage API are prefixed with
\code{"oc_"}.
}
\description{
Forward geocoding from a column or vector of location names to latitude and
longitude tuples.
}
\examples{
\dontshow{if (oc_key_present() && oc_api_ok()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}

library(tibble)
df <- tibble(
  id = 1:3,
  locations = c("Nantes", "Hamburg", "Los Angeles")
)

# Return lat, lng, and formatted address
oc_forward_df(df, placename = locations)

# Return more detailed information about the locations
oc_forward_df(df, placename = locations, output = "all")

# Do not column bind results to input data frame
oc_forward_df(df, placename = locations, bind_cols = FALSE)

# Add more results by changing the limit from the default of 1.
oc_forward_df(df, placename = locations, limit = 5)

# Restrict results to a given bounding box
oc_forward_df(df,
  placename = locations,
  bounds = oc_bbox(-5, 45, 15, 55)
)

# oc_forward_df accepts unquoted column names for all
# arguments except bind_cols and output.
# This makes it possible to build up more detailed queries
# through the data frame passed to the data argument.

df2 <- add_column(df,
  bounds = oc_bbox(
    xmin = c(-2, 9, -119),
    ymin = c(47, 53, 34),
    xmax = c(0, 10, -117),
    ymax = c(48, 54, 35)
  ),
  limit = 1:3,
  countrycode = c("ca", "us", "co"),
  language = c("fr", "de", "en")
)

# Use the bounds column to help return accurate results and
# language column to specify preferred language of results
oc_forward_df(df2,
  placename = locations,
  bounds = bounds,
  language = language
)

# Different limit of results for each placename
oc_forward_df(df2,
  placename = locations,
  limit = limit
)

# Specify the desired results by the countrycode column
oc_forward_df(df2,
  placename = locations,
  countrycode = countrycode
)
\dontshow{\}) # examplesIf}
}
\seealso{
\code{\link[=oc_forward]{oc_forward()}} for inputs as vectors, or \code{\link[=oc_reverse]{oc_reverse()}} and
\code{\link[=oc_reverse_df]{oc_reverse_df()}} for reverse geocoding. For more information about the API
and the various parameters, see the \href{https://opencagedata.com/api}{OpenCage API documentation}.
}
