#' This script contains three function. `build_all_occ_data()` and 
#'     `write_spatial_data()` might need to be modified  for your pipeline.
#' 
#' List of functions:
#'   -   `build_all_occ_data()`
#'   -   `build_basemap_data()`
#'   -   `write_spatial_data()`


#' This function combines all of the occurrence point data into a single [sf] 
#'     object.
#' 
#' **Note**: The input data sets might need to be modified for your pipeline. 
#'     GBIF, SEINet, IMBCR, and Forest Service data will not change. State NHP 
#'     data might need to be updated or duplicated depending on your pipeline.
#' 
#' @param gbif_data Spatial GBIF data from this pipeline.
#' @param seinet_data Spatial SEINet data from this pipeline.
#' @param imbcr_data Spatial IMBCR data from this pipeline.
#' @param nhp_data Spatial UNHP **point** data from this pipeline.
#' @param fs_data Spatial Forest Service **point** data from this pipeline.
#' @param tar_crs Target coordinate reference system. 
#'
#' @return An [sf] object.
build_all_occ_data <- function(spp_list, gbif_data, seinet_data, imbcr_data, 
                               nhp_data, fs_data, tar_crs = crs) {
  
  # Load these parameters to troubleshoot/modify this function
  # spp_list = targets::tar_read(elig_list)
  # gbif_data = targets::tar_read(gbif_unit)
  # seinet_data = targets::tar_read(sei_unit)
  # imbcr_data = targets::tar_read(imbcr_unit)
  # nhp_data = targets::tar_read(unhp_unit)
  # fs_data = targets::tar_read(fs_unit)
  # dataset_name = "EligOccData"; data_prefix = "elig"
  # tar_crs = "EPSG:26912"; proj_gdb = file.path("data", "DIF_SppOcc_Data.gdb")
  
  library(sf)
  # Function to reduce and standardize data
  process_sf = function(sf_data, source){
    # sf_data = gbif_data; source = "GBIF"
    # Reduce data
    dat = dplyr::select(sf_data, taxon_id) |>
      dplyr::mutate(taxon_id = as.numeric(taxon_id), source = source) |> 
      sf::st_make_valid()
    # Transform data if they are not in the project CRS
    if(!sf::st_crs(dat) == tar_crs){
      dat = sf::st_transform(x = dat, crs = tar_crs)
    }
    return(dat)
  }

  # Standardize data
  g_pts = mpsgSE::build_gbif_spatial_data(gbif_data$all_data, spp_list) |> 
    process_sf(source = "GBIF")
  s_pts = mpsgSE::build_seinet_spatial_data(seinet_data$all_data, spp_list) |> 
    process_sf(source = "SEINet")
  i_pts = mpsgSE::build_imbcr_spatial_data(imbcr_data, spp_list) |> 
    process_sf(source = "IMBCR")
  c_pts = dplyr::filter(nhp_data, taxon_id %in% spp_list$taxon_id) |> 
    process_sf(source = "UNHP")
  f_pts = dplyr::filter(fs_data, taxon_id %in% spp_list$taxon_id) |>
    sf::st_centroid(fs) |> 
    process_sf(source = "FS")
  # Combine data
  obs_dat = dplyr::bind_rows(g_pts, s_pts, i_pts, c_pts, f_pts) |> 
    sf::st_as_sf()
  # Return data
  return(obs_dat)
}


