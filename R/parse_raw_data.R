#' @title Parse a zip archive containing the raw data per volunteer
#'
#' @param path A character directing to zip archive containing data from
#' a single volunteer
#' @param path_out A character directing to the directory where the unzipped
#' files must be stored
#' @param volunteer_id A character single string indicating from which
#' volunteer you are parsing the data
#'
#' @return a [tibble][tibble::tibble-package]
#'
#' @export

parse_raw_data <- function(path = NULL,
                           path_out = NULL,
                           volunteer_id = NULL){

  dir.create(path_out)

  ## unzipping the archive
  utils::unzip(path, exdir = path_out)

  ## files list unzippes csv
  data_files <- list.files(path_out,
                           pattern = "\\.csv",
                           full.names = TRUE)

  ## add file names
  names(data_files) <- basename(data_files)

  ## read instructions file
  instructions <- readr::read_csv(
    file = data_files["subject01_instruction_command.csv"],
    col_names = TRUE)

  data_list_no_header <- purrr::map(data_files[2:length(data_files)],
                                    readr::read_csv,
                                    col_names = FALSE)


  names(data_list_no_header)
  ## add index for timestamp
  add_row_index <- function(df){

    df$row_index <- c(1:nrow(df))
    return(df)
  }

  ## add index to each df "no header"
  data_list_no_header <- purrr::map(data_list_no_header, add_row_index)
  instructions <- add_row_index(instructions)

  ## file_name to dataframes
#  add_file_name <- function(df, path){
#
#    file <- basename(path)
#
#    df$filename <- file
#
#    return(df)
#
#  }

#  data_list_no_header <- map2(.x = data_list_no_header,
#                              .y = names(data_list_no_header),
#                              .f = add_file_name)

#  instructions$file_name <- paste(volunteer_id, "instruction_command.csv",
#                                  sep = "_")

  data_list_no_header[[1]]
  ## inspect
  # data_list_no_header$subject01_left_eda_data.csv
  # data_list_no_header$subject01_left_eda_timestamp.csv
#  data_list_no_header %>% names

  ## left hand/arm
  instructions_time <- data_list_no_header[[1]]
  acc_data_left <- data_list_no_header[[2]]
  acc_time_left <- data_list_no_header[[3]]
  eda_data_left <- data_list_no_header[[4]]
  eda_time_left <- data_list_no_header[[5]]

  ## right hand/arm
  acc_data_right <- data_list_no_header[[6]]
  acc_time_right <- data_list_no_header[[7]]
  eda_data_right <- data_list_no_header[[8]]
  eda_time_right <- data_list_no_header[[9]]

  ## define headers
  annotations_acc <- c("x_axis_acc",
                       "y_axis_acc",
                       "z_axis_acc",
                       "row_index"
                       )
  annotations_eda <- c("eda",
                       "row_index"
                       )
  annotations_time <- c("time",
                        "row_index"
                        )

  ## add headers
  names(instructions_time) <- annotations_time
  names(acc_data_left) <- annotations_acc
  names(acc_data_right) <- annotations_acc
  names(eda_data_left) <- annotations_eda
  names(eda_data_right) <- annotations_eda
  names(eda_time_left) <- annotations_time
  names(eda_time_right) <- annotations_time
  names(acc_time_left) <- annotations_time
  names(acc_time_right) <- annotations_time

  ##inspect
  instructions
  instructions_time
  acc_data_left
  acc_data_right
  acc_time_left
  acc_time_right
  eda_data_left
  eda_data_right
  eda_time_left
  eda_time_right



  ## join data and time
  instructions_join <- left_join(instructions,
                                 instructions_time,
                                 by = "row_index")

  acc_join_left <- dplyr::left_join(
    acc_data_left,
    acc_time_left
  ) %>%
    dplyr::mutate(side = "left")
  #%>% ## add a variable for which hand (left/right)
   # print()

  acc_join_right <- dplyr::left_join(
    acc_data_right,
    acc_time_right
  ) %>%
    dplyr::mutate(side = "right")
  #%>% ## add a variable for which hand (left/right)
  #  print()

  eda_join_left <- dplyr::left_join(
    eda_data_left,
    eda_time_left
  ) %>%
    dplyr::mutate(side = "left")
  #%>% ## add a variable for which hand (left/right)
   # print()

  eda_join_right <- dplyr::left_join(
    eda_data_right,
    eda_time_right
  ) %>%
    dplyr::mutate(side = "right")
  #%>% ## add a variable for which hand (left/right)
   # print()

  ## bind all together
  data_all_acc <- dplyr::bind_rows(
    acc_join_left,
    acc_join_right
  )

  data_all_eda <- dplyr::bind_rows(
    eda_join_left,
    eda_join_right
  )

  ## add volunteer id
  data_all_acc <- data_all_acc %>%
    dplyr::mutate(volunteer_id = volunteer_id)

  data_all_eda <- data_all_eda %>%
    dplyr::mutate(volunteer_id = volunteer_id)

  instructions_join <- instructions_join %>%
    dplyr::mutate(volunteer_id = volunteer_id)

   data_all_list <- list(
     data_all_acc,
     data_all_eda,
     instructions_join)

   names(data_all_list) <- c("acceleration",
                             "skin-conductance",
                             "instructions")

   return(data_all_list)
}
