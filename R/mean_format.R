#' @title Format mean_table Output for Publication and Dissemination
#'
#' @description The mean_format function is intended to make it quick and easy to
#'   format the output of the mean_table function for tables that may be used
#'   for publication. For example, a mean and 95% confidence interval
#'   could be formatted as "24.00 (21.00 - 27.00)."
#'
#' @param .data A data frame of class "mean_table" or "mean_table_grouped".
#'
#' @param recipe A recipe used to create a new column from existing mean_table
#'   columns. The recipe must be in the form of a quoted string. It may contain
#'   any combination of column names, spaces, and characters. For example:
#'   "mean (sd)" or "mean (lcl - ucl)".
#'
#' @param name An optional name to assign to the column created by the recipe.
#'   The default name is "formatted_stats"
#'
#' @param digits The number of decimal places to display.
#'
#' @return A tibble
#' @export
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#' library(meantables)
#'
#' data(mtcars)
#'
#' # Overall mean table with defaults
#'
#' mtcars %>%
#'   mean_table(mpg) %>%
#'   mean_format("mean (sd)") %>%
#'   select(response_var, formatted_stats)
#'
#' # A tibble: 1 × 2
#'   response_var formatted_stats
#'   <chr>        <chr>
#' 1 mpg          20.09 (6.03)
#'
#' # Grouped means table with defaults
#'
#' mtcars %>%
#'   group_by(cyl) %>%
#'   mean_table(mpg) %>%
#'   mean_format("mean (sd)") %>%
#'   select(response_var:group_cat, formatted_stats)
#'
#'   # A tibble: 3 × 4
#'   response_var group_var group_cat formatted_stats
#'   <chr>        <chr>         <dbl> <chr>
#' 1 mpg          cyl               4 26.66 (4.51)
#' 2 mpg          cyl               6 19.74 (1.45)
#' 3 mpg          cyl               8 15.1 (2.56)
#' }
mean_format <- function(.data, recipe, name = NA, digits = NA) {

  # ===========================================================================
  # Prevents R CMD check: "no visible binding for global variable ‘.’"
  # ===========================================================================
  # name = recipe = ingredients = stat = NULL

  # ===========================================================================
  # Check function arguments
  # ===========================================================================
  # If no name given, default to formatted_stats
  if(is.na(name)) {
    name <- "formatted_stats"
  }

  # Break up the recipe into its component pieces
  # [1] "" "n" " (" "percent" ")"
  recipe <- stringr::str_split(recipe, "\\b")
  # First component is always an empty string. Drop it.
  recipe <- unlist(recipe)[-1]

  # Loop over each row of the mean_table
  for(i in seq(nrow(.data))) {
    # Empty vector to hold the stats and symbols that will make up the new
    # variable in that row. The ingredients for the recipe.
    ingredients <- c()
    # Loop over each component of the recipe
    # [1] "n" " (" "percent" ")"
    for(j in seq_along(recipe)) {
      # If that the component is a column in the data frame then grab the value
      # for that column in that row and add it to the ingredients.
      if(recipe[j] %in% names(.data)){
        # Get the stat (e.g., n or percent)
        stat <- .data[[recipe[j]]][i]
        # Round the stat if an argument is supplied to the digits argument
        if(!is.na(digits)) {
          # But don't add trailing zeros to integers
          if(!is.integer(stat)) {
            stat <- round(stat, digits)
            stat <- format(stat, nsmall = digits, big.mark = ",")
            stat <- trimws(stat)
          }
        }
        ingredients <- c(ingredients, stat)
        # If that component is not a column in .data then add it to the
        # ingredients vector as a character.
      } else {
        ingredients <- c(ingredients, recipe[j])
      }
    }
    # Add the new variable to the .data
    .data[i, name] <- paste(ingredients, collapse = "")
  }

  # Return .data with the new variable
  .data
}
