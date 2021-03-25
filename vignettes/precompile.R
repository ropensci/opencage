# Precompiled vignettes that depend on API key

library(knitr) # also load the current version of the package
stopifnot("no OPENCAGE_KEY envvar present" = nzchar(Sys.getenv("OPENCAGE_KEY")))
knit("vignettes/opencage.Rmd.src", "vignettes/opencage.Rmd")
knit("vignettes/customise_query.Rmd.src", "vignettes/customise_query.Rmd")
knit("vignettes/output_options.Rmd.src", "vignettes/output_options.Rmd")
