#' @title Estimate Percents and 95 Percent Confidence Intervals in dplyr Pipelines
#'
#' @description The mean_table function produces overall and grouped
#'   tables of means with related statistics. In addition to means, the
#'   mean_table missing/non-missing frequencies, the standared error of the
#'   mean (sem), the 95% confidence intervals for the mean(s), the minimum
#'   value, and the maximum value. For grouped tibbles, mean_table displays
#'   these statistics for each category of the group_by variable.
#'
#' @param .data A tibble or grouped tibble.
#'
#' @param x The continuous response variable for which the statistics are
#'   desired.
#'
#' @param t_prob (1 - alpha / 2). Default value is 0.975, which corresponds to
#'   an alpha of 0.05. Used to calculate a critical value from Student's t
#'   distribution with n - 1 degrees of freedom.
#'
#' @param output Options for this parameter are "default" and "all".
#'
#'   Default output includes the n, mean, sem, and 95% confidence interval for
#'   the mean. Using output = "all" also returns the the number of missing
#'   values for x and the critical t-value.
#'
#' @param digits Round mean, lcl, and ucl to digits. Default is 2.
#'
#' @param ... Other parameters to be passed on.
#'
#' @return A tibble of class "mean_table" or "mean_table_grouped"
#' @export
#'
#' @references
#'   SAS documentation: http://support.sas.com/documentation/cdl/en/proc/65145/HTML/default/viewer.htm#p0klmrp4k89pz0n1p72t0clpavyx.htm
#'
#' @examples
#' library(tidyverse)
#' library(bfuncs)
#'
#' data(mtcars)
#'
#' # Overall mean table with defaults
#'
#' mtcars %>%
#'   mean_table(mpg)
#'
#' #> # A tibble: 1 x 8
#' #>   response_var     n  mean      sem   lcl   ucl   min   max
#' #>          <chr> <int> <dbl>    <dbl> <dbl> <dbl> <dbl> <dbl>
#' #> 1          mpg    32 20.09 1.065424 17.92 22.26  10.4  33.9
#'
#' # Grouped means table with defaults
#'
#' mtcars %>%
#'   group_by(cyl) %>%
#'   mean_table(mpg)
#'
#' #> # A tibble: 3 x 10
#' #>   response_var group_var group_cat     n  mean       sem   lcl   ucl   min   max
#' #>          <chr>     <chr>     <dbl> <int> <dbl>     <dbl> <dbl> <dbl> <dbl> <dbl>
#' #> 1          mpg       cyl         4    11 26.66 1.3597642 23.63 29.69  21.4  33.9
#' #> 2          mpg       cyl         6     7 19.74 0.5493967 18.40 21.09  17.8  21.4
#' #> 3          mpg       cyl         8    14 15.10 0.6842016 13.62 16.58  10.4  19.2

