countrycodes <- read.csv("data-raw/countrycodes.csv", na = "")
usethis::use_data(countrycodes, overwrite = TRUE, version = 2)
