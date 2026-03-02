#' Write range data to geodatabase
#'
#' This function writes spatial (`sf`) BIEN, eBird, and IUCN range data to a 
#'     geodatabase and has the option to return a list of `sf` objects. 
#'
#' @param bien_maps bien maps from this pipeline
#' @param ebird_range eBird range maps from this pipeline
#' @param iucn_maps iucn maps from this pipeline
#' @param gdb_path path to geodatabase
#' @param return_sf Optional. TRUE/FALSE. Return a list of `sf` objects. Default 
#'     is FALSE.
#'
#' @returns A list of `sf` objects including BIEN, eBird, and IUCN range data.
#' @seealso [download_bien_maps()], [download_ebird_range_maps()], [build_iucn_maps()]
#' @export
#' 
#' @examples
#' # Coming soon 
#' message("Stay tuned.")
#' 
write_range_data <- function(bien_maps, ebird_range, iucn_maps, gdb_path, 
                             return_sf = FALSE){
  
  # gdb_path = file.path("data", "MBF_spp_eval.gdb")
  
  # Activate ArcGIS license
  arcgisbinding::arc.check_product()
  
  message("Writing BIEN Maps")
  # bien_maps = targets::tar_read(bien_maps)
  arcgisbinding::arc.write(
    path = file.path(gdb_path, "RangeMaps", "BIEN"),
    data = bien_maps,
    overwrite = TRUE
  )
  
  message("Writing eBird Range Maps")
  # ebird_range = targets::tar_read(ebird_range_maps)
  ebird_sf = ebird_range |> sf::st_cast("POLYGON") |> 
    dplyr::rename("sort_order" = order)
  arcgisbinding::arc.write(
    path = file.path(gdb_path, "RangeMaps", "eBird"),
    data = ebird_sf,
    overwrite = TRUE
  )
  
  message("Writing IUCN Maps")
  # iucn_maps = targets::tar_read(iucn_maps)
  arcgisbinding::arc.write(
    path = file.path(gdb_path, "RangeMaps", "IUCN"),
    data = iucn_maps,
    overwrite = TRUE
  )
  
  if (return_sf){
    return(range_maps = list("bien" = bien_maps, "ebird" = ebird_sf, 
                             "iucn" = iucn_maps))
    
    }
}
