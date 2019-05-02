#' @title Parse a zip archive containing the raw data per volunteer
#' @param path A character directing to the path of the zip archive
#' @return a [tibble][tibble::tibble-package]
#' @export

parse_raw_data <- function(path = NULL,
                           path_out = NULL,
                           volunteer_id = NULL){

  ## unzipping the archive
  unzip(path, exdir = path_out)

  ## files list unzippes csv
  data_files <- list.files(path_out,
                           pattern = "\\.csv",
                           full.names = TRUE)

  names(data_files) <- basename(data_files)
  # # data_files["subject01_instruction_command.csv"] ## has names? - check
  #
  # ## read data into list of dataframes
  # data_list <- purrr::map(data_files, readr::read_csv)

  ## add names to list for tracebility
  # names(data_list) <- basename(data_files)

  # ## inspect the dataframes and isolate individual dataframes
  # data_list$subject01_instruction_command.csv ## header
  # data_list$subject01_instruction_timestamp.csv ## file with no header
  # data_list$subject01_left_acc_data.csv ## no header
  # data_list$subject01_left_acc_timestamp.csv ## no header
  # data_list$subject01_left_eda_data.csv ## no header
  # data_list$subject01_left_eda_timestamp.csv ## no header
  # data_list$subject01_right_acc_data.csv ## no header
  # data_list$subject01_right_acc_timestamp.csv ## no header
  # data_list$subject01_right_eda_data.csv ## no header
  # data_list$subject01_right_eda_timestamp.csv ## no header

  ## looks like all but datafiles do not have a header
  ## Try again
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

  data_list_no_header[[1]]
  ## inspect
  # data_list_no_header$subject01_left_eda_data.csv
  # data_list_no_header$subject01_left_eda_timestamp.csv
  data_list_no_header %>% names

  ## left hand/arm
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
  annotations_acc <- c("x_axis_acc", "y_axis_acc", "z_axis_acc", "row_index")
  annotations_eda <- c("eda", "row_index")
  annotations_time <- c("time", "row_index")

  ## add headers
  names(acc_data_left) <- annotations_acc
  names(acc_data_right) <- annotations_acc
  names(eda_data_left) <- annotations_eda
  names(eda_data_right) <- annotations_eda
  names(eda_time_left) <- annotations_time
  names(eda_time_right) <- annotations_time
  names(acc_time_left) <- annotations_time
  names(acc_time_right) <- annotations_time

  ##inspect
  acc_data_left
  acc_data_right
  acc_time_left
  acc_time_right
  eda_data_left
  eda_data_right
  eda_time_left
  eda_time_right

  ## join data and time
  acc_join_left <- left_join(
    acc_data_left,
    acc_time_left
  ) %>%
    mutate(side = "left")
  #%>% ## add a variable for which hand (left/right)
   # print()

  acc_join_right <- left_join(
    acc_data_right,
    acc_time_right
  ) %>%
    mutate(side = "right")
  #%>% ## add a variable for which hand (left/right)
  #  print()

  eda_join_left <- left_join(
    eda_data_left,
    eda_time_left
  ) %>%
    mutate(side = "left")
  #%>% ## add a variable for which hand (left/right)
   # print()

  eda_join_right <- left_join(
    eda_data_right,
    eda_time_right
  ) %>%
    mutate(side = "right")
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
    mutate(volunteer_id = volunteer_id)

  data_all_eda <- data_all_eda %>%
    mutate(volunteer_id = volunteer_id)



   data_all_list <- list(data_all_acc,
              data_all_eda)

   names(data_all_list) <- c("acceleration",
                             "skin-conductance")

   return(data_all_list)
}
