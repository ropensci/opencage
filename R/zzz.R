
# Prevent build-time dependencies on {ratelimitr} and {memoise}
# The functions do not get ratelimited/memoised at build-time, but when the
# package is loaded.
# cf. https://github.com/r-lib/memoise/issues/76

# First make sure that the functions are defined at build time
oc_get_limited <- oc_get
oc_get_memoise <- oc_get_limited

# Then modify them at load-time
# nocov start
.onLoad <- function(libname, pkgname) { # nolint because snake_case
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
