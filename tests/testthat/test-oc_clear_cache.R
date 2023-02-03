test_that("oc_clear_cache clears cache", {
  skip_on_cran()
  skip_if_offline("httpbin.org")

  # until a memoise >v.1.1 is released, we need to run oc_get_memoise() twice to
  # have it really cache results
  # https://github.com/ropensci/opencage/pull/87#issuecomment-573573183
  replicate(2, oc_get_memoise())
  expect_true(memoise::has_cache(oc_get_memoise)())
  oc_clear_cache()
  expect_false(memoise::has_cache(oc_get_memoise)())
})
