#' Set Up Species Evaluation Pipeline
#' 
#' This function establishes a targets pipeline for species evaluation data 
#'     pulls and evaluation templates. This function copies sub-directories and
#'     files into a specified directroy.
#' 
#' @param dir_path Path to directory you'd like your pipeline.
#' @param unit_code Unit acronym.
#'
#' @returns Nothing. 
#' @export
#'
#' @examples
#' \dontrun{
#' library("psoSppEvals")
#' scc_library <- file.path(Sys.getenv("USERPROFILE"), 
#'                          "USDA/Mountain Planning Service Group - SCC Library", 
#'                          "12_Lolo NF")
#' set_up_pipeline(file.path(scc_library, "Species List"), "LNF")
#' }
set_up_pipeline <- function(dir_path, unit_code){
  template_dir = system.file("pipeline", package = "psoSppEvals")
  pipeline_dir = file.path(dir_path, paste0(unit_code, "_SppEval_Pipeline"))
  if(!dir.exists(pipeline_dir)) dir.create(pipeline_dir, recursive = TRUE)
  fs::dir_copy(template_dir, pipeline_dir)
  }