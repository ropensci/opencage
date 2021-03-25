# opencage (development version)

* The geocoding functions will not send a query to the API anymore if no API key is present (#133).
* {opencage} now uses {[vcr](https://docs.ropensci.org/vcr/)} for tests that make API requests (#48, #87, #130, #137).

# opencage 0.2.2

* Fixed a test that caused an error on CRAN's Solaris (#131).

# opencage 0.2.1

This is a major rewrite of the {opencage} package. `opencage_forward()` and `opencage_reverse()` have been deprecated and are superseded by `oc_forward()` and `oc_reverse()`, respectively. In addition there are two new functions `oc_forward_df()` and `oc_reverse_df()`, which geocode place names or addresses into geographic coordinates (latitude and longitude) or vice versa, and return a data frame. 

The new features include:

* `oc_forward()` and `oc_reverse()` return either lists of data frames, JSON strings, GeoJSON strings, or URLs to be sent to the API (the latter for debugging purposes).
* `oc_forward_df()` and `oc_reverse_df()` take a data frame or vectors as input and return a data frame with the geocoding results, optionally with the source data frame bound to the results data frame. 
* Almost all arguments of the geocoding functions are vectorised (the exceptions being `output`), so it is possible to serially (reverse) geocode lists of locations or coordinates. The geocoding functions show a progress indicator when more than one `placename` or `latitude`/`longitude` pair is provided.
* The forward geocoding functions now support multiple `countrycode`s in accordance with the OpenCage API (#44). The `countrycode`s can now be provided in upper or lower case (#47).
* A helper function `oc_bbox()` now makes it easier to create a list of bounding boxes from numeric vectors, bbox objects or data frames. 
* `oc_forward` and `oc_forward_df` now support [OpenCage's `proximity` parameter](https://blog.opencagedata.com/post/new-optional-parameter-proximity). The results of the geocoding request will be biased towards that location (#60).
* A helper function `oc_points()` now makes it easier to create a list of point coordinates from numeric vectors or data frames to pass to the `proximity` argument for example. 
* All geocoding functions now support [OpenCage's `roadinfo` parameter](https://blog.opencagedata.com/post/new-optional-parameter-roadinfo) (#65). If set to `TRUE`, OpenCage attempts to match the nearest road (rather than an address) and provides additional road and driving information.
* Language tags passed to the `language` argument are not validated anymore, since the language tags used by OpenStreetMap and hence OpenCage do not always conform with the IETF BCP 47 standard (#90). The `languagecodes`, which were stored in {opencage} as external data, have therefore been omitted from the package. In addition, it is now possible to specify `language = "native"`, so OpenCage will attempt to return the [results in the "official" language](https://blog.opencagedata.com/post/support-for-local-language) of the country. 
* http requests are now handled by {[crul](https://docs.ropensci.org/crul/)}, not {[httr](https://httr.r-lib.org)} (#37).
* API calls are now rate limited (#32). The default limit is set to 1 call per second as per the API limit of the [Free Trial plan](https://opencagedata.com/pricing).
* {opencage} settings like the OpenCage API key or the API rate limit can be configured with `oc_config()`. If you want OpenCage to have no record of the contents of your queries, you can also set the `no_record` parameter for the active R session with `oc_config()` (as opposed to providing the parameter with each function call). All `oc_config()` settings can be set more permanently via `options()` or environment variables, see `help(oc_config)`.

## Breaking changes

* `opencage_forward()`, `opencage_reverse()`, and `opencage_key()` are [soft-deprecated](https://lifecycle.r-lib.org/reference/deprecate_soft.html). 
* `opencage_forward()` and `opencage_reverse()` will always output strings as characters, i.e. they won't coerce to factor depending on the `stringsAsFactor` option.
* `opencage_key()` returns the OpenCage API key invisibly.
* `NA` values are not allowed anymore for the `placename` or `latitude`/`longitude` arguments, because OpenCage throws a HTTP 400 ‘bad query’ error when the query is empty (#98). 

## Minor changes

* The column name for `countrycodes` is now `code`, not `Code`. 
* HTTP error messages are now returned directly from the API and are therefore always up-to-date. The previously used responses in `code_message`, which were stored in {opencage} as external data, have been deleted. For more information on OpenCage's HTTP status codes see https://opencagedata.com/api#codes.
* Fixed two URLs, one of which was rejected on the v0.2.0 submission.

# opencage 0.1.4

* Bug fix: now the `countrycode` argument can be used for Namibia (#24, #25).

# opencage 0.1.3

* Added a `add_request` parameter (for appending original query to results).

# opencage 0.1.2

* Added a `abbrv` parameter, see https://blog.opencagedata.com/post/160294347883/shrtr-pls.

# opencage 0.1.1

* Added a `no_record` parameter, see https://blog.opencagedata.com/post/145602604628/more-privacy-with-norecord-parameter

# opencage 0.1.0

* Added a `NEWS.md` file to track changes to the package.
