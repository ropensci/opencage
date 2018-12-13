
<!-- README.md is generated from README.Rmd. Please edit that file -->

# opencage

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/opencage)](http://cran.r-project.org/package=opencage)
[![Build
Status](https://travis-ci.org/ropensci/opencage.svg?branch=master)](https://travis-ci.org/ropensci/opencage)
[![Build
status](https://ci.appveyor.com/api/projects/status/iketgu0vk55kt0b0?svg=true)](https://ci.appveyor.com/project/ropensci/opencage)
[![codecov.io](https://codecov.io/github/ropensci/opencage/coverage.svg?branch=master)](https://codecov.io/github/ropensci/opencage?branch=master)
[![](https://badges.ropensci.org/36_status.svg)](https://github.com/ropensci/onboarding/issues/36)

Geocode with the OpenCage API, either from placename to longitude and
latitude (forward geocoding) or from longitude and latitude to placename
(reverse geocoding).

# Installation

Install the package with:

``` r
install.packages("opencage")
```

Or install the development version using
[remotes](https://remotes.r-lib.org/) with:

``` r
remotes::install_github("ropensci/opencage")
```

# Geocoding

The [OpenCage](https://opencagedata.com/) API supports forward and
reverse geocoding. Sources of OpenCage are open geospatial data
including OpenStreetMap, Yahoo\! GeoPlanet, Natural Earth Data, Thematic
Mapping, Ordnance Survey OpenSpace, Statistics New Zealand, Zillow,
MaxMind, GeoNames, the US Census Bureau and Flickr’s shapefiles plus a
whole lot more besides. See [this
page](https://opencagedata.com/credits) for the full list of credits.

## API key

To use the package, you will need to register at
<https://opencagedata.com/users/sign_up> to get an API key. The “Free
Trial” plan provides up to 2,500 API requests a day.

The geocoding functions of the package will conveniently retrieve your
API key with `oc_key()` if it is saved in the environment variable
`"OPENCAGE_KEY"`. For ease of use, save your API key as an environment
variable in `.Renviron` as described at
<http://happygitwithr.com/api-tokens.html>.

## Forward geocoding

Forward geocoding is from placename to latitude and longitude tuplet(s).

``` r
library("opencage")
output <- oc_forward(placename = "Sarzeau")
knitr::kable(output)
```

| confidence | formatted                                       | northeast\_lat | northeast\_lng | southwest\_lat | southwest\_lng | ISO\_3166\_1\_alpha\_2 | type         | city    | country | country\_code | county | political\_union | postcode | state    | post\_office | road            | suburb   | village |      lat |        lng |
| ---------: | :---------------------------------------------- | -------------: | -------------: | -------------: | -------------: | :--------------------- | :----------- | :------ | :------ | :------------ | :----- | :--------------- | :------- | :------- | :----------- | :-------------- | :------- | :------ | -------: | ---------: |
|          6 | 56370 Sarzeau, France                           |       47.56668 |     \-2.663120 |       47.48408 |     \-2.853616 | FR                     | city         | Sarzeau | France  | fr            | Vannes | European Union   | 56370    | Brittany | NA           | NA              | NA       | NA      | 47.52877 | \-2.764200 |
|          9 | Sarzeau, Rue de la Poste, 56370 Sarzeau, France |       47.52804 |     \-2.768803 |       47.52794 |     \-2.768903 | FR                     | post\_office | NA      | France  | fr            | Vannes | European Union   | 56370    | Brittany | Sarzeau      | Rue de la Poste | Kerjolis | Sarzeau | 47.52799 | \-2.768853 |

## Reverse geocoding

Reverse geocoding is from latitude and longitude to placename(s).

``` r
output2 <- oc_reverse(latitude = 51.5034070, longitude = -0.1275920)
knitr::kable(output2)
```

| confidence | formatted                                                                   | northeast\_lat | northeast\_lng | southwest\_lat | southwest\_lng | ISO\_3166\_1\_alpha\_2 | type       | attraction              | city   | country        | country\_code | house\_number | neighbourhood | political\_union | postcode | road           | state   | state\_district | suburb        |      lat |         lng |
| ---------: | :-------------------------------------------------------------------------- | -------------: | -------------: | -------------: | -------------: | :--------------------- | :--------- | :---------------------- | :----- | :------------- | :------------ | :------------ | :------------ | :--------------- | :------- | :------------- | :------ | :-------------- | :------------ | -------: | ----------: |
|          9 | Prime Minister’s Office, 10 Downing Street, London SW1A 2AA, United Kingdom |       51.50365 |    \-0.1273038 |       51.50326 |    \-0.1278356 | GB                     | attraction | Prime Minister’s Office | London | United Kingdom | gb            | 10            | St. James’s   | European Union   | SW1A 2AA | Downing Street | England | Greater London  | Covent Garden | 51.50344 | \-0.1277082 |

## Return type

Depending on what you specify as the `return` parameter, `oc_forward()`
and `oc_reverse()` will return either a list of tibbles (`df_list`, the
default), JSON lists (`json_list`), GeoJSON lists (`geojson_list`), or
the URL with which the API would be called (`url_only`).

Both `oc_forward_df()` and `oc_reverse_df()` return a single tibble.

## Multiple results

Forward geocoding typically returns multiple results. Regarding these
ambigious results, the API doc
[states](https://opencagedata.com/api#ambiguous-results): “When forward
geocoding we may find multiple valid matches. Many places have the same
or similar names. In this case the geocoder will return multiple
results. The `confidence`, coordinates, or \[`type` fields\] for each
result should be examined to determine whether each result from an
ambiguous query is sufficiently correct to warrant using a result or
not. A good strategy to reduce ambiguity is to use the optional
`bounds`, `countrycode`, and/or `proximity`. parameters.” Multiple
results might mean you get a result for an airport and a road when
querying a city name, or results for cities with the same name in
different countries.

When building queries, OpenCage [best practices
docs](https://opencagedata.com/api#bestpractices) can be very useful.

## Specifying the target area

The `bounds`, `countrycode` and `proximity` arguments can make the query
more precise. They are only relevant and available for forward
geocoding.

  - `bounds`: Provides the geocoder with a hint to the region that the
    query resides in. This value will restrict the possible results to
    the supplied region. The bounds parameter can most easily be
    specified with `oc_bbox()`as 4 coordinate points forming the
    south-west and north-east corners of a bounding box, i.e. `(xmin,
    ymin, xmax, ymax)`. For example, it can be specified as `bounds =
    oc_bbox(-0.56, 51.28, 0.27, 51.68)`.

Below is an example of the use of `bounds` where the rectangle given in
the second call does not include Europe so that we don’t get results for
Berlin in Germany.

``` r
results1 <- oc_forward(placename = "Berlin")
knitr::kable(results1)
```

| confidence | formatted                                    | northeast\_lat | northeast\_lng | southwest\_lat | southwest\_lng | ISO\_3166\_1\_alpha\_2 | type | city           | country | country\_code | political\_union | postcode | state         | county            | state\_code | town   |      lat |        lng |
| ---------: | :------------------------------------------- | -------------: | -------------: | -------------: | -------------: | :--------------------- | :--- | :------------- | :------ | :------------ | :--------------- | :------- | :------------ | :---------------- | :---------- | :----- | -------: | ---------: |
|          4 | 10117 Berlin, Germany                        |       52.67704 |       13.54886 |       52.35704 |       13.22886 | DE                     | city | Berlin         | Germany | de            | European Union   | 10117    | Berlin        | NA                | NA          | NA     | 52.51704 |   13.38886 |
|          2 | Berlin, Germany                              |       52.67551 |       13.76116 |       52.33826 |       13.08835 | DE                     | city | Berlin         | Germany | de            | European Union   | NA       | Berlin        | NA                | NA          | NA     | 52.51985 |   13.43860 |
|          5 | Berlin, NH 03570, United States of America   |       44.52844 |     \-71.12364 |       44.44506 |     \-71.39786 | US                     | city | Berlin         | USA     | us            | NA               | 03570    | New Hampshire | Coös County       | NH          | NA     | 44.46907 | \-71.18523 |
|          6 | Berlin, VT, United States of America         |       44.27197 |     \-72.51979 |       44.15478 |     \-72.68368 | US                     | city | Berlin         | USA     | us            | NA               | NA       | Vermont       | Washington County | VT          | NA     | 44.21008 | \-72.60340 |
|          7 | Berlin, CT 06037, United States of America   |       41.66149 |     \-72.70565 |       41.58149 |     \-72.78565 | US                     | city | NA             | USA     | us            | NA               | 06037    | Connecticut   | Hartford County   | CT          | Berlin | 41.62149 | \-72.74565 |
|          7 | Berlin, NJ, United States of America         |       39.80915 |     \-74.90796 |       39.77601 |     \-74.96611 | US                     | city | Berlin         | USA     | us            | NA               | NA       | New Jersey    | Camden County     | NJ          | NA     | 39.79123 | \-74.92905 |
|          7 | Berlin, MA 01503, United States of America   |       42.41828 |     \-71.58023 |       42.35059 |     \-71.67880 | US                     | city | Berlin         | USA     | us            | NA               | 01503    | Massachusetts | NA                | MA          | NA     | 42.38120 | \-71.63701 |
|          7 | Berlin, MD, United States of America         |       38.35518 |     \-75.18802 |       38.30841 |     \-75.23479 | US                     | city | Berlin         | USA     | us            | NA               | NA       | Maryland      | Worcester County  | MD          | NA     | 38.32262 | \-75.21769 |
|          7 | City of Berlin, WI, United States of America |       43.99797 |     \-88.92073 |       43.94761 |     \-88.98085 | US                     | city | City of Berlin | USA     | us            | NA               | NA       | Wisconsin     | Green Lake County | WI          | NA     | 43.96804 | \-88.94345 |
|          8 | Berlin, PA, United States of America         |       39.92738 |     \-78.93729 |       39.91442 |     \-78.96559 | US                     | city | Berlin         | USA     | us            | NA               | NA       | Pennsylvania  | Somerset County   | PA          | NA     | 39.92064 | \-78.95780 |

``` r
results2 <- oc_forward(placename = "Berlin", bounds = oc_bbox(-90,38,0, 45))
knitr::kable(results2)
```

| confidence | formatted                                    | northeast\_lat | northeast\_lng | southwest\_lat | southwest\_lng | ISO\_3166\_1\_alpha\_2 | type | city           | country | country\_code | county            | postcode | state         | state\_code | town   |      lat |        lng |
| ---------: | :------------------------------------------- | -------------: | -------------: | -------------: | -------------: | :--------------------- | :--- | :------------- | :------ | :------------ | :---------------- | :------- | :------------ | :---------- | :----- | -------: | ---------: |
|          5 | Berlin, NH 03570, United States of America   |       44.52844 |     \-71.12364 |       44.44506 |     \-71.39786 | US                     | city | Berlin         | USA     | us            | Coös County       | 03570    | New Hampshire | NH          | NA     | 44.46907 | \-71.18523 |
|          6 | Berlin, VT, United States of America         |       44.27197 |     \-72.51979 |       44.15478 |     \-72.68368 | US                     | city | Berlin         | USA     | us            | Washington County | NA       | Vermont       | VT          | NA     | 44.21008 | \-72.60340 |
|          7 | Berlin, CT 06037, United States of America   |       41.66149 |     \-72.70565 |       41.58149 |     \-72.78565 | US                     | city | NA             | USA     | us            | Hartford County   | 06037    | Connecticut   | CT          | Berlin | 41.62149 | \-72.74565 |
|          7 | Berlin, NJ, United States of America         |       39.80915 |     \-74.90796 |       39.77601 |     \-74.96611 | US                     | city | Berlin         | USA     | us            | Camden County     | NA       | New Jersey    | NJ          | NA     | 39.79123 | \-74.92905 |
|          7 | Berlin, MA 01503, United States of America   |       42.41828 |     \-71.58023 |       42.35059 |     \-71.67880 | US                     | city | Berlin         | USA     | us            | NA                | 01503    | Massachusetts | MA          | NA     | 42.38120 | \-71.63701 |
|          7 | Berlin, MD, United States of America         |       38.35518 |     \-75.18802 |       38.30841 |     \-75.23479 | US                     | city | Berlin         | USA     | us            | Worcester County  | NA       | Maryland      | MD          | NA     | 38.32262 | \-75.21769 |
|          7 | City of Berlin, WI, United States of America |       43.99797 |     \-88.92073 |       43.94761 |     \-88.98085 | US                     | city | City of Berlin | USA     | us            | Green Lake County | NA       | Wisconsin     | WI          | NA     | 43.96804 | \-88.94345 |
|          8 | Berlin, PA, United States of America         |       39.92738 |     \-78.93729 |       39.91442 |     \-78.96559 | US                     | city | Berlin         | USA     | us            | Somerset County   | NA       | Pennsylvania  | PA          | NA     | 39.92064 | \-78.95780 |

  - `countrycode`: The `countrycode` parameter restricts the results to
    the given country. The country code is a two letter code as defined
    by the [ISO 3166-1 Alpha 2](https://www.iso.org/obp/ui/#search/code)
    standard. E.g. “GB” for the United Kingdom, “FR” for France, “US”
    for United States. Multiple countrycodes per `placename` must be
    wrapped in a list. See example below.

<!-- end list -->

``` r
results3 <- oc_forward(placename = "Berlin", countrycode = "DE")
knitr::kable(results3)
```

| confidence | formatted             | northeast\_lat | northeast\_lng | southwest\_lat | southwest\_lng | ISO\_3166\_1\_alpha\_2 | type | city   | country | country\_code | political\_union | postcode | state  |      lat |      lng |
| ---------: | :-------------------- | -------------: | -------------: | -------------: | -------------: | :--------------------- | :--- | :----- | :------ | :------------ | :--------------- | :------- | :----- | -------: | -------: |
|          4 | 10117 Berlin, Germany |       52.67704 |       13.54886 |       52.35704 |       13.22886 | DE                     | city | Berlin | Germany | de            | European Union   | 10117    | Berlin | 52.51704 | 13.38886 |
|          2 | Berlin, Germany       |       52.67551 |       13.76116 |       52.33826 |       13.08835 | DE                     | city | Berlin | Germany | de            | European Union   | NA       | Berlin | 52.51985 | 13.43860 |

``` r
results4 <- oc_forward(placename = c("Paris"), countrycode = list(c("FR", "US")))
knitr::kable(results4)
```

| confidence | formatted                                                                      | northeast\_lat | northeast\_lng | southwest\_lat | southwest\_lng | ISO\_3166\_1\_alpha\_2 | type      | city      | country | country\_code | county         | political\_union | state                      | postcode | state\_code | bus\_stop | locality | road                      | road\_type | suburb        | place |      lat |          lng |
| ---------: | :----------------------------------------------------------------------------- | -------------: | -------------: | -------------: | -------------: | :--------------------- | :-------- | :-------- | :------ | :------------ | :------------- | :--------------- | :------------------------- | :------- | :---------- | :-------- | :------- | :------------------------ | :--------- | :------------ | :---- | -------: | -----------: |
|          6 | Paris, France                                                                  |       48.90216 |        2.46976 |       48.81558 |       2.224122 | FR                     | city      | Paris     | France  | fr            | Paris          | European Union   | Ile-de-France              | NA       | NA          | NA        | NA       | NA                        | NA         | NA            | NA    | 48.85661 |     2.351499 |
|          7 | Paris, AR 72855, United States of America                                      |       35.30650 |     \-93.67508 |       35.26725 |    \-93.761807 | US                     | city      | Paris     | USA     | us            | Logan County   | NA               | Arkansas                   | 72855    | AR          | NA        | NA       | NA                        | NA         | NA            | NA    | 35.29203 |  \-93.729917 |
|          5 | Paris, TX 75460, United States of America                                      |       33.73839 |     \-95.43541 |       33.62063 |    \-95.627940 | US                     | city      | Paris     | USA     | us            | Lamar County   | NA               | Texas                      | 75460    | TX          | NA        | NA       | NA                        | NA         | NA            | NA    | 33.66180 |  \-95.555513 |
|          7 | Paris, KY 40361, United States of America                                      |       38.23827 |     \-84.23209 |       38.16492 |    \-84.307326 | US                     | city      | Paris     | USA     | us            | Bourbon County | NA               | Kentucky                   | 40361    | KY          | NA        | NA       | NA                        | NA         | NA            | NA    | 38.20980 |  \-84.252987 |
|          9 | Paris, South Las Vegas Boulevard, Paradise, NV 89109, United States of America |       36.11205 |    \-115.17261 |       36.11195 |   \-115.172711 | US                     | bus\_stop | NA        | USA     | us            | Clark County   | NA               | Nevada                     | 89109    | NV          | Paris     | Paradise | South Las Vegas Boulevard | bus\_stop  | Hughes Center | NA    | 36.11200 | \-115.172661 |
|          7 | Paris, MO 65275, United States of America                                      |       39.48928 |     \-91.99168 |       39.46916 |    \-92.021480 | US                     | city      | Paris     | USA     | us            | Monroe County  | NA               | Missouri                   | 65275    | MO          | NA        | NA       | NA                        | NA         | NA            | NA    | 39.48087 |  \-92.001281 |
|          7 | Paris, IL 61944, United States of America                                      |       39.64998 |     \-87.64920 |       39.58149 |    \-87.721046 | US                     | city      | Paris     | USA     | us            | Edgar County   | NA               | Illinois                   | 61944    | IL          | NA        | NA       | NA                        | NA         | NA            | NA    | 39.61115 |  \-87.696137 |
|          7 | Paris, TN 38242, United States of America                                      |       36.32902 |     \-88.26507 |       36.26600 |    \-88.367113 | US                     | city      | Paris     | USA     | us            | Henry County   | NA               | Tennessee                  | 38242    | TN          | NA        | NA       | NA                        | NA         | NA            | NA    | 36.30200 |  \-88.326711 |
|         10 | Paris, 47210 Villeréal, France                                                 |             NA |             NA |             NA |             NA | FR                     | place     | Villeréal | France  | fr            | Lot-et-Garonne | European Union   | Aquitaine                  | 47210    | NA          | NA        | NA       | NA                        | NA         | NA            | Paris | 44.63933 |     0.747184 |
|         10 | Paris, 83590 Gonfaron, France                                                  |             NA |             NA |             NA |             NA | FR                     | place     | Gonfaron  | France  | fr            | Var            | European Union   | Provence-Alpes-Côte d’Azur | 83590    | NA          | NA        | NA       | NA                        | NA         | NA            | Paris | 43.32019 |     6.312719 |

## Specifying what is returned

  - `language`: If you would like to get your results in a specific
    language, you can pass an [IETF language
    tag](https://en.wikipedia.org/wiki/IETF_language_tag), such as “es”
    for Spanish or “pt-BR” for Brazilian Portuguese, to the `language`
    parameter. OpenCage will attempt to return results in that language.
    If it is not specified, “en” (English) will be assumed by the
API.

<!-- end list -->

``` r
results5 <- oc_forward(placename = "Berlin", country = "DE", language = "de")
knitr::kable(results5)
```

| confidence | formatted                 | northeast\_lat | northeast\_lng | southwest\_lat | southwest\_lng | ISO\_3166\_1\_alpha\_2 | type | city   | country     | country\_code | political\_union | postcode | state  |      lat |      lng |
| ---------: | :------------------------ | -------------: | -------------: | -------------: | -------------: | :--------------------- | :--- | :----- | :---------- | :------------ | :--------------- | :------- | :----- | -------: | -------: |
|          4 | 10117 Berlin, Deutschland |       52.67704 |       13.54886 |       52.35704 |       13.22886 | DE                     | city | Berlin | Deutschland | de            | European Union   | 10117    | Berlin | 52.51704 | 13.38886 |
|          2 | Berlin, Deutschland       |       52.67551 |       13.76116 |       52.33826 |       13.08835 | DE                     | city | Berlin | Deutschland | de            | European Union   | NA       | Berlin | 52.51985 | 13.43860 |

  - `limit` specifies the maximum number of results that should be
    returned. Integer values between 1 and 100 are allowed, the default
    is 10 for `oc_forward()` and 1 for `oc_forward_df()`. Reverse
    geocoding always returns at most one result.

  - `min_confidence`, an integer value between 0 and 10, indicates the
    precision of the returned result as defined by it’s geographical
    extent, (i.e. by the extent of the result’s bounding box). See the 
    for details. Only results with at least the requested confidence
    will be returned.

  - `no_annotations`: OpenCage supplies additional information about the
    result location in the annotations field. The annotations include,
    among others, country information, time of sunset and sunrise, or
    the location in different geocoding formats, like Maidenhead,
    Mercator projection (EPSG 3857), geohash or what3words. Some
    annotations, like the Irish Transverse Mercator (ITM) or the US
    Federal Information Processing Standards (FIPS) code will only be
    shown, where appropriate. `no_annotations` is `TRUE` by default,
    which means that the output will not contain annotations.

  - `no_dedupe` is `FALSE` by default. When TRUE the output will not be
    deduplicated.

For more information about the output and the query parameters, see the
package documentation, the [API doc](https://opencagedata.com/api) and
[OpenCage FAQ](https://opencagedata.com/faq).

## Caching

The underlying data at OpenCage is updated about once a day. Note that
this package uses [memoise](https://github.com/r-lib/memoise) with no
timeout argument so that results are cached inside an active R session.

``` r
system.time(oc_reverse(latitude = 10, longitude = 10))
```

    ##    user  system elapsed 
    ##    0.03    0.00    0.99

``` r
system.time(oc_reverse(latitude = 10, longitude = 10))
```

    ##    user  system elapsed 
    ##    0.02    0.00    0.02

To clear the cache of all results, you need to call
`memoise::forget(opencage:::oc_get_memoise)`.

``` r
memoise::forget(opencage:::oc_get_memoise)
```

    ## [1] TRUE

``` r
system.time(oc_reverse(latitude = 10, longitude = 10))
```

    ##    user  system elapsed 
    ##    0.04    0.00    0.96

## Privacy

All geocoding functions have a parameter `no_record`. It is `FALSE` by
default.

  - When `no_record` is `FALSE` a log of the query is made by OpenCage.
    These logs are used for debugging and in order to improve the
    service. [According](https://opencagedata.com/faq#legal) to
    OpenCage, all logs are automatically deleted after six months.

  - When `no_record` is `TRUE`, OpenCage still records that a request
    was made (e.g. to see whether you exceeded your quota), but not the
    specific content of your query. Please use if you have concerns
    about privacy and want OpenCage to have no record of your query.
    More information about privacy can be found on OpenCage’s [GDPR
    page](https://opencagedata.com/gdpr).

## Addresses

The geocoding functions also have an `abbr` parameter, `FALSE` by
default. When it is `TRUE` the addresses in the `formatted` field of the
results are abbreviated (e.g. “Main St.” instead of “Main Street”). For
more details see [this blog
post](http://blog.opencagedata.com/post/160294347883/shrtr-pls).

## Return query text

`oc_forward()` and `oc_reverse()` have an `add_request` argument,
indicating whether the request is returned again with the results. If
the `return` value is a `df_list`, the `placename` or
`latitude,longitude` is added as a column to the results. `json_list`
results will contain all request parameters, including the API key
used\! For `geojson_list` results `add_request` is currently ignored by
OpenCage.

## Meta

  - Please [report any issues or
    bugs](https://github.com/ropensci/opencage/issues).
  - License: GPL
  - Get citation information for `opencage` in R doing `citation(package
    = 'opencage')`
  - Please note that this project is released with a [Contributor Code
    of Conduct](CONDUCT.md). By participating in this project you agree
    to abide by its
terms.

[![ropensci\_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