mean_table <- function(.data, x, t_prob = 0.975, output = default, digits = 2, ...) {

  # ------------------------------------------------------------------
  # Prevents R CMD check: "no visible binding for global variable ‘.’"
  # ------------------------------------------------------------------
  n = t_crit = sem = lcl = ucl = var = n_groups = group_1 = NULL
  group_2 = output_arg = default = response_var = `.` = NULL
  group_var = group_cat = group_1_cat = group_2_cat = n_miss = NULL

  # ===========================================================================
  # Quick data checks
  # Input data frame is class data.frame
  # The "x" argument is a numeric vector
  # There are zero, one, or two group_by variables
  # ===========================================================================
  if (!("data.frame" %in% class(.data))) {
    message("Expecting the class of .data to include data.frame. Instead, the ",
            "class was ", class(.data))
  }

  if (missing(x)) {
    stop("No argument was passed to the 'x' parameter. Expecting 'x' to be a ",
         "numeric column.")
  }

  # ===========================================================================
  # Enquo arguments
  # enquo the x argument so that it can be used in the dplyr pipeline below.
  # The x argument is the variable you want the mean of.
  # enquo/quo_name/UQ the output argument so that I don't have to use
  # quotation marks around the argument being passed.
  # ===========================================================================
  x          <- rlang::enquo(x)
  output_arg <- rlang::enquo(output) %>% rlang::quo_name()

  # ===========================================================================
  # Grouping variables
  # Count the number of them - accept zero, one, or two
  # Grab their names - later returned in summary table
  # ===========================================================================
  if ("grouped_df" %in% class(.data)) {
    n_groups <- attributes(.data)$groups %>% length() - 1
  } else {
    n_groups <- 0L
  }

  if (n_groups == 1) {
    group_1 <- attributes(.data)$groups[1] %>% names()

  } else if (n_groups == 2) {
    group_1 <- attributes(.data)$groups[1] %>% names()
    group_2 <- attributes(.data)$groups[2] %>% names()

  } else if (n_groups > 2) {
    stop(".data can be grouped by up to two variables. It is currently grouped ",
         n_groups, " variables")
  }

  # ===========================================================================
  # First, create a general summary table of means and related stats. Then, add
  # group variable names to summary table where applicable
  # 1. No group_by variables
  # 2. One group_by variable
  # 3. Two group_by variables
  # ===========================================================================
  out <- .data %>%
    # Drop missing
    dplyr::filter(!is.na(!! x)) %>%
    dplyr::summarise(
      # Grab variable (x) name
      response_var = rlang::quo_name(x),
      # Count missing from before drop
      n_miss   = is.na(.data[[rlang::quo_name(x)]]) %>% sum(),
      n        = n(),
      mean     = mean(!! x),
      t_crit   = stats::qt(t_prob, n - 1),
      sem      = stats::sd(!! x) / sqrt(n),
      lcl      = mean - t_crit * sem,
      ucl      = mean + t_crit * sem,
      mean     = round(mean, digits),   # Round mean
      lcl      = round(lcl, digits),    # Round lcl
      ucl      = round(ucl, digits),    # Round ucl
      min      = min(!! x),
      max      = max(!! x)
    ) %>%
    tibble::as.tibble()

  # ===========================================================================
  # Add group variable names to summary table - if applicable
  # Then move to the front of the summary table.

  # Also add classes to "out"
  # If the input data frame (.data) was a grouped data frame, then the output
  # will be a bivariate analysis of means ("mean_table_grouped"). Pass that
  # information on to "out." It can be used later in format_table.
  # Otherwise the output will be a univariate analysis of means ("mean_table")
  # That class will also be used later in format_table.
  # ===========================================================================
  if (n_groups == 0) {

    out <- out %>%
      dplyr::select(response_var, dplyr::everything())
    class(out) <- c("mean_table", class(out))

  }
  else if (n_groups == 1) {

    out <- out %>%
      dplyr::mutate(group_var = group_1) %>%
      dplyr::rename(group_cat = !! names(.)[1]) %>%
      dplyr::select(response_var, group_var, group_cat, dplyr::everything())
    class(out) <- c("mean_table_grouped", class(out))

  } else if (n_groups == 2) {

    out <- out %>%
      dplyr::mutate(
        group_1 = group_1,
        group_2 = group_2
      ) %>%
      dplyr::rename(
        group_1_cat = !! names(.)[1],
        group_2_cat = !! names(.)[2]
      ) %>%
      dplyr::select(response_var, group_1, group_1_cat, group_2, group_2_cat,
                    dplyr::everything()) %>%
      dplyr::ungroup()
    class(out) <- c("mean_table_grouped", class(out))
  }

  # ===========================================================================
  # Control output:
  # Typically, I only want the frequency, mean, 95% CI, sem, min, and max.
  # Make that the default.
  # ===========================================================================
  if (output_arg == "default") {
    out <- out %>%
      dplyr::select(-c(n_miss, t_crit))
  }

  # Return summary table
  out
}
