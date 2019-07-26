## Test oc_key ##
test_that("`oc_key()` returns NULL if the OPENCAGE_KEY envvar is not found", {
  withr::local_envvar(c("OPENCAGE_KEY" = ""))
  expect_null(oc_key())
})

test_that("`oc_key(quiet = FALSE)` messages", {
  withr::local_envvar(c("OPENCAGE_KEY" = "fakekey"))
  expect_message(
    object = oc_key(quiet = FALSE),
    regexp = "Using Opencage API Key from envvar OPENCAGE_KEY"
  )
})
