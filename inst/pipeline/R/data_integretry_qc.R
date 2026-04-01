#' Filter valid and invalid data from spatial (`sf`) object.
#' 
#' This function filters spatial (`sf`) data with invalid dates and uncertainty 
#'     values and returns a list of `sf` objects.
#'     
#' **Note**: This function is not an function included in the `psoSppEval` 
#'     package. I don't know if I'll integrate it with the package at this 
#'     point.
#' 
#' @param sf_data Spatial (`sf`) object.
#'
#' @returns A list of `sf` objects.
data_integrety_qc <- function(sf_data){
  valid_data = sf_data |> 
    dplyr::filter(!is.na(parsed_date)) |> 
    dplyr::filter(!is.na(coordinateUncertaintyInMeters))
  invalid_data = sf_data |> 
    dplyr::filter(is.na(parsed_date) | is.na(coordinateUncertaintyInMeters))
  return(tibble::lst('all_data' = sf_data,
                     'valid_data' = valid_data,
                     'invalid_data' = invalid_data))
  }






