## code to prepare `DATASET` dataset goes here

## packages
library(tidyverse)
library(here)

## dummies
path = here::here("data-raw", "subject01.zip")
path_out = here::here("data-raw", "subject01")
volunteer_id = "subject01"

## volunteer 1
data_volunteer_1 <- artefacts::parse_raw_data(
  path = path,
  path_out = path_out,
  volunteer_id = "subject01"
) %>%
  print()

usethis::use_data(data_volunteer_1)

## all_volunteers
## volunteer ids
volunteer_ids <- paste("volunteer", c(1:15), sep = "_")
list_archives <- list.files(path = path_out,
                            full.names = TRUE)

x <- purrr::map2(.x = list_archives[2:16],
    .f = parse_raw_data,
    path_out = path_out,
    .y = volunteer_ids[1:15])

#x[[1]]$acceleration$volunteer_id %>% unique()

y <- x %>% purrr::transpose()
data_acceleration_all <- y$acceleration %>% dplyr::bind_rows()
data_eda_all <- y$`skin-conductance` %>% dplyr::bind_rows()

usethis::use_data(data_acceleration_all)
usethis::use_data(data_eda_all)

#acc$volunteer_id %>% unique()


