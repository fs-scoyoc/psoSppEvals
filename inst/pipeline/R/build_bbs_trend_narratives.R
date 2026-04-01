#' This builds the USGS Breeding Bird Survey (BBS) narratives for bird species. 
#'     The USGS breeding bird survey data can be found here:
#'     https://www.sciencebase.gov/catalog/item/67aba702d34e329fb20457b1
#'
#' @param region_codes Vector of BBS region codes.
#' @param region_names Vector of BBS region names.

build_bbs_trend_narratives <- function(){

  # Look at the BCR metadata to get region codes and names
  # Look at definitions under `<attrlabl>Region</attrlabl>`
  
  bcrs = tibble::tibble(region = c("UT", "S09", "S16", "US1"),
                        region_names = c("Utah", "Great Basin",
                                         "Southern Rockies/Colorado Plateau",
                                         "the United States"))
  
  bbs_narratives = mpsgSEdata::core_trend |> 
    dplyr::filter(region %in% bcrs$region) |>
    dplyr::left_join(bcrs, by = "region") |>
    dplyr::mutate(
      trend_description = dplyr::case_when(significance == 1 ~ "increasing",
                                           significance == 2 ~ "decreasing",
                                           is.na(significance) ~ "uncertain"),
      narrative_chunk = glue::glue(
        "in {region_names} the trend is {trend_description} with a trend of {trend}% [95% CI {x2_5_percent_ci}%, {x97_5_percent_ci}%]"
        )
    ) |> 
    dplyr::group_by(taxon_id, species) |>
    dplyr::summarize(
      narrative_total_chunk = paste(narrative_chunk, collapse = "; "),
      n = dplyr::n(), 
      .groups = 'drop'
    ) |>
    dplyr::mutate(
      citation = "(Hostelter et al. 2025 via USDA Forest Service 2025)",
      narrative_total_chunk = ifelse(
        n == 2, 
        stringr::str_replace(narrative_total_chunk, ";", " and"),
        stringr::str_replace(narrative_total_chunk, ";(?=[^;]*$)", ", and")
        ),
      narrative_total_chunk = stringr::str_replace(narrative_total_chunk, 
                                                   "i", "I"),
      narrative_total_chunk = stringr::str_replace_all(narrative_total_chunk, 
                                                       ";", ","),
      final_narrative = glue::glue(
        "The USGS estimates population trend with data from the North American Breeding Bird Survey collected from 1966 to 2022. {narrative_total_chunk} {citation}."
        )
    )
  
  return(bbs_narratives)
}
