.libPaths("/home/alber-d005/R/x86_64-pc-linux-gnu-library/4.0")
#Sys.setenv("SITS_USER_CONFIG_FILE" = "/home/alber-d005/Documents/samples_mapbiomas/config.yml")

library(dplyr)
library(rstac)
library(sits)
library(snow)

source("/home/alber-d005/Documents/bdc_access_key.R")
source("/home/alber-d005/Documents/samples_mapbiomas/scripts/00_util.R")

csv_dir  <- "/home/alber-d005/Documents/samples_mapbiomas/data/samples/csv"
out_file <- "/home/alber-d005/Documents/samples_mapbiomas/data/samples/samples"

stopifnot(dir.exists(csv_dir))

for (my_year in 2017:2018) {
    print(sprintf("%s Staring year: %s", Sys.time(), my_year))
    my_out_file <- paste0(out_file, "_", my_year, ".rds")
    if (file.exists(my_out_file)) {
        warning(sprintf("Year %s was already processed. Skipping...", my_year))
        next()
    }
    lc8_cube <- sits_cube(type        = "BDC",
                          url         = "http://datacube-005.dpi.inpe.br:8010/stac/",
                          name        = "cerrado",
                          bands       = c("BAND1", "BAND2", "BAND3", "BAND4",
                                          "BAND5", "BAND6", "BAND7", "EVI",
                                          "NDVI", "FMASK4"),
                          collection  = "LC8_30_16D_STK-1",
                          start_date  = paste0(my_year, "-01-01"),
                          end_date    = paste0(my_year, "-12-31"))
    samples <- do_get_ts(in_dir = paste0(csv_dir, "/", my_year), 
                         out_file = my_out_file,
                         cube = lc8_cube, 
                         multicores = 46)
    print(sprintf("%s Finished year: %s", Sys.time(), my_year))
}