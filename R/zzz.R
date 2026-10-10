# We use `assign()` below to modify the package's namespace.
# It doesn't modify the global environment.
# We do this to prevent build time dependencies on {memoise} and {ratelimitr},
# as recommended in <http://memoise.r-lib.org/reference/memoise.html#details>.
# Cf. <https://github.com/r-lib/memoise/issues/76> for further details.

# First make sure that the functions are defined at build time
oc_get_limited <- oc_get
oc_get_memoise <- oc_get_limited

# Then modify them at load-time
# nocov start
.onLoad <- function(libname, pkgname) {
  ns <- asNamespace(pkgname)

  # limit requests per second
  assign(
    "oc_get_limited",
    ratelimitr::limit_rate(
      oc_get,
      # rate can be changed via oc_config()/ratelimitr::UPDATE_RATE()
      ratelimitr::rate(
        n = 1L,
        period = 1L
      )
    ),
    envir = ns
  )

  assign(
    "oc_get_memoise",
    memoise::memoise(oc_get_limited),
    envir = ns
  )
}
# nocov end
