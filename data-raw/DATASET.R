## code to prepare `DATASET` dataset goes here

data_dummy <- tibble::tibble(A = rnorm(1000),
                    B = rnorm(1000))

usethis::use_data(data_dummy)
