## code to prepare `sp_list_ex` dataset goes here
library(tidyverse)
library(readxl)

data_raw <- read_excel("C:\\Users\\MichaelSchmidt2\\USDA\\Mountain Planning Service Group - SCC Library\\Cimarron Comanche NG\\Species List\\CURRENT 20240605_CCNG_SpeciesList.xlsx")


sp_list_ex <- data_raw |>
  select(common_name, scientific_name) |>
  bind_rows(
    tibble(
      common_name = c("Western Toad", "Northern Leopard Frog", "Mountain Plover",
                      "Snowy Plover", "American Goshawk", "Ferruginous Hawk",
                      "Hopi Chipmunk", "Canada Lynx", "American Pika",
                      "Largemouth Bass", "Westslope Cutthroat Trout",
                      "Vargo's Furcula", "Western Bumblebee", "Monarch"),
      scientific_name = c("Anaxyrus boreas", "Lithobates pipiens",
                          "Anarhynchus montanus", "Anarhynchus nivosus",
                          "Accipiter atricapillus", "Buteo regalis",
                          "Neotamias rufus", "Lynx canadensis", "Ochotona princeps",
                          "Micropterus nigricans", "Oncorhynchus lewisi",
                          "Furcula vargoi", "Bombus occidentalis",
                          "Danaus plexippus")
    )
  )
usethis::use_data(sp_list_ex, overwrite = TRUE)
