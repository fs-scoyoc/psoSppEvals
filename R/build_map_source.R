#' Build Map Sources
#' 
#' This function takes in the maps that were retrieved using 
#'     `download_bien_range_maps()`,`download_ebird_range_maps()`, and 
#'     `build_iucn_maps()` and returns the data frame with taxonomic ID's, 
#'     taxonomies, and range map data sources.
#'     
#' @param spp_list A species list with taxon ID's from `get_taxonomies()`.
#' @param bien_maps `sf` object from `download_bien_range_maps()`.
#' @param ebird_maps `sf` object from `download_ebird_range_maps()`.
#' @param iucn_maps `sf` object from `build_iucn_maps()`.
#' 
#' @return A [tibble::tibble()]
#' 
#' @seealso [get_taxonomies()], 
#' 
#' @export
#' 
#' @examples
#' ## Not run:
#' 
#' library("mpsgSE")
#' ebird_key <- "abcde12fghij34"
#' 
#' # Build speceis list
#' spp_list <- get_taxonomies(sp_list_ex)
#' 
#' # BIEN Maps
#' bien_range_maps <- download_bien_range_maps(spp_list, 
#'                                             file.path("data", "bien_maps"))
#' 
#' # eBird Maps
#' ebird_status <- download_ebird_status_maps(spp_list, 
#'                                            output_path = file.path("data/ebirdst"), 
#'                                            ebird_access_key = ebird_key)
#' ebird_maps <- download_ebird_range_maps(spp_list,
#'                                         output_path = file.path("data/ebirdst"),
#'                                         ebird_access_key = ebird_key)
#' 
#' # IUCN Maps
#' iucn_maps <- get_iucn_maps(spp_list)
#'
#' # Build map source data frame
#' map_sources <- build_map_source(spp_list, bien_maps, ebird_maps, iucn_maps)
#' 
#' ## End(Not run)                     
build_map_source <- function(spp_list, bien_maps, ebird_maps, iucn_maps) {
  all_maps = spp_list |>
    dplyr::select(taxon_id) |>
    dplyr::distinct() |> 
    dplyr::mutate(
      bien = ifelse(taxon_id %in% bien_maps$taxon_id, "BIEN", NA),
      ebird = ifelse(taxon_id %in% ebird_maps$taxon_id, "eBird", NA),
      iucn = ifelse(taxon_id %in% iucn_maps$taxon_id, "IUCN", NA)
    ) |> 
    tidyr::pivot_longer(cols = c(bien, ebird, iucn), names_to = "data", 
                        values_to = 'source') |> 
    dplyr::filter(!is.na(source)) |>
    dplyr::group_by(taxon_id) |> 
    dplyr::reframe(map_source = stringr::str_c(source, collapse = ", "))
  
  source_list = spp_list |>
    dplyr::select(taxon_id) |>
    dplyr::distinct() |> 
    dplyr::left_join(all_maps, by = 'taxon_id') |> 
    dplyr::mutate(map_source = ifelse(is.na(map_source), "gbif", map_source))
  
  return(source_list)
}
