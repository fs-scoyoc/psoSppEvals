#' Write Habitat Excel Workbook
#' 
#' This function takes the data from `count_spp_by_hab()`, `pull_landfire()`, 
#'     and `extract_landfire_evt()` and writes them to an Excel workbook.
#'
#' @param ns_hab_count_data Data returned from `count_spp_by_hab()`.
#' @param lf_data Data returned from `pull_landfire()`
#' @param lf_extract_data Data returned from `extract_landfire_evt()`.
#' @param unit_code 4-letter Forest Service unit acronym.
#' @param dir_path Directory path to save workbook in. Default is a subfolder in
#'     your working directory named "output".
#' @param scc_library Directory path to SCC SharePoint Library to make a copy in.
#'
#' @returns Nothing.
#' @seealso [count_spp_by_hab()], [pull_landfire()], [extract_landfire_evt()]
#' @export
#'
#' @examples
#' # Coming soon, to a theater near you...
#' message("Check back soon")
write_habitat_xlsx <- function(ns_hab_count_data, lf_data, lf_extract_data, 
                               unit_code, dir_path = "output", scc_library){
  # ns_hab_count_data = targets::tar_read(ns_habitat_count)
  # lf_extract_data = targets::tar_read(spp_lf_evt)
  # lf_data = targets::tar_read(lf_evt)
  # unit_code = "CODE"
  
  # Write data ----
  if(!dir.exists(dir_path)) dir.create(dir_path)
  f_name = paste0(gsub("-", "", Sys.Date()), "_", unit_code, 
                  "_Habitats.xlsx")
  writexl::write_xlsx(
    list("NatureServe Habitat Crosswalk" = ns_hab_count_data,
         "LANDFIRE EVT" = lf_data$EVT, 
         "LANDFIRE PHYS" = lf_data$PHYS, 
         "Species LF EVT" = lf_extract_data$EVT,
         "Species LF PHYS" = lf_extract_data$PHYS),
    file.path(dir_path, f_name)
  )
  #-- Copy to parent species list directory
  if(dir.exists(scc_library)){
    file.copy(file.path("output", f_name), 
              file.path(scc_library, "Species List", f_name))
    } else(message("SCC library does not exist. 
                    Workbook not copied to SCC library."))
  
}