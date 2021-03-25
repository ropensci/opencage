test_that("oc_clear_cache clears cache", {
  vcr::use_cassette("oc_clear_cache", {
    oc_get_memoise("https://httpbin.org/get")
  })
  expect_true(memoise::has_cache(oc_get_memoise)("https://httpbin.org/get"))
  oc_clear_cache()
  expect_false(memoise::has_cache(oc_get_memoise)("https://httpbin.org/get"))
})
