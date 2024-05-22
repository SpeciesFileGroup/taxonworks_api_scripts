# Install the development version of Rtaxonworks since it is not published in CRAN yet
install.packages("remotes")
remotes::install_github("SpeciesFileGroup/rtaxonworks")
library(“rtaxonworks”)

# Set API hostname url
TW_API_URL <- "https://sfg.taxonworks.org/api/v1"

# Get the project token from: https://sfg.taxonworks.org/api/v1
# Set the project token:
TW_PROJECT_TOKEN <- "3oerVKf82_196cIECvHYNg"

# To get all results from the simple biological associations table, you can fetch each page and use the dplyr package's bind_rows() function to merge them into a single table in R:
install.packages("dplyr")
library("dplyr") 
# Learn more on dplyr at: https://datacarpentry.org/R-genomics/04-dplyr.html

page <- 1
per <- 10000

res <- tw_dwc_occurrences(page = page, per = per)
results <- res$data
while (page < res$meta$total_pages) {
  page <- page + 1
  res <- tw_dwc_occurrences(page = page, per = per)
  results <- bind_rows(results, res$data)
}

# If you find any issues with the rtaxonworks package or need other API endpoints 
# wrapped that are not yet supported, please open an issue in the GitHub repository:
#
#   https://github.com/SpeciesFileGroup/rtaxonworks/issues
