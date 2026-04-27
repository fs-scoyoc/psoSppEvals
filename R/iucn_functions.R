#' Read IUCN Species Range Maps into R
#' 
#' This function reads spatial (polygon) range data from International Union for 
#'     Conservation of Nature (IUCN) into R. These shapefiles were downloaded 
#'     from IUCN (<https://www.iucnredlist.org/resources/spatial-data-download>), 
#'     and saved on the MPSG T-drive. This function will this function will fail 
#'     if you are not on a FS network.
#'
#' @param spp_list A species list with taxon ID's from `get_taxonomies()`.
#'
#' @returns An [sf] object.
#' @export
#' @seealso [get_taxonomies()]
#' @examples
#' \dontrun{
#' library('psoSppEvals')
#' spp_list <- get_taxonomies(psoSppEvals::sp_list_ex, correct = TRUE)
#' iucn_maps <- get_iucn_maps(spp_list)
#' }
get_iucn_maps <- function(spp_list){
  
  # spp_list = targets::tar_read(rfss)
  
  # Read in RDS file and filter to eligible list
  iucn_paths = readRDS(
    file.path("T:/FS/NFS/PSO/MPSG/Data/ExternalData/IUCN", "iucn_shp_paths")
  ) |> 
    dplyr::filter(taxon_id %in% spp_list$taxon_id) |> 
    dplyr::filter(!is.na(taxon_id) & taxon_id != 1)
  
  iucn_maps = lapply(unique(iucn_paths$file_path), function(shp_path){
    # shp_path = unique(iucn_paths$file_path)[1]
    message("Reading ", basename(shp_path))
    sp_l = dplyr::filter(iucn_paths, file_path == shp_path)
    
    shp = sf::read_sf(shp_path)  |> 
      dplyr::filter(sci_name %in% sp_l$iucn_name) |> 
      dplyr::left_join(dplyr::select(iucn_paths, taxon_id, iucn_name), 
                       by = dplyr::join_by("sci_name" == "iucn_name"), 
                       relationship = 'many-to-many')
    return(shp)
  }) |> 
    dplyr::bind_rows() |> 
    sf::st_as_sf()
  return(iucn_maps)
}

