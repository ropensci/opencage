test_that("oc_clear_cache clears cache", {
  skip_on_cran()
  skip_if_offline("httpbin.org")

  replicate(2, oc_get_memoise())
  expect_true(memoise::has_cache(oc_get_memoise)())
  oc_clear_cache()
  expect_false(memoise::has_cache(oc_get_memoise)())
})
