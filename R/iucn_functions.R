

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


#' Build IUCN Maps (Deprecated)
#' 
#' This function reads spatial (polygon) range data from International Union for 
#'     Conservation of Nature (IUCN) into R. These shapefiles were downloaded 
#'     from IUCN (<https://www.iucnredlist.org/resources/spatial-data-download>), 
#'     and saved on the MPSG T-drive. This function will fail if you are not on 
#'     a FS network or in the FS VDI. Use `get_iucn_shp_paths()` to get the 
#'     shapefile paths prior to running this function.
#'
#' @param iucn_paths File paths to IUCN shapefiles.
#' 
#' @seealso [get_taxonomies()], [get_iucn_shp_paths()]
#' 
#' @return An [sf] object.
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' library(psoSppEvals)
#' spp_list <- get_taxonomies(sp_list_ex)
#' map_paths <- get_iucn_shp_paths(spp_list)
#' iucn_maps <- build_iucn_maps(map_paths)
#' }
build_iucn_maps <- function(iucn_paths) {
  grouped_data = iucn_paths |>
    dplyr::group_by(file_path) |>
    dplyr::summarize(
      where_in = paste(sprintf("'%s'", iucn_name), collapse = ", ")
                     ) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      layer_n = basename(file_path) |> stringr::str_replace(".shp", "")
      )
  
  test_f = function(file_path, where_in, layer_n) {
    query_string = sprintf("SELECT * FROM %s WHERE sci_name IN (%s)", 
                           layer_n, where_in)
    sf::st_read(file_path, query = query_string)
  }
  
  purrr::pmap(grouped_data, test_f) |>
    dplyr::bind_rows() |>
    dplyr::left_join(dplyr::select(iucn_paths, taxon_id, iucn_name), 
                     by = c("sci_name" = "iucn_name"))
}


#' Get paths to IUCN Shapefiles (Deprecated)
#' 
#' This function reads in an *.RDS file of IUCN shapefile paths and filters it 
#'     to the eligible species list. The *.RDS file is on the MPSG T-drive, so 
#'     this function will fail if you are not on a FS network or in the FS VDI.
#'
#' @param spp_list A species list with taxon ID's from `get_taxonomies()`.
#'
#' @seealso [get_taxonomies()]
#' 
#' @return A [tibble::tibble()].
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' library(psoSppEvals)
#' spp_list <- get_taxonomies(sp_list_ex)
#' bien_map_paths <- get_iucn_shp_paths(spp_list)
#' }
get_iucn_shp_paths <- function(spp_list){
  
  # spp_list = targets::tar_read(rfss)
  
  sp_tids <- spp_list |> dplyr::pull(taxon_id) |> unique()
  
  # Read in RDS file and filter to eligible list
  iucn_shp_paths = readRDS(
    file.path("T:/FS/NFS/PSO/MPSG/Data/ExternalData/IUCN", "iucn_shp_paths")
    )
  # Filter by 'taxon_id'
  iucn_paths = dplyr::filter(iucn_shp_paths, taxon_id %in% sp_tids) |> 
    dplyr::filter(!is.na(taxon_id) & taxon_id != 1)
  return(iucn_paths)
}