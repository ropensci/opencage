#' @importFrom magrittr `%>%`

# We use `<<-` below to modify the package's namespace.
# It doesn't modify the global environment.
# We do this to prevent build time dependencies on {memoise},
# as recommended in <http://memoise.r-lib.org/reference/memoise.html#details>.
# Cf. <https://github.com/r-lib/memoise/issues/76> for further details.

# First make sure that the function is defined at build time
oc_get_memoise <- oc_get

# Then modify them at load-time
# nocov start
.onLoad <- function(libname, pkgname) {
  oc_get_memoise <<- memoise::memoise(oc_get)
}
# nocov end
