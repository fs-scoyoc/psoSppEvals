#' This function builds a single narrative from narratives by strata from IMBCR.
#' 
#' The comments noted with **TODO** are sections that will need updated for 
#'     your project.
#' 
#' @param target_aoa Spatial polygon (`sf` object) for your area of analysis. 
#' @param tar_unit_name Unit name. Default is `unit_name` from this pipeline.
#' @param tar_unit_code Unit acronym. Default is `unit_code` from this pipeline.

build_imbcr_trend_narratives <- function(target_aoa, tar_unit_name = unit_name, 
                                         tar_unit_code = unit_code){
  
  # Load these parameters to troubleshoot/modify this function
  # target_aoa = targets::tar_read(sd_proc_bndry)
  # tar_unit_name <- "Dixie National Forest" # Full name
  # tar_unit_code <- "DIF" # Unit acronym

  citation = "(Reese et al. 2024 via USDA Forest Service 2026)"
  imbcr_dir <- file.path("T:/FS/NFS/PSO/MPSG/MPSG_Restricted/Species/IMBCR")
  
  # TODO: Un-comment code below to see available IMBCR strata  
  # readRDS(file = file.path(imbcr_dir, "imbcr_trends.RDS")) |> 
  #   dplyr::pull(stratum) |> unique() |> sort()
  bcrs = psoSppEvals::get_bc_regions(target_aoa) |>  
    dplyr::pull(bcr_label_name) |> 
    unique() |> 
    # TODO: Add relevant IMBCR strata below
    c("USFS-Region 4 National Forests", tar_unit_name, "UT", "UT-BCR16", 
      "UT-BCR9")
  
  imbcr_trends = readRDS(file = file.path(imbcr_dir, "imbcr_trends.RDS")) |> 
    dplyr::filter(stratum %in% bcrs) # |>
    # dplyr::filter(!dplyr::if_any(dplyr::any_of(stats_vars), is.na))
  
  trend_narratives = imbcr_trends |>
    dplyr::mutate(
      start_year = stringr::str_extract(years, "^[0-9]{4}") |> as.numeric(),
      end_year = stringr::str_extract(years, "[0-9]{4}$") |> as.numeric(),
      no_of_years = end_year - start_year + 1
    ) |>
    dplyr::filter(no_of_years > 5) |>
    dplyr::rowwise() |>
    dplyr::mutate(
      stratum_code = dplyr::case_when(
        # TODO: Revise stratum names
        stratum == "USFS-Region 4 National Forests" ~ "R4",
        stratum == "UT" ~ "UT",
        stratum == "UT-BCR16" ~ "BCR16",
        stratum == "UT-BCR9" ~ "BCR09",
        stratum == tar_unit_name ~ tar_unit_code,
        TRUE ~ stratum
      ),
      stratum_name = dplyr::case_when(
        # TODO: Revise stratum names
        stratum == "USFS-Region 4 National Forests" ~ "USFS Region 4 National Forests",
        stratum == "UT" ~ "Utah",
        stratum == "UT-BCR16" ~ "Southern Rockies/Colorado Plateau (Utah)",
        stratum == "UT-BCR9" ~ "Great Basin (Utah)",
        stratum == tar_unit_name ~ tar_unit_name,
        TRUE ~ stratum
      ),
      order = dplyr::case_when(
        stringr::str_detect(stratum_code, "UT") ~ 3,
        stringr::str_detect(stratum_code, "BCR[0-9]{2}") ~ 1,
        stringr::str_detect(stratum_code, "R4") ~ 2,
        stringr::str_detect(stratum_code, tar_unit_code) ~ 4,
        TRUE ~ 5
        ),
      d_t = round(as.numeric(percent_change_yr_density), 2),
      d_t = ifelse(d_t <= -5 & f_density_trend >= 0.9, glue::glue("**{d_t}**"), as.character(d_t)),
      lcl95_d = round(lcl95_d, 2),
      ucl95_d = round(ucl95_d, 2),
      d_n_p = dplyr::case_when(
        d_t > 0 & as.numeric(f_density_trend) >= 0.9 ~ "estimated an increasing",
        d_t < 0 & as.numeric(f_density_trend) >= 0.9 ~ "estimated a decreasing",
        TRUE ~ "estimated an uncertain"
        ),
      o_t = round(as.numeric(percent_change_yr_occupancy), 2),
      o_t = ifelse(o_t <= -5 & f_occupancy_trend >= 0.9, glue::glue("**{o_t}**"), as.character(o_t)),
      lcl95_occ = round(lcl95_occ, 2),
      ucl95_occ = round(ucl95_occ, 2),
      o_t_p = dplyr::case_when(
        o_t > 0 & as.numeric(f_occupancy_trend) >= 0.9 ~ "estimated an increasing",
        o_t < 0 & as.numeric(f_occupancy_trend) >= 0.9 ~ "estimated a decreasing",
        TRUE ~ "estimated an uncertain"
        ),
      narrative_single = glue::glue("{stratum_name} ({stratum_code}) {d_n_p} median density population trend of {d_t}% [95% CL {lcl95_d}%, {ucl95_d}%, (n={scales::label_comma()(no_of_detections)}, f={round(as.numeric(f_density_trend), 3)})] per year and {o_t_p} median occupancy trend of {o_t}% [95% CL {lcl95_occ}%, {ucl95_occ}%, (n={scales::label_comma()(no_of_points)}, f={round(as.numeric(f_occupancy_trend), 3) })] per year from {stringr::str_replace(years,'-', ' to ')}")
    )
  
  
  unit_narratives <- trend_narratives |>
    dplyr::arrange(desc(order), stratum_name) |>
    dplyr::group_by(taxon_id, common_name) |>
    dplyr::summarize(narrative = paste(narrative_single, collapse = "; "), 
                     n = dplyr::n(), 
                     .groups = 'drop') |>
    dplyr::ungroup() |>
    dplyr::mutate(narrative = ifelse(n > 0,
      glue::glue("Surveys were conducted by the Bird Conservancy of the Rockies on the {tar_unit_name}. Analysis of survey results produces a trend estimate that represents the per year percent change in population for a given stratum. Estimates are considered robust if the F-statistic is greater than or equal to 0.9 and uncertain if the F-statistic is less than 0.9. Surveys reported the following trends by strata for {common_name}: {narrative} {citation}."),
      "There are no trend results available."
    ))

  additional_narratives <- trend_narratives |>
    dplyr::arrange(desc(order), stratum_name) |>
    dplyr::group_by(taxon_id) |>
    dplyr::summarize(narrative = paste(narrative_single, collapse = "; "), n = dplyr::n()) |>
    dplyr::ungroup()

  return(tibble::lst(unit_narratives, additional_narratives))
}
