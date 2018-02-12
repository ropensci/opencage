library("opencage")
context("lintr")
if (requireNamespace("lintr", quietly = TRUE)) {
  context("lints")
  test_that("Package Code Style", {
    skip_on_appveyor()
    skip_on_travis()
    skip_on_cran()
    # lintr::expect_lint_free()
  })
}
