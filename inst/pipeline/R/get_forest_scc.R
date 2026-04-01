#' Read the Manti-La Sal SCC list into R
#' 
#' This is an example of reading a forest SCC list into the pipeline. Modify 
#'     this function as needed.
#' 
#' @param xlsx_path Path the Excel workbook.
#'
#' @returns A [tibble::tibble()].
get_forest_scc <- function(xlsx_path){
  dat = readxl::read_excel(xlsx_path) |> 
    janitor::clean_names() |> 
    mpsgSE::get_taxonomies("scientific_name", correct = TRUE) |> 
    dplyr::mutate(
      dup_taxon = ifelse(duplicated(taxon_id) | 
                           duplicated(taxon_id, fromLast = TRUE),
                         "Yes", "No")
      ) 
  return(dat)
}