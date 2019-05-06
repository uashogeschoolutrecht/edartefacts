## code to prepare all `DATASETS` from package {edartefacts}
#######################################################
# author: Marc A.T. Teunis
# email: marc.teunis@hu.nl
#
#######################################################

## packages
library(tidyverse)
library(here)

## dummies
path = here::here("data-raw", "zip_archives", "subject01.zip")
path_out = here::here("data-raw", "unzipped")
volunteer_id = "subject01"

## volunteer 1
data_volunteer_1 <- artefacts::parse_raw_data(
  path = path,
  path_out = path_out,
  volunteer_id = "subject01"
) %>%
  print()

# usethis::use_data(data_volunteer_1, overwrite = TRUE)

## all_volunteers
## volunteer ids
volunteer_ids <- read_lines(here::here("data-raw", "subjects.txt"),
                            skip = 1)

## paths
path = here::here("data-raw", "zip_archives")
path_out = here::here("data-raw", "unzipped")

list_archives <- list.files(path = path,
                            full.names = TRUE)

data_full <- purrr::map2(.x = list_archives,
    .f = parse_raw_data,
    path_out = path_out,
    .y = volunteer_ids)

#x[[1]]$acceleration$volunteer_id %>% unique()

data_full_transposed <- data_full %>%
  purrr::transpose()
## y$instructions[[5]]

## acceleration data
data_acceleration_all <- data_full_transposed$acceleration %>%
  dplyr::bind_rows()

## eda data
data_eda_all <- data_full_transposed$`skin-conductance` %>%
  dplyr::bind_rows()

## instructions
data_instructions_all <- data_full_transposed$instructions %>%
  dplyr::bind_rows()

## add datasets
usethis::use_data(data_acceleration_all, overwrite = TRUE)
usethis::use_data(data_eda_all, overwrite = TRUE)
usethis::use_data(data_instructions_all, overwrite = TRUE)
#acc$volunteer_id %>% unique()


