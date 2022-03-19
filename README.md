
<!-- README.md is generated from README.Rmd. Please edit that file -->

# meantables <img style="padding: 15px;" align="left" src="man/figures/meantables_hex/meantables.png" alt="meantables hex logo" width="250" height="289">

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/meantables)](https://cran.r-project.org/package=meantables)
<!-- badges: end -->

The goal of meantables is to quickly make tables of descriptive
statistics (i.e., counts, means, confidence intervals) for continuous
variables. This package is designed to work in a Tidyverse pipeline, and
consideration has been given to get results from R to ‘Microsoft Word’ ®
with minimal pain.

## Installation

You can install the released version of meantables from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("meantables")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("brad-cannell/meantables")
```

## Example

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(meantables)
```

``` r
data("mtcars")
```

### Overall mean table with defaults

``` r
mtcars %>% 
  mean_table(mpg)
#> # A tibble: 1 × 9
#>   response_var     n  mean    sd   sem   lcl   ucl   min   max
#>   <chr>        <int> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 mpg             32  20.1  6.03  1.07  17.9  22.3  10.4  33.9
```

### Formatting overall mean and 95% CI

``` r
mtcars %>%
  mean_table(mpg) %>%
  mean_format(
    recipe = "mean (lcl - ucl)",
    name = "mean_95",
    digits = 1
  ) %>% 
  select(response_var, mean_95)
#> # A tibble: 1 × 2
#>   response_var mean_95           
#>   <chr>        <chr>             
#> 1 mpg          20.1 (17.9 - 22.3)
```

### Formatting grouped means table with mean and sd

``` r
mtcars %>%
  group_by(cyl) %>%
  mean_table(mpg) %>%
  mean_format("mean (sd)") %>% 
  select(response_var:group_cat, formatted_stats)
#> # A tibble: 3 × 4
#>   response_var group_var group_cat formatted_stats
#>   <chr>        <chr>         <dbl> <chr>          
#> 1 mpg          cyl               4 26.66 (4.51)   
#> 2 mpg          cyl               6 19.74 (1.45)   
#> 3 mpg          cyl               8 15.1 (2.56)
```

### Grouped means table with defaults

``` r
mtcars %>% 
  group_by(cyl) %>% 
  mean_table(mpg)
#> # A tibble: 3 × 11
#>   response_var group_var group_cat     n  mean    sd   sem   lcl   ucl   min
#>   <chr>        <chr>         <dbl> <int> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 mpg          cyl               4    11  26.7  4.51 1.36   23.6  29.7  21.4
#> 2 mpg          cyl               6     7  19.7  1.45 0.549  18.4  21.1  17.8
#> 3 mpg          cyl               8    14  15.1  2.56 0.684  13.6  16.6  10.4
#> # … with 1 more variable: max <dbl>
```
