
#' calculate weighted average vwr per lai 
#' for the non-focal species without T rates
#'
#' @param vwr
#'
#' @return weighted average vwr per leaf area index dataframe
#' @export
#'
#' @examples
weighted_avg <- function(vwr){
  vwr %>% filter(species != 'OTHER') %>% filter(all.hits >0) %>%
    group_by(site,period) %>%
    summarise(w_avg_vwr_per_lai = sum(vwr)/sum(lai)) %>%
    mutate(species = 'OTHER')
}

#' join vwr and weighted avg vwr for 'other species' total and total the two for a 
#'
#' @param vwr
#' @param weighted.avg.
#'
#' @return vwr totals in dataframe
#' @export
#'
#' @examples
vwr_total <- function(vwr, weighted.avg.){
  vwr %>% left_join(weighted.avg., by = c('site', 'species', 'period')) %>%
    mutate(other.vwr = w_avg_vwr_per_lai * lai,
           total.vwr = case_when(!is.na(vwr)~vwr,
                                 !is.na(other.vwr)~other.vwr),
           site.f = factor(site, levels = c("LW1",
                                            "LW2",
                                            "LW3",
                                            "BC1",
                                            "BC2",
                                            "BC3",
                                            "BP1",
                                            "BP2",
                                            "BP3",
                                            "BP4",
                                            "TA3",
                                            "TA4",
                                            "TA5",
                                            "TA6",
                                            "TAC",
                                            "TS1",
                                            "TS2",
                                            "TS3",
                                            "TS4",
                                            "TSC",
                                            "IO1",
                                            "IO2",
                                            "IC1",
                                            "IC2",
                                            "SS1",
                                            "SS2",
                                            "SS3",
                                            "SS4",
                                            "BG2",
                                            "BGC")
                           )
    )

}


#' total VWR from species to site level
#' and for each period
#' @param vwr.total
#' @param cYear
#'
#' @returnwide wide data frame with period as columns and VWR by site rows
#' @export
#'
#' @examples
vwr_site_total_period <- function(vwr.total,cYear){
  vwr.total %>% filter(all.hits > 0) %>%
  select(site.f,period,species,lai,total.vwr) %>%
  group_by(site.f,period) %>%
  summarise(site.vwr = sum(total.vwr)) %>%
  pivot_wider(names_from = period, values_from = site.vwr)
}
