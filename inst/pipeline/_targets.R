#' title: "Pipeline for Automated Species Evaluations"
#' author: "Matthew Van Scoyoc"
#' date: YYYY Month DD
#' 
#' This script a targets pipeline for the [Forest Name] National Forest species 
#'     data pull and automated evaluation reports.
#' 
#' **Notes**: This pipeline needs to be modified for your project. This is an 
#'     example pipeline from the Fishlake NF data pull modified to Smoke Bear NF
#'     to make it generic. Below is a list of things that will need editing or 
#'     modification for your project. 
#'     
#' 1.   Replace the variables int the **Project variables** section to fit your 
#'          project. The variables noted with the *TODO* comment need updated.
#' 2.   Some of the scripts in the R directory will also need to be modified, 
#'          particularly: 
#'        -   build_conservation_list.R
#'        -   build_imbcr_trend_narratives.R
#'        -   build_spatial_data.R (this script might run fine depending on your 
#'                pipeline)
#'        -   build_spp_list.R
#'        -   fs_edw_functions.R
#'        -   get_forest_scc.R
#'        -   nhp_functions.R
#'        -   read_nko_xlsx.R
#' 3.   The Quarto scrips in the *qmd* folder will need substantial 
#'          modification. Currently, the notes indicating necessary 
#'          modifications are lacking in those scripts.
#' 4.   The pipeline is currently commented out. You will need to uncomment the
#'          targets to run the pipeline. I typically run the pipeline in 
#'          sections, e.g., Spatial Data, then Conservation Lists, and so on.
#' -----------------------------------------------------------------------------

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c(        # Packages that your targets need.
    "arcgisbinding",  # interface with ESRI products
    "dplyr",          # data management
    "janitor",        # data management
    "lubridate",      # makes dating easier
    "mpsgSE",         # MPSG species evaluation tools
    "mpsgSEdata",     # MPSG species evaluation data
    "readxl",         # read Excel files
    "sf",             # spatial tools for vector data
    "stringr",        # string (character) management tools
    "tibble",         # data frame management
    "tidyr",          # data management
    "writexl"         # read/write Excel files
  ),          
  format = "qs" # Optionally set the default storage format. qs is fast.
)

# Project variables ----
# TODO: Update states data frame, region and forest variables
states <- tibble::tibble(name = c("New Mexico", "Arizona"), abb = c("NM", "AZ"))
fs_region <- "R3"
unit_name <- "Smokey Bear National Forest" # Full name
unit_code <- "SBF" # Unit acronym

# Project Coordinate Reference System
# TODO: Update CRS
crs = "EPSG:26912" # NAD83 UTM Zone 12

#-- Keys
# TODO: Update gbif_key after you run the pipeline so you don't accidentally 
#     submit a data request to GBIF twice for the same project. The 23-digit 
#     file name of the zip file is your GBIF key, excluding ".zip".
gbif_key <- "new"
# TODO: acquire a eBird data key if you don't already have one. 
#     See the **Data Access** section of https://ebird.github.io/ebirdst/articles/status.html
ebird_key <- Sys.getenv("EBIRDST_KEY")

#-- Directory Paths
# TODO: Update the SCC library path for your project
scc_library <- file.path(Sys.getenv("USERPROFILE"),
                         "USDA/Mountain Planning Service Group - SCC Library",
                         "xx_Smokey Bear NF")
# These directories will not need to be modified.
bien_dir <- file.path("output/bien_maps")
ebird_dir <- file.path("output/ebirdst")
lf_dir <- file.path("data/LANDFIRE")

#-- Geodatabase Paths
# TODO: Update the geodatabase paths for your project
proj_gdb <- file.path("data", "SBF_SppOcc_Data.gdb")
# sf::st_layers(proj_gdb) |> dplyr::pull(name) |> sort() # View features in gdb
t_gdb <- file.path("T:/FS/NFS/PSO/MPSG/2025_FishlakeNF/1_PreAssessment", 
                   "Projects/SpeciesList_FIF/SpeciesList_FIF.gdb")

