
<!-- README.md is generated from README.Rmd. Please edit that file -->

# opencage

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/opencage)](http://cran.r-project.org/package=opencage)
[![Build
Status](https://travis-ci.org/ropensci/opencage.svg?branch=master)](https://travis-ci.org/ropensci/opencage)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/ropensci/opencage?branch=master&svg=true)](https://ci.appveyor.com/project/maelle/opencage)
[![codecov.io](https://codecov.io/github/ropensci/opencage/coverage.svg?branch=master)](https://codecov.io/github/ropensci/opencage?branch=master)
[![](https://badges.ropensci.org/36_status.svg)](https://github.com/ropensci/onboarding/issues/36)

Geocode with the OpenCage API, either from placename to longitude and
latitude (forward geocoding) or from longitude and latitude to placename
(reverse geocoding).

### Package functionality

There are a few R packages that provide forward and reverse geocoding,
see how {opencage} compares to alternative solutions:

| Task                                           | [opencage](https://github.com/ropensci/opencage) | [ggmap](https://github.com/dkahle/ggmap)                                                 | [tmaptools](https://github.com/mtennekes/tmaptools)                                                              |
| ---------------------------------------------- | ------------------------------------------------ | ---------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Available on CRAN                              | ✅                                                | ✅                                                                                        | ✅                                                                                                                |
| Requires API key                               | ✅                                                | ✅                                                                                        | ❌                                                                                                                |
| Underlying Geocoding service                   | [OpenCage Geocoder](https://opencagedata.com)    | [Google Maps Platform](https://developers.google.com/maps/documentation/geocoding/start) | [Nominatim](https://nominatim.org/release-docs/develop/api/Overview/)                                            |
| Requires payment details before it can be used | ❌                                                | ✅                                                                                        | ❌                                                                                                                |
| Limits on free usage                           | Free use limited to 2,500 requests per day.      | After providing payment details, most users receive $200 of free credit per month.       | Poorly defined usage limits.<br>Unexpected geocoding failure can happen at any time and is difficult to resolve. |

See `vignette("free-usage-of-opencage")` for more information.

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

# Usage

You need an **OpenCage API key** to use this package, sign up for a free
account and obtain your key from
<https://opencagedata.com/dashboard#api-keys>.

Running `oc_config()` in an interactive session will request your API
key. After this has been done once your API key will be stored as an
environmental variable for later use. See `vignette("opencage-api")` for
more details.

## Forward geocoding

Forward geocoding is the conversion of addresses into coordinates, and
is achieved with `oc_forward()`

``` r
library("opencage")
oc_results <- oc_forward("221b Baker St, Marylebone, London NW1 6XE")
oc_results
```

    ## # A tibble: 1 x 2
    ##   oc_query                                  data             
    ##   <chr>                                     <list>           
    ## 1 221b Baker St, Marylebone, London NW1 6XE <tibble [2 × 26]>

The `data` column contains the goecoding results from OpenCage as a
nested tibble. Use `unnest()` from `{tidyr}` to extract this data:

``` r
library("tidyverse")
oc_results %>%
  unnest(cols = data)
```

    ## # A tibble: 2 x 27
    ##   oc_query oc_confidence oc_formatted oc_iso_3166_1_a… oc_iso_3166_1_a…
    ##   <chr>            <int> <chr>        <chr>            <chr>           
    ## 1 221b Ba…            10 London NW1 … GB               GBR             
    ## 2 221b Ba…             9 Sherlock Ho… GB               GBR             
    ## # … with 22 more variables: oc_category <chr>, oc_type <chr>, oc_city <chr>,
    ## #   oc_continent <chr>, oc_country <chr>, oc_country_code <chr>,
    ## #   oc_county <chr>, oc_county_code <chr>, oc_postcode <chr>, oc_state <chr>,
    ## #   oc_state_code <chr>, oc_suburb <chr>, oc_house_number <chr>,
    ## #   oc_museum <chr>, oc_road <chr>, oc_state_district <chr>, oc_lat <dbl>,
    ## #   oc_lng <dbl>, oc_northeast_lat <dbl>, oc_northeast_lng <dbl>,
    ## #   oc_southwest_lat <dbl>, oc_southwest_lng <dbl>

`oc_forward()` can be provided with multiple addresses and restrictions
on search terms, see `vignette("forward-geocoding")` for full details.

``` r
oc_forward(c("High Street, Reading", "Main Street, Reading"),
           countrycode = c("GB", "US"),
           limit = 1)
```

    ## # A tibble: 2 x 2
    ##   oc_query             data             
    ##   <chr>                <list>           
    ## 1 High Street, Reading <tibble [1 × 27]>
    ## 2 Main Street, Reading <tibble [1 × 27]>

To augment an existing `data.frame` with data from OpenCage, use
`oc_forward_df()`:

``` r
street_addresses <- tibble(
  number = c(1, 10),
  street = c("High Street", "Main Street"),
  city = c("Reading", "Reading"),
  countrycode = c("GB", "US")
)

oc_forward_df(street_addresses, placename = paste(street, city, sep = ", "), output = "all")
```

    ## # A tibble: 2 x 6
    ##   number street      city    countrycode oc_query             data             
    ##    <dbl> <chr>       <chr>   <chr>       <chr>                <list>           
    ## 1      1 High Street Reading GB          High Street, Reading <tibble [1 × 27]>
    ## 2     10 Main Street Reading US          Main Street, Reading <tibble [1 × 27]>

## Reverse geocoding

Reverse geocoding is the process of converting geo coordinates into a
street address, and is achieved with `oc_reverse()`

``` r
oc_results <- oc_reverse(latitude = -36.85007, longitude = 174.7706)
oc_results %>%
  unnest(cols = data) %>%
  pull(oc_formatted)
```

    ## [1] "University of Auckland, Alfred Street, Auckland Central, Waitematā 1010, New Zealand"

`oc_reverse()` can be provided with multiple coordinates and be
instructed to attempt to return the nearest road with `roadinfo = TRUE`.
See `vignette("reverse-geocoding")` for more examples.

``` r
oc_results <- oc_reverse(latitude = -36.85007, longitude = 174.7706, roadinfo = TRUE)
oc_results %>%
  unnest(cols = data) %>%
  select(oc_formatted, contains("road")) %>%
  knitr::kable()
```

| oc\_formatted                                                    | oc\_roadinfo\_drive\_on | oc\_roadinfo\_lanes | oc\_roadinfo\_maxspeed | oc\_roadinfo\_road | oc\_roadinfo\_road\_type | oc\_roadinfo\_speed\_in | oc\_roadinfo\_surface | oc\_road          | oc\_road\_type |
| :--------------------------------------------------------------- | :---------------------- | ------------------: | ---------------------: | :----------------- | :----------------------- | :---------------------- | :-------------------- | :---------------- | :------------- |
| Waterloo Quadrant, Auckland Central, Waitematā 1053, New Zealand | left                    |                   4 |                     50 | Waterloo Quadrant  | secondary                | km/h                    | asphalt               | Waterloo Quadrant | secondary      |

## Language

Address specific language is important and OpenCage combines many
different datasets to support multiple languages. See
`vignette("language")` for full details.

## Privacy and GDPR Compliance

See `vignette("opencage-gdpr-compliance")` for details about how
OpenCage processes data sent through the API and how to ensure GDPR
compliance.

## Meta

  - Please [report any issues or
    bugs](https://github.com/ropensci/opencage/issues).
  - License: GPL \>= 2
  - Get citation information for `opencage` in R doing `citation(package
    = 'opencage')`
  - Please note that this project is released with a [Contributor Code
    of Conduct](CONDUCT.md). By participating in this project you agree
    to abide by its terms.

[![ropensci\_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
