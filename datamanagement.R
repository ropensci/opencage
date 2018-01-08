countrycodes <- readr::read_csv("inst/extdata/countrycodes.csv", na = "")
save(countrycodes, file = "data/countrycodes.RData")

languagecodes <- readr::read_csv("inst/extdata/languagecodes.csv", na = "")
save(languagecodes, file = "data/languagecodes.RData")

code_message <- readr::read_csv("inst/extdata/messages.csv")
save(code_message, file = "data/code_message.RData")