#-- Name of Native & Known to Occur Excel workbook
# Reviewed by Species Group Biologists
# NULL if a Native & Known to Occur workbook has not been produced
# TODO: Update the Excel file names for your project. These file names will be
#     assigned in the pipeline.
nko_xlsx_file <- "20260309_FIF_EligibleSppList.xlsx"
# Sheet of eligible species (reviewed by Species Group Biologists)
eligible_sheet <- "Eligible Species - Valid Data"
# Habitat Crosswalk Excel workbook
habitat_xwalk_xlsx_file <- "20260318_FIF_Habitats.xlsx"


# Run the R scripts in the R/ folder with your custom functions:
tar_source()

# Pipeline ----
# Replace the target list below with your own:
list(
  ## Spatial Data ----
  # tar_target(
  #   sd_proc_bndry,
  #   mpsgSE::read_fc("FIF_ProclaimedBoundary", proj_gdb, crs)
  # ),
  # tar_target(
  #   sd_plan_area,
  #   mpsgSE::read_fc("FIF_ProclaimedPlanArea", proj_gdb, crs)
  # ),
  # tar_target(
  #   sd_basemap_data,
  #   build_basemap_data(sd_proc_bndry, sd_plan_area, target_crs = crs)
  # ),
  
  
  ## Conservation List ----
  # # State NatureServe List
  # tar_target(
  #   cl_natureserve_data,
  #   mpsgSE::get_ns_state_list(state = states$abb[1], correct = TRUE)
  # ),
  # tar_target(
  #   cl_ns_list,
  #   mpsgSE::build_ns_spp_list(cl_natureserve_data)
  # ),
  # # Regional Foresters Sensitive Species List
  # tar_target(
  #   cl_rfss_list,
  #   mpsgSE::get_rfss_list(fs_region)
  # ),
  # # USFWS Birds of Conservation Concern List
  # tar_target(
  #   cl_bcc_list,
  #   mpsgSE::get_bcr_list(sd_basemap_data$admin_bndry)
  # ),
  # # Utah SWAP List
  # tar_target(
  #   cl_ut_swap,
  #   mpsgSEdata::ut_swap
  # ),
  # # BLM Sensitive Species List
  # tar_target(
  #   cl_ut_blm_ssl,
  #   mpsgSEdata::ut_blm_ss
  # ),
  # tar_target(
  #   cl_mlsnf_scc_list, 
  #   get_forest_scc(file.path("data", "Manti-LaSal_SCC_20260305.xlsx"))
  # ),
  # # Build master conservation list
  # tar_target(
  #   cl_master_status_list,
  #   build_conservation_list(cl_ns_list, cl_rfss_list, cl_bcc_list, cl_ut_swap, 
  #                           cl_ut_blm_ssl, cl_mlsnf_scc_list)
  # ),


  ## Occurrence Data ----
  ### GBIF Data ----
  # tar_target(
  #   od_gbif_data,
  #   mpsgSE::get_gbif_data(gbif_key = gbif_key, t_path = file.path("data"),
  #                         aoa_wkt = mpsgSE::wkt_string(sd_basemap_data$aoa),
  #                         gbif_user = Sys.getenv("GBIF_USER"),
  #                         gbif_pwd = Sys.getenv("GBIF_PWD"),
  #                         gbif_email = Sys.getenv("GBIF_EMAIL"),
  #                         crs = crs, correct = TRUE)
  # ),
  # tar_target(
  #   od_gbif_unit,
  #   mpsgSE::clip_fc(od_gbif_data, sd_basemap_data$plan_area, unit_code) |>
  #     data_integrety_qc()
  # ),
  # tar_target(
  #   od_gbif_unit_spp,
  #   tibble::lst('all_spp' = mpsgSE::build_gbif_spp(od_gbif_unit$all_data),
  #               'valid_spp' = mpsgSE::build_gbif_spp(od_gbif_unit$valid_data),
  #               'invalid_spp' = mpsgSE::build_gbif_spp(od_gbif_unit$invalid_data))
  # ),
  # tar_target(
  #   od_gbif_buff,
  #   mpsgSE::clip_fc(od_gbif_data, sd_basemap_data$plan_area_doughnut, "Buffer")
  # ),
  # tar_target(
  #   od_gbif_buff_spp,
  #   mpsgSE::build_gbif_spp(od_gbif_buff)
  # ),

  ### SEINet Data ----
  # tar_target(
  #   od_sei_data,
  #   mpsgSE::get_seinet_data(file.path("data", "SEINet"), crs = crs,
  #                           correct = TRUE)
  # ),
  # tar_target(
  #   od_sei_unit,
  #   mpsgSE::clip_fc(od_sei_data, sd_basemap_data$plan_area, unit_code) |>
  #     data_integrety_qc()
  # ),
  # tar_target(
  #   od_sei_unit_spp,
  #   tibble::lst('all_spp' = mpsgSE::build_seinet_spp(od_sei_unit$all_data),
  #               'valid_spp' = mpsgSE::build_seinet_spp(od_sei_unit$valid_data),
  #               'invalid_spp' = mpsgSE::build_seinet_spp(od_sei_unit$invalid_data))
  # ),
  # tar_target(
  #   od_sei_buff,
  #   mpsgSE::clip_fc(od_sei_data, sd_basemap_data$plan_area_doughnut, "Buffer")
  # ),
  # tar_target(
  #   od_sei_buff_spp,
  #   mpsgSE::build_seinet_spp(od_sei_buff)
  # ),

  ### IMBCR Data ----
  # tar_target(
  #   od_imbcr_data,
  #   mpsgSE::get_imbcr_data(fs_unit = unit_name, crs = crs)
  # ),
  # tar_target(
  #   od_imbcr_unit,
  #   mpsgSE::clip_fc(od_imbcr_data, sd_basemap_data$plan_area, unit_code)
  # ),
  # tar_target(
  #   od_imbcr_unit_spp,
  #   mpsgSE::build_imbcr_spp(od_imbcr_unit)
  # ),
  # tar_target(
  #   od_imbcr_buff,
  #   mpsgSE::clip_fc(od_imbcr_data, sd_basemap_data$plan_area_doughnut, "Buffer")
  # ),
  # tar_target(
  #   od_imbcr_buff_spp,
  #   mpsgSE::build_imbcr_spp(od_imbcr_buff)
  # ),

  ### Utah NHP Data ----
  # TODO: This section will need to be modified for you pipeline.
  # tar_target(
  #   od_unhp_pts,
  #   get_unhp_point_data()
  # ),
  # tar_target(
  #   od_unhp_plants,
  #   get_unhp_plant_data()
  # ),
  # tar_target(
  #   od_unhp_data,
  #   combine_unhp_data(od_unhp_pts, od_unhp_plants)
  # ),
  # tar_target(
  #   od_unhp_unit,
  #   mpsgSE::clip_fc(od_unhp_data, sd_basemap_data$plan_area, unit_code)
  # ),
  # tar_target(
  #   od_unhp_unit_spp,
  #   build_unhp_spp(od_unhp_unit, unit_code)
  # ),
  # tar_target(
  #   od_unhp_buff,
  #   mpsgSE::clip_fc(od_unhp_data, sd_basemap_data$plan_area_doughnut, "Buffer")
  # ),
  # tar_target(
  #   od_unhp_buff_spp,
  #   build_unhp_spp(od_unhp_buff, unit_code)
  # ),

  ### FS EDW Data ----
  # tar_target(
  #   od_fs_data,
  #   get_fs_data("Biology_TESP_OccurrenceAll_3miBuffer",
  #               "Biology_InvasivePlant_All_3miBuffer")
  # ),
  # tar_target(
  #   od_fs_unit,
  #   mpsgSE::clip_fc(od_fs_data, sd_basemap_data$plan_area, unit_code)
  # ),
  # tar_target(
  #   od_fs_unit_spp,
  #   build_fs_spp(od_fs_unit, unit_code)
  # ),
  # tar_target(
  #   od_fs_buff,
  #   mpsgSE::clip_fc(od_fs_data, sd_basemap_data$plan_area_doughnut, "Buffer")
  # ),
  # tar_target(
  #   od_fs_buff_spp,
  #   build_fs_spp(od_fs_buff, unit_code)
  # ),


  ## Eligible Species ----
  # TODO: This section will need to be modified for you pipeline.
  ### Build Species Lists ----
  # tar_target(
  #   elig_unit_list,
  #   build_spp_list(od_gbif_unit_spp, od_sei_unit_spp, od_imbcr_unit_spp,
  #                  od_unhp_unit_spp, od_fs_unit_spp, cl_master_status_list, 
  #                  unit_code)
  # ),
  # tar_target(
  #   elig_buffer_list,
  #   build_spp_list(od_gbif_buff_spp, od_sei_buff_spp, od_unhp_buff_spp,
  #                  od_fs_buff_spp, cl_master_status_list, "Buffer")
  # ),
  #-- Eligible Species LIst
  # tar_target(
  #   elig_list,
  #   dplyr::filter(elig_unit_list$all_spp, elig_scc == "Yes")
  # ),
  
  ### Synonyms ----
  # tar_target(
  #   elig_synonyms,
  #   mpsgSE::get_synonyms(elig_list)
  # ),


  ### Save Eligible Data ----
  # TODO: This section will need to be modified for you pipeline.
  #### Spatial Data ----
  # Write eligible species observations to geodatabase and return point data for
  #     eligible species.
  # tar_target(
  #   elig_occ_pts,
  #   build_all_occ_data(elig_list, od_gbif_unit, od_sei_unit, od_imbcr_unit, 
  #                      od_unhp_unit, od_fs_unit)
  # ),
  # tar_target(
  #   elig_occ_proj_gdb,
  #   write_spatial_data(elig_list, od_gbif_unit, od_sei_unit, od_imbcr_unit, 
  #                      od_unhp_unit, od_fs_unit, dataset_name = "EligOccData",
  #                      data_prefix = "Elig_v2", gdb_path = proj_gdb)
  # ),
  # tar_target(
  #   elig_occ_t_gdb,
  #   write_spatial_data(elig_list, od_gbif_unit, od_sei_unit, od_imbcr_unit, 
  #                      od_unhp_unit, od_fs_unit, dataset_name = "EligOccData",
  #                      data_prefix = "Elig_v3", gdb_path = t_gdb)
  # ),
  
  #### Write Excel workbook ----
  # tar_target(
  #   write_elig_xlsx,
  #   write_eligible_xlsx(tar_elig_list = elig_list,
  #                       tar_unit_list = elig_unit_list,
  #                       tar_buff_list = elig_buffer_list,
  #                       tar_elig_syns = elig_synonyms,
  #                       tar_plan_area = sd_basemap_data$plan_area)
  # ),

  ### Habitat ----
  #### NatureServe ----
  # tar_target(
  #   elig_ns_habitats,
  #   mpsgSE::get_ns_habitat(cl_ns_list, elig_list)
  # ),
  # tar_target(
  #   elig_ns_habitat_count,
  #   mpsgSE::count_spp_by_hab(elig_ns_habitats)
  # ),
  # #### LANDFIRE EVT ----
  # tar_target(
  #   elig_lf_evt,
  #   mpsgSE::pull_landfire(sd_basemap_data$plan_area, lf_dir, 
  #                         "matthew.vanscoyoc@usda.gov")
  # ),
  # tar_target(
  #   elig_spp_lf_evt,
  #   mpsgSE::extract_landfire_evt(elig_list, elig_occ_pts, lf_dir)
  # ),
  #-- Write Excel workbook
  # tar_target(
  #   write_elig_habitat_xlsx,
  #   mpsgSE::write_habitat_xlsx(elig_ns_habitat_count, elig_lf_evt, 
  #                              elig_spp_lf_evt, unit_code, 
  #                              scc_library = scc_library)
  # ),


  ### Range Maps ----
  #### BIEN ----
  # tar_target(
  #   elig_bien_maps,
  #   mpsgSE::download_bien_maps(elig_list, 
  #                              output_path = file.path("output/bien_maps"))
  # ),
  #### eBird ----
  # tar_target(
  #   elig_ebird_status_maps,
  #   mpsgSE::download_ebird_status_maps(
  #     elig_list,
  #     output_path = ebird_dir,
  #     ebird_access_key = ebird_key
  #   )
  # ),
  # tar_target(
  #   elig_ebird_range_maps,
  #   mpsgSE::download_ebird_range_maps(
  #     elig_list,
  #     output_path = ebird_dir,
  #     ebird_access_key = ebird_key
  #   )
  # ),
  #### IUCN ----
  # tar_target(
  #   elig_iucn_maps,
  #   mpsgSE::get_iucn_shp_paths(elig_list) |> mpsgSE::build_iucn_maps()
  # ),
  #-- Write range data
  # tar_target(
  #   write_elig_range_data_gdb,
  #   mpsgSE::write_range_data(bien_maps = elig_bien_maps,
  #                            ebird_range = elig_ebird_range_maps,
  #                            iucn_maps = elig_iucn_maps,
  #                            gdb_path = proj_gdb)
  # ),
  # tar_target(
  #   write_elig_range_data_tgdb,
  #   mpsgSE::write_range_data(bien_maps = elig_bien_maps,
  #                            ebird_range = elig_ebird_range_maps,
  #                            iucn_maps = elig_iucn_maps,
  #                            gdb_path = t_gdb)
  # ),
  
  
  ## Native & Known to Occur List ----
  # tar_target(
  #   nko_xlsx,
  #   file.path(scc_library, "Species List", nko_xlsx_file),
  #   format = "file"
  # ),
  # tar_target(
  #   nko_list,
  #   read_nko_xlsx(nko_xlsx, tar_master_cons_list = cl_master_status_list)
  # ),
  
  
  ### Pull Synonyms ----
  # tar_target(
  #   nko_synonyms,
  #   mpsgSE::get_synonyms(nko_list)
  # ),
  
  ### Read Habitat Crosswalk ----
  # tar_target(
  #   nko_ns_habitats,
  #   mpsgSE::get_ns_habitat(cl_ns_list, nko_list)
  # ),
  # tar_target(
  #   nko_habitat_xwalk_xlsx,
  #   file.path(scc_library, "Species List", habitat_xwalk_xlsx_file),
  #   format = "file"
  # ),
  # tar_target(
  #   nko_habitats_crosswalk,
  #   read_habitat_xwalk(nko_habitat_xwalk_xlsx, nko_ns_habitats)
  # ),
  
  
  ### Subset Occurrence Data ----
  # TODO: This section will need to be modified for you pipeline.
  # tar_target(
  #   nko_occ_data,
  #   build_all_occ_data(nko_list, od_gbif_unit, od_sei_unit, od_imbcr_unit, 
  #                      od_unhp_unit, od_fs_unit)
  # ),
  # tar_target(
  #   write_nko_occ_proj_gdb,
  #   write_spatial_data(nko_list, od_gbif_unit, od_sei_unit, od_imbcr_unit, 
  #                      od_unhp_unit, od_fs_unit, dataset_name = "NKO_OccData",
  #                      data_prefix = "nko", gdb_path = proj_gdb)
  # ),
  # tar_target(
  #   write_nko_occ_t_gdb,
  #   write_spatial_data(nko_list, od_gbif_unit, od_sei_unit, od_imbcr_unit, 
  #                      od_unhp_unit, od_fs_unit, dataset_name = "NKO_OccData",
  #                      data_prefix = "nko", gdb_path = t_gdb)
  # ),
  
  ### Range Maps ----
  #### BIEN ----
  # tar_target(
  #   nko_bien_maps,
  #   mpsgSE::download_bien_maps(nko_list, output_path = bien_dir)
  # ),
  #### eBird ----
  # tar_target(
  #   nko_ebird_status_maps,
  #   mpsgSE::download_ebird_status_maps(nko_list, output_path = ebird_dir,
  #                                      ebird_access_key = ebird_key)
  # ),
  # tar_target(
  #   nko_ebird_range_maps,
  #   mpsgSE::download_ebird_range_maps(nko_list, output_path = ebird_dir,
  #                                     ebird_access_key = ebird_key)
  # ),
  #### IUCN ----
  # tar_target(
  #   nko_iucn_maps,
  #   mpsgSE::get_iucn_maps(nko_list)
  # ),
  #### List map sources ----
  # tar_target(
  #   nko_map_source,
  #   mpsgSE::build_map_source(nko_list, nko_bien_maps, nko_ebird_range_maps,
  #                            nko_iucn_maps)
  # ),
  #### Write range data ----
  # tar_target(
  #   write_nko_range_data_gdb,
  #   mpsgSE::write_range_data(bien_maps = nko_bien_maps,
  #                            ebird_range = nko_ebird_range_maps,
  #                            iucn_maps = nko_iucn_maps,
  #                            gdb_path = proj_gdb)
  # ),
  # tar_target(
  #   write_nko_range_data_tgdb,
  #   mpsgSE::write_range_data(bien_maps = nko_bien_maps,
  #                            ebird_range = nko_ebird_range_maps,
  #                            iucn_maps = nko_iucn_maps,
  #                            gdb_path = t_gdb)
  # ),
  
  
  ### Status and Trends ----
  #### Pull eBird Trend Data ----
  # tar_target(
  #   nko_ebird_trend_maps,
  #   mpsgSE::download_ebird_trends_maps(nko_list, output_path = ebird_dir,
  #                                      ebird_access_key = ebird_key)
  # ),
  # tar_target(
  #   nko_ebird_trends,
  #   mpsgSE::get_ebird_trends(nko_list, output_path = ebird_dir,
  #                            ebird_access_key = ebird_key)
  # ),
  # tar_target(
  #   nko_ebird_regional_trends,
  #   mpsgSE::get_ebird_regional_stats(nko_list, ebird_access_key = ebird_key)
  # ),
  
  
  #### Build Trend Narratives ----
  ##### IMBCR ----
  # tar_target(
  #   nko_imbcr_trend_narratives,
  #   build_imbcr_trend_narratives(sd_proc_bndry)
  # ),
  
  ##### BBS ----
  # tar_target(
  #   nko_bbs_trend_narratives,
  #   build_bbs_trend_narratives()
  # ),
  
  
  ## Data Pull Report ----
  # tar_quarto_rep(
  #   name = rpt_data_pull_docx,
  #   path = "qmd/data_pull_report.qmd",
  #   execute_params = tibble::tibble(
  #     unit_short = unit_code,
  #     unit_full = unit_name,
  #     gbif_key = gbif_key,
  #     output_file = file.path(
  #       "qmd",
  #       paste(lubridate::year(Sys.Date()), unit_code, "SpeciesDataReport.docx",
  #             sep = "_")
  #     )
  #   )
  # ),
  # tar_quarto_rep(
  #   name = rpt_data_pull_html,
  #   path = "qmd/data_pull_report.qmd",
  #   execute_params = tibble::tibble(
  #     unit_short = unit_code,
  #     unit_full = unit_name,
  #     gbif_key = gbif_key,
  #     output_file = file.path(
  #       "qmd",
  #       paste(lubridate::year(Sys.Date()), unit_code, "SpeciesDataReport.html",
  #             sep = "_")
  #     )
  #   )
  # ),
  
  
  ## Evaluation Templates ----
  # tar_target(
  #   rpt_qmd_params,
  #   mpsgSE::build_quarto_params(nko_list, unit_name, states$name[1], crs = crs, 
  #                               file.path("output", "spp_evals"))
  # ),
  # tar_target(
  #   rpt_create_folders,
  #   mpsgSE::setup_directories(rpt_qmd_params)
  # ),
  # tar_target(
  #   rpt_auto_evals,
  #   # mpsgSE::write_evals(dplyr::sample_n(rpt_qmd_params, 5))
  #   mpsgSE::write_evals(rpt_qmd_params[rpt_qmd_params$taxon_id != 8727679, ])
  # ),
  # tar_target(
  #   rpt_release_reports,
  #   copy_reports(
  #     file.path("output/spp_evals"),
  #     file.path(scc_library, "Species Evaluations/automated_evaluation_templates")
  #   )
  # ),
  
  
  # End of pipeline.
  tar_target(
    the_end,
    message("Pipeline complete. The end.")
  )
)
