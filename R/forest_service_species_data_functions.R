#' Pull biological data from the Forest Service Eneterprise Data Warehouse
#' 
#' This function is in active development. This function pulls species 
#'     observation data from the internal Forest Service ArcGIS REST Service 
#'     (*arcn*) into R.
#' 
#' @note
#' Aquatic biota observation data (*EDW_Aquatic_Biota_Observations_01*) is not 
#'     currently reading into R.
#'
#' @param aoa_sf Simple feature (`sf`) object of the area of analysis.
#' @param crs Target coordinate reference system.
#' @param write Logical (TRUE/FALSE). Write the data to a geodatabase. Default 
#'     is FALSE.
#' @param gdb_path Optional. Character. Directory path to the geodatabase.
#' @param suffix Optional. 
#'
#' @returns A simple feature (`sf`) object.
#' @export
#'
#' @examples
#' library("dplyr")
#' library("psoGIStools")
#' library("sf")
#' library("units")
#' 
#' crs <- "EPSG:26912"
#' admin_bndry <- read_edw_lyr("EDW_ForestSystemBoundaries_01", 1, "arcx", 
#'                             crs = crs) |> 
#'   dplyr::filter(forestname == "Dixie National Forest")
#' aoa <- sf::st_buffer(admin_bndry, dist = units::as_units(3, "mi"))
#' fs_edw <- pull_edw_bio_data(aoa, crs = crs)
#' 
pull_edw_bio_data <- function(aoa_sf, crs, 
                              write = FALSE, gdb_path, suffix = "3miBuffer"){
  
  # Activate ArcGIS license
  if(write) arcgisbinding::arc.check_product()
  # Function to pull data
  pull_edw = function(lyr_name, lyr_no = 1){
    dat = psoGIStools::read_edw_lyr(lyr_name, lyr_no, "arcn", crs = crs) |> 
      psoGIStools::clip_sf(aoa_sf) |> 
      dplyr::mutate(edw_source = lyr_name, 
                    date_accessed = as.character(Sys.Date()))
    if(write){
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
  
  message("Reading Aquatic Biota")
  aq_biota = pull_edw("EDW_Aquatic_Biota_Observations_01", 0)
  message("Reading Invasive Plants")
  invplant = pull_edw("EDW_BioInvasivePlant_01")
  message("Reading TESP")
  bio_tesp = pull_edw("EDW_BioTESP_01")
  
  # Get taxon ID's
  message("Getting taxon ID's")
  taxa_ids = dplyr::bind_rows(bio_tesp, invplant) |> 
    # dplyr::bind_rows(aq_biota) |> 
    sf::st_drop_geometry() |> 
    dplyr::select(accepted_scientific_name) |> 
    dplyr::distinct() |> 
    mpsgSE::get_taxonomies(query_field = "accepted_scientific_name", 
                           correct = TRUE)
  
  # Date formats
  date_formats = c("%m/%d/%Y", "%Y", "%Y-%m", "%Y-%m-%d %H:%M:%S")
  # Combine data
  all_dat = dplyr::bind_rows(bio_tesp, invplant) |> 
    # dplyr::bind_rows(aq_biota) |> 
    sf::st_as_sf() |> 
    dplyr::mutate(
      parsed_date_collected = lubridate::parse_date_time(date_collected, orders = date_formats) |> as.Date(),
      parsed_date_collected_recent = lubridate::parse_date_time(date_collected_most_recent, orders = date_formats) |> as.Date(),
    )
  
  dplyr::mutate(source = "FS_EDW") |> 
    dplyr::left_join(taxa_ids, by = "accepted_scientific_name", 
                     relationship = 'many-to-many')
  return(all_dat)
}
