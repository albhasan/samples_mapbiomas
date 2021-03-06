# Split the samples into CSV files before retrieving the time series.
library(dplyr)
library(ensurer)
library(ggplot2)
library(sf)
library(stringr)



#---- Setup ----

# NOTE: First Landat BDC is 2016-08
# NOTE: Last MapBiomas sample is from 2018
sample_years <- 2017:2018

samples_file  <- "./data/samples/mapbiomas_pts_coordsok.shp"
stopifnot(file.exists(samples_file))

bdc_grid_file <- "./data/bdc_grid/BDC_MD.shp"
stopifnot(file.exists(bdc_grid_file))

source("./scripts/00_util.R")



#---- Script ----

# The BDC grid will be used to group the sample points.
grid_sf <- bdc_grid_file %>%
    sf::read_sf() %>%
    dplyr::select(tile_id = id) %>%
    sf::st_transform(crs = 4326) 

# Read samples
samples_sf <- samples_file %>%
    sf::read_sf()

# Process the samples.
samples_tb <- samples_sf %>%
    sf::st_transform(crs = 4326) %>%
    sf::st_join(y = grid_sf,
                join = sf::st_intersects) %>%  
    add_coords() %>%
    sf::st_set_geometry(NULL) %>%
    dplyr::select(longitude, latitude, tile_id, 
                  tidyselect::starts_with("CLASS")) %>%
    tidyr::pivot_longer(cols = tidyselect::starts_with("CLASS"),
                        names_to = "label_year",
                        values_to = "label") %>%
    dplyr::mutate(year = as.integer(stringr::str_sub(label_year, 7, 10))) %>%
    ensurer::ensure_that(all(.$year >= 1985), 
                         all(.$year <= 2022),
                         err_desc = "Invalid years found!") %>%
    dplyr::filter(year %in% sample_years) %>%
    dplyr::mutate(start_date = stringr::str_c(year, "-01-01"),
                  end_date   = stringr::str_c(year, "-12-31"),
                  cube = "",
                  time_series = "") %>%
    dplyr::select(longitude, latitude, start_date, end_date, 
                  label, cube, time_series, tile_id)

# Split data by tile and year.
group_ls <- samples_tb %>%
    dplyr::group_by(tile_id, start_date) %>%
    dplyr::group_split()

# Write CSVs.
out_dir <- "./data/samples/csv"
for (data_tb in group_ls) {
    file_tile <- unique(data_tb$tile_id)
    file_start <- unique(data_tb$start_date)
    file_end <- unique(data_tb$end_date)
    lon_interval <- seq(from = range(data_tb$longitude)[1], 
                        to   = range(data_tb$longitude)[2],
                        length.out = 20)
    batch_ls <- data_tb %>%
        dplyr::mutate(batch = findInterval(longitude, vec = lon_interval)) %>%
        dplyr::group_by(batch) %>%
        dplyr::group_split()
    for (batch_tb in batch_ls) {
        if (nrow(batch_tb) == 0)
            next()
        file_batch <- unique(batch_tb$batch)
        out_dir_year <- paste0(out_dir, "/", 
                               stringr::str_sub(unique(batch_tb$start_date), 
                                                1, 4))
        if (!dir.exists(out_dir_year))
            dir.create(out_dir_year)
        batch_tb %>%
            dplyr::select(-tile_id, -batch) %>%
            dplyr::arrange(longitude, desc(latitude)) %>%
            readr::write_csv(file = file.path(out_dir_year, 
                                              paste0(
                                                  paste("mapbiomas",
                                                        file_tile, 
                                                        file_start, 
                                                        file_end,
                                                        file_batch,
                                                        sep = "_"),
                                                  ".csv")))
    }
}
