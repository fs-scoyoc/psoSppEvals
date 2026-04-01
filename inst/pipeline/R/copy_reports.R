#' Copy automated reports to another folder.
#' 
#' **Note**: This function is not yet an function included in the `psoSppEval` 
#'     package. It will likely be integrated into this package at some point.
#'
#' @param source_dir The source folder for the automated reports from this 
#'                       pipeline.
#' @param destination_dir The file path to the folder where the reports are to 
#'                            be copied.
#' 
#' @returns Nothing.
#' @export
#' 
#' @examples
#' \dontrun{
#' library(psoSppEvals)
#' 
#' copy_reports()
#' }
copy_reports <- function(
    source_dir = file.path("output/spp_evals"), 
    destination_dir = file.path(scc_library, "Species Evaluations", "Automated Evaluations")
    ){
  if(!dir.exists(destination_dir)) dir.create(destination_dir)
  file.copy(list.files(source_dir, full.names = TRUE), destination_dir, 
            recursive = TRUE)
}
