library("opencage")
context("lintr")
if (requireNamespace("lintr", quietly = TRUE)) {
  context("lints")
  test_that("Package Code Style", {
    lintr::expect_lint_free()
  })
}
