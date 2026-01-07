#' Write range data to geodatabase
#'
#' @param ebird_range eBird range maps from this pipeline
#' @param iucn_maps iucn maps from this pipeline
#' @param bien_maps bien maps from this pipeline
#' @param gdb_path path to geodatabase
#'
#' @returns Nothing.
#' @seealso [download_ebird_range_maps()], [download_bien_range_maps()], [build_iucn_maps()]
#' @export
#' 
#' @examples
#' # Coming soon 
#' message("Stay tuned.")
#' 
write_range_data <- function(ebird_range, iucn_maps, bien_maps, gdb_path){
  
  # gdb_path = file.path("data", "MBF_spp_eval.gdb")
  
  # Activate ArcGIS license
  arcgisbinding::arc.check_product()
  
  message("Writing eBird Range Maps")
  # ebird_range = targets::tar_read(ebird_range_maps)
  ebird_sf = sf::st_as_sf(ebird_range) |> sf::st_cast("POLYGON") |> 
    dplyr::rename("sort_order" = order)
  arcgisbinding::arc.write(
    path = file.path(gdb_path, "RangeMaps", "eBird_RangeMaps"),
    data = ebird_sf,
    overwrite = TRUE
  )
  
  message("Writing IUCN Maps")
  # iucn_maps = targets::tar_read(iucn_maps)
  arcgisbinding::arc.write(
    path = file.path(gdb_path, "RangeMaps", "IUCN_Maps"),
    data = iucn_maps,
    overwrite = TRUE
  )
  
  message("Writing BIEN Maps")
  # bien_maps = targets::tar_read(bien_maps)
  bien_maps_sf = lapply(bien_maps$scientific_name, function(sp){
    sp_dat = dplyr::filter(bien_maps, scientific_name == sp)
    shp_path = file.path("output/bien_maps", paste0(gsub(" ", "_", sp), ".shp"))
    sf_dat = sf::read_sf(shp_path) |> 
      dplyr::mutate(taxon_id = sp_dat$taxon_id)
    return(sf_dat)
  }) |>
    dplyr::bind_rows() |> 
    sf::st_as_sf() |> 
    sf::st_cast("POLYGON")
  arcgisbinding::arc.write(
    path = file.path(gdb_path, "RangeMaps", "BIEN_Maps"),
    data = bien_maps_sf,
    overwrite = TRUE
  )
}
