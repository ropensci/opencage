# initialise progress bar
oc_init_progress <- function(vec) {
  progress::progress_bar$new(
    format =
      "Retrieving results from OpenCage [:spin] :percent ETA: :eta",
    total = length(vec),
    clear = FALSE,
    width = 60
  )
}

# check whether to show progress
oc_show_progress <- function() {
  # in an interactive session
  interactive() &&
  # not when actively knitting a document
  !isTRUE(getOption("knitr.in.progress")) &&
  # not when running in an RStudio notebook chunk
  !isTRUE(getOption("rstudio.notebook.executing"))
}
