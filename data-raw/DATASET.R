## code to prepare `DATASET` dataset goes here

## packages
library(tidyverse)
library(here)

path = here::here("data-raw", "subject01.zip")
path_out = here::here("data-raw")
volunteer_id = "volunteer_1"

data_volunteer_1 <- artefacts::parse_raw_data(
  path = data_raw_path,
  path_out = path_out,
  volunteer_id = "volunteer_1"
) %>%
  print()

usethis::use_data(data_volunteer_1)
