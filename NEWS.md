# opencage 0.1.4.9002

This is a major rewrite of the {opencage} package. `opencage_forward()` and `opencage_reverse()` have been deprecated and are superseded by `oc_forward()` and `oc_reverse()`, respectively. In addition there are two new functions `oc_forward_df()` and `oc_reverse_df()`, which (reverse) geocode a `placename` column (or `latitude`/`longitude` columns) in a data frame. 

The new features include:

* `oc_forward()` and `oc_reverse()` return either lists of data frames, JSON strings, GeoJSON strings, or URLs to be sent to the API (for debugging purposes).
* `oc_forward_df()` and `oc_reverse_df()` take a data frame as input and return a data frame with the geocoding results, optionally with the source data frame bound to the results data frame. 
* Almost all arguments of the geocoding functions are vectorised (the exceptions being `output`, `key` and `no_record`), so it is possible to serially (reverse) geocode lists of placenames or coordinates. The geocoding functions show a progress indicator when more than one `placename` or `latitude`/`longitude` pair is provided.
* The forward geocoding functions now support multiple `countrycode`s in accordance with the OpenCage API (#44). The `countrycode`s can now be provided in upper or lower case (#47).
* A helper function `oc_bbox()` now makes it easier to create (lists of) bounding boxes from vectors, bbox objects and data frames. 
* http requests are now handled by {[crul](https://ropensci.github.io/crul/)}, not {[httr](http://httr.r-lib.org/)} (#37).
* API calls are now rate limited (#32). The default limit is set to 1 call per second as per the API limit of the [Free Trial plan](https://opencagedata.com/pricing). The rate limit can be adjusted with `oc_config()`.

## Breaking changes

* `opencage_forward()`, `opencage_reverse()`, and `opencage_key()` are (soft) deprecated. `opencage_key()` has just been renamed to `oc_key()` for consistency.
* `opencage_forward()` and `opencage_reverse()` will always output strings as characters, i.e. they won't coerce to factor depending on the `stringsAsFactor` option.

## Minor changes

* The column name for both `languagecodes` and `countrycodes` is now `code`, and not `alpha2` and `Code`, respectively. 
* HTTP error messages are now returned directly from the API and are therefore always up-to-date. The previously used responses in `code_message`, which were stored in opencage as external data, have been deleted. For more information on OpenCage's HTTP status codes see https://opencagedata.com/api#codes.

# opencage 0.1.4

* Bug fix: now the `countrycode` argument can be used for Namibia (#24, #25).

# opencage 0.1.3

* Added a `add_request` parameter (for appending original query to results).

# opencage 0.1.2

* Added a `abbrv` parameter, see http://blog.opencagedata.com/post/160294347883/shrtr-pls.

# opencage 0.1.1

* Added a `no_record` parameter, see http://blog.opencagedata.com/post/145602604628/more-privacy-with-norecord-parameter

# opencage 0.1.0

* Added a `NEWS.md` file to track changes to the package.




