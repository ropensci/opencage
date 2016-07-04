opencage
========

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/opencage)](http://cran.r-project.org/package=opencage) [![Build Status](https://travis-ci.org/ropenscilabs/opencage.svg?branch=master)](https://travis-ci.org/ropenscilabs/opencage) [![Build status](https://ci.appveyor.com/api/projects/status/w7174arrgs1daskd?svg=true)](https://ci.appveyor.com/project/masalmon/opencage) [![codecov.io](https://codecov.io/github/ropenscilabs/opencage/coverage.svg?branch=master)](https://codecov.io/github/ropenscilabs/opencage?branch=master)

Installation
============

Install the package with:

``` r
install.packages("opencage")
```

Or install the development version using [devtools](https://github.com/hadley/devtools) with:

``` r
library("devtools")
install_github("ropenscilabs/opencage")
```

This package is an interface to the OpenCage API that allows forward and reverse geocoding. To use the package, you will need an API key. To get an API key for OpenCage geocoding, register at <https://geocoder.opencagedata.com/pricing>. The free API key provides up to 2,500 calls a day. For ease of use, save your API key as an environment variable as described at <http://stat545.com/bit003_api-key-env-var.html>.

Both functions of the package will conveniently look for your API key using `Sys.getenv("OPENCAGE_KEY")` so if your API key is an environment variable called "OPENCAGE\_KEY" you don't need to input it manually.

Geocoding
=========

The [OpenCage](https://geocoder.opencagedata.com/) API supports forward and reverse geocoding. Sources of OpenCage are open geospatial data including OpenStreetMap, Yahoo! GeoPlanet, Natural Earth Data, Thematic Mapping, Ordnance Survey OpenSpace, Statistics New Zealand, Zillow, MaxMind, GeoNames, the US Census Bureau and Flickr's shapefiles plus a whole lot more besides. See [this page](https://geocoder.opencagedata.com/credits) for the full list of credits.

Both forward and reverse geocoding typically return multiple results. Regarding these multiple results, the API doc states, "In cases where the geocoder is able to find multiple matches, the geocoder will return multiple results. The confidence or coordinates for each result should be examined to determine whether each result from an ambiguous query is sufficiently high to warrant using a result or not. A good strategy to reduce ambiguity is to use the optional `bounds` parameter described below to limit the area searched." Multiple results might mean you get a result for the airport and a road when querying a city name, or results for cities with the same name in different countries.

Below are two simple examples.

Forward geocoding
-----------------

Forward geocoding is from placename to latitude and longitude tuplet(s).

``` r
library("opencage")
output <- opencage_forward(placename = "Sarzeau")
print(output$time_stamp)
```

    ## [1] "2016-07-04 14:35:00 CEST"

``` r
library("dplyr")
output$rate_info %>% knitr::kable()
```

|  limit|  remaining| rest                |
|------:|----------:|:--------------------|
|   2500|       2065| 2016-07-05 02:00:00 |

``` r
output$results %>% knitr::kable()
```

| bounds.northeast.lat | bounds.northeast.lng | bounds.southwest.lat | bounds.southwest.lng | components.\_type | components.city | components.country | components.country\_code | components.county | components.postcode | components.state | confidence | formatted                                       |  geometry.lat|  geometry.lng| components.post\_office | components.road | components.suburb | components.village |
|:---------------------|:---------------------|:---------------------|:---------------------|:------------------|:----------------|:-------------------|:-------------------------|:------------------|:--------------------|:-----------------|:-----------|:------------------------------------------------|-------------:|-------------:|:------------------------|:----------------|:------------------|:-------------------|
| 47.568813            | -2.6630649           | 47.484236            | -2.8536849           | city              | Sarzeau         | France             | fr                       | Vannes            | 56370               | Brittany         | 6          | 56370 Sarzeau, France                           |      47.52877|       -2.7642| NA                      | NA              | NA                | NA                 |
| 47.5280523           | -2.7687504           | 47.5279523           | -2.7688504           | post\_office      | NA              | France             | fr                       | Vannes            | 56370               | Brittany         | 10         | SARZEAU, Rue de la Poste, 56370 Sarzeau, France |      47.52800|       -2.7688| SARZEAU                 | Rue de la Poste | Kerjolis          | Sarzeau            |

Reverse geocoding
-----------------

Reverse geocoding is from latitude and longitude to placename(s).

``` r
output2 <- opencage_reverse(latitude = 51.5034070, 
                            longitude = -0.1275920)
print(output2$time_stamp)
```

    ## [1] "2016-07-04 14:35:00 CEST"

``` r
output2$rate_info %>% knitr::kable()
```

|  limit|  remaining| rest                |
|------:|----------:|:--------------------|
|   2500|       2064| 2016-07-05 02:00:00 |

``` r
output2$results %>% knitr::kable()
```

| components.\_type | components.attraction | components.city | components.country | components.country\_code | components.house\_number | components.postcode | components.road | components.state | components.state\_district | components.suburb | confidence | formatted                                          |  geometry.lat|  geometry.lng|
|:------------------|:----------------------|:----------------|:-------------------|:-------------------------|:-------------------------|:--------------------|:----------------|:-----------------|:---------------------------|:------------------|:-----------|:---------------------------------------------------|-------------:|-------------:|
| attraction        | 10 Downing Street     | London          | United Kingdom     | gb                       | 10                       | SW1A 2AA            | Downing Street  | England          | Greater London             | Covent Garden     | 10         | 10 Downing Street, London SW1A 2AA, United Kingdom |      51.50344|    -0.1277081|

Output
------

For both `opencage_forward` and `opencage_reverse` functions, the package returns a list with a time stamp for the query, the total number of results, a data.frame (`dplyr tbl_df`) with information about the remaining calls to the API unless you have an unlimited account, and a data.frame (`dplyr tbl_df`) with the results corresponding to your query. You can find longitude and latitude for each results as `geometry.lat` and `geometry.lng`. Other information includes country and country information, time of sunset and sunrise, geohash (a geocoding system identifying a point with a single string, as explained in many more details [here](https://www.elastic.co/guide/en/elasticsearch/guide/current/geohashes.html) and [here](https://en.wikipedia.org/wiki/Geohash); for pure conversion between longitude/latitude and geohashes, see [this package](https://github.com/Ironholds/geohash)). Depending on the data available in the API for the results one gets different columns; there can be a lot to explore!

Parameters
----------

Optional parameters of both `opencage_forward` and `opencage_reverse` can make the query more precise:

-   `bounds`: Provides the geocoder with a hint to the region that the query resides in. This value will restrict the possible results to the supplied region. The bounds parameter should be specified as 4 coordinate points forming the south-west and north-east corners of a bounding box. For example, `bounds = c(-0.563160, 51.280430, 0.278970, 51.683979)` (min long, min lat, max long, max lat).

Below is an example of the use of `bounds` where the rectangle given in the second call does not include Europe so that we don't get results for Berlin in Germany.

``` r
results1 <- opencage_forward(placename = "Berlin")
results1$results %>% knitr::kable()
```

| bounds.northeast.lat | bounds.northeast.lng | bounds.southwest.lat | bounds.southwest.lng | components.\_type | components.city | components.country       | components.country\_code | components.state | confidence | formatted                                                              |  geometry.lat|  geometry.lng| components.county | components.town | components.city\_district |
|:---------------------|:---------------------|:---------------------|:---------------------|:------------------|:----------------|:-------------------------|:-------------------------|:-----------------|:-----------|:-----------------------------------------------------------------------|-------------:|-------------:|:------------------|:----------------|:--------------------------|
| 52.6770365           | 13.5488599           | 52.3570365           | 13.2288599           | city              | Berlin          | Germany                  | de                       | Berlin           | 4          | Berlin, Germany                                                        |     52.517037|      13.38886| NA                | NA              | NA                        |
| 52.6754755           | 13.7611541           | 52.3382449           | 13.0883476           | state             | NA              | Germany                  | de                       | Berlin           | 2          | Berlin, Germany                                                        |     52.519854|      13.43860| NA                | NA              | NA                        |
| 44.528436            | -71.1236419          | 44.445057            | -71.3978579          | city              | Berlin          | United States of America | us                       | New Hampshire    | 5          | Berlin, Coös County, New Hampshire, United States of America           |     44.468670|     -71.18508| Coös County       | NA              | NA                        |
| 41.661488            | -72.7056518          | 41.581488            | -72.7856518          | city              | NA              | United States of America | us                       | Connecticut      | 7          | Berlin, Hartford County, Connecticut, United States of America         |     41.621488|     -72.74565| Hartford County   | Berlin          | NA                        |
| 39.8091498           | -74.9079589          | 39.77601             | -74.9661129          | city              | Berlin          | United States of America | us                       | New Jersey       | 7          | Berlin, Camden County, New Jersey, United States of America            |     39.791226|     -74.92905| Camden County     | NA              | NA                        |
| 42.4182811           | -71.5802309          | 42.3505932           | -71.6787957          | city              | Berlin          | United States of America | us                       | Massachusetts    | 7          | Berlin, Worcester County, Massachusetts, United States of America      |     42.381204|     -71.63701| Worcester County  | NA              | NA                        |
| 38.355184            | -75.1880179          | 38.308406            | -75.2347939          | city              | Berlin          | United States of America | us                       | Maryland         | 7          | Berlin, Worcester County, Maryland, United States of America           |     38.322615|     -75.21769| Worcester County  | NA              | NA                        |
| 43.997968            | -88.9207259          | 43.947614            | -88.9808519          | city              | City of Berlin  | United States of America | us                       | Wisconsin        | 7          | City of Berlin, Green Lake County, Wisconsin, United States of America |     43.968036|     -88.94345| Green Lake County | NA              | NA                        |
| 39.927231            | -78.9372069          | 39.914615            | -78.9657809          | city              | Berlin          | United States of America | us                       | Pennsylvania     | 8          | Berlin, Somerset County, Pennsylvania, United States of America        |     39.920636|     -78.95780| Somerset County   | NA              | NA                        |
| 4.8118583            | -75.6783716          | 4.8088997            | -75.6845896          | neighbourhood     | Pereira         | Colombia                 | co                       | Risaralda        | 9          | Berlin, Pereira, Colombia                                              |      4.810465|     -75.68213| Pereira           | NA              | Berlin                    |

``` r
results2 <- opencage_forward(placename = "Berlin",
                             bounds = c(-90,38,0, 45))
results2$results %>% knitr::kable()
```

| bounds.northeast.lat | bounds.northeast.lng | bounds.southwest.lat | bounds.southwest.lng | components.\_type | components.city | components.country       | components.country\_code | components.county | components.state | confidence | formatted                                                              |  geometry.lat|  geometry.lng| components.town | components.village |
|:---------------------|:---------------------|:---------------------|:---------------------|:------------------|:----------------|:-------------------------|:-------------------------|:------------------|:-----------------|:-----------|:-----------------------------------------------------------------------|-------------:|-------------:|:----------------|:-------------------|
| 44.528436            | -71.1236419          | 44.445057            | -71.3978579          | city              | Berlin          | United States of America | us                       | Coös County       | New Hampshire    | 5          | Berlin, Coös County, New Hampshire, United States of America           |      44.46867|     -71.18508| NA              | NA                 |
| 41.661488            | -72.7056518          | 41.581488            | -72.7856518          | city              | NA              | United States of America | us                       | Hartford County   | Connecticut      | 7          | Berlin, Hartford County, Connecticut, United States of America         |      41.62149|     -72.74565| Berlin          | NA                 |
| 39.8091498           | -74.9079589          | 39.77601             | -74.9661129          | city              | Berlin          | United States of America | us                       | Camden County     | New Jersey       | 7          | Berlin, Camden County, New Jersey, United States of America            |      39.79123|     -74.92905| NA              | NA                 |
| 42.4182811           | -71.5802309          | 42.3505932           | -71.6787957          | city              | Berlin          | United States of America | us                       | Worcester County  | Massachusetts    | 7          | Berlin, Worcester County, Massachusetts, United States of America      |      42.38120|     -71.63701| NA              | NA                 |
| 38.355184            | -75.1880179          | 38.308406            | -75.2347939          | city              | Berlin          | United States of America | us                       | Worcester County  | Maryland         | 7          | Berlin, Worcester County, Maryland, United States of America           |      38.32262|     -75.21769| NA              | NA                 |
| 43.997968            | -88.9207259          | 43.947614            | -88.9808519          | city              | City of Berlin  | United States of America | us                       | Green Lake County | Wisconsin        | 7          | City of Berlin, Green Lake County, Wisconsin, United States of America |      43.96804|     -88.94345| NA              | NA                 |
| 39.927231            | -78.9372069          | 39.914615            | -78.9657809          | city              | Berlin          | United States of America | us                       | Somerset County   | Pennsylvania     | 8          | Berlin, Somerset County, Pennsylvania, United States of America        |      39.92064|     -78.95780| NA              | NA                 |
| 39.764932            | -89.8931649          | 39.750371            | -89.9121009          | city              | Berlin          | United States of America | us                       | Sangamon County   | Illinois         | 8          | Berlin, Sangamon County, Illinois, United States of America            |      39.75894|     -89.90316| NA              | NA                 |
| 42.7131351           | -73.3520548          | 42.6731351           | -73.3920548          | village           | NA              | United States of America | us                       | Rensselaer County | New York         | 7          | Berlin, Rensselaer County, New York, United States of America          |      42.69314|     -73.37205| NA              | Berlin             |
| 40.5811734           | -81.7743004          | 40.5411734           | -81.8143004          | village           | NA              | United States of America | us                       | Holmes County     | Ohio             | 7          | Berlin, Holmes County, Ohio, United States of America                  |      40.56117|     -81.79430| NA              | Berlin             |

-   `countrycode`: Restricts the results to the given country. The country code is a two letter code as defined by the ISO 3166-1 Alpha 2 standard. E.g. "GB" for the United Kingdom, "FR" for France, "US" for United States. See example below.

``` r
results3 <- opencage_forward(placename = "Berlin", country = "DE")
results3$results %>% knitr::kable()
```

| bounds.northeast.lat | bounds.northeast.lng | bounds.southwest.lat | bounds.southwest.lng | components.\_type | components.city | components.country | components.country\_code | components.state       | confidence | formatted                                                            |  geometry.lat|  geometry.lng| components.county                     | components.postcode | components.village | components.road     | components.city\_district  | components.house\_number | components.suburb                    | components.unknown | components.building     | components.residential | components.restaurant | components.town |
|:---------------------|:---------------------|:---------------------|:---------------------|:------------------|:----------------|:-------------------|:-------------------------|:-----------------------|:-----------|:---------------------------------------------------------------------|-------------:|-------------:|:--------------------------------------|:--------------------|:-------------------|:--------------------|:---------------------------|:-------------------------|:-------------------------------------|:-------------------|:------------------------|:-----------------------|:----------------------|:----------------|
| 52.6770365           | 13.5488599           | 52.3570365           | 13.2288599           | city              | Berlin          | Germany            | de                       | Berlin                 | 4          | Berlin, Germany                                                      |      52.51704|     13.388860| NA                                    | NA                  | NA                 | NA                  | NA                         | NA                       | NA                                   | NA                 | NA                      | NA                     | NA                    | NA              |
| 52.6754755           | 13.7611541           | 52.3382449           | 13.0883476           | state             | NA              | Germany            | de                       | Berlin                 | 2          | Berlin, Germany                                                      |      52.51985|     13.438596| NA                                    | NA                  | NA                 | NA                  | NA                         | NA                       | NA                                   | NA                 | NA                      | NA                     | NA                    | NA              |
| 54.0563605           | 10.4661313           | 54.0163605           | 10.4261313           | village           | NA              | Germany            | de                       | Schleswig-Holstein     | 7          | 23823 Berlin, Germany                                                |      54.03636|     10.446131| Trave-Land                            | 23823               | Berlin             | NA                  | NA                         | NA                       | NA                                   | NA                 | NA                      | NA                     | NA                    | NA              |
| 54.4069751           | 9.4342708            | 54.4029778           | 9.4299614            | road              | NA              | Germany            | de                       | Schleswig-Holstein     | 10         | Berlin, 24848 Klein Bennebek, Germany                                |      54.40512|      9.431997| Kropp-Stapelholm                      | 24848               | Klein Bennebek     | Berlin              | NA                         | NA                       | NA                                   | NA                 | NA                      | NA                     | NA                    | NA              |
| 52.5037925           | 13.3300096           | 52.5036925           | 13.3299096           | building          | NA              | Germany            | de                       | Berlin                 | 10         | Berlin, Kurfürstendamm 21, 10719 Berlin, Germany                     |      52.50374|     13.329960| NA                                    | 10719               | NA                 | Kurfürstendamm      | Charlottenburg-Wilmersdorf | 21                       | Charlottenburg                       | Berlin             | NA                      | NA                     | NA                    | NA              |
| 52.370238            | 9.7530007            | 52.370138            | 9.7529007            | road              | Hanover         | Germany            | de                       | Lower Saxony           | 10         | Berliner Allee, 30175 Hanover, Germany                               |      52.37019|      9.752951| Region Hannover                       | 30175               | NA                 | Berliner Allee      | South-City-Bult            | NA                       | South-City                           | Berlin             | NA                      | NA                     | NA                    | NA              |
| 52.5058587           | 13.3323934           | 52.5057587           | 13.3322934           | building          | NA              | Germany            | de                       | Berlin                 | 10         | Berlin, Hardenbergstraße 27-28a, 10623 Berlin, Germany               |      52.50581|     13.332343| NA                                    | 10623               | NA                 | Hardenbergstraße    | Charlottenburg-Wilmersdorf | 27-28a                   | Charlottenburg                       | Berlin             | NA                      | NA                     | NA                    | NA              |
| 53.8513094           | 10.6825311           | 53.8512094           | 10.6824311           | road              | Lübeck          | Germany            | de                       | Schleswig-Holstein     | 10         | Berliner Platz, 23560 Lübeck, Germany                                |      53.85126|     10.682481| NA                                    | 23560               | NA                 | Berliner Platz      | Sankt Jürgen               | NA                       | Hüxtertor / Mühlentor / Gärtnergasse | Berlin             | NA                      | NA                     | NA                    | NA              |
| 52.4569793           | 13.5798073           | 52.4565392           | 13.5784995           | building          | NA              | Germany            | de                       | Berlin                 | 10         | Vitanas Seniorencentrum, Parrisiusstraße 4-14, 12555 Berlin, Germany |      52.45675|     13.579215| NA                                    | 12555               | NA                 | Parrisiusstraße     | Treptow-Köpenick           | 4-14                     | Köpenick                             | NA                 | Vitanas Seniorencentrum | Dammvorstadt           | NA                    | NA              |
| 53.559646            | 13.2550201           | 53.559546            | 13.2549201           | restaurant        | NA              | Germany            | de                       | Mecklenburg-Vorpommern | 10         | Berlin, Fritz-Reuter-Straße 1, 17033 Neubrandenburg, Germany         |      53.55960|     13.254970| Landkreis Mecklenburgische Seenplatte | 17033               | NA                 | Fritz-Reuter-Straße | NA                         | 1                        | Jahnviertel                          | NA                 | NA                      | NA                     | Berlin                | Neubrandenburg  |

-   `language`: an IETF format language code (such as "es" for Spanish or "pt-BR" for Brazilian Portuguese). If no language is explicitly specified, we will look for an HTTP Accept-Language header like those sent by a brower and use the first language specified and if none are specified "en" (English) will be assumed. See example below.

``` r
results3$results %>% knitr::kable()
```

| bounds.northeast.lat | bounds.northeast.lng | bounds.southwest.lat | bounds.southwest.lng | components.\_type | components.city | components.country | components.country\_code | components.state       | confidence | formatted                                                            |  geometry.lat|  geometry.lng| components.county                     | components.postcode | components.village | components.road     | components.city\_district  | components.house\_number | components.suburb                    | components.unknown | components.building     | components.residential | components.restaurant | components.town |
|:---------------------|:---------------------|:---------------------|:---------------------|:------------------|:----------------|:-------------------|:-------------------------|:-----------------------|:-----------|:---------------------------------------------------------------------|-------------:|-------------:|:--------------------------------------|:--------------------|:-------------------|:--------------------|:---------------------------|:-------------------------|:-------------------------------------|:-------------------|:------------------------|:-----------------------|:----------------------|:----------------|
| 52.6770365           | 13.5488599           | 52.3570365           | 13.2288599           | city              | Berlin          | Germany            | de                       | Berlin                 | 4          | Berlin, Germany                                                      |      52.51704|     13.388860| NA                                    | NA                  | NA                 | NA                  | NA                         | NA                       | NA                                   | NA                 | NA                      | NA                     | NA                    | NA              |
| 52.6754755           | 13.7611541           | 52.3382449           | 13.0883476           | state             | NA              | Germany            | de                       | Berlin                 | 2          | Berlin, Germany                                                      |      52.51985|     13.438596| NA                                    | NA                  | NA                 | NA                  | NA                         | NA                       | NA                                   | NA                 | NA                      | NA                     | NA                    | NA              |
| 54.0563605           | 10.4661313           | 54.0163605           | 10.4261313           | village           | NA              | Germany            | de                       | Schleswig-Holstein     | 7          | 23823 Berlin, Germany                                                |      54.03636|     10.446131| Trave-Land                            | 23823               | Berlin             | NA                  | NA                         | NA                       | NA                                   | NA                 | NA                      | NA                     | NA                    | NA              |
| 54.4069751           | 9.4342708            | 54.4029778           | 9.4299614            | road              | NA              | Germany            | de                       | Schleswig-Holstein     | 10         | Berlin, 24848 Klein Bennebek, Germany                                |      54.40512|      9.431997| Kropp-Stapelholm                      | 24848               | Klein Bennebek     | Berlin              | NA                         | NA                       | NA                                   | NA                 | NA                      | NA                     | NA                    | NA              |
| 52.5037925           | 13.3300096           | 52.5036925           | 13.3299096           | building          | NA              | Germany            | de                       | Berlin                 | 10         | Berlin, Kurfürstendamm 21, 10719 Berlin, Germany                     |      52.50374|     13.329960| NA                                    | 10719               | NA                 | Kurfürstendamm      | Charlottenburg-Wilmersdorf | 21                       | Charlottenburg                       | Berlin             | NA                      | NA                     | NA                    | NA              |
| 52.370238            | 9.7530007            | 52.370138            | 9.7529007            | road              | Hanover         | Germany            | de                       | Lower Saxony           | 10         | Berliner Allee, 30175 Hanover, Germany                               |      52.37019|      9.752951| Region Hannover                       | 30175               | NA                 | Berliner Allee      | South-City-Bult            | NA                       | South-City                           | Berlin             | NA                      | NA                     | NA                    | NA              |
| 52.5058587           | 13.3323934           | 52.5057587           | 13.3322934           | building          | NA              | Germany            | de                       | Berlin                 | 10         | Berlin, Hardenbergstraße 27-28a, 10623 Berlin, Germany               |      52.50581|     13.332343| NA                                    | 10623               | NA                 | Hardenbergstraße    | Charlottenburg-Wilmersdorf | 27-28a                   | Charlottenburg                       | Berlin             | NA                      | NA                     | NA                    | NA              |
| 53.8513094           | 10.6825311           | 53.8512094           | 10.6824311           | road              | Lübeck          | Germany            | de                       | Schleswig-Holstein     | 10         | Berliner Platz, 23560 Lübeck, Germany                                |      53.85126|     10.682481| NA                                    | 23560               | NA                 | Berliner Platz      | Sankt Jürgen               | NA                       | Hüxtertor / Mühlentor / Gärtnergasse | Berlin             | NA                      | NA                     | NA                    | NA              |
| 52.4569793           | 13.5798073           | 52.4565392           | 13.5784995           | building          | NA              | Germany            | de                       | Berlin                 | 10         | Vitanas Seniorencentrum, Parrisiusstraße 4-14, 12555 Berlin, Germany |      52.45675|     13.579215| NA                                    | 12555               | NA                 | Parrisiusstraße     | Treptow-Köpenick           | 4-14                     | Köpenick                             | NA                 | Vitanas Seniorencentrum | Dammvorstadt           | NA                    | NA              |
| 53.559646            | 13.2550201           | 53.559546            | 13.2549201           | restaurant        | NA              | Germany            | de                       | Mecklenburg-Vorpommern | 10         | Berlin, Fritz-Reuter-Straße 1, 17033 Neubrandenburg, Germany         |      53.55960|     13.254970| Landkreis Mecklenburgische Seenplatte | 17033               | NA                 | Fritz-Reuter-Straße | NA                         | 1                        | Jahnviertel                          | NA                 | NA                      | NA                     | Berlin                | Neubrandenburg  |

``` r
results4 <- opencage_forward(placename = "Berlin", country = "DE", language = "de")
results4$results %>% knitr::kable()
```

| bounds.northeast.lat | bounds.northeast.lng | bounds.southwest.lat | bounds.southwest.lng | components.\_type | components.city | components.country | components.country\_code | components.state       | confidence | formatted                                                                |  geometry.lat|  geometry.lng| components.county                     | components.postcode | components.village | components.road     | components.city\_district  | components.house\_number | components.suburb                    | components.unknown | components.building     | components.residential | components.restaurant | components.town |
|:---------------------|:---------------------|:---------------------|:---------------------|:------------------|:----------------|:-------------------|:-------------------------|:-----------------------|:-----------|:-------------------------------------------------------------------------|-------------:|-------------:|:--------------------------------------|:--------------------|:-------------------|:--------------------|:---------------------------|:-------------------------|:-------------------------------------|:-------------------|:------------------------|:-----------------------|:----------------------|:----------------|
| 52.6770365           | 13.5488599           | 52.3570365           | 13.2288599           | city              | Berlin          | Deutschland        | de                       | Berlin                 | 4          | Berlin, Deutschland                                                      |      52.51704|     13.388860| NA                                    | NA                  | NA                 | NA                  | NA                         | NA                       | NA                                   | NA                 | NA                      | NA                     | NA                    | NA              |
| 52.6754755           | 13.7611541           | 52.3382449           | 13.0883476           | state             | NA              | Deutschland        | de                       | Berlin                 | 2          | Berlin, Deutschland                                                      |      52.51985|     13.438596| NA                                    | NA                  | NA                 | NA                  | NA                         | NA                       | NA                                   | NA                 | NA                      | NA                     | NA                    | NA              |
| 54.0563605           | 10.4661313           | 54.0163605           | 10.4261313           | village           | NA              | Deutschland        | de                       | Schleswig-Holstein     | 7          | 23823 Berlin, Deutschland                                                |      54.03636|     10.446131| Trave-Land                            | 23823               | Berlin             | NA                  | NA                         | NA                       | NA                                   | NA                 | NA                      | NA                     | NA                    | NA              |
| 54.4069751           | 9.4342708            | 54.4029778           | 9.4299614            | road              | NA              | Deutschland        | de                       | Schleswig-Holstein     | 10         | Berlin, 24848 Klein Bennebek, Deutschland                                |      54.40512|      9.431997| Kropp-Stapelholm                      | 24848               | Klein Bennebek     | Berlin              | NA                         | NA                       | NA                                   | NA                 | NA                      | NA                     | NA                    | NA              |
| 52.5037925           | 13.3300096           | 52.5036925           | 13.3299096           | building          | NA              | Deutschland        | de                       | Berlin                 | 10         | Berlin, Kurfürstendamm 21, 10719 Berlin, Deutschland                     |      52.50374|     13.329960| NA                                    | 10719               | NA                 | Kurfürstendamm      | Charlottenburg-Wilmersdorf | 21                       | Charlottenburg                       | Berlin             | NA                      | NA                     | NA                    | NA              |
| 52.370238            | 9.7530007            | 52.370138            | 9.7529007            | road              | Hannover        | Deutschland        | de                       | Niedersachsen          | 10         | Berliner Allee, 30175 Hannover, Deutschland                              |      52.37019|      9.752951| Region Hannover                       | 30175               | NA                 | Berliner Allee      | Südstadt-Bult              | NA                       | Südstadt                             | Berlin             | NA                      | NA                     | NA                    | NA              |
| 52.5058587           | 13.3323934           | 52.5057587           | 13.3322934           | building          | NA              | Deutschland        | de                       | Berlin                 | 10         | Berlin, Hardenbergstraße 27-28a, 10623 Berlin, Deutschland               |      52.50581|     13.332343| NA                                    | 10623               | NA                 | Hardenbergstraße    | Charlottenburg-Wilmersdorf | 27-28a                   | Charlottenburg                       | Berlin             | NA                      | NA                     | NA                    | NA              |
| 53.8513094           | 10.6825311           | 53.8512094           | 10.6824311           | road              | Lübeck          | Deutschland        | de                       | Schleswig-Holstein     | 10         | Berliner Platz, 23560 Lübeck, Deutschland                                |      53.85126|     10.682481| NA                                    | 23560               | NA                 | Berliner Platz      | Sankt Jürgen               | NA                       | Hüxtertor / Mühlentor / Gärtnergasse | Berlin             | NA                      | NA                     | NA                    | NA              |
| 52.4569793           | 13.5798073           | 52.4565392           | 13.5784995           | building          | NA              | Deutschland        | de                       | Berlin                 | 10         | Vitanas Seniorencentrum, Parrisiusstraße 4-14, 12555 Berlin, Deutschland |      52.45675|     13.579215| NA                                    | 12555               | NA                 | Parrisiusstraße     | Treptow-Köpenick           | 4-14                     | Köpenick                             | NA                 | Vitanas Seniorencentrum | Dammvorstadt           | NA                    | NA              |
| 53.559646            | 13.2550201           | 53.559546            | 13.2549201           | restaurant        | NA              | Deutschland        | de                       | Mecklenburg-Vorpommern | 10         | Berlin, Fritz-Reuter-Straße 1, 17033 Neubrandenburg, Deutschland         |      53.55960|     13.254970| Landkreis Mecklenburgische Seenplatte | 17033               | NA                 | Fritz-Reuter-Straße | NA                         | 1                        | Jahnviertel                          | NA                 | NA                      | NA                     | Berlin                | Neubrandenburg  |

-   `limit`: How many results should be returned (1-100). Default is 10.

-   `min_confidence`: an integer from 1-10. Only results with at least this confidence will be returned.

-   `no_annotations`: Logical (default FALSE), when TRUE the output will not contain annotations.

-   `no_dedupe`: Logical (default FALSE), when TRUE the output will not be deduplicated.

For more information about the output and the query parameters, see the package documentation, the [API doc](https://geocoder.opencagedata.com/api) and [OpenCage FAQ](https://geocoder.opencagedata.com/faq).

Caching
-------

The underlying data at OpenCage is updated about once a day. Note that the package uses [memoise](https://github.com/hadley/memoise) with no timeout argument so that results are cached inside an active R session.

``` r
system.time(opencage_reverse(latitude = 10, longitude = 10))
```

    ##    user  system elapsed 
    ##    0.03    0.01    0.36

``` r
system.time(opencage_reverse(latitude = 10, longitude = 10))
```

    ##    user  system elapsed 
    ##       0       0       0

``` r
memoise::forget(opencage_reverse)
```

    ## [1] TRUE

``` r
system.time(opencage_reverse(latitude = 10, longitude = 10))
```

    ##    user  system elapsed 
    ##    0.01    0.00    0.36

Privacy
-------

Both functions have a parameter `no_record`. It is `FALSE` by default.

-   When `no_record` is `FALSE` a log of the query is made by OpenCage. The company uses them to better generally understand how people are using its service (forward or reverse geocoding, what parts of the world are people most interested in, etc) and for debugging. The overwhelming majority (99.9999+% of queries) are never specifically looked at (sheer volume prevents that) and are automatically deleted after a few days. More information about privacy can be found [here](https://geocoder.opencagedata.com/faq#legal).

-   When `no_record` is `TRUE` the actual query is replaced with FILTERED in OpenCage logs, so that the company has no chance to see what your request was.

Meta
----

-   Please [report any issues or bugs](https://github.com/ropenscilabs/opencage/issues).
-   License: GPL
-   Get citation information for `opencage` in R doing `citation(package = 'opencage')`
-   Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci\_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
