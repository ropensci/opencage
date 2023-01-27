# test keys ---------------------------------------------------------------
# https://opencagedata.com/api#testingkeys

key_200 <- "6d0e711d72d74daeb2b0bfd2a5cdfdba" # always returns a 200 response
key_402 <- "4372eff77b8343cebfc843eb4da4ddc4" # always returns a 402 responce
key_403 <- "2e10e5e828262eb243ec0b54681d699a" # always returns a 403 responce
key_429 <- "d6d0f0065f4348a4bdfe4587ba02714b" # always returns a 429 responce


# skip if API offline -----------------------------------------------------

skip_if_oc_offline <- function(host = "api.opencagedata.com") {
  testthat::skip_if_offline(host = host)
}


# skip if API key is missing ----------------------------------------------

skip_if_no_key <- function() {
  testthat::skip_if_not(
    condition = oc_key_present(),
    message = "OpenCage API key is missing"
  )
}

# test data ---------------------------------------------------------------

## forward -----------------------------------------------------------------

oc_locs <- function() c("Nantes", "Flensburg", "Los Angeles")

oc_fw1 <- function() tibble::tibble(id = 1:3, loc = oc_locs())

oc_fw2 <- function() {
  tibble::add_column(
    oc_fw1(),
    bounds = oc_bbox(
      xmin = c(-72, -98, -73),
      ymin = c(45, 43, -38),
      xmax = c(-70, -90, -71),
      ymax = c(46, 49, -36)
    ),
    proximity = oc_points(
      latitude = c(45.5, 46, -37),
      longitude = c(-71, -95, -72)
    ),
    countrycode = c("ca", "us", "cl"),
    language = c("de", "fr", "ja"),
    limit = 1:3,
    confidence = c(7, 9, 5),
    annotation = c(FALSE, TRUE, TRUE),
    abbrv = c(FALSE, FALSE, TRUE),
    address_only = c(TRUE, FALSE, FALSE)
  )
}

oc_fw3 <- function() {
  tibble::tibble(
    id = 1:3,
    loc = c("Nantes", "Elbphilharmonie Hamburg", "Los Angeles City Hall"),
    roadinfo = c(FALSE, TRUE, TRUE)
  )
}

## reverse -----------------------------------------------------------------

oc_lat1 <- function() c(47.21864, 53.55034, 34.05369)
oc_lng1 <- function() c(-1.554136, 10.000654, -118.242767)

oc_rev1 <- function() tibble::tibble(id = 1:3, lat = oc_lat1(), lng = oc_lng1())

oc_rev2 <- function() {
  tibble::add_column(
    oc_rev1(),
    language = c("en", "fr", "ja"),
    confidence = rep(1L, 3L),
    annotation = c(FALSE, TRUE, TRUE),
    roadinfo = c(FALSE, TRUE, TRUE),
    abbrv = c(FALSE, FALSE, TRUE),
    address_only = c(TRUE, TRUE, FALSE)
  )
}

oc_rev3 <- function() {
  tibble::add_row(oc_rev2(), id = 4, lat = 25, lng = 36, confidence = 5)
}
