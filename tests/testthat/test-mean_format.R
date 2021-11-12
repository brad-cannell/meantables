library(dplyr)
library(meantables)

data(mtcars)

testthat::context("test-mean_format.R")

# =============================================================================
# Test ungrouped mean table, stats = mean and 95% CI
# =============================================================================
df <- mtcars %>%
  mean_table(mpg) %>%
  mean_format(
    recipe = "mean (lcl - ucl)",
    name = "mean_95",
    digits = 1
  )

testthat::test_that("Dimensions of the object returned by mean_format are as expected", {
  dims <- dim(df)
  testthat::expect_equal(dims, c(1L, 10L))
})

testthat::test_that("The the name argument to mean_format works as expected", {
  name <- names(df)[10]
  testthat::expect_match(name, "mean_95")
})

testthat::test_that("The correct statistics are returned by mean_format", {
  mean_95 <- pull(df, mean_95)
  testthat::expect_equal(mean_95, "20.1 (17.9 - 22.3)")
})


# =============================================================================
# Test grouped means table, stats = mean and sd
# =============================================================================
df <- mtcars %>%
  group_by(cyl) %>%
  mean_table(mpg) %>%
  mean_format("mean (sd)")

testthat::test_that("Dimensions of the object returned by mean_format are as expected", {
  dims <- dim(df)
  testthat::expect_equal(dims, c(3L, 12L))
})

testthat::test_that("The correct statistics are returned by mean_format", {
  mean_sd <- pull(df, formatted_stats)
  testthat::expect_equal(mean_sd, c("26.66 (4.51)", "19.74 (1.45)", "15.1 (2.56)"))
})


# =============================================================================
# Clean up
# =============================================================================
rm(mtcars, df)
detach("package:dplyr", unload=TRUE)
detach("package:meantables", unload=TRUE)
