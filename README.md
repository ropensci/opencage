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

Below are two simple examples. For more information about the query parameters, see the package documentation, the [API doc](https://geocoder.opencagedata.com/api) and [OpenCage FAQ](https://geocoder.opencagedata.com/faq).

Forward geocoding
-----------------

Forward geocoding is from placename to latitude and longitude tuplet(s).

``` r
library("opencage")
opencage_forward(placename = "Sarzeau", key = Sys.getenv("OPENCAGE_KEY"))
```

    ## $results
    ## Source: local data frame [2 x 42]
    ## 
    ##    annotations.DMS.lat annotations.DMS.lng annotations.MGRS
    ##                  (chr)               (chr)            (chr)
    ## 1 47° 31' 43.56984'' N 2° 45' 51.11892'' W  30TWT1774963954
    ## 2 47° 31' 40.80828'' N  2° 46' 7.68180'' W  30TWT1740363867
    ## Variables not shown: annotations.Maidenhead (chr), annotations.Mercator.x
    ##   (chr), annotations.Mercator.y (chr), annotations.OSM.edit_url (chr),
    ##   annotations.OSM.url (chr), annotations.callingcode (fctr),
    ##   annotations.geohash (chr), annotations.sun.rise.apparent (fctr),
    ##   annotations.sun.rise.astronomical (fctr), annotations.sun.rise.civil
    ##   (fctr), annotations.sun.rise.nautical (fctr),
    ##   annotations.sun.set.apparent (fctr), annotations.sun.set.astronomical
    ##   (fctr), annotations.sun.set.civil (fctr), annotations.sun.set.nautical
    ##   (fctr), annotations.timezone.name (fctr),
    ##   annotations.timezone.now_in_dst (fctr), annotations.timezone.offset_sec
    ##   (fctr), annotations.timezone.offset_string (fctr),
    ##   annotations.timezone.short_name (fctr), annotations.what3words.words
    ##   (chr), bounds.northeast.lat (chr), bounds.northeast.lng (chr),
    ##   bounds.southwest.lat (chr), bounds.southwest.lng (chr), components.city
    ##   (fctr), components.country (fctr), components.country_code (fctr),
    ##   components.county (fctr), components.postcode (fctr), components.state
    ##   (fctr), confidence (chr), formatted (chr), geometry.lat (chr),
    ##   geometry.lng (chr), components.post_office (fctr), components.road
    ##   (fctr), components.suburb (fctr), components.village (fctr)
    ## 
    ## $total_results
    ## [1] 2
    ## 
    ## $time_stamp
    ## [1] "2016-04-10 07:03:59 UTC"

Reverse geocoding
-----------------

Reverse geocoding is from latitude and longitude to placename(s).

``` r
opencage_reverse(latitude = 0, longitude = 0, 
                 key = Sys.getenv("OPENCAGE_KEY"),
                 limit = 2)
```

    ## $results
    ## Source: local data frame [2 x 39]
    ## 
    ##    annotations.DMS.lat  annotations.DMS.lng annotations.MGRS
    ##                  (chr)                (chr)            (chr)
    ## 1 43° 58' 33.33144'' N 11° 35' 26.17116'' E  32TQP0778572461
    ## 2 43° 58' 34.72680'' N  11° 34' 5.56536'' E  32TQP0598872448
    ## Variables not shown: annotations.Maidenhead (chr), annotations.Mercator.x
    ##   (chr), annotations.Mercator.y (chr), annotations.OSM.edit_url (chr),
    ##   annotations.OSM.url (chr), annotations.callingcode (fctr),
    ##   annotations.geohash (chr), annotations.sun.rise.apparent (fctr),
    ##   annotations.sun.rise.astronomical (fctr), annotations.sun.rise.civil
    ##   (fctr), annotations.sun.rise.nautical (fctr),
    ##   annotations.sun.set.apparent (fctr), annotations.sun.set.astronomical
    ##   (fctr), annotations.sun.set.civil (fctr), annotations.sun.set.nautical
    ##   (fctr), annotations.timezone.name (fctr),
    ##   annotations.timezone.now_in_dst (fctr), annotations.timezone.offset_sec
    ##   (fctr), annotations.timezone.offset_string (fctr),
    ##   annotations.timezone.short_name (fctr), annotations.what3words.words
    ##   (chr), bounds.northeast.lat (chr), bounds.northeast.lng (chr),
    ##   bounds.southwest.lat (chr), bounds.southwest.lng (chr),
    ##   components.country (fctr), components.country_code (fctr),
    ##   components.county (fctr), components.road (chr), components.state
    ##   (fctr), components.suburb (fctr), components.village (fctr), confidence
    ##   (chr), formatted (chr), geometry.lat (chr), geometry.lng (chr)
    ## 
    ## $total_results
    ## [1] 2
    ## 
    ## $time_stamp
    ## [1] "2016-04-10 07:04:01 UTC"

Caching
-------

Note that the package uses [memoise](https://github.com/hadley/memoise) with no timeout argument so that results are cached inside an active R session. The underlying data at OpenCage is updated about once a day.

``` r
system.time(opencage_reverse(latitude = 10, longitude = 10,
key = Sys.getenv("OPENCAGE_KEY")))
```

    ##    user  system elapsed 
    ##    0.11    0.00    0.56

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

    ##    user  system elapsed 
    ##    0.09    0.01    0.65
