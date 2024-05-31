# load the function libraries
library(targets)
library(tidyverse)
library(tarchetypes)
library(DT)

# source the custom functions for the pipeline
source("code/R/functions.R")
tar_option_set(
  packages = c(
    "tidyverse",
    "stringr"
  )

)
# Here we string together the pipeline in a list
list(
  # set the year we are working with
  tar_target(cYear, 2022),
  
  # set the file names to watch for changes 
  # point_frame_`cYear`.csv is a dynamic target and will be updated when the cYear is
  # changed in annual updates
  
  # vwr max lookup table
  tar_target(vwrmax_file, "data/vwr_max_lookup.csv", format = "file"),
  
  # site soil conditions influencing water holding capacity
  tar_target(sitesoil_file, "data/vwr_site_soil_designation.csv", format = "file"),
  
  # updated with cYear (current year) parameter and dictaates which year is calculated.
  tar_target(pointframe_file, paste0("data/point_frame_",cYear,".csv"), format = "file"),

  # read the data from files specified above
  # if the file has changed since the last tar_make(), read in the updated file
  tar_target(vwrmax_lookt, read.csv(vwrmax_file)),
  tar_target(sitesoil, read.csv(sitesoil_file)),
  tar_target(pointframe_wide, read.csv(pointframe_file)),

  # wrangling - tidy point frame data
  tar_target(pointframe_long, gather(pointframe_wide, species, all.hits, SPAI:OTHER)),
  
  # calculate LAI from species cover rows - greenbook formula .5 extinction coefficient
  tar_target(pointframe_lai, mutate(pointframe_long, lai = all.hits/334 * 2)),

  # Join columns, site soil, lai, vwr max lookup values
  tar_target(lai_ss, left_join(sitesoil,pointframe_lai, by = "site")),
  tar_target(lai_ss_vwrmax,left_join(lai_ss,vwrmax_lookt, by = c('soil','species'))),

  # calculate vwr of six primary species
  tar_target(vwr, mutate(lai_ss_vwrmax,vwr = lai*vwr_at_lai_max)),
  
  # calculate weighted average of six species VWR/LAI for each site
  tar_target(weighted.avg, weighted_avg(vwr)),

  # joins the weighted average and calcs vwr for other category
  # creates new column containing both vwr for each species and the other column
  # creates new site column as factor with levels corresponding north to south 
  # following VWR excel table.
  tar_target(vwr.total,vwr_total(vwr,weighted.avg)),

  # view wider with period (july, oct) as columns following VWR excel table.
  tar_target(vwr.wide.period, vwr_site_total_period(vwr.total, cYear))
  )



