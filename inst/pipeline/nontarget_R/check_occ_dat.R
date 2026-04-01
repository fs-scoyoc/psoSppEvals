#' title: "Quality Control: Occurrence Data"
#' author: "Matthew Van Scoyoc"
#' date: 17 February 2026
#' 
#' This script a makes simple maps to visually examine occurrence data. This 
#'     script will likely need to be modified for your pipeline.
#' 
#' -----------------------------------------------------------------------------


# set up ----
#-- packages
pkgs <- c('targets', 'tmap')
lapply(pkgs, library, character.only = TRUE) |> invisible()

#-- load base map data
targets::tar_load(basemap_data)

#-- map function
#' Custom map function
#'
#' @param occ_dat Occurrence data from this pipeline
#' @param data_source Character string for data source
#'
#' @returns a map (graphic object)
occ_map <- function(occ_dat, data_source){
  tmap::tm_shape(occ_dat) +
    tmap::tm_symbols(col = 'blue', fill = "blue", size = 0.25) +
    tmap::tm_shape(basemap_data$admin_bndry) +
    tmap::tm_borders(col = 'black', lwd = 2) +
    tmap::tm_title(data_source, position = c("right", "top"), size = 1, 
                   fontface = "bold")
}


# GBIF ----
targets::tar_load(gbif_data)
occ_map(gbif_data, "GBIF")

targets::tar_load(gbif_unit)
occ_map(gbif_unit$all_data,  "GBIF")


# SEINet ----
sei_obs_csv <- file.path("data/SEINet", "occurrences.csv")
sei_obs <- readr::read_csv(sei_obs_csv, show_col_types = FALSE) |>
  dplyr::filter(!is.na(decimalLongitude) |!is.na(decimalLatitude)) |> 
  sf::st_as_sf(coords = c("decimalLongitude", "decimalLatitude"),
               crs = "EPSG:4326") |> 
  sf::st_transform("EPSG:26912")
occ_map(sei_obs, "SEINet")

targets::tar_load(sei_unit)
occ_map(sei_unit$all_data,  "SEINet")


# IMBCR ----
occ_map(targets::tar_read(imbcr_data), "IMBCR")
occ_map(targets::tar_read(imbcr_unit), "IMBCR")


# UNHP ----
occ_map(targets::tar_read(unhp_data), "UNHP")
occ_map(targets::tar_read(unhp_unit), "UNHP")


# FS EDW ----
occ_map(targets::tar_read(fs_data), "FS EDW")
occ_map(targets::tar_read(fs_unit), "FS EDW")

