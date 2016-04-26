opencage
========

[![Build Status](https://travis-ci.org/masalmon/opencage.svg?branch=master)](https://travis-ci.org/masalmon/opencage) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/masalmon/opencage?branch=master&svg=true)](https://ci.appveyor.com/project/masalmon/opencage) [![codecov.io](https://codecov.io/github/masalmon/opencage/coverage.svg?branch=master)](https://codecov.io/github/masalmon/opencage?branch=master)

Installation
============

To install the package, you will need the devtools package.

``` r
library("devtools")
install_github("masalmon/opencage")
```

To use the package, you will also need an API key. For this register at <https://geocoder.opencagedata.com/pricing>. The free API key provides up to 2,500 calls a day. It is recommended you save your API key as an environment variable. See <https://stat545-ubc.github.io/bit003_api-key-env-var.html>

Geocoding
=========

The [OpenCage](https://geocoder.opencagedata.com/) API supports forward and reverse geocoding. Sources of OpenCage are open geospatial data including OpenStreetMap, Yahoo! GeoPlanet, Natural Earth Data, Thematic Mapping, Ordnance Survey OpenSpace, Statistics New Zealand, Zillow, MaxMind, GeoNames, the US Census Bureau and Flickr's shapefiles plus a whole lot more besides. See [this page](https://geocoder.opencagedata.com/credits) for the full list of credits.

Below are two simple examples.

Forward geocoding
-----------------

Forward geocoding is from placename to latitude and longitude tuplet(s).

``` r
library("opencage")
output <- opencage_forward(placename = "Sarzeau", key = Sys.getenv("OPENCAGE_KEY"))
```

    ## Warning: All formats failed to parse. No formats found.

``` r
print(output$time_stamp)
```

    ## [1] NA

``` r
library("dplyr")
```

    ## Warning: package 'dplyr' was built under R version 3.2.5

``` r
output$rate_info %>% knitr::kable()
```

|  limit|  remaining| rest                |
|------:|----------:|:--------------------|
|   2500|       2405| 2016-04-27 02:00:00 |

``` r
output$results %>% knitr::kable()
```

| annotations.DMS.lat  | annotations.DMS.lng | annotations.MGRS | annotations.Maidenhead | annotations.Mercator.x | annotations.Mercator.y | annotations.OSM.edit\_url                                                     | annotations.OSM.url                                                                   | annotations.callingcode | annotations.geohash  | annotations.sun.rise.apparent | annotations.sun.rise.astronomical | annotations.sun.rise.civil | annotations.sun.rise.nautical | annotations.sun.set.apparent | annotations.sun.set.astronomical | annotations.sun.set.civil | annotations.sun.set.nautical | annotations.timezone.name | annotations.timezone.now\_in\_dst | annotations.timezone.offset\_sec | annotations.timezone.offset\_string | annotations.timezone.short\_name | annotations.what3words.words | bounds.northeast.lat | bounds.northeast.lng | bounds.southwest.lat | bounds.southwest.lng | components.\_type | components.city | components.country | components.country\_code | components.county | components.postcode | components.state | confidence | formatted                                       |  geometry.lat|  geometry.lng| components.post\_office | components.road | components.suburb | components.village |
|:---------------------|:--------------------|:-----------------|:-----------------------|:-----------------------|:-----------------------|:------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------|:------------------------|:---------------------|:------------------------------|:----------------------------------|:---------------------------|:------------------------------|:-----------------------------|:---------------------------------|:--------------------------|:-----------------------------|:--------------------------|:----------------------------------|:---------------------------------|:------------------------------------|:---------------------------------|:-----------------------------|:---------------------|:---------------------|:---------------------|:---------------------|:------------------|:----------------|:-------------------|:-------------------------|:------------------|:--------------------|:-----------------|:-----------|:------------------------------------------------|-------------:|-------------:|:------------------------|:----------------|:------------------|:-------------------|
| 47° 31' 43.56984'' N | 2° 45' 51.11856'' W | 30TWT1774963954  | IN87om86hv             | -307709.292            | 5997281.031            | <https://www.openstreetmap.org/edit?relation=959447#map=17/47.52877/-2.76420> | <https://www.openstreetmap.org/?mlat=47.52877&mlon=-2.76420#map=17/47.52877/-2.76420> | 33                      | gbqn3h75jkz3h3mvtyj6 | 1461646860                    | 1461639480                        | 1461644820                 | 1461642300                    | 1461698220                   | 1461705660                       | 1461700260                | 1461702780                   | Europe/Paris              | 1                                 | 7200                             | 200                                 | CEST                             | gasp.jiggle.creamier         | 47.568813            | -2.6630649           | 47.484236            | -2.8536849           | city              | Sarzeau         | France             | fr                       | Vannes            | 56370               | Brittany         | 6          | 56370 Sarzeau, France                           |      47.52877|       -2.7642| NA                      | NA              | NA                | NA                 |
| 47° 31' 40.80828'' N | 2° 46' 7.68144'' W  | 30TWT1740363867  | IN87om76rr             | -308221.451            | 5997154.952            | <https://www.openstreetmap.org/edit?node=846574100#map=17/47.52800/-2.76880>  | <https://www.openstreetmap.org/?mlat=47.52800&mlon=-2.76880#map=17/47.52800/-2.76880> | 33                      | gbqn2upydmbc15dm9h6g | 1461646860                    | 1461639480                        | 1461644820                 | 1461642300                    | 1461698220                   | 1461705660                       | 1461700260                | 1461702780                   | Europe/Paris              | 1                                 | 7200                             | 200                                 | CEST                             | netball.anchored.accomplice  | 47.5280523           | -2.7687504           | 47.5279523           | -2.7688504           | post\_office      | NA              | France             | fr                       | Vannes            | 56370               | Brittany         | 10         | SARZEAU, Rue de la Poste, 56370 Sarzeau, France |      47.52800|       -2.7688| SARZEAU                 | Rue de la Poste | Kerjolis          | Sarzeau            |

Reverse geocoding
-----------------

Reverse geocoding is from latitude and longitude to placename(s).

``` r
output2 <- opencage_reverse(latitude = 51.5034070, 
                            longitude = -0.1275920, 
                 key = Sys.getenv("OPENCAGE_KEY"))
```

    ## Warning: All formats failed to parse. No formats found.

``` r
print(output2$time_stamp)
```

    ## [1] NA

``` r
output2$rate_info %>% knitr::kable()
```

|  limit|  remaining| rest                |
|------:|----------:|:--------------------|
|   2500|       2404| 2016-04-27 02:00:00 |

``` r
output2$results %>% knitr::kable()
```

| annotations.DMS.lat  | annotations.DMS.lng | annotations.MGRS | annotations.Maidenhead | annotations.Mercator.x | annotations.Mercator.y | annotations.OSGB.easting | annotations.OSGB.gridref | annotations.OSGB.northing | annotations.OSM.edit\_url                                                      | annotations.OSM.url                                                                   | annotations.callingcode | annotations.geohash  | annotations.sun.rise.apparent | annotations.sun.rise.astronomical | annotations.sun.rise.civil | annotations.sun.rise.nautical | annotations.sun.set.apparent | annotations.sun.set.astronomical | annotations.sun.set.civil | annotations.sun.set.nautical | annotations.timezone.name | annotations.timezone.now\_in\_dst | annotations.timezone.offset\_sec | annotations.timezone.offset\_string | annotations.timezone.short\_name | annotations.what3words.words | components.\_type | components.attraction | components.city | components.country | components.country\_code | components.house\_number | components.postcode | components.road | components.state | components.state\_district | components.suburb | confidence | formatted                                          |  geometry.lat|  geometry.lng|
|:---------------------|:--------------------|:-----------------|:-----------------------|:-----------------------|:-----------------------|:-------------------------|:-------------------------|:--------------------------|:-------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------|:------------------------|:---------------------|:------------------------------|:----------------------------------|:---------------------------|:------------------------------|:-----------------------------|:---------------------------------|:--------------------------|:-----------------------------|:--------------------------|:----------------------------------|:---------------------------------|:------------------------------------|:---------------------------------|:-----------------------------|:------------------|:----------------------|:----------------|:-------------------|:-------------------------|:-------------------------|:--------------------|:----------------|:-----------------|:---------------------------|:------------------|:-----------|:---------------------------------------------------|-------------:|-------------:|
| 51° 30' 12.38490'' N | 0° 7' 39.74919'' E  | 30UXC9933909723  | IO91wm40qt             | -14216.402             | 6677371.368            | 530044.64                | TQ 300 799               | 179939.726                | <https://www.openstreetmap.org/edit?relation=1879842#map=17/51.50344/-0.12771> | <https://www.openstreetmap.org/?mlat=51.50344&mlon=-0.12771#map=17/51.50344/-0.12771> | 44                      | gcpuvpgj21jujy3ytfp1 | 1461645600                    | 1461637080                        | 1461643380                 | 1461640500                    | 1461698220                   | 1461706860                       | 1461700500                | 1461703380                   | Europe/London             | 1                                 | 3600                             | 100                                 | BST                              | onions.toned.active          | attraction        | 10 Downing Street     | London          | United Kingdom     | gb                       | 10                       | SW1A 2AA            | Downing Street  | England          | Greater London             | Covent Garden     | 10         | 10 Downing Street, London SW1A 2AA, United Kingdom |      51.50344|    -0.1277081|

Output
------

For both `opencage_forward` and `opencage_reverse` functions, the package returns a list with a time stamp for the query, the total number of results, a data.frame (`dplyr tbl_df`) with information about the remaining calls to the API unless you have an unlimited account, and a data.frame (`dplyr tbl_df`) with the results corresponding to your query. You can find longitude and latitude for each results as `geometry.lat` and `geometry.lng`. Other information includes country and country information, time of sunset and sunrise, geohash (a geocoding system identifying a point with a single string, as explained in many more details [here](https://www.elastic.co/guide/en/elasticsearch/guide/current/geohashes.html) and [here](https://en.wikipedia.org/wiki/Geohash) -- for pure conversion between longitude/latitude and geohashes, see [this package](https://github.com/Ironholds/geohash)). Depending on the data available in the API for the results one gets different columns: there can be a lot to explore!

Parameters
----------

Optional parameters of both `opencage_forward` and `opencage_reverse` can make the query more precise:

-   `bounds`: Provides the geocoder with a hint to the region that the query resides in. This value will restrict the possible results to the supplied region. The bounds parameter should be specified as 4 coordinate points forming the south-west and north-east corners of a boundsing box. For example bounds=-0.563160,51.280430,0.278970,51.683979 (min long, min lat, max long, max lat).

-   `countrycode`: Restricts the results to the given country. The country code is a two letter code as defined by the ISO 3166-1 Alpha 2 standard. E.g. 'GB' for the United Kingdom, 'FR' for France, 'US' for United States.

-   `language`: an IETF format language code (such as es for Spanish or pt-BR for Brazilian Portuguese). If no language is explicitly specified, we will look for an HTTP Accept-Language header like those sent by a brower and use the first language specified and if none are specified en (English) will be assumed

-   `limit`: How many results should be returned (1-100). Default is 10.

-   `min_confidence`: an integer from 1-10. Only results with at least this confidence will be returned.

-   `no_annotations`: Logical (default FALSE), when TRUE the output will not contain annotations.

-   `no_dedupe`: Logical (default FALSE), when TRUE the output will not be deduplicated.

For more information about the output and the query parameters, see the package documentation, the [API doc](https://geocoder.opencagedata.com/api) and [OpenCage FAQ](https://geocoder.opencagedata.com/faq).

Caching
-------

Note that the package uses [memoise](https://github.com/hadley/memoise) with no timeout argument so that results are cached inside an active R session. The underlying data at OpenCage is updated about once a day.

``` r
system.time(opencage_reverse(latitude = 10, longitude = 10,
key = Sys.getenv("OPENCAGE_KEY")))
```

    ## Warning: All formats failed to parse. No formats found.

    ##    user  system elapsed 
    ##    0.03    0.00    0.34

``` r
system.time(opencage_reverse(latitude = 10, longitude = 10,
key = Sys.getenv("OPENCAGE_KEY")))
```

    ##    user  system elapsed 
    ##       0       0       0

``` r
memoise::forget(opencage_reverse)
```

    ## [1] TRUE

``` r
system.time(opencage_reverse(latitude = 10, longitude = 10,
key = Sys.getenv("OPENCAGE_KEY")))
```

    ## Warning: All formats failed to parse. No formats found.

    ##    user  system elapsed 
    ##    0.04    0.00    0.35
