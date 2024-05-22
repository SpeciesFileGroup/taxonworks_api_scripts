# Goal: To show some examples of how to use the rtaxonworks package to access the TaxonWorks API
#
# Inspiration: https://app.element.io/#/room/#TaxonWorks:gitter.im/$OlM8HdXYoLNGp81EcL0i441CYjJoXUOHx4l4i6gxAzA

# This short tutorial covers:
# 1. How to install and setup the rtaxonworks package
# 2. How to access the simple biological associations table
# 3. How to join the OTU and TaxonName tables using the sqldf package
# 4. How to get Darwin Core inventory for an OTU
# 5. Where to open issue tickets for the rtaxonworks package if you find a bug or need additional endpoints wrapped


# 1. How to install and setup the rtaxonworks package

# Install the rtaxonworks package
install.packages("rtaxonworks")

# If the above command fails, the package may not be published in CRAN yet, but you can install the development version with:
install.packages("remotes")
remotes::install_github("SpeciesFileGroup/rtaxonworks")

# Load the rtaxonworks package
require("rtaxonworks")

# Set the URL for the TaxonWorks API
# For the examples in this script, we will use the sandbox environment, but
# you likely might want to set this to the production environment at:

TW_API_URL <- "https://sandbox.taxonworks.org/api/v1"  # sandbox environment
# TW_API_URL <- "https://sfg.taxonworks.org/api/v1"  # production environment

# In order to authenticate yourself for API access and specify the project that you want to access it is necessary to setup API tokens
# You can view the list of open projects to get a project token.
tw_projects()

# You'll see output similar to below with "cmLdk2o_O1-OYSjAxjqQfQ" being a project token:
#
#                                  name          project_token
# 1                             Seabase (redacted)
# 2                         TPT Sandbox (redacted)
# 3                            Lepindex (redacted)
# 4                  3i Auchenorrhyncha cmLdk2o_O1-OYSjAxjqQfQ

# Set the API project token which you can find at: https://sandbox.taxonworks.org/api/v1 (replacing the sandbox hostname with the one you are using)
TW_PROJECT_TOKEN = "cmLdk2o_O1-OYSjAxjqQfQ"

# Set your API user token, which you can find in the Account tab in the top right corner of the TaxonWorks web interface.
# The user token is optional for most endpoints
TW_USER_TOKEN = "YfaketwBapWzsMeXNX7N5q"



# 2. How to access the simple biological associations table

# View the simple biological associations table
tw_biological_associations(subresource = "simple")

# Note that you get metadata with information on the pagination of the results, and the total number of records and result pages:


# $meta
# $meta$page
# [1] 1

# $meta$next_page
# [1] 2

# $meta$per
# [1] 50

# $meta$total
# [1] 6190

# $meta$total_pages
# [1] 124


# The data is stored in the $data variable, which contains a tibble (a modernized version of a data.frame):

# $data
# # A tibble: 50 × 11
#    subject_order subject_family subject_genus subject         subject_properties
#    <chr>         <chr>          <chr>         <chr>           <chr>             
#  1 Fagales       Betulaceae     Carpinus      Carpinus betul… Host              
#  2 Rosales       Rosaceae       Prunus        Prunus padus L. Host              
#  3 Malpighiales  Clusiaceae     Hypericum     Hypericum macu… Host              
#  4 Fabales       Fabaceae       Acacia        Acacia          Host              
#  5 Rosales       Rosaceae       Amelanchier   Amelanchier     Host              
#  6 Fagales       Fagaceae       Quercus       Quercus         Host              
#  7 Rosales       Rosaceae       Crataegus     Crataegus       Host              
#  8 Ericales      Ericaceae      Calluna       Calluna         Host              
#  9 Rosales       Rosaceae       Prunus        Prunus amygdal… Host              
# 10 Rosales       Rosaceae       Prunus        Prunus persica… Host              
# # ℹ 40 more rows
# # ℹ 6 more variables: biological_relationships <chr>, object_properties <chr>,
# #   object <chr>, object_order <chr>, object_family <chr>, object_genus <chr>
# # ℹ Use `print(n = ...)` to see more rows


