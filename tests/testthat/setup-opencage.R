# keys from https://opencagedata.com/api#testingkeys
key_200 <- "6d0e711d72d74daeb2b0bfd2a5cdfdba" # always returns a 200 response
key_402 <- "4372eff77b8343cebfc843eb4da4ddc4" # always returns a 402 responce
key_403 <- "2e10e5e828262eb243ec0b54681d699a" # always returns a 403 responce
key_429 <- "d6d0f0065f4348a4bdfe4587ba02714b" # always returns a 429 responce

# skip if API offline
skip_if_oc_offline <- function(host = "api.opencagedata.com") {
  testthat::skip_if_offline(host = host)
}

# skip if API key is missing
skip_if_no_key <- function() {
  testthat::skip_if_not(
    condition = oc_key_present(),
    message = "OpenCage API key is missing"
  )
}
