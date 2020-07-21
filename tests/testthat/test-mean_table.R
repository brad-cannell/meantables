library(dplyr)
library(meantables)

data(mtcars)

testthat::context("test-mean_table.R")

# =============================================================================
# Test one-way mean tables
# =============================================================================
df <- mtcars %>%
  mean_table(mpg)

testthat::test_that("Dimensions of the object returned by mean_table are as expected", {
  rows    <- nrow(df)
  columns <- ncol(df)

  testthat::expect_equal(rows, 1L)
  testthat::expect_equal(columns, 8L)
})

testthat::test_that("Class of mean_table_one_way is mean_table", {
  testthat::expect_is(df, "mean_table")
})

testthat::test_that("The correct var name is returned by mean_table", {
  name <- names(df)[1]
  testthat::expect_match(name, "response_var")
})

testthat::test_that("The correct default statistics are returned by mean_table", {
  n    <- pull(df, n)
  mean <- pull(df, mean)
  sem  <- pull(df, sem) %>% round(2)
  lcl  <- pull(df, lcl) %>% round(2)
  ucl  <- pull(df, ucl) %>% round(2)
  min  <- pull(df, min)
  max  <- pull(df, max)

  testthat::expect_equal(n, 32)
  testthat::expect_equal(mean, 20.09)
  testthat::expect_equal(sem, 1.07)
  testthat::expect_equal(lcl, 17.92)
  testthat::expect_equal(ucl, 22.26)
  testthat::expect_equal(min, 10.4)
  testthat::expect_equal(max, 33.9)
})


# =============================================================================
# Test grouped mean tables
# =============================================================================
df <- mtcars %>%
  group_by(cyl) %>%
  mean_table(mpg)

testthat::test_that("Dimensions of the object returned by mean_table are as expected", {
  rows    <- nrow(df)
  columns <- ncol(df)

  testthat::expect_equal(rows, 3L)
  testthat::expect_equal(columns, 10L)
})

testthat::test_that("Class of mean_table_two_way is mean_table_grouped", {
  testthat::expect_is(df, "mean_table_grouped")
})

testthat::test_that("The correct var names are returned by mean_table", {
  row_var <- pull(df, response_var)
  col_var <- pull(df, group_var)

  testthat::expect_match(row_var, "mpg")
  testthat::expect_match(col_var, "cyl")
})

testthat::test_that("The correct variables levels are returned by mean_table", {
  group_cat <- pull(df, group_cat)

  testthat::expect_equal(group_cat, c(4, 6, 8))
})

testthat::test_that("The correct default statistics are returned by mean_table", {
  n    <- pull(df, n)
  mean <- pull(df, mean)
  sem  <- pull(df, sem) %>% round(2)
  lcl  <- pull(df, lcl) %>% round(2)
  ucl  <- pull(df, ucl) %>% round(2)
  min  <- pull(df, min)
  max  <- pull(df, max)

  testthat::expect_equal(n, c(11, 7, 14))
  testthat::expect_equal(mean, c(26.66, 19.74, 15.10))
  testthat::expect_equal(sem, c(1.36, 0.55, 0.68))
  testthat::expect_equal(lcl, c(23.63, 18.40, 13.62))
  testthat::expect_equal(ucl, c(29.69, 21.09, 16.58))
  testthat::expect_equal(min, c(21.4, 17.8, 10.4))
  testthat::expect_equal(max, c(33.9, 21.4, 19.2))
})


# =============================================================================
# Clean up
# =============================================================================
rm(mtcars, df)
detach("package:dplyr", unload=TRUE)
detach("package:meantables", unload=TRUE)
