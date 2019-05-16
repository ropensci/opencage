countrycodes <- readr::read_csv("inst/extdata/countrycodes.csv", na = "")
save(countrycodes, file = "data/countrycodes.RData")

languagecodes <- readr::read_csv("inst/extdata/languagecodes.csv", na = "")
save(languagecodes, file = "data/languagecodes.RData")
