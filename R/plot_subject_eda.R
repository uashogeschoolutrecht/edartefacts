#'
#'
#' @export

plot_subject_eda <- function(subject){

  edartefacts::data_eda_all %>%
    dplyr::filter(volunteer_id == subject) %>%
    gather(x_axis_acc:z_axis_acc, key = "axis", value = "acceleration") %>%
    group_by(side, axis) %>%
    ggplot(aes(x = time,
               y = acceleration)) +
    geom_point(aes(colour = side)) +
    facet_wrap(~ axis)


}



#' @title Plot instruction
#'
#'
#'
