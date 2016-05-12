## ---- echo = FALSE, warning=FALSE, message=FALSE-------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN,
  eval = NOT_CRAN
)

## ---- warning = FALSE, message = FALSE-----------------------------------
library("opencage")
output <- opencage_forward(placename = "Sarzeau")
print(output$time_stamp)
library("dplyr")
output$rate_info %>% knitr::kable()
output$results %>% knitr::kable()

## ---- message=FALSE------------------------------------------------------
output2 <- opencage_reverse(latitude = 51.5034070, 
                            longitude = -0.1275920)
print(output2$time_stamp)
output2$rate_info %>% knitr::kable()
output2$results %>% knitr::kable()

## ---- message=FALSE------------------------------------------------------
results1 <- opencage_forward(placename = "Berlin")
results1$results %>% knitr::kable()
results2 <- opencage_forward(placename = "Berlin",
                             bounds = c(-90,38,0, 45))
results2$results %>% knitr::kable()

## ---- message=FALSE------------------------------------------------------
results3 <- opencage_forward(placename = "Berlin", country = "DE")
results3$results %>% knitr::kable()


## ---- message=FALSE------------------------------------------------------
results3$results %>% knitr::kable()
results4 <- opencage_forward(placename = "Berlin", country = "DE", language = "de")
results4$results %>% knitr::kable()


## ---- message=FALSE------------------------------------------------------
system.time(opencage_reverse(latitude = 10, longitude = 10))

system.time(opencage_reverse(latitude = 10, longitude = 10))

memoise::forget(opencage_reverse)
system.time(opencage_reverse(latitude = 10, longitude = 10))


