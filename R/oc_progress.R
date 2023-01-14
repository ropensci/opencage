#' Initialise progress bar
#'
#' @param vec character vector for which to initialise a progress bar
#'
#' @noRd

oc_init_progress <- function(vec) {
  progress::progress_bar$new(
    format =
      "Retrieving results from OpenCage [:spin] :percent ETA: :eta",
    total = length(vec),
    clear = FALSE,
    width = 60
  )
}

#' Are the conditions met to show a progress bar
#'
#' A progress bar should only be shown
#' - in an interactive session
#' - when not knitting a document (i.e. knitr is in progress)
#' - when not running in an R Notebook (html_notebook) chunk
#'
#' @noRd

oc_show_progress <- function() {
  interactive() &&
  !isTRUE(getOption("knitr.in.progress")) &&
  !isTRUE(getOption("rstudio.notebook.executing"))
}
