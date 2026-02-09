# Species Evaluation Automation Process

2024-12-05

# Introduction

This document details the data acquisition process and the production of
automated reports for the Mountain Planning Service Group’s (MPSG)
Species Evaluations for Species of Conservation Concern (SCC). The MPSG
assists National Forests and Grasslands, or planning units, with land
management plan revision. Part of the pre-assessment phase of the plan
revision process is writing species evaluation documents in preparation
for the SCC process. Species evaluations are intended to inform
selection of SCC by providing the best available scientific information
(BASI) on whether there is “substantial concern about the species’
capability to persist over the long-term in the plan area” (36 CFR
219.9(c)). This process is detailed in draft in the “Species of
Conservation Concern Identification Process” (TODO: CITE MPSG) document.
This document will focus on the data acquisition, or data pull, process
and the production of automated species evaluation documents, and is not
intended to outline the SCC process.

# Species Evaluation Automation Process

Automation is recommended for this process for two primary reasons: 1)
to maintain document content and format consistency, and 2) to reduce
workload. Hundreds of Species Evaluations are required for any given
planning unit. Automating repeatable steps produces consistent and
repeatable documents, and decreases the workload of MPSG staff.

Broadly there are three parts to automating: 1. Develop a list of
species eligible for SCC. 2. Gather BASI for each eligible species to
assess nativity and occurrence on the planing unit. 3. Automate species
evaluation documents for species that are native and known to occur on
the planning unit.

## Process Preface

### The Use of R Programming Language

MPSG staff uses the R programming language (R Core Team 2025) to
automate much of this work for repeatability and consistency across
planning units. However, automation is not necessarily dependent on R.
Many of these processes could be completed by other means. Coding
languages, like R, allow MPSG staff to increase efficiency by developing
code, or scripted tools, for repeated processes. R code and packages
will be referenced in this document to explain the work accomplished.

### Taxonomy

<!-- from data acquisition report

### Taxonomy {#sec-taxonomy}

The classification of living organisms changes frequently, as further specimens and newer techniques change our understanding of the relationships among species and even change our understanding of the boundaries between distinct taxa. The externally sourced data include verbatim scientific names of varying vintage and a matching of a species’ taxonomic concept to the GBIF Backbone Taxonomy (described below in section 3). Each taxonomic system reflected in the GBIF backbone has different policies for when to accept taxonomic revisions and may not include certain suites of taxa like insects, non-vascular plants, and microorganisms. A single scientific name might refer to completely different sets of organisms in the different systems used in the backbone or a group of organisms may have different scientific names applied in the different systems.

# Taxonomic Validation {#sec-taxa_validation}

Taxonomic names were validated against the GBIF Backbone Taxonomy (Global Biodiversity Information Facility Secretariat 2023) using the `rgbif` package (version `r packageVersion("rgbif")`; Chamberlain et al. 2023). The GBIF Backbone Taxonomy provides a method to resolve taxonomic conflicts between data sources. The GBIF Backbone Taxonomy is based on 105 taxonomic checklists including but not limited to the Catalogue of Life, Integrated Taxonomic Information System, and the International Barcode of Life project. The GBIF Backbone Taxonomy was used because it is a comprehensive taxonomic list with over four million accepted names and three million synonyms that offers flexible and repeatable tools to programmatically validate taxonomies. Every scientific taxon name from each dataset was validated with the GBIF Backbone Taxonomy and assigned a unique taxonomic identifier that allows the taxon to be joined to like taxa.

-->

This workflow would not be possible without first addressing taxonomic
classification of species names. This workflow relies on dozens of
external resources for information. Many of those resources have their
own methods for resolving taxonomy, but almost all of them differ on how
they define and classify species. This is problematic for automating
species evaluations because almost every part of the process relies on
reliably cross referencing information by species name. For example, for
occurrence records we rely on SEINet, GBIF, and state natural history
programs. It could be possible that for the grass blue grama (*Bouteloua
gracilis*) one source uses *Bouteloua gracilis* and another uses a
recognized synonym *Chondrosum gracile*. We need a way to recognize both
names as the same species. In other words to make use of both sources,
we needed a way to link the same species referred to by different names.
It is important that it could be done using an algorithm because some
data sets return hundreds of thousands of records for a planning unit.
Manual resolution of taxonomic classification is not possible with large
dataset like these, amplified by the scale that MPSG is assisting
planning units embark on plan revision.

