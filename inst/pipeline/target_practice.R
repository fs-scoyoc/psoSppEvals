#' This is a scratch pad for working with your pipeline.


# Install packages ----
# Install requisite packages not on CRAN
install.packages("arcgisbinding", repos="https://r.esri.com", type="win.binary")
remotes::install_github("fs-scoyoc/psoGIStools")

# Install psoSppEvals
remotes::install_github("fs-scoyoc/psoSppEvals")


# Run targets ----
# Run all targets
targets::tar_make()

# Run spatial data (sd) targets
targets::tar_make(names = dplyr::starts_with("sd"))

# Run conservation list (cl) targets
targets::tar_make(names = dplyr::starts_with("cl"))

# Run occurrence data (od) targets
targets::tar_make(names = dplyr::starts_with("occ"))

# Run eligible species (elig) targets
targets::tar_make(names = dplyr::starts_with("elig"))
# targets::tar_make(names = dplyr::starts_with("write_elig"))

# Run Native & Known to Occur (nko) targets
targets::tar_make(names = dplyr::starts_with("nko"))
targets::tar_make(names = !dplyr::starts_with("write_nko"))

# Run report (rpt) targets
targets::tar_make(names = dplyr::starts_with("rpt"))


# Work with pipeline ----
#-- Inspect pipeline
targets::tar_meta()  # View metadata
targets::tar_manifest() |> dplyr::arrange(name)  # Inspect the pipeline
targets::tar_outdated()  # View outdated targets
targets::tar_sitrep()  # Status of each target
targets::tar_validate()  # Validate pipeline

#-- Visualize pipeline
targets::tar_glimpse()  # Visualize dependencies
targets::tar_network()  # Visualize the vertices and edges of dependencies
targets::tar_visnetwork()  # Visualize the pipeline

#-- Clean pipeline
targets::tar_prune_list() |> sort()  # List targets to prune
# targets::tar_prune()  # Prune unused targets
# targets::tar_delete(c(rpt_data_pull_docx, rpt_data_pull_html))  # Delete targets
# targets::tar_destroy()  # Delete all targets


# Load data from pipeline
targets::tar_load(cl_master_status_list)
targets::tar_read(nko_map_source) |> dplyr::pull(map_source) |> sort()









