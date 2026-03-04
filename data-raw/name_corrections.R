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


# Name Corrections ----
# This data frame has common name, scientific names that do not return taxon 
#     ID's, and corrected names for the same species that will return taxon ID's 
name_corrections = tibble::tibble(
  # Common names
  common_name = c(
    "Mountain Plover", "Snowy Plover", "Snowy Plover", "American Goshawk", 
    "Hopi Chipmunk", "Largemouth Bass", "Westslope Cutthroat Trout", 
    "Vargo's Furcula", "a lepidostomatid caddisfly", "Lapland Buttercup",
    "Rough Rattlesnake-root", "Open-ground Whitlow-grass", "Diana Fritillary", 
    "an angle moth", "Pin Lichen", "Lindberg's Plait Moss", 
    "Tufted Evening-primrose", "Nuttals's Sandwart", "Glaucous Rattlesnakeroot",
    "Tall Fescue", "Colorado River Cutthroat Trout", 
    "Bonneville Cutthroat Trout", "Trinity Lewisia"
    ),
  # Names throwing taxon ID errors
  errored_name = c(
    "Anarhynchus montanus", "Anarhynchus nivosus", "Anarhynchus nivosus nivosus", 
    "Accipiter atricapillus", "Neotamias rufus", "Micropterus nigricans",
    "Oncorhynchus lewisi", "Furcula vargoi", "Lepidostoma apache", 
    "Ranunculus lapponicus", "Prenanthes aspera", "Draba aprica", 
    "Argynnis diana", "Macaria prunosata", "Calicium tigillare", 
    "Hypnum lindbergii", "Oenothera caespitosa", "Minuartia nuttallii", 
    "Prenanthes racemose", "Schedonorus arundinaceus", 
    "Oncorhynchus virginalis pleuriticus", "Oncorhynchus virginalis utah", 
    "Lewisia taylorii"
    ), 
  # Corrected scientific names
  corrected_name = c(
    "Charadrius montanus", "Charadrius nivosus", "Charadrius nivosus", 
    "Accipiter gentilis atricapillus", "Tamias rufus", "Micropterus floridanus",
    "Oncorhynchus clarkii lewisi", "Furcula vargoi", "Lepidostoma apache", 
    "Coptidium lapponicum", "Nabalus asper", "Abdra aprica", "Speyeria diana",
    "Speranza prunosata", "Calicium tigillare", "Calliergonella lindbergii", 
    "Oenothera cespitosa", "Sabulina nuttallii", "Nabalus racemosus", 
    "Lolium arundinaceum", "Oncorhynchus clarkii pleuriticus", 
    "Oncorhynchus clarkii utah", "Lewisia taylorii"
    )
  ) |> 
  # Pull taxon IDs from GBIF
  mpsgSE::get_taxonomies("corrected_name") |> 
  dplyr::mutate(
    # taxon_id = taxize::get_gbifid(corrected_name, ask = FALSE, rows = 1, 
    #                               messages = FALSE),
    # manual corrections
    taxon_id = ifelse(errored_name == "Furcula vargoi", 10047243, taxon_id),
    taxon_id = ifelse(errored_name == "Lepidostoma apache", 125954696, taxon_id),
    taxon_id = ifelse(errored_name == "Calicium tigillare", 7682261, taxon_id),
    taxon_id = ifelse(errored_name == "Lewisia taylorii", 295883556, taxon_id),
    taxon_id = as.numeric(taxon_id)
  ) |> 
  dplyr::arrange(kingdom, phylum, class, order, family, genus, species, corrected_name)


# manual corrections ----
# This is a data frame of species that won't query in GBIF, but taxon IDs were 
#     found manually on the GBIF website.
manual_corrections <- tibble::tibble(
  # Common names
  common_name = c(
    "Vargo's Furcula", "a lepidostomatid caddisfly", "pin lichen", 
    "Trinity Lewisia"
    ),
  # Names throwing taxon ID errors
  scientific_name = c(
    "Furcula vargoi", "Lepidostoma apache", "Calicium tigillare", 
    "Lewisia taylorii"), 
  # Taxon ID's
  taxon_id = c(10047243, 125954696, 7682261, 295883556)
  )


# save ----
usethis::use_data(name_corrections, overwrite = TRUE)
usethis::use_data(manual_corrections, overwrite = TRUE)
