.libPaths("/home/alber-d005/R/x86_64-pc-linux-gnu-library/4.0")
#Sys.setenv("SITS_USER_CONFIG_FILE" = "/home/alber-d005/Documents/samples_mapbiomas/config.yml")

library(dplyr)
library(rstac)
library(sits)
library(snow)

source("/home/alber-d005/Documents/bdc_access_key.R")
source("/home/alber-d005/Documents/samples_mapbiomas/scripts/00_util.R")

csv_dir  <- "/home/alber-d005/Documents/samples_mapbiomas/data/samples/csv"
out_file <- "/home/alber-d005/Documents/samples_mapbiomas/data/samples.rds"

stopifnot(dir.exists(csv_dir))

lc8_cube <- sits_cube(type        = "BDC",
                      url         = "http://datacube-005.dpi.inpe.br:8010/stac/",
                      name        = "cerrado",
                      bands       = c("BAND1", "BAND2", "BAND3", "BAND4",
                                      "BAND5", "BAND6", "BAND7", "EVI",
                                      "NDVI", "FMASK4"),
                      collection  = "LC8_30_16D_STK-1",
                      start_date  = "2018-01-01",
                      end_date    = "2018-12-31")

samples <- do_get_ts(in_dir = csv_dir, 
                     out_file = out_file,
                     cube = lc8_cube, 
                     multicores = 40)



# Error in mis_val[b] <<- as.numeric(sits_env$config[[sensor]][["missing_value"]][[b]]) : 
#     replacement has length zero
# 
# 11.
# 
# .f(.x[[i]], ...)
# 
# 10.
# 
# purrr::map(., function(b) {
#     mis_val[b] <<- as.numeric(sits_env$config[[sensor]][["missing_value"]][[b]])
# })
# 
# 9.
# 
# bands %>% purrr::map(function(b) {
#     mis_val[b] <<- as.numeric(sits_env$config[[sensor]][["missing_value"]][[b]])
# }) at
# sits_config.R#512
# 8.
# 
# .sits_config_missing_values(cube$sensor, bands) at
# sits_raster_data.R#283
# 7.
# 
# .sits_raster_data_get_ts(cube = tile, points = csv, bands = bands, 
#                          cld_band = cld_band, impute_fn = impute_fn) at
# sits_get_data.R#362
# 6.
# 
# .f(.x, ...)
# 
# 5.
# 
# slide_common(x = .x, f_call = f_call, ptype = .ptype, env = environment(), 
#              params = params)
# 
# 4.
# 
# slide_impl(.x, .f, ..., .before = .before, .after = .after, .step = .step, 
#            .complete = .complete, .ptype = list(), .constrain = FALSE, 
#            .atomic = FALSE)
# 
# 3.
# 
# slider::slide(cube, function(tile) {
#     ts <- .sits_raster_data_get_ts(cube = tile, points = csv, 
#                                    bands = bands, cld_band = cld_band, impute_fn = impute_fn)
#     return(ts) ... at
#     sits_get_data.R#360
#     2.
#     
#     sits_get_data.csv_raster_cube(cube = cube, file = file) at
#     sits_get_data.R#116
#     1.
#     
#     sits::sits_get_data(cube = cube, file = file)
#     