A variety of resources were evaluated as potential solutions for
taxonomic classification. Ultimately, we decided to use the
[taxize](https://github.com/ropensci/taxize) R package
(**chamberlainTaxizeTaxonomicInformation2020?**) because is can accesses
the GBIF Backbone Taxonomy
(**gbifsecretariatGBIFBackboneTaxonomy2023?**) and is easy to use.
NatureServe, ITIS, and USDA plants were candidates for taxonomic
classification systems. ITIS was routinely down and would fail when
trying to resolve long lists of scientific names. NatureServe frequently
returned incorrect scientific names and required user input for
resolution of each species. USDA plants was also considered but there is
not an API for name resolution and is not usable in an automated system.
GBIF was chosen because it reliably returned the correct scientific name
without user input and could reliably be queried in a timely manner.

Often when a scientific name is searched in GBIF, the name that is
returned does not match the name in the NatureServe database. Forest
Service Land Management Planning Handbook, Chapter 10 - Assessments
((**usdaforestserviceForestServiceHandbook2015?**)) directs the use of
NatureServe in species consideration lists. Therefore, scientific names
provided by NatureServe are used for species evaluations. The taxonomic
process that was developed is agnostic to scientific names. It instead
relies on the a taxonomic identification number, or taxon ID, that is
tied to accepted scientific names and associated known synonyms. The
taxon ID is used to join the data when combining data sets, and not the
scientific names. This process allows us to efficiently use data sets
that use different scientific names for the same species.

While the system works well, it is not perfect, and occasionally many
scientific names recognized by NatureServe will resolve to the same
species in the GBIF Backbone Taxonomy. In this case manual resolution of
scientific names is necessary and species evaluations must be completed
manually. This is necessary because without matching taxon IDs we have
no way of telling if we are using the correct occurrence records or
federal and state rankings. It may be possible to resolve this in the
future with internal identification but for now these species much be
manually completed.

### The `mpsgSE` R package

MPSG staff have been developing the
[mpsgSE](https://github.com/fs-scoyoc/mpsgSE) R package
(**vanscoyocMpsgSEFunctionsCreating2026?**) that includes R code
functions that conduct steps in this workflow. This section describes
key functions in the `mpsgSE` R package.

#### Resolving Taxonomies

The process for resolving taxonomy is codified in a function called
[`get_taxonomies()`](https://github.com/fs-scoyoc/mpsgSE/blob/main/R/get_taxonomies.R).
This function takes a table or spatial occurrence data with species
names and classifies each species name returning a taxon ID and full
taxonomy added to the table that was originally provided to the
function. It takes one parameter which identifies the field with the
scientific name.

#### Pulling NatureServe State Data

The
[`get_ns_state_list()`](https://github.com/fs-scoyoc/mpsgSE/blob/main/R/get_ns_state_list.R)
function was developed for pulling state NatureServe data for a given
state. It uses the [natserve](https://github.com/cran/natserv)
(**chamberlainNatservNatureServeInterface2026?**) R package. This could
also be accomplished by querying the [NatureServe API
directly](https://explorer.natureserve.org/api-docs/?gad_source=1&gclid=CjwKCAiA34S7BhAtEiwACZzv4QJvuZl31unU2neO0rDSs3JlxTfPvisTwUBKEfuogoeqspagN02w0BoCPeAQAvD_BwE#_export).
It takes one input, which is the state short code (ex: “CO” for
Colorado) and returns the full list of track NatureServe species for
that state. This function then uses
[`get_taxonomies()`](https://github.com/fs-scoyoc/mpsgSE/blob/main/R/get_taxonomies.R)
to get the taxon ID for each species.

## Building the Eligible Species List

<!-- use pipeline to guide narrative -->

### Planning Unit Spatial Data

Spatial administrative boundary data (S_USA.AdministrativeForest) are
acquired from the Forest Service Enterprise Data Warehouse (EDW). Forest
or grassland administrative boundaries are filtered using a Definition
Query for that Forest Service unit in ArcGIS Pro
(**esriinc.ArcGISPro2025?**). The basic ownership data
(S_USA.BasicOwnership) are also acquired from the EDW and a Definition
Query is used to filter the data by Forest Service unit in ArcGIS Pro .
Forest Service ownership is then filtered using a Definition Query to
delineate the planning area. One-kilometer buffers are created around
the planning area boundary using the Buffer tool (Analysis Toolbox,
(**esriinc.ArcGISPro2025?**)) to capture occurrence records immediately
adjacent to the plan area. These data are used throughout the planning
process and are exported to a file geodatabase.

### Conservaiton Lists

In addition to global and state ranks provided by NatureServe, four
additional sources are needed to determine if any given species is
eligible for SCC evaluation:

-   State Ranks: State Threatened and Endangered, and State Wildlife
    Action Plan (SWAP) Tier 1 Lists
-   Regional Sensitive Species Lists
-   Neighboring Unit SCC lists
-   USFWS Status (see above in NatureServe)

#### NatureServe State List

The development of the eligible species list begins with pulling state
species lists from NatureServe. These data include global and state
conservation ranks and US Fish and Wildlife (USFWS) Endangered Species
Act (ESA) status. To do this, we begin by pulling all species for the
state where a unit resides. In most cases one state species list is
needed. But for units that overlap multiple states, each state list must
be pulled and then the lists are merged and duplicate species are
removed.

A data pull for any given state does note determine eligibility for a
unit list, instead it is the total number of species tracked by
NatureServe for any given state. To be considered an eligible species, a
species on a state list must also be found to occupy a given unit (i.e.,
determined to be native and known to occur) and meet other qualifying
criteria as outlined in Chapter 10 of the Forest Service Land Management
Handbook (USDA Forest Service 2015).

Data used to determine species eligibility from the NatureServe state
data pull include:

1.  Scientific Name,
2.  NatureServe Global Rank (G/T Rank),
3.  NatureServe State Rank (S/T Rank) for a given state, and
4.  USFWS ESA Status (Endangered, Threatened, Candidate, or Under
    Review)

#### State Wildlife Action Plans and Other State Rankings

States have a variety of wildlife and plant conservation lists for
imperiled species. These lists are typically developed by State Natural
Resource or Natural Heritage organizations. Conservation lists, most
commonly come in the form of State Wildlife Actions Plans, which make
states eligible for federal conservation funding, and Threatened,
Endangered and Sensitive Wildlife Lists. The MPSG interprets the that
from these conservation lists species with Tier 1 and Species of
Greatest Conservation Need (SGCN) rankings as well as Threatened and
Endangered rankings are eligible for SCC species evaluations. Some state
develop rankings that do not adhere to these ranking criteria and may
need to be evaluated on a case by case bases. South Dakota for example
has a three number ranking system (species were given 1,2 or 3 ranks).
The MPSG, based on the description of the ranking criteria, determined
that just those species ranked 1 would qualify for evaluations.

#### Regional Sensitive Species Lists

If a species is ranked as sensitive by the Regional Forester in the
region where the planning unit resides that species is considered
eligible for ranking if it is native and known to occur on the planning
unit. These lists are acquired from Forest Service websites
(i.e. [Region 2 Sensitive Species
List](https://www.fs.usda.gov/detail/r2/landmanagement/?cid=stelprdb5390116))

#### Neighboring Unit SCC Lists

If SCC are developed for a neighboring Forests, they should be
considered eligible for SCC if they are native and known on the unit.
Current SCC lists can be found here on the Forest Service planning
public site. Some region make them available grouped by region and
others are available at the Forest Level. A few examples:

-   Region 1 -
    <https://www.fs.usda.gov/detail/r1/landmanagement/planning/?cid=fseprd500402>
-   Region 2, GMUG NF-
    <https://www.fs.usda.gov/detail/carson/landmanagement/planning/?cid=stelprdb5443166>.
-   Region 4, Manti La Sal NF -
    <https://www.fs.usda.gov/main/mantilasal/landmanagement/planning>

#### USFWS Lists

The USFWS, rankings are retrieved from Nature Serve. Species that have
been delisted within the last 5 years or have had a positive 90 day
finding and are under review for listing are eligible.

#### Building the Master Conservation List

A master conservation list is constructed by combining all of the
conservaiton data we have described above. These steps are as follows.

1.  To the NatureServe State List, which already includes global, state
    and USFWS ranks, full_join (so that if species is not on one list it
    does not get dropped) by taxon ID:

-   State SWAP Lists
-   State T and E list
-   Regional Foresters Sensitive Species Lists
-   Neighboring Forest Service Unit’s SCC lists

1.  Then to create all potential species eligible filter the list by:

-   G/T 1,2 or 3 Ranks.
-   Any S/T 1 or 2 Ranks.
-   State SWAP Tier 1 Ranks
-   State T and E Ranks
-   Regional Foresters Sensitive Species Lists
-   Neighboring Forest Service Unit’s SCC lists

#### A Note About Tribal Species of Concern

The MPSG is still developing procedures to incorporate species
recognized by “federally recognized Tribes”. Those species will be
included in the future.

### Occurrence Data

As stated in the 2012 Planning Rule species must be native and known to
occur in the planning area. To determine if species are known to occur,
open source occurrence databases are queried for species occurrences
records on the planning unit. While occurrence records provide the first
line of evidence for known to occur we also rely on people who work on
the planning unit for additional information. The following datasets are
assigned a taxonomic ID using the
[`mpsgSE::get_taxonomies()`](https://github.com/fs-scoyoc/mpsgSE/blob/main/R/get_taxonomies.R)
function and summarized to the species, subspecies, or variety taxa
levels.

#### Global Biodiversity Information Facility

Global Biodiversity Information Facility (GBIF; Global Biodiversity
Information Facility 2022a) is a repository of externally sourced
species occurrence records from museum collections, academic studies,
and citizen science programs. GBIF records requests are staged on GBIF
servers and have to be downloaded (see [Getting Occurrence Data From
GBIF](https://docs.ropensci.org/rgbif/articles/getting_occurrence_data.html)
for details). An R script submits a records request using the 1-km
buffer around the planning area boundary to spatially query GBIF
records. The data are downloaded in [Darwin Core Archive
format](https://www.gbif.org/darwin-core) (GBIF, 2022b) for full data
provenance. The data are unzipped and read in to R once the request is
available using the `rgbif` package (version 3.7.8, Chamberlain et
al. 2023).

#### SEINet

[SEINet](https://swbiodiversity.org/seinet/index.php) is a data portal
that provides a suite of data access tools, including species occurrence
data from museums, collections, and state and federal agencies. SEINet
data are available through an online data portal and are downloaded
manually. A polygon box, or well-known text (WKT) footprint, is drawn
around the administrative boundary to query species observations using
the Taxonomic Criteria search page
(<https://swbiodiversity.org/seinet/collections/harvestparams.php>). The
query results are downloaded in Darwin Core Archive format, manually
unzipped, and a script reads them into R.

#### Integrated Monitoring in Bird Conservation Regions

The [Integrated Monitoring in Bird Conservation Regions
(IMBCR)](https://www.birdconservancy.org/what-we-do/science/monitoring/imbcr-program/)
is a long-term avian monitoring program coordinated by the [Birds
Conservancy of the Rockies](https://www.birdconservancy.org/), and
maintains monitoring plots on public lands throughout Forest Service
Regions 1-4. IMBCR data spanning 2008-2023 were obtained for Forest
Service lands on 12 December, 2023, for use in these analyses. These
data were received in and Excel file and an script reads them into R.

#### EO State Data (NHP Data)

State Natural Heritage Programs (NHPs) provide species occurrence data,
and habitat and distribution models for federal, state, and
non-governmental agencies throughout their state. Element occurrence
(EO) spatial data are requested from an HNP which are often provided in
a geodatabase. The EO data are read to R using an R script.

#### Forest Service Data

Wildlife, aquatic biota, rare plant, and invasive plant data from the
Forest EDW. These data were clipped to the 1-km buffer of the plan area
using ArcGIS Pro (version 3.3.1; Environmental Systems Research
Institute 2024) and a script reads them into R.

#### A Note on Limitations of Species Occurrence Data

<!-- from data acquisition report

### Occurrence Data {#sec-occurrence_data}

These are occurrence, or presence-only, data and can document the presence of species in an area of interest. Probable or possible presence is not quantified, and most importantly, these data cannot determine the absence or abundance of a species. Lack of species observations is not evidence of absence: a lack of observation may be because the species is rare in that area, or because no one ever looked for it there. Similarly, the number of occurrence records is not an indicator of abundance. For example, showy flowering plants or rare birds will trigger many more occurrence records relative to their abundance than “less interesting” or common species. Lastly, the source external species occurrence datasets often lack information on collection level of effort and on species absences which is essential for estimating abundance.

### Spatial Accuracy {#sec-spatial_accuracy}

Species occurrence locations are not validated and may include coordinate data of varying and undocumented precision or accuracy. The occurrence records from this data pull have geographic location coordinates in longitude and latitude and may include country and state codes and location descriptors. Each observation may include an estimate of the location uncertainty, which may range from a few meters to several kilometers or may be missing. Any use of the occurrence locations should consider the location uncertainty and/or precision noted for each observation. Recent observations may be generated using GPS technology, while coordinates in older observations may have been read from a map, and very old observations usually include only verbal descriptions of the observation location. Some of the verbal descriptions may be “geo-referenced” using current maps and historic location names. Also, some source datasets may have the location coordinates deliberately fuzzed to protect the location of sensitive species.

### Duplicate Records {#sec-duplicate_records}

Some museums and natural history institutions share their data with state heritage programs, GBIF, and SEINet; therefore, we can assume that some observations are duplicated. These analyses do not attempt to reduce duplicated records. Instead, these analyses assemble a comprehensive list of species known to occur on the forest or grassland. It is not appropriate to use these data to estimate populations (see section 2.6.1).

-->

#### Build Summary Occurrence Dataset

Once all occurrence records are retrieved, each dataset is summarized by
taxon ID with the following fields:

-   “nObs”: Total number of observations on Forest Service land.
-   “minYear”: Minimum year of observations on Forest Service land.
-   “maxYear”: Maximum year of observations on Forest Service land.
-   “occID”: A list of occurrence record identification codes if the
    total number of observations is less than or equal to six.

### Make Preliminary Eligible List

1.  Join all occurrence lists to all potential species eligible filtered
    list
2.  Filter by those species that have one occurrence record in the
    planning unit.

The result is a list of species with at least one occurrence record
inside the planning area the meats at least one qualifying criteria for
consideration as SCC. This list is preliminary because we recognize that
his process does not perfectly capture all species that should be
considered for SCC and that user input and manual vetting of the list
could lead to the addition or subtraction of species.

### Manually Check and Automated Checks: Accidental Transients, Native and Known, and Local Concern, to Produce Final SCC Eligible List

<!-- I think we should add into this process the Units local concern species -->
<!-- One thing I'm unclear on is if this step leads to shorter evaluations or no evaluation at all. -->

#### Transient Bird List

Per the 2012 planning rule only species that are native to a planning
area and not transients or accidental are required to be considered for
species evaluation for SCC consideration. As such species must be
checked to determine if they are indeed native and not occurring
accidentally or due to migration. For many groups of species we can
assume that if they are detected and if they have a state ranking or
some other ranking that they are likely not accidental nor transients on
the plan area. However for migratory birds, some verification should be
performed to remove birds that are accidental or transient, including
those with detection during migration.

Birds must overwinter or breed within a planning unit to not be
considered accidental or transient. To verify that species that are on
the initial species list winter or breed on the planning unit we use
species distribution modeling provided by the Cornell Lab of
Ornothology, through analysis of ebird data (Fink et al. 2023). Species
distribution models are provided through the
[ebirdst](https://doi.org/10.2173/ebirdst.2022) R package. Several
datasets are available, for our analysis we relied on the 27k resolution
“Smooth Range” (“range_smooth”) dataset. The dataset provides a variety
of polygon spatial layers for each species queried that contain a season
attribute that can be used to determine if the species should occur in
the planning unit during: breeding, non breeding, pre breeding
migration, and post breeding migration or if it occurs year round a
single layer representing the resident range. The layers useful to us
are those that are breeding, non breeding and resident.

To run the check, each of the native layers (breeding, non breeding or
resident) are clipped to the unit boundary. Each range is returned with
a TRUE for the range type for that species. So for example if a American
goshawks breeding range overlaps overlaps the planning unit goshawk is
returned with a true. If any of the non-transient ranges overlaps the
planning unit then the variable should_remain_eligible is returned as
TRUE. If non of the non-transient ranges overlaps the planning unit then
the variable is returned false. These automated checks can be manually
verified by an individual if necessary.

This product is stored and read into to inform the final eligible list.
Those species with non-transient ranges are kept while those with no
resident ranges are removed.

#### Filter those species that need native and known checks

For species with with occurrence records on the unit that could be
eligible it must be verified that they are native and known to occur on
the planning unit. For many species, there are dozens of records on the
planning unit. In these cases we assume that they are native an known to
occur on the planning unit (unless they are a bird species that migrates
over the area, for instance, and is removed in the previous step). For
species with very few occurrence records or with records that are very
old we manually check to verify that the occurrence records completely
occur on the unit or that that least one record is less than 40 years
old.

These checks are run manually. To provide specialists a list of
potential checks that need to be conducted we output a spreadsheet with
species that have less than 6 occurrence records on the unit or were
recorded more than 40 years ago.

Native and known determinations are made and recorded for each species
with the following categories with the options:

-   Is the Species Native and Known to Occur?
-   Yes
-   No, the species was introduced or is adventive to the plan area
-   No, there is insufficient taxonomic certainty to identify the
    observation data to a species
-   No, there is insufficient temporal certainty that the species still
    occupies the plan area
-   No, there is insufficient spatial certainty that the observation
    occurred within the plan area
-   No, the species is accidental or transient to the plan area
-   No, the observations represent an expanding species range or
    irruptive population that is not established in the plan area
-   No, the species is not in the plan area but is in the admin unit
    therfore is not included in the species overview spatial layer

The checker also writes notes on their determination under “*What is the
rationale and supporting BASI for recommending that an observation does
not meet the requirements of native to, and known to occur in the plan
area?*”. Species that are not not Native an Known will remain on the
list be will get short species evaluations that only include taxonomic
information, eligibility ranking information and a section noting that
they are not native and known and why.

#### Species with uncertain taxonomic determinations

Multiple species may be taxonomically identified as the same species
with `get_taxonomies()`. Because we cannot determine the taxonomic
status programatically, we cannot join them to occurrence lists or
status lists. Therefore they must be manually vetted. Additionally, for
those species with ambiguous taxonomy we cannot produce automated
evaluations.

An example of a species or group of species with ambiguous taxonomic
status is the eastern woodrat (*Neotoma floridana*). Natureserve
recognizes three subspecies of eastern woodrat: *Neotoma floridana
attwateri*, *Neotoma floridana baileyi*, and *Neotoma floridana
campestris*. Neither GBIF nor ITIS recognize any of these subspecies but
they both recognize the speices *Neotoma floridana*. Because we use the
scientific name, varieity or subspecies that NatureServe recognizes, we
must recognize all three of these subspecies. However, if we were to
link other qualifying lists and occurrence records with the taxon_id
provided by GBIF we would use the same ID for occurrence records of all
three subspecies and the species. Additionally, if we have no automated
way to link the species or subspecies together there is no way to build
an automated report as all steps are automated by referencing the
`taxon_id`.

#### Add in Species with Local Concern

Unit specialists may have species that they are locally concerned about.
Species with local concern are eligible for SCC evaluation if they are
native and known to occur on the unit. These species should be added to
the eligible list prior to running any further steps. As with every
other species species taxonomies should be acquired using the
get_taxonomies() function.

One unfortunate part of this step is that it requires that some steps
above be rerun. Species do not need any of the rankings above to be
considered for this step but all steps should be run to get the status
of each local concern species. These steps can rely on the same
functionality as those above, but they should be appended prior to
running any automated reporting steps.

#### Use user feedback to refine list

Based on manual checks remove species that are:

-   Determined to not be native and known to occur within the unit.
-   Determined to be accidental or transients on the unit

Add species that were identified as having local concern by the unit.

## Retrieve External Data for Automating Reports

### Get Synonyms

For each species we retrieve all recognized synonyms from GBIF for any
given taxon_id. We use the function `mpsgSO::get_synonyms()` to query
the GBIF Taxonomic Backbone for synonyms. The function takes a vector of
taxon_ids and returns a table with all synonmyms associated with each
taxon_id. The function relies on the function
`rbgif::name_usage(..., data="synonyms")`. This dataset is a stand alone
table.

### Get Data for Making Automated Maps

#### Subset Occurrence Spatial Data to Include on Unit and Eligible Species

Occurrence datasets are typically quite large. So that they can more
efficiently be loaded into automated reports it is helpful to take the
eligible list and subset it to just those species that are on the
eligible list and those records that occur on the unit. This step simply
filters any given list to those species on the eligible list and then
clips the occurrence records to the unit. At the moment it returns a
list of two objects, one with all eligible and one with all eligible on
the unit identified as `eligible` and `eligible_unit`.

#### Load Species Distribution Models

Species distribution models are needed to understand the context of a
species range to any given planning units location. We use a variety of
sources of species distribution models to get this information.

##### IUCN

The IUCN provides a variety of species distribution maps for a variety
of groups. These maps must be downloaded as shapefiles and then queried
for species by taxonomic group (i.e Mammals, Amphibians, Fish, etc). At
the moment we use IUCN for all Taxa groups except Birds and Plants. Of
all the data sources used for species distribution maps, this is the
least efficient source. At the moment, the steps for using these data
are:

-   download the data for each taxa group from the IUCN data website
    <https://www.iucnredlist.org/resources/spatial-data-download>
-   then get the taxonomies off all species in the shapefile with
    `mpsgSE::get_taxonomies()`.
-   filter the shapefile converted to a table by the species on the
    eligible lists comparing the taxon_id from each source. We complete
    this step because filtering a shapefile takes a lot longer (we may
    want to revise this step).
-   return a list of species with available maps from that data source.
-   if the source has at least one species on the eligible list we then
    subset the shapefile by those species.
-   For each taxa group we return a shapefile and then those shapefiles
    are combined.
-   BIEN Plant Maps
-   Ebird Maps

#### Get Other Base Map Information

-   State Boundaries
-   United States - lower 48
-   North America
-   The Americas (North and South America)
-   Get Open Street Map Highways (“highway”)
-   motorway
-   trunk
-   primary
-   Clean Unit Names

#### Get NatureServe Habitats From the NatureServe API and Manually Crosswalk to Ecology

#### Retrieve, Clean, and Build Narratives for IMBCR Trend Information

#### Retrieve, Clean, and Build Narratives for Breeding Bird Survey

## Automate Reports

<!-- Look at the qmd and write out each section. (Maybe should wait until we finish revamping the reports) -->

# References

Fink, D, T Auer, A Johnston, M Strimas-Mackey, S Ligocki, O Robinson, W
Hochachka, et al. 2023. “eBird Status and Trends.”
<https://doi.org/10.2173/ebirdst.2022>.

R Core Team. 2025. “R: A Language and Environment for Statistical
Computing.” <https://www.R-project.org/>.

USDA Forest Service. 2015. “Handbook 1909.12. Land Management Planning
Handbook. Chapter 10 - the Assessments.”
