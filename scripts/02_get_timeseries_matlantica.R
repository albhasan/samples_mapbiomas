#.libPaths("/home/alber-d005/R/x86_64-pc-linux-gnu-library/4.0")
#Sys.setenv("SITS_USER_CONFIG_FILE" = "/home/alber-d005/Documents/samples_mapbiomas/config.yml")

library(dplyr)
library(rstac)
library(sits)
library(snow)

source("/home/alber-d006/Documents/bdc_access_key.R")
source("/home/alber-d006/Documents/samples_mapbiomas/scripts/00_util.R")

csv_dir  <- "/home/alber-d006/Documents/samples_mapbiomas/data/samples/csv"
out_file <- "/home/alber-d006/Documents/samples_mapbiomas/data/samples/samples"

stopifnot(dir.exists(csv_dir))

my_tiles <- c("042055", "043054", "043055")

do_get_ts_local <- function(in_dir, out_file, cube, multicores = 20) {
    stopifnot(inherits(cube, "raster_cube"))
    stopifnot(dir.exists(in_dir))
    stopifnot(!file.exists(out_file))
    samples_csv_files <- list.files(path = in_dir,
                                    pattern = "\\.csv$",
                                    full.names = TRUE)
    samples_csv_files <- grep(paste0("mapbiomas_(",
                              paste(my_tiles, collapse = "|"),
                              ").*[.]csv$"), 
                              samples_csv_files, 
                              value = TRUE) 
    cl <- snow::makeSOCKcluster(multicores)
    on.exit({snow::stopCluster(cl)})
    snow::clusterExport(cl, "cube", envir = environment())
    samples_lst <- .apply_cluster(cl, x = samples_csv_files, 
                                  fun = function(file) {
        samples_outfile <- paste0(sub("^(.*)\\.csv$", "\\1.rds", file))
        if (file.exists(samples_outfile))
            return(samples_outfile)
            samples <- sits::sits_get_data(cube = cube, file = file)
        saveRDS(samples, file = samples_outfile)
        samples_outfile
    })
    samples <- dplyr::bind_rows(lapply(samples_lst, readRDS))
    saveRDS(samples, file = out_file)
    out_file
}

for (my_year in 2017:2018) {
    print(sprintf("%s Staring year: %s", Sys.time(), my_year))
    my_out_file <- paste0(out_file, "_", my_year, ".rds")
    if (file.exists(my_out_file)) {
        warning(sprintf("Year %s was already processed. Skipping...", my_year))
        next()
    }
    lc8_cube <- sits_cube(source = "BDC",
                          url    = "http://datacube-005.dpi.inpe.br:8010/stac/",
                          name   = "cerrado",
                          bands  = c("BAND1", "BAND2", "BAND3", "BAND4",
                                     "BAND5", "BAND6", "BAND7", "EVI",
                                     "NDVI", "FMASK4"),
                          tiles = my_tiles,
                          collection = "LC8_30_16D_STK-1",
                          start_date = paste0(my_year, "-01-01"),
                          end_date   = paste0(my_year, "-12-31"))
    samples <- do_get_ts_local(in_dir = paste0(csv_dir, "/", my_year), 
                               out_file = my_out_file,
                               cube = lc8_cube, 
                               multicores = 46)
    print(sprintf("%s Finished year: %s", Sys.time(), my_year))
}


for (my_year in 2017:2018) {
    my_out_file <- paste0(out_file, "_", my_year, ".rds")
    print(sprintf("Testing out file %s", my_out_file))
    s_tb <- readRDS(my_out_file)
    s_tb %>% 
        mutate(n_rows = purrr::map_int(time_series, nrow)) %>%
        dplyr::pull(n_rows) %>%
        unique() %>%
        sort() %>%
        print()
}
