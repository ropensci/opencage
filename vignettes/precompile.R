# Precompiled vignettes that depend on API key

library(knitr) # also load the current version of the package
knit("vignettes/intro_opencage.Rmd.src", "vignettes/intro_opencage.Rmd")
knit("vignettes/customise_query.Rmd.src", "vignettes/customise_query.Rmd")
knit("vignettes/output_options.Rmd.src", "vignettes/output_options.Rmd")
