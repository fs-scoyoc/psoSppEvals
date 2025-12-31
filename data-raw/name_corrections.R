#' ---
#' title: "Taxonomy and Taxon ID's for Regional Foresters Sensitive Species Lists"
#' author:
#'   - name: "Matthew Van Scoyoc" 
#'     affiliation: |
#'       | Mountain Planning Service Group, Regions 1-4
#'       | Information Management Group
#'       | Forest Service, USDA
#' date: 22 April, 2025
#' 
#' This script queries taxonomy and taxon IDs using the `get_taxonomies()` 
#' function.
#'-----------------------------------------------------------------------------

# Set up ----
pkgs <- c("tibble", "dplyr", "taxize")

# Install packages if they aren't in your library
inst_pkgs <- pkgs %in% rownames(installed.packages())
if (any(inst_pkgs == FALSE)) {
  install.packages(pkgs[!inst_pkgs], 
                   lib =  .libPaths()[1], 
                   repos = "https://cloud.r-project.org",
                   type = 'source', 
                   dependencies = TRUE, 
                   quiet = TRUE)
}

# Load packages
invisible(lapply(pkgs, library, character.only = TRUE))



# data ----
name_corrections = tibble::tibble(
  # Common names
  common_name = c("Mountain Plover", "Snowy Plover", "American Goshawk",
                  "Hopi Chipmunk", "Largemouth Bass", 
                  "Westslope Cutthroat Trout", "Vargo's Furcula"),
  # Names throwing taxon ID errors
  errored_name = c("Anarhynchus montanus", "Anarhynchus nivosus",
                   "Accipiter atricapillus", "Neotamias rufus",
                   "Micropterus nigricans", "Oncorhynchus lewisi",
                   "Furcula vargoi"), 
  # Corrected scientific names
  corrected_name = c("Charadrius montanus", "Charadrius nivosus",
                     "Accipiter gentilis atricapillus", "Tamias rufus",
                     "Micropterus floridanus", "Oncorhynchus clarkii lewisi",
                     "Furcula vargoi")
  ) |> 
  # Pull taxon IDs from GBIF
  dplyr::mutate(
    taxon_id = taxize::get_gbifid(corrected_name, ask = FALSE, rows = 1, 
                                  messages = FALSE),
    taxon_id = as.numeric(taxon_id),
    # manual corrections
    taxon_id = ifelse(errored_name == "Furcula vargoi", 10047243, taxon_id)
  )

# save ----
usethis::use_data(name_corrections, overwrite = TRUE)
