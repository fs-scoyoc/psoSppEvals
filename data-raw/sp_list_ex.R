## code to prepare `sp_list_ex` dataset goes here
library(tidyverse)
library(readr)

sp_list_ex <- readr::read_csv(file.path("data-raw/data", "spp_list.csv"),
                              show_col_types = FALSE) |>
  dplyr::bind_rows(
    tibble::tibble(
      common_name = c("Western Toad", "Northern Leopard Frog", "Mountain Plover",
                      "Snowy Plover", "American Goshawk", "Ferruginous Hawk",
                      "Hopi Chipmunk", "Canada Lynx", "American Pika",
                      "Largemouth Bass", "Westslope Cutthroat Trout",
                      "Vargo's Furcula", "Western Bumblebee", "Monarch"),
      scientific_name = c("Anaxyrus boreas", "Lithobates pipiens",
                          "Anarhynchus montanus", "Anarhynchus nivosus",
                          "Accipiter atricapillus", "Buteo regalis",
                          "Neotamias rufus", "Lynx canadensis", 
                          "Ochotona princeps", "Micropterus nigricans", 
                          "Oncorhynchus lewisi", "Furcula vargoi", 
                          "Bombus occidentalis", "Danaus plexippus")
      )
    )
usethis::use_data(sp_list_ex, overwrite = TRUE)
