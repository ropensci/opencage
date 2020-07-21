## ---- echo = FALSE, warning=FALSE, message=FALSE-------------------------
not_cran <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = not_cran,
  eval = not_cran
)
