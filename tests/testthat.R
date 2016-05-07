library(testthat)
library(opencage)

if (identical(tolower(Sys.getenv("NOT_CRAN")), "true")) {
  test_check("opencage")
}