#' Get base map data
#' 
#' @description
#' Pull spatial base map data for North and South America, the lower 48 US 
#'     states, and a user specified National Forest. Continental and national 
#'     scale data are acquired using the `rnaturalearth` package and Forest 
#'     Service data are acquired from Forest Service ArcGIS Rest Services
#'     (https://apps.fs.usda.gov/arcx/rest/services/EDW) using `arcgislayers` 
#'     package. Roads data are acquired using the `osmdata` package.
#'
#' @param states A list of state names or abbreviations.
#' @param region_number The Forest Service Region number
#' @param forest_number The Forest Service Forest number.
#' @param forest_name The Name of the National Forest.
#' @param admin_bndry Optional. 'sf' object of administrative Forest Service 
#'     boundary can be provided. Default is TRUE. If TRUE administrative Forest
#'     Service boundary will be pulled from the Forest Service ArcGIS REST 
#'     service.
#' @param plan_area Optional. 'sf' object of the plan area (Forest Service land) 
#'     boundary can be provided. Default is TRUE. If TRUE the plan area boundary 
#'     will be pulled from the Forest Service ArcGIS REST service.
#' @param districts Optional. 'sf' object of the Forest Service district 
#'     boundaries for the National Forest can be provided. Default is TRUE. If 
#'     TRUE the district boundary will be pulled from the Forest Service ArcGIS 
#'     REST service.
#' @param target_crs The target coordinate reference system. The default is 
#'      EPSG:4326 (WGS 84).
#'
#' @details
#' `get_basemap_data` returns a list of spatial features used to produce 
#'     automated species evaluations.
#' @details
#' Continental-scale data include 'americas', 'north_america', and 'l_48'. These 
#'     data are acquired using [rnaturalearth::ne_countries()] and 
#'     [rnaturalearth::ne_states()] functions. These data are in the NAD83 CONUS 
#'     Albers (EPSG:5070).
#' @details
#' National Forest-scale data include 'admin_bndry', 'plan_area', 'districts', 
#'     'aoa', 'aoa_bbox', and 'plan_area_doughnut'. 'admin_bndry', 'plan_area', 
#'     and 'districts' are acquired using [read_edw_lyr()]. 'buffer', 'aoa', 
#'     'aoa_bbox', and 'plan_area_doughnut' are derived using the [sf] package. 
#'     'aoa', or area of analysis, is a 4828 meter (3 mile) buffer of 
#'     'admin_bndry' using [sf::st_buffer()]. 'aoa_bbox' is a bounding box of 
#'     'aoa' using [sf::st_bbox()]. 'plan_area_doughnut' is a 1000 meter buffer 
#'     of 'plan_area' with 'plan_area' erased using [sf::st_difference()]. 
#'     These data are returned in the coordinate reference system provided by 
#'     the `crs` parameter.
#' @note
#' Sometimes the connection to the Forest Service REST Service or [osmdata] 
#'     fails. This will throw the following error message: "**Error:** 
#'     tar_make() Status code: 500. Error: json". In most instances, the 
#'     function can simply be executed again to retrieve the data. Check the 
#'     data servers if the error is persistent. 
#' @returns A list of [sf] objects.
#' @seealso [read_edw_lyr()], [rnaturalearth::ne_countries()], 
#'          [rnaturalearth::ne_states], [osmdata::osmdata_sf()]
#' @export
#'
#' @examples
#' library(mpsgSE)
#' states <- c("Utah", "Nevada", "New Mexico")
#' region_number <- "04"
#' forest_number <- "07"
#' forest_name <- "Dixie National Forest"
#' basemap_data <- get_basemap_data(states, region_number, forest_number, 
#'                                  forest_name)
build_basemap_data = function(admin_bndry_sf, plan_area_sf, target_crs = "EPSG:4326"){
  
  # Load these parameters to troubleshoot/modify this function
  # target_crs = "EPSG:26913"
  # admin_bndry_sf = targets::tar_read(proc_bndry)
  # plan_area_sf = targets::tar_read(plan_area)
  # states = c("Utah", "Nevada", "Arizona")
  
  message("Western hemisphere")
  americas = rnaturalearth::ne_countries(scale = "medium",
                                         continent = c("North America",
                                                       "South America"),
                                         returnclass = "sf") |>
    dplyr::filter(name != "Hawaii") |>
    sf::st_transform(crs = 5070)
  
  message("North America")
  north_america_c = rnaturalearth::ne_countries(
    scale = "medium", continent = "North America", returnclass = "sf"
  ) |>
    dplyr::select(name) |>
    dplyr::filter(name != "United States of America")
  north_america_s = rnaturalearth::ne_states(
    country = c("United States of America", "Canada", "Mexico"), 
    returnclass = "sf"
  ) |>
    dplyr::filter(name != "Hawaii") |>
    dplyr::select(name = name_en)
  north_america = dplyr::bind_rows(north_america_c, north_america_s) |>
    sf::st_transform(crs = 5070)
  
  message("Lower 48 states")
  l_48 = rnaturalearth::ne_states(country = c("United States of America")) |>
    sf::st_as_sf() |>
    dplyr::filter(name != "Hawaii", name != "Alaska") |>
    sf::st_transform(crs = 5070)
  
  message("FS Boundaries")
  # Area of Analysis
  aoa = sf::st_buffer(admin_bndry_sf, units::as_units(3,"mi")) |> 
    sf::st_transform(target_crs) |> 
    sf::st_make_valid()
  # Buffer
  plan_area_doughnut = sf::st_buffer(plan_area_sf, units::as_units(1,"km")) |> 
    sf::st_difference(plan_area_sf) |> 
    sf::st_transform(target_crs) |> 
    sf::st_make_valid() |> 
    suppressWarnings()
  
  #-- Assemble final data set
  dat = tibble::lst(americas, north_america, l_48, aoa, 
                    'admin_bndry' = admin_bndry_sf, 'plan_area' = plan_area_sf, 
                    plan_area_doughnut)
  return(dat)
}