# To get all results from the simple biological associations table, you can fetch each page and use the dplyr package's bind_rows() function to merge them into a single table in R:
install.packages("dplyr")
library("dplyr") 
# Learn more on dplyr at: https://datacarpentry.org/R-genomics/04-dplyr.html

page <- 1
per <- 500
res <- tw_biological_associations(subresource = "simple", csv = FALSE, page = page, per = per)
results <- res$data
while (page < res$meta$total_pages) {
  page <- page + 1
  res <- tw_biological_associations(subresource = "simple", csv = FALSE, page = page, per = per)
  results <- bind_rows(results, res$data)
}

# The results variable now should contain all of the simple biological associations records
results$subject[1]

# You can confirm you got all of the records by checking the number of rows in the results variable
#  and check that the total number of rows matches the total in the res metadata
nrow(results)
res$meta$total

# For convenience, most of the methods have shorter aliases. For example you can accesss the tw_biological_associations 
# method with the tw_ba() method alias:
res <- tw_ba(subresource = "simple")
# which is the same as calling:
res <- tw_biological_associations(subresource = "simple")



# 3. How to join the OTU and TaxonName tables using the sqldf package

# The sqldf package allows you to run SQL queries on data.frames, including doing SQL joins
# You can install the sqldf package with the following command:
install.packages("sqldf")

# Here is an example of how to join the OTU and TaxonName tables using the sqldf package
require("sqldf")

# With csv = TRUE, the tw_otu and tw_tn methods will download all records from the endpoint but you should always confirm that the number of records matches the total in the metadata with csv = FALSE
# Not all TaxonWorks API endpoints support the csv parameter, but most do.
otu <- tw_otu(csv = TRUE)
tn <- tw_tn(csv = TRUE)

# Confirm that the number of records matches the total in the metadata, commands should return TRUE
nrow(tn) == tw_tn(per = 1)$meta$total
nrow(otu) == tw_otu(per = 1)$meta$total

# This sql query joins the tn and otu tables on the taxon_name_id column, keeping all the records from the tn table and only the records from the otu table that have a matching taxon_name_id
tn_otu <- sqldf("SELECT otu.id AS otu_id, tn.id AS tn_id, tn.cached AS name FROM tn LEFT JOIN otu ON otu.taxon_name_id = tn.id")

# View the number of rows:
nrow(tn_otu)
# [1] 108193

# If you only want taxon names that have an OTU, use an inner join instead of a left join:
tn_otu <- sqldf("SELECT otu.id AS otu_id, tn.id AS tn_id, tn.cached AS name FROM tn INNER JOIN otu ON otu.taxon_name_id = tn.id")

# View the number of rows:
nrow(tn_otu)
# [1] 79551

