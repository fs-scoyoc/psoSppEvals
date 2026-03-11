#' Build Quarto Parameters for Automated Evaluation Templates
#' 
#' This function builds the parameters for automated reporting.
#'      
#' @param spp_list Species list with taxon ID's and taxonomies from 
#'     `get_taxonomies()`.
#' @param output_path The base directory where you want the reports saved.
#' @param target_unit_name Name of FS unit "e.g. Dixie National Forests". 
#'
#' @returns A [tibble::tibble()].
#' 
#' @export
#' @seealso [get_taxonomies()]
#' @examples
#' \dontrun{
#' library('mpsgSE')
#' spp_list <- get_taxonomies(mpsgSE::sp_list_ex, 'scientific_name', 
#'                            correct = TRUE)
#' qmd_params <- build_quarto_params(spp_list, file.path('output', 'spp_evlas'), 
#'                                   "Smokey Bear National Forest")
#' }
build_quarto_params <- function(nat_known_list, output_path, target_unit_name){
  # targets::tar_load(nat_known_list); output_path = "output/spp_evals"
  # target_unit_name = "Cimarron and Comanche National Grasslands"
  
  date_stamp = gsub("-", "", Sys.Date())
  
  qmd_params = nat_known_list |> 
    dplyr::filter(new_spp == "Yes") |>
    dplyr::select(taxon_id, scientific_name, common_name, kingdom, phylum, 
                  class) |> 
    dplyr::group_by(taxon_id) |>
    dplyr::mutate(n = dplyr::n()) |>
    dplyr::filter(n == 1) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      output_folder = output_path,
      subfolder = dplyr::case_when(
        kingdom == "Plantae" ~ "Plants",
        phylum == "Ascomycota" ~ "Lichens",
        phylum == "Arthropoda" ~ "Invertebrates",
        class == "Aves" ~ "Birds",
        class == "Amphibia" ~ "Herpetofauna",
        class == "Squamata" ~ "Herpetofauna",
        class == "Testudines" ~ "Herpetofauna",
        class == "Mammalia" ~ "Mammals",
        is.na(class) ~ "Fish"
      ),
      sn_base = gsub(" ", "_", scientific_name),
      sn_base = gsub("'", "", sn_base),
      sn_base = gsub("\\.", "", sn_base),
      sn_base = gsub("ssp", "", sn_base),
      sn_base = gsub("var", "", sn_base),
      cn = stringr::str_replace_all(common_name, " ", "_"),
      cn = gsub("'", "", cn),
      output_file = glue::glue("{output_folder}/{subfolder}/{date_stamp}_AUTO_GENERATED_{cn}__{sn_base}.docx"),
      unit_name = target_unit_name
    ) |>
    dplyr::select(taxon_id, unit_name, output_file)
  return(qmd_params)
}

