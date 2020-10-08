
<!-- README.md is generated from README.Rmd. Please edit that file -->

opencage
========

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/opencage)](http://cran.r-project.org/package=opencage)
[![Build
Status](https://travis-ci.org/ropensci/opencage.svg?branch=master)](https://travis-ci.org/ropensci/opencage)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/ropensci/opencage?branch=master&svg=true)](https://ci.appveyor.com/project/maelle/opencage)
[![codecov.io](https://codecov.io/github/ropensci/opencage/coverage.svg?branch=master)](https://codecov.io/github/ropensci/opencage?branch=master)
[![](https://badges.ropensci.org/36_status.svg)](https://github.com/ropensci/onboarding/issues/36)

Geocode with the [OpenCage](https://opencagedata.com/) API, either from
placename to longitude and latitude (forward geocoding) or from
longitude and latitude to placename (reverse geocoding).

Installation
------------

Install the package with:

    install.packages("opencage")

Or install the development version using
[remotes](https://remotes.r-lib.org/) with:

    remotes::install_github("ropensci/opencage")

Quickstart
----------

For the best experience, we recommend that you read through the “Get
started” vignette (`vignette("intro_opencage")`), but if you are in a
hurry:

1.  Register at
    [opencagedata.com/users/sign\_up](https://opencagedata.com/users/sign_up).
2.  Generate an API key at the [OpenCage
    dashboard](https://opencagedata.com/dashboard#api-keys).
3.  Save your API key as an [environment
    variable](https://rstats.wtf/r-startup.html#renviron) like
    `OPENCAGE_KEY=yourkey` in `.Renviron`. (See `help(oc_config)` for
    alternative ways to set your OpenCage API key.)

Now you are ready to turn placenames into latitude/longitude
coordinates:

    library(opencage)
    oc_forward_df(placename = "Sarzeau")

    ## # A tibble: 1 x 4
    ##   placename oc_lat oc_lng oc_formatted             
    ##   <chr>      <dbl>  <dbl> <chr>                    
    ## 1 Sarzeau     47.5  -2.76 Sarzeau, Morbihan, France

Or turn coordinates into placenames:

    oc_reverse_df(latitude = 51.5034070, longitude = -0.1275920)

    ## # A tibble: 1 x 3
    ##   latitude longitude oc_formatted                                               
    ##      <dbl>     <dbl> <chr>                                                      
    ## 1     51.5    -0.128 Prime Minister’s Office, Westminster, 10 Downing Street, L~

But remember, the vignettes are really great! We have:

-   “Introduction to opencage” `vignette("intro_opencage")`
-   “Customise your query” `vignette("customise_query")`
-   “Output options” `vignette("output_options")`

About OpenCage
--------------

The [OpenCage](https://opencagedata.com/) API supports forward and
reverse geocoding. Sources of OpenCage are open geospatial data
including [OpenStreetMap](https://www.openstreetmap.org/),
[DataScienceToolkit](http://www.datasciencetoolkit.org/), [Yahoo!
GeoPlanet](https://developer.yahoo.com/geo/geoplanet/data/), [Natural
Earth Data](https://www.naturalearthdata.com/),
[OpenGeoCode](http://www.opengeocode.com/),
[libpostal](https://github.com/openvenues/libpostal),
[GeoNames](https://www.geonames.org/), and [Flickr’s
shapefiles](https://code.flickr.net/2009/05/21/flickr-shapefiles-public-dataset-10/)
plus a whole lot more besides. Refer to the current full [list of
credits](https://opencagedata.com/credits).

Meta
----

-   Please [report any issues or
    bugs](https://github.com/ropensci/opencage/issues).
-   License: GPL &gt;= 2
-   Get citation information for `opencage` in R doing
    `citation(package = 'opencage')`
-   Please note that this project is released with a [Contributor Code
    of Conduct](CONDUCT.md). By participating in this project you agree
    to abide by its terms.

[![ropensci\_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