# Let's view what ranks are included in the data:
unique(tn$rank_class)
#  [1] "NomenclaturalRank"
#  [2] "NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom"
#  [3] "NomenclaturalRank::Iczn::HigherClassificationGroup::Phylum"
#  [4] "NomenclaturalRank::Iczn::HigherClassificationGroup::ClassRank"
#  [5] "NomenclaturalRank::Iczn::HigherClassificationGroup::Order"
#  [6] "NomenclaturalRank::Iczn::FamilyGroup::Family"
#  [7] "NomenclaturalRank::Iczn::GenusGroup::Genus"
#  [8] "NomenclaturalRank::Iczn::HigherClassificationGroup::Subphylum"
#  [9] "NomenclaturalRank::Iczn::SpeciesGroup::Species"
# [10] "NomenclaturalRank::Iczn::GenusGroup::Subgenus"
# [11] "NomenclaturalRank::Iczn::HigherClassificationGroup::Suborder"
# [12] "NomenclaturalRank::Iczn::HigherClassificationGroup::Infraorder"
# [13] "NomenclaturalRank::Iczn::FamilyGroup::Superfamily"
# [14] "NomenclaturalRank::Iczn::FamilyGroup::Subfamily"
# [15] "NomenclaturalRank::Iczn::FamilyGroup::Tribe"
# [16] "NomenclaturalRank::Iczn::SpeciesGroup::Subspecies"
# [17] "NomenclaturalRank::Iczn::FamilyGroup::Subtribe"
# [18] "NomenclaturalRank::Iczn::SpeciesGroup::Superspecies"
# [19] "NomenclaturalRank::Iczn::GenusGroup::Supergenus"
# [20] "NomenclaturalRank::Iczn::FamilyGroup::Supertribe"
# [21] NA
# [22] "NomenclaturalRank::Icn::HigherClassificationGroup::Kingdom"
# [23] "NomenclaturalRank::Icn::HigherClassificationGroup::Phylum"
# [24] "NomenclaturalRank::Icn::HigherClassificationGroup::ClassRank"
# [25] "NomenclaturalRank::Icn::HigherClassificationGroup::Order"
# [26] "NomenclaturalRank::Icn::FamilyGroup::Family"
# [27] "NomenclaturalRank::Icn::GenusGroup::Genus"
# [28] "NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Species"
# [29] "NomenclaturalRank::Icn::GenusGroup::Subgenus"
# [30] "NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Variety"
# [31] "NomenclaturalRank::Iczn::HigherClassificationGroup::Subclass"


# Of the taxon names with OTUs, if you only want ICZN species groups you can use the SQL WHERE clause with a LIKE statement that includes a wildcard character (%):
tn_otu_iczn_species_groups <- sqldf("SELECT otu.id AS otu_id, tn.id AS tn_id, tn.cached AS name, tn.rank_class AS rank FROM tn INNER JOIN otu ON otu.taxon_name_id = tn.id WHERE tn.rank_class LIKE 'NomenclaturalRank::Iczn::SpeciesGroup%'")

unique(tn_otu_iczn_species_groups$rank)
# [1] "NomenclaturalRank::Iczn::SpeciesGroup::Species"
# [2] "NomenclaturalRank::Iczn::SpeciesGroup::Subspecies"
# [3] "NomenclaturalRank::Iczn::SpeciesGroup::Superspecies"

# Or if you want all species groups regardless of nomenclatural code, you could use the following command which uses two wildcard characters (%) to match any characters before and after the SpeciesGroup string:
tn_otu_species_groups <- sqldf("SELECT otu.id AS otu_id, tn.id AS tn_id, tn.cached AS name, tn.rank_class AS rank FROM tn INNER JOIN otu ON otu.taxon_name_id = tn.id WHERE tn.rank_class LIKE '%SpeciesGroup%'")

unique(tn_otu_species_groups$rank)
# [1] "NomenclaturalRank::Iczn::SpeciesGroup::Species"
# [2] "NomenclaturalRank::Iczn::SpeciesGroup::Subspecies"
# [3] "NomenclaturalRank::Iczn::SpeciesGroup::Superspecies"
# [4] "NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Species"
# [5] "NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Variety"



# 4. How to get Darwin Core inventory for an OTU

# To get Darwin Core inventory for an OTU, you can use the tw_otu method with the subresource parameter set to "inventory/dwca":
tw_otu(id = 1284606, subresource = "inventory/dwc", project_token="4lguA4gFHs4SnloppYeqEg")
# Note: In this example, the environment variable TW_PROJECT_TOKEN is overridden by the project_token parameter, because the 3i sandbox dataset doens't have Collection Objects



# 5. Where to open issue tickets for the rtaxonworks package if you find a bug or need additional endpoints wrapped

# If you find any issues with the rtaxonworks package or need other API endpoints 
# wrapped that are not yet supported, please open an issue in the GitHub repository:
#
#   https://github.com/SpeciesFileGroup/rtaxonworks/issues
