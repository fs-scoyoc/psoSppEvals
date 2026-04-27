#' Pull biological data from the Forest Service Eneterprise Data Warehouse
#' 
#' This function is in active development. This function pulls species 
#'     observation data from the internal Forest Service ArcGIS REST Service 
#'     (*arcn*) into R.
#' 
#' @note
#' Aquatic biota observation data (*EDW_Aquatic_Biota_Observations_01*) is not 
#'     currently reading into R. It's throwing a "subscript out of bounds" 
#'     error. This is probably because it is "SENSITIVE - NOT EXPORTABLE".
#'
#' @param aoa_sf Simple feature (`sf`) object of the area of analysis.
#' @param crs Target coordinate reference system.
#' @param write Logical (TRUE/FALSE). Write the data to a geodatabase. Default 
#'     is FALSE.
#' @param gdb_path Optional. Character. Directory path to the geodatabase.
#' @param suffix Optional. A suffix to add to the end of the data set name if 
#'     writing data to a geodatabase.
#'
#' @returns A simple feature (`sf`) object.
#' @export
#'
#' @examples
#' \dontrun{
#' library("dplyr")
#' library("psoGIStools")
#' library("sf")
#' library("units")
#' 
#' crs <- "EPSG:26912"
#' dif <- read_edw_lyr("EDW_ForestSystemBoundaries_01", 1, "arcx", 
#'                             crs = crs) |> 
#'   dplyr::filter(forestname == "Dixie National Forest")
#' aoa <- sf::st_buffer(dif, dist = units::as_units(3, "mi"))
#' fs_edw <- pull_edw_bio_data(aoa, crs = crs)
#' }
pull_edw_bio_data <- function(aoa_sf, crs, 
                              write = FALSE, gdb_path, suffix = "3miBuffer"){
  # aoa_sf = aoa
  
  # Activate ArcGIS license
  if(write) arcgisbinding::arc.check_product()
  # Function to pull data from EDW
  pull_edw = function(lyr_name, lyr_no = 1){
    dat = psoGIStools::read_edw_lyr(lyr_name, lyr_no, "arcn", crs = crs) |> 
      psoGIStools::clip_sf(aoa_sf) |> 
      dplyr::mutate(edw_source = lyr_name, 
                    date_accessed = as.character(Sys.Date())) |> 
      try()
    if(write & methods::is(dat, "sf")){
      message("Writing data to geodatabase")
      # Activate ArcGIS license
      arcgisbinding::arc.write(
        path = file.path(gdb_path, "FS_EDW", 
                         paste(lyr_name, suffix, sep = "_")),
        data = dat, overwrite = TRUE
      )
    }
    return(dat)
  }
  
  ## Pull Data ----
  message("Reading Aquatic Biota")
  aq_biota = pull_edw("EDW_Aquatic_Biota_Observations_01", 0) |> try()
  if(methods::is(aq_biota, "sf")){
    message("Aquatic biota data successfully downloaded")
    } else({
      message("EDW Connection Failed. Aquatic biota data not downloaded")
      aq_biota = FALSE
      })
  
  message("Reading Invasive Plants")
  invplant = pull_edw("EDW_BioInvasivePlant_01") |> try()
  if(methods::is(invplant, "sf")){
    message("Invasive plant data successfully downloaded")
    } else({
      message("EDW Connection Failed. Invasive plant data not downloaded")
      invplant = FALSE
      })
  
  message("Reading TESP")
  bio_tesp = pull_edw("EDW_BioTESP_01") |> try()
  if(methods::is(bio_tesp, "sf")){
    message("TESP data successfully downloaded")
    } else({
      message("EDW Connection Failed. TESP data not downloaded")
      bio_tesp = FALSE
      })
  
  ## Combine Data ----
  dat_ls = list(aq_biota, invplant, bio_tesp)
  dat = dat_ls[dat_ls != "FALSE"] |> dplyr::bind_rows() |> sf::st_as_sf()

  ## Get taxon ID's  ----
  message("Getting taxon ID's")
  taxa = dat |> 
    sf::st_drop_geometry() |> 
    dplyr::select(scientific_name) |> 
    dplyr::distinct() |> 
    psoSppEvals::get_taxonomies(query_field = "scientific_name", correct = TRUE)
  
  ## Final Data Set ----
  # Format Dates
  date_formats = c("%m/%d/%Y", "%Y", "%Y-%m", "%Y-%m-%d %H:%M:%S")
  date_vars = c("survey_obs_date", "date_collected", 
                "date_collected_most_recent", "last_update", 
                "last_update_survey")
  
  # Function to safely parse dates
  parse_date_safe <- function(x, time_zone = 'UTC') {
    # Try multiple formats; return NA if parsing fails
    parsed_date <- suppressWarnings(
      lubridate::parse_date_time(x, orders = date_formats, tz = time_zone)
      ) |> 
      as.Date()
    return(parsed_date)
  }
  
  # Parse dates and join taxonomies
  all_dat = dat |> 
    dplyr::mutate(
      dplyr::across(dplyr::any_of(date_vars), ~ parse_date_safe(.), 
                    .names = "parsed_{.col}")
      ) |>
    dplyr::mutate(source = "FS_EDW") |>
    dplyr::left_join(taxa, by = "scientific_name", relationship = 'many-to-many')
  return(all_dat)
}
