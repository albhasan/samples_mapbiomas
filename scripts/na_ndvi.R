library(dplyr)
library(sits)

source("~/Documents/bdc_access_key.R")

csv_file <- tempfile(pattern = "samples_", fileext = ".csv")

samples_tb <- tibble::tribble(
    ~longitude, ~latitude, ~start_date, ~end_date, ~label, ~cube,
    -57.84777, -17.47933, "2018-01-01", "2018-12-31", "test", "my_cube", 
    -57.82917, -17.46639, "2018-01-01", "2018-12-31", "test", "my_cube", 
    -57.75291, -17.51625, "2018-01-01", "2018-12-31", "test", "my_cube", 
    -53.59434, -20.65694, "2018-01-01", "2018-12-31", "test", "my_cube"    
)

samples_tb %>%
    readr::write_csv(file = csv_file)

lc8_cube <- sits_cube(type        = "BDC",
                      url         = "http://datacube-005.dpi.inpe.br:8010/stac/",
                      name        = "cerrado",
                      bands       = c("BAND1", "BAND2", "BAND3", "BAND4",
                                      "BAND5", "BAND6", "BAND7", "EVI",
                                      "NDVI", "FMASK4"),
                      collection  = "LC8_30_16D_STK-1",
                      start_date  = "2018-01-01",
                      end_date    = "2018-12-31")

samples <- sits::sits_get_data(cube = lc8_cube, 
                               file = csv_file)

samples
samples$time_series[[1]]$NDVI
samples$time_series[[2]]$NDVI
samples$time_series[[3]]$NDVI
samples$time_series[[4]]$NDVI