countrycodes <- readr::read_csv("inst/extdata/countrycodes.csv")
save(countrycodes, file = "data/countrycodes.RData")

languagecodes <- readr::read_csv("inst/extdata/languagecodes.csv")
save(languagecodes, file = "data/languagecodes.RData")
