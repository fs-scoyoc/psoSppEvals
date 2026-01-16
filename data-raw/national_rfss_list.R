#' ---
#' title: "Taxonomy and Taxon ID's for Regional Foresters Sensitive Species Lists"
#' author:
#'   - name: "Matthew Van Scoyoc" 
#'     affiliation: |
#'       | Mountain Planning Service Group, Regions 1-4
#'       | Information Management Group
#'       | Forest Service, USDA
#' date: 16 January 2026
#' 
#' This script queries taxonomy and taxon IDs using the `get_taxonomies()` 
#' function.
#'-----------------------------------------------------------------------------

# setup ----
pkgs <- c("dplyr",   # data management
          "janitor", # data management
          "mpsgSE",  # taxonomy function 
          "readxl",  # read Excel files
          "tidyr")   # data management

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


# 2025 data ----
#' Read RFSS Excel workbook sheets into R
#'
#' @param sheet_name The name of the sheet.
#' @param xlsx_path Path to Excel workbook.
read_rfss <- function(sheet_name, xlsx){
  message(paste0("Reading ", sheet_name, " list"))
  dat = readxl::read_excel(xlsx_path, sheet = sheet_name) |> 
    janitor::clean_names() |> 
    dplyr::distinct() |> 
    dplyr::mutate(region = sheet_name)
  return(dat)
}

## read RFSS's ----
xlsx_path = file.path("data/data", "2025_National_RFSS_list.xlsx")
reg_list = c("R1", "R2", "R3", "R4", "R5", "R6", "R8", "R9", "R10")
dat = lapply(reg_list, read_rfss, xlsx = xlsx_path) |> 
  dplyr::bind_rows() |> 
  dplyr::mutate(orig_scientific_name = scientific_name, 
                scientific_name = trimws(scientific_name), 
                scientific_name = gsub(" +", " ", scientific_name))

## taxon ID's and taxonomies
taxa = dat |> 
  dplyr::select(scientific_name) |> 
  dplyr::distinct() |>
  # dplyr::slice(1:1000) |> 
  mpsgSE::get_taxonomies(correct = TRUE)

rfss = dplyr::left_join(dat, taxa, by = 'scientific_name', 
                        relationship = 'many-to-many') |> 
  mpsgSE::correct_taxon_ids(scientific_names = TRUE)

## save ----
saveRDS(rfss, file.path("data-raw/data", "national_rfss_taxon_id"))
rfss <- readRDS(file.path("data-raw/data", "national_rfss_taxon_id"))
usethis::use_data(rfss, overwrite = TRUE)


# 2024 data ----
#-- raw data
rfss_file <- file.path("data-raw", "data", "2024_RFSS_Lists_R1-10.xlsx")
rfss_raw <- readxl::read_excel(rfss_file, sheet = "RFSSL Master List") |> 
  dplyr::select(-fs_name) |> 
  dplyr::distinct() |> 
  mpsgSE::get_taxonomies() |> 
  mpsgSE::correct_taxon_ids()

#-- regional lists
rfss <- rfss_raw |> 
  dplyr::select(taxon_id, scientific_name:R10) |> 
  tidyr::pivot_longer(R1:R10, names_to = "region", values_to = "rfss") |> 
  dplyr::mutate(rfssl = ifelse(rfss == "X", TRUE, FALSE), 
                region = factor(region, 
                                levels = c("R1", "R2", "R3", "R4", "R5", "R6", 
                                           "R8", "R9", "R10"))) |> 
  dplyr::filter(rfssl == TRUE) |>
  dplyr::mutate(
    region_num = stringr::str_remove(region, "R"),
    status_area = paste("USFS Region", region_num, sep = " "),
    status_authority = "US Forest Service",
    status_all = paste("USFS", region, "Sensitive Species", sep = " "),
    status_simple = "Sensitive Species",
    status_type = "Sensitive Species"
  ) |>
  dplyr::select(-rfss) |> 
  dplyr::arrange(group_level2, scientific_name, region)

#-- taxonomies
taxa_select = c("taxon_id", "scientific_name", "kingdom", "phylum", "class",
                "order", "family", "genus", "species", "subspecies", "variety", 
                "form")
rfss_taxonomy <- dplyr::select(rfss_raw, dplyr::any_of(taxa_select))

## save ----
# readr::write_csv(rfss,
#                  file.path("data-raw/output/fs_rfss_lists.csv"))
# readr::write_csv(rfss_taxonomy,
#                  file.path("data-raw/output/fs_rfss_taxonomy.csv"))

# rfss <- readr::read_csv(
#   file.path("data-raw/output/species_lists/fs_rfss_lists.csv")
#   )
# rfss_taxonomy <- readr::read_csv(
#   file.path("data-raw/output/species_lists/fs_rfss_taxonomy.csv")
# )
# usethis::use_data(rfss, rfss_taxonomy, overwrite = TRUE)

