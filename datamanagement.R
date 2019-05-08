countrycodes <- readr::read_csv("inst/extdata/countrycodes.csv", na = "")
save(countrycodes, file = "data/countrycodes.RData")

languagecodes <- readr::read_csv("inst/extdata/languagecodes.csv", na = "")
save(languagecodes, file = "data/languagecodes.RData")

# From https://opencagedata.com/api#codes
code_message <-
  readr::read_csv(
    "inst/extdata/messages.csv",
    col_types =
      readr::cols(
        code = readr::col_integer(),
        message = readr::col_character()
      )
    )
save(code_message, file = "data/code_message.RData")
