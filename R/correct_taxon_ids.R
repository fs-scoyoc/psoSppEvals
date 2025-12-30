#' Correct known issues with taxon ID's and scientific names.
#' 
#' Documentation will be updated shortly.
#'
#' @param spp_list A data frame with taxon ID's from `get_taxonomies()`.
#' @param query_field Field holding scientific names
#'
#' @returns A [tibble::tibble()] with corrected taxon ID's and scientific names.
#' @seealso [get_taxonomies()]
#' @export
#' 
#' @examples
#' library(mpsgSE)
#' 
#'  spp_list = tibble::tibble(
#'    common_name = c("Western Toad", "Northern Leopard Frog", "Mountain Plover", 
#'                    "Snowy Plover", "American Goshawk", "Ferruginous Hawk", 
#'                    "Hopi Chipmunk", "Canada Lynx", "American Pika",
#'                    "Largemouth Bass", "Westslope Cutthroat Trout", 
#'                    "Vargo's Furcula", "Western Bumblebee", "Monarch"),
#'    scientific_name = c("Anaxyrus boreas", "Lithobates pipiens", 
#'                        "Anarhynchus montanus", "Anarhynchus nivosus", 
#'                        "Accipiter atricapillus", "Buteo regalis", 
#'                        "Neotamias rufus", "Lynx canadensis", "Ochotona princeps", 
#'                        "Micropterus nigricans", "Oncorhynchus lewisi", 
#'                        "Furcula vargoi", "Bombus occidentalis", 
#'                        "Danaus plexippus")
#'    ) |> 
#'    dplyr::mutate(
#'      taxon_id = taxize::get_gbifid(scientific_name, ask = FALSE, rows = 1, 
#'                                    messages = FALSE)) |> 
#'    dplyr::distinct()
#'  correct_taxon_ids(spp_list)
correct_taxon_ids <- function(spp_list, query_field = "scientific_name"){
  # Corrections
  n_cor = tibble::tibble(
    # Common names
    com_nam = c("Mountain Plover", "Snowy Plover", "American Goshawk",
                "Hopi Chipmunk", "Largemouth Bass", "Westslope Cutthroat Trout", 
                "Vargo's Furcula"),
    # Names throwing taxon ID errors
    err_nam = c("Anarhynchus montanus", "Anarhynchus nivosus",
                "Accipiter atricapillus", "Neotamias rufus",
                "Micropterus nigricans", "Oncorhynchus lewisi",
                "Furcula vargoi"), 
    # Corrected scientific names
    cor_nam = c("Charadrius montanus", "Charadrius nivosus",
                "Accipiter gentilis atricapillus", "Tamias rufus",
                "Micropterus floridanus", "Oncorhynchus clarkii lewisi",
                "Furcula vargoi")
    ) |> 
    # Pull taxon IDs from GBIF
    dplyr::mutate(
      t_id = taxize::get_gbifid(cor_nam, ask = FALSE, rows = 1, 
                                    messages = FALSE),
      t_id = as.numeric(t_id),
      # manual corrections
      t_id = ifelse(err_nam == "Furcula vargoi", 10047243, t_id)
    )
  
  # Match scientific names
  spp_list_sci_names = dplyr::pull(spp_list, query_field)
  mat_nam = match(spp_list_sci_names, n_cor$err_nam)
  
  # Correct taxon ID's
  spp_list$taxon_id[!is.na(mat_nam)] = n_cor$t_id[mat_nam[!is.na(mat_nam)]]
  cor_sci_names = spp_list_sci_names
  cor_sci_names[!is.na(mat_nam)] = n_cor$cor_nam[mat_nam[!is.na(mat_nam)]]
  spp_list[, query_field] = cor_sci_names
  
  # Return data
  return(spp_list)
}