#' Write spatial data to geodatabase
#'
#' **Note**: The input data sets might need to be modified for your pipeline. 
#'     GBIF, SEINet, IMBCR, and Forest Service data will not change. State NHP 
#'     data might need to be updated or duplicated depending on your pipeline.
#' 
#' @param gbif_data Spatial GBIF occurrence data from this pipeline.
#' @param seinet_data Spatial SEINet occurrence data from this pipeline.
#' @param imbcr_data Spatial IMBCR occurrence data from this pipeline.
#' @param nhp_data Spatial ID NHP occurrence data from this pipeline.
#' @param fs_data Spatial MT NHP occurrence data from this pipeline.
#' @param dataset_name Feature dataset name to write data in.
#' @param data_prefix Prefix to add to data name (e.g., "elig" or "nko")
#' @param t_path_gdb File path to geodatabase from this pipeline.
#' @param tar_crs Targets coordinate reference system.
#' 
write_spatial_data <- function(spp_list, gbif_data, seinet_data, imbcr_data, 
                               nhp_data, fs_data, dataset_name, data_prefix, 
                               gdb_path = proj_gdb, tar_crs = crs){
  
  # Load these parameters to troubleshoot/modify this function
  # spp_list = targets::tar_read(elig_list)
  # gbif_data = targets::tar_read(gbif_unit)
  # seinet_data = targets::tar_read(sei_unit)
  # imbcr_data = targets::tar_read(imbcr_unit)
  # nhp_data = targets::tar_read(unhp_unit)
  # fs_data = targets::tar_read(fs_unit)
  # dataset_name = "EligOccData"; data_prefix = "elig"
  # tar_crs = "EPSG:26912"; proj_gdb = file.path("data", "DIF_SppOcc_Data.gdb")
  
  # Activate ArcGIS license
  arcgisbinding::arc.check_product()
  
  # data cleaning function
  clean_sf <- function(dat){
    # dat = gbif_data$valid_data
    sf_d <- dat |> 
      dplyr::mutate(
        dplyr::across(dplyr::where(lubridate::is.Date), as.character)
      )
    if(sf::st_crs(sf_d) != tar_crs) sf_d = sf::st_transform(sf_d, tar_crs)
    return(sf_d)
  }
  
  
  message("Writing GBIF data")
  arcgisbinding::arc.write(
    path = file.path(gdb_path, dataset_name, paste0(data_prefix, "_GBIF")),
    data = mpsgSE::build_gbif_spatial_data(gbif_data$all_data, spp_list) |> 
      clean_sf(),
    overwrite = TRUE
  )
  # Build uncertainty buffers
  gbif_u <- mpsgSE::build_gbif_spatial_data(gbif_data$valid_data, spp_list) |> 
    dplyr::mutate(
      coordinateUncertaintyInMeters = units::set_units(coordinateUncertaintyInMeters, "m")
    )
  gbif_b <- sf::st_buffer(gbif_u, dist = gbif_u$coordinateUncertaintyInMeters)
  arcgisbinding::arc.write(
    path = file.path(gdb_path, dataset_name, 
                     paste0(data_prefix, "_GBIF_UncertaintyBuffers")),
    data = clean_sf(gbif_b),
    overwrite = TRUE
  )
  
  message("Writing SEINet data")
  arcgisbinding::arc.write(
    path = file.path(gdb_path, dataset_name, paste0(data_prefix, "_SEINet")),
    data = mpsgSE::build_seinet_spatial_data(seinet_data$all_data, spp_list) |> 
      clean_sf(),
    overwrite = TRUE
  )
  # Build uncertainty buffers
  sei_u <- mpsgSE::build_seinet_spatial_data(seinet_data$valid_data, spp_list) |>
    dplyr::mutate(
      coordinateUncertaintyInMeters = units::set_units(coordinateUncertaintyInMeters, "m")
    )
  sei_b <- sf::st_buffer(sei_u, dist = sei_u$coordinateUncertaintyInMeters)
  arcgisbinding::arc.write(
    path = file.path(gdb_path, dataset_name, 
                     paste0(data_prefix, "_SEINet_UncertaintyBuffers")),
    data = clean_sf(sei_b),
    overwrite = TRUE
  )
  
  message("Writing IMBCR data")
  arcgisbinding::arc.write(
    path = file.path(gdb_path, dataset_name, paste0(data_prefix, "_IMBCR")),
    data = mpsgSE::build_imbcr_spatial_data(imbcr_data, spp_list) |> clean_sf(),
    overwrite = TRUE
  )

  message("Writing UNHP data")
  arcgisbinding::arc.write(
    path = file.path(gdb_path, dataset_name, paste0(data_prefix, "_UNHP")),
    data = dplyr::filter(nhp_data, taxon_id %in% spp_list$taxon_id) |> 
      clean_sf(),
    overwrite = TRUE
  )
  # Build uncertainty buffers
  unhp_u <- nhp_data |>
    dplyr::mutate(locuncert = units::set_units(loc_uncert_m, "m")) |>
    dplyr::filter(!is.na(loc_uncert_m))
  unhp_b <- sf::st_buffer(unhp_u, dist = unhp_u$loc_uncert_m)
  arcgisbinding::arc.write(
    path = file.path(gdb_path, dataset_name, 
                     paste0(data_prefix, "_UNHP_UncertaintyBuffers")),
    data = clean_sf(unhp_b),
    overwrite = TRUE
  )
  
  message("Writing FS EDW data")
  arcgisbinding::arc.write(
    path = file.path(gdb_path, dataset_name, paste0(data_prefix, "_FS_EDW")),
    data = dplyr::filter(fs_data, taxon_id %in% spp_list$taxon_id) |> 
      clean_sf(),
    overwrite = TRUE
  )
  
}


