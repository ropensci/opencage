# We use `<<-` below to modify the package's namespace.
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
  # limit requests per second
  oc_get_limited <<-
    ratelimitr::limit_rate(
      oc_get,
      # rate can be changed via oc_config()/ratelimitr::UPDATE_RATE()
      ratelimitr::rate(
        n = 1L,
        period = 1L
      )
    )

  oc_get_memoise <<- memoise::memoise(oc_get_limited)
}
# nocov end
