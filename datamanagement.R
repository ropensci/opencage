countrycodes <- readr::read_csv("inst/extdata/countrycodes.csv", na = "")
save(countrycodes, file = "data/countrycodes.RData")
