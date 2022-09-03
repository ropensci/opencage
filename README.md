
<!-- README.md is generated from README.Rmd. Please edit that file -->

# opencage

<!-- badges: start -->

[![CRAN
Version](https://www.r-pkg.org/badges/version/opencage)](https://cran.r-project.org/package=opencage)
[![CRAN Checks
Status](https://badges.cranchecks.info/worst/opencage.svg)](https://cran.r-project.org/web/checks/check_results_opencage.html)
[![CRAN Downloads per
Month](https://cranlogs.r-pkg.org/badges/opencage)](https://cran.r-project.org/package=opencage)
[![R-universe
status](https://ropensci.r-universe.dev/badges/opencage)](https://ropensci.r-universe.dev/ui#package:opencage)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check Status on GitHub
Actions](https://github.com/ropensci/opencage/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/opencage/actions?query=workflow%3AR-CMD-check)
[![codecov.io
Status](https://codecov.io/github/ropensci/opencage/coverage.svg?branch=main)](https://codecov.io/github/ropensci/opencage?branch=main)
[![rOpenSci
Peer-Review](https://badges.ropensci.org/36_status.svg)](https://github.com/ropensci/software-review/issues/36)
[![License](https://img.shields.io/cran/l/opencage)](https://opensource.org/licenses/gpl-license)

<!-- badges: end -->

Geocode with the [OpenCage](https://opencagedata.com) API, either from
place name to longitude and latitude (forward geocoding) or from
longitude and latitude to the name and address of the location (reverse
geocoding).

## Installation

You can install {opencage} from
[CRAN](https://cran.r-project.org/package=opencage),
[R-universe](https://ropensci.r-universe.dev/ui#package:opencage) or
[GitHub](https://github.com/ropensci/opencage) like this:

- Release version from CRAN

  ``` r
  install.packages("opencage")
  ```

- Development version from R-universe

  ``` r
  install.packages(
    "opencage", 
    repos = c("https://ropensci.r-universe.dev", getOption("repos"))
  )
  ```

- Development version from GitHub with
  {[pak](https://github.com/r-lib/pak/)}

  ``` r
  pak::pak("ropensci/opencage")
  ```

  or with {[remotes](https://github.com/r-lib/remotes/)}

  ``` r
  remotes::install_github("ropensci/opencage")
  ```

## Quickstart

For the best experience, we recommend that you read through the
“[Introduction to
opencage](https://docs.ropensci.org/opencage/articles/opencage.html)”
vignette (`vignette("opencage")`), but if you are in a hurry:

1.  Register at
    [opencagedata.com/users/sign_up](https://opencagedata.com/users/sign_up).
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

| placename |   oc_lat |  oc_lng | oc_formatted          |
|:----------|---------:|--------:|:----------------------|
| Sarzeau   | 47.52877 | -2.7642 | 56370 Sarzeau, France |

Or turn a set of coordinates into the name and address of the location:

``` r
oc_reverse_df(latitude = 51.5034070, longitude = -0.1275920)
```

| latitude | longitude | oc_formatted                                        |
|---------:|----------:|:----------------------------------------------------|
| 51.50341 | -0.127592 | 10 Downing Street, London, SW1A 2AA, United Kingdom |

But remember, the vignettes are really great! We have:

- “[Introduction to
  opencage](https://docs.ropensci.org/opencage/articles/opencage.html)”
  `vignette("opencage")`
- “[Customise your
  query](https://docs.ropensci.org/opencage/articles/customise_query.html)”
  `vignette("customise_query")`
- “[Output
  options](https://docs.ropensci.org/opencage/articles/output_options.html)”
  `vignette("output_options")`

## About OpenCage

The [OpenCage](https://opencagedata.com) API supports forward and
reverse geocoding. Sources of OpenCage are open geospatial data
including [OpenStreetMap](https://www.openstreetmap.org),
[DataScienceToolkit](https://github.com/petewarden/dstk),
[GeoPlanet](https://en.wikipedia.org/wiki/GeoPlanet), [Natural Earth
Data](https://www.naturalearthdata.com),
[libpostal](https://github.com/openvenues/libpostal),
[GeoNames](https://www.geonames.org), and [Flickr’s
shapefiles](https://code.flickr.net/2009/05/21/flickr-shapefiles-public-dataset-10/)
plus a whole lot more besides. Refer to the current full [list of
credits](https://opencagedata.com/credits).

## Code of Conduct

Please note that this package is released with a [Contributor Code of
Conduct](https://ropensci.org/code-of-conduct/). By contributing to this
project, you agree to abide by its terms.
