
<!-- README.md is generated from README.Rmd. Please edit that file -->

# opencage

<!-- badges: start -->

[![CRAN
Status](https://www.r-pkg.org/badges/version/opencage)](https://cran.r-project.org/package=opencage)
[![CRAN
Checks](https://cranchecks.info/badges/worst/opencage)](https://cran.r-project.org/web/checks/check_results_opencage.html)
[![CRAN Downloads per
Month](https://cranlogs.r-pkg.org/badges/opencage)](https://cran.r-project.org/package=opencage)
[![R build
status](https://github.com/ropensci/opencage/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/opencage/actions)
[![codecov.io](https://codecov.io/github/ropensci/opencage/coverage.svg?branch=master)](https://codecov.io/github/ropensci/opencage?branch=master)
[![rOpenSci
Peer-Review](https://badges.ropensci.org/36_status.svg)](https://github.com/ropensci/software-review/issues/36)
[![License](https://img.shields.io/cran/l/opencage)](https://opensource.org/licenses/gpl-license)

<!-- badges: end -->

Geocode with the [OpenCage](https://opencagedata.com/) API, either from
place name to longitude and latitude (forward geocoding) or from
longitude and latitude to the name and address of the location (reverse
geocoding).

## Installation

Install the package with:

``` r
install.packages("opencage")
```

Or install the development version using
[remotes](https://remotes.r-lib.org/) with:

``` r
remotes::install_github("ropensci/opencage")
```

## Quickstart

For the best experience, we recommend that you read through the
“Introduction to opencage” vignette (`vignette("opencage")`), but if you
are in a hurry:

1.  Register at
    [opencagedata.com/users/sign\_up](https://opencagedata.com/users/sign_up).
2.  Generate an API key at the [OpenCage
    dashboard](https://opencagedata.com/dashboard#api-keys).
3.  Save your API key as an [environment
    variable](https://rstats.wtf/r-startup.html#renviron) like
    `OPENCAGE_KEY=yourkey` in `.Renviron`. See `help(oc_config)` for
    alternative ways to set your OpenCage API key.

Now you are ready to turn place names into latitude and longitude
coordinates:

``` r
library(opencage)
oc_forward_df(placename = "Sarzeau")
```

    ## # A tibble: 1 x 4
    ##   placename oc_lat oc_lng oc_formatted         
    ##   <chr>      <dbl>  <dbl> <chr>                
    ## 1 Sarzeau     47.5  -2.76 56370 Sarzeau, France

Or turn a set of coordinates into the name and address of the location:

``` r
oc_reverse_df(latitude = 51.5034070, longitude = -0.1275920)
```

    ## # A tibble: 1 x 3
    ##   latitude longitude oc_formatted                                               
    ##      <dbl>     <dbl> <chr>                                                      
    ## 1     51.5    -0.128 Prime Minister’s Office, Westminster, 10 Downing Street, L~

But remember, the vignettes are really great! We have:

-   “Introduction to opencage” `vignette("opencage")`
-   “Customise your query” `vignette("customise_query")`
-   “Output options” `vignette("output_options")`

## About OpenCage

The [OpenCage](https://opencagedata.com/) API supports forward and
reverse geocoding. Sources of OpenCage are open geospatial data
including [OpenStreetMap](https://www.openstreetmap.org/),
[DataScienceToolkit](https://github.com/petewarden/dstk), [Yahoo!
GeoPlanet](https://developer.yahoo.com/geo/geoplanet/data/), [Natural
Earth Data](https://www.naturalearthdata.com/),
[libpostal](https://github.com/openvenues/libpostal),
[GeoNames](https://www.geonames.org/), and [Flickr’s
shapefiles](https://code.flickr.net/2009/05/21/flickr-shapefiles-public-dataset-10/)
plus a whole lot more besides. Refer to the current full [list of
credits](https://opencagedata.com/credits).

## Meta

-   Please [report any issues or
    bugs](https://github.com/ropensci/opencage/issues).
-   License: GPL &gt;= 2
-   Get citation information for `opencage` in R doing
    `citation(package = 'opencage')`
-   Please note that this package is released with a [Contributor Code
    of Conduct](https://ropensci.org/code-of-conduct/). By contributing
    to this project, you agree to abide by its terms.
