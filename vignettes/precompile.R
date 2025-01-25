# Pre-compile vignettes that depend on API key

pak::local_install() # make sure to use current local version

library(opencage)
library(knitr)

stopifnot("no OPENCAGE_KEY envvar present" = nzchar(Sys.getenv("OPENCAGE_KEY")))

# write data frames as markdown tables via `knitr::kable()`
knit_print.data.frame = function(x, ...) {
  res = paste0(c(kable(x, output = FALSE)), collapse = "\n")
  asis_output(res)
}
# register the method
registerS3method("knit_print", "data.frame", knit_print.data.frame)

knit("vignettes/opencage.Rmd.src", "vignettes/opencage.Rmd")
knit("vignettes/customise_query.Rmd.src", "vignettes/customise_query.Rmd")

# reset print method for output_options vignette,
# because kable() doesn't print list columns well
knit_print.data.frame = function(x, ...) {
  print(x)
}
# register the method
registerS3method("knit_print", "data.frame", knit_print.data.frame)

knit("vignettes/output_options.Rmd.src", "vignettes/output_options.Rmd")
