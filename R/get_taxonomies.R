#' Get Taxonomies from GBIF
#'
#' This function adds taxonomy information from GBIF to any data frame that has
#'     valid scientific names and returns a tibble. `gbif_taxonID` is the GBIF
#'     ID for the given scientific name and full taxonomy from the GBIF backbone
#'     taxonomies database. `taxon_id` is ID number of the accepted taxonomy
#'     from the GBIF backbone.
#'
#' @param spp_list A data frame containing valid scientific species names.
#' @param query_field The name of the variable with valid scientific names.
#' @param correct Logical. If TRUE, `correct_taxon_ids()` is used to correct 
#'     known issues with taxon ID's and scientific names. Default is FALSE.
#'
#' @returns A [tibble::tibble()]
#' @seealso [correct_taxon_ids()]
#' @export
#'
#' @examples
#' ## Not run:
#'
#' library(mpsgSE)
#' spp_list <- get_taxonomies(sp_list_ex)
#'
#' ## End(Not run)
get_taxonomies <- function(spp_list, query_field = "scientific_name", 
                           correct = FALSE) {
  # spp_list = mpsgSE::sp_list_ex
  
  # Get list of distinct species.
  distinct_spp = spp_list |>
    dplyr::select(dplyr::any_of(query_field)) |>
    dplyr::distinct()
  # Clean text
  distinct_spp$my_clean_query_name = distinct_spp |>
    dplyr::pull(query_field) |>
    stringr::str_replace("[\r\n]", " ") |>
    stringr::str_replace("[\r\n]", "") |>
    stringr::str_replace("  ", " ") |>
    stringr::str_replace("[^A-Za-z0-9 ]", "") |> 
    stringr::str_to_sentence()
  
  # Correct Scientific Names with known Errors
  if(correct) {
    # Read corrected names data frame
    cor_names = mpsgSE::name_corrections
    # Match scientific names
    matched_names = match(distinct_spp$my_clean_query_name, cor_names$errored_name)
    # Correct scientific names
    distinct_spp$my_clean_query_name[!is.na(matched_names)] = cor_names$corrected_name[matched_names[!is.na(matched_names)]]
  }
  
  # Get GBIF Taxon ID's
  distinct_spp$gbif_taxonID <- taxize::get_gbifid(
    distinct_spp$my_clean_query_name, ask = FALSE, rows = 1, messages = FALSE
  )

  # Pull Taxonomy from GBIF backbone taxonomy
  taxonomy_list = taxize::classification(distinct_spp$gbif_taxonID, db = "gbif")

  # Function to convert long list to wide data frame and add taxon ID's
  convert_taxonomy = function(i, tax_list) {
    # Get GBIF IF
    gbif_taxonID = names(tax_list)[[i]]
    if(!is.na(gbif_taxonID)){
      # Get MPSG taxon ID
      final_id = tax_list[[i]] |>
        tail(1) |>
        dplyr::pull(id)
      # Get taxonomy
      named_taxonomy = tax_list[[i]] |>
        dplyr::select(rank, name) |>
        tidyr::pivot_wider(names_from = rank, values_from = name)
      # Stitch together data frame
      tibble::tibble(taxon_id = as.numeric(final_id)) |>
        dplyr::bind_cols(tibble::tibble(gbif_taxonID = gbif_taxonID)) |>
        dplyr::bind_cols(named_taxonomy)
    }
  }

  # Convert list to data frame
  all_taxonomies = lapply(seq_along(taxonomy_list), convert_taxonomy, 
                          taxonomy_list) |>
    dplyr::bind_rows()

  # Create final data frame
  variable_order = c(query_field, "taxon_id", "gbif_taxonID", "kingdom",
                     "phylum", "class", "order", "family", "genus", "species",
                     "subspecies", "variety", "form")
  all_spp_taxonomies = distinct_spp |>
    dplyr::mutate(gbif_taxonID = as.character(gbif_taxonID)) |>
    dplyr::left_join(all_taxonomies, by = "gbif_taxonID") |>
    dplyr::select(dplyr::any_of(variable_order))
  
  returned_dat = dplyr::left_join(spp_list, all_spp_taxonomies, 
                                  by=query_field) |> 
    dplyr::distinct()
  
  if(correct) {
    returned_dat = correct_taxon_ids(returned_dat, query_field = query_field)
  }
  
  return(returned_dat)
}


#' Get Taxonomic Synonyms
#'
#' This function queries synonyms from the GBIF Backbone taxonomy. It will only
#'     return synonyms for unique taxon ID's (i.e., duplicated taxon ID's will
#'     not be queried).
#'
#' @param spp_list Species list with taxon ID's from `get_taxonomies()`.
#'
#' @returns A [tibble::tibble()]
#' @export
#'
#' @examples
#' library(mpsgSE)
#' spp_data <- mpsgSE::sp_list_ex |>
#'   get_taxonomies('scientific_name')
#' get_synonyms(spp_data)
get_synonyms <- function(spp_list) {

  # eligible_list = targets::tar_read(elig_list)
  # u_code = "BRF"

  t_ids = unique(spp_list$taxon_id)

  syns = lapply(t_ids, function(x){
    rgbif::name_usage(key = x, data = "synonyms")$data
  }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(taxon_id = acceptedKey) |>
    tibble::tibble()

  return(syns)
}
