#reference: https://httr2.r-lib.org/articles/wrapping-apis.html - https://www.tidyverse.org/blog/2023/11/httr2-1-0-0/ - https://github.com/melissavanbussel/YouTube-Tutorials/blob/main/httr2/httr2_examples.R
#objectives: get a taxon_names_id and other attributes of a taxon name, from endpoint taxon_names in a csv file
library(httr2)
library(tidyverse)

#Define access token
access_token_taxonworks_sandfly = TAXONWORKS_TOKEN
project_token_taxonworks_sandfly = TAXONWORKS_PROJECT_TOKEN

#Define base urls
base_url_taxonworks_sandfly = "https://sandfly.taxonworks.org/api/v1"

#Define endpoints
endpoint_taxonnames = "/taxon_names" #first objectives: get the taxon_id of a taxon name

#Define request
req_taxonnames_sandfly = request(base_url_taxonworks_sandfly) %>% 
  req_url_path_append(endpoint_taxonnames) %>%
  req_url_query(project_token=project_token_taxonworks_sandfly) #the project_token is necessary to authorize the request

#Define query
req_taxonnames_sandfly_query = req_taxonnames_sandfly %>%
  req_url_query(
    validity="true",
    name_exact="true")

#Provide access token via header
req_taxonnames_sandfly_query_auth = req_taxonnames_sandfly_query %>%
  req_headers(
    'Authorization'=paste0('Token ',access_token_taxonworks_sandfly)
  )

library(readr)
identificati <- read_csv("lista_identificati.csv")
lista_identificati = as_vector(identificati$name)
#names=lapply(lista_identificati, function(lista_identificati) paste0("name=",lista_identificati))

reqs = lapply(lista_identificati, function(lista_identificati) req_url_query(req_taxonnames_sandfly_query_auth,name=lista_identificati))

#Perform responses
resps = reqs %>%
  req_perform_sequential()

resp_perform_taxonnames_sandfly_string = resps |> resps_successes() |> resps_data(\(resp) resp_body_string(resp))

#Transform to dataframe
library(jsonlite)
resp_perform_taxonnames_sandfly_dataframe = lapply(resp_perform_taxonnames_sandfly_string, function(x) fromJSON(x))
library(dplyr)
dataframe = bind_rows(resp_perform_taxonnames_sandfly_dataframe)



