
# Error: [extract] cannot read values
# In addition: Warning messages:
# 1: In x@ptr$extractVector(y@ptr, touches[1], method[1], isTRUE(cells[1]),  :
#   GDAL Error 1: TIFFFillTile:Read error at row 9472, col 4864, tile 1051; got 0 bytes, expected 130604
# 2: In x@ptr$extractVector(y@ptr, touches[1], method[1], isTRUE(cells[1]),  :
#   GDAL Error 1: TIFFReadEncodedTile() failed.
# 3: In x@ptr$extractVector(y@ptr, touches[1], method[1], isTRUE(cells[1]),  :
#   GDAL Error 1: LC8_30_16D_STK_v001_043049_2017-11-17_2017-12-02_band2.tif?access_token=0GEjUgyxEI7UYVcMxOJBWBWxOcTxCB1fMC89Y67biy, band 1: IReadBlock failed at X offset 39, Y offset 23: TIFFReadEncodedTile() failed.
# Execution halted
# gdalUtils::gdalinfo("/vsicurl/http://datacube-005.dpi.inpe.br:8010/data/d006/Mosaic/LC8_30_16D_STK/v001/043049/2017-11-17_2017-12-02/LC8_30_16D_STK_v001_043049_2017-11-17_2017-12-02_band2.tif?access_token=0GEjUgyxEI7UYVcMxOJBWBWxOcTxCB1fMC89Y67biy")

library(sits)
source("scripts/pb_snow.R")

# define the get time series routine
do_get_ts <- function(proj_dir, cube, multicores = 20) {

  stopifnot(inherits(cube, "raster_cube"))
  stopifnot(dir.exists(proj_dir))

  samples_csv_split_dir <- paste0(proj_dir, "/samples/splits")

  samples_out <- paste0(proj_dir, "/samples/samples.rds")

  stopifnot(dir.exists(samples_csv_split_dir))

  samples_csv_files <- list.files(path = samples_csv_split_dir,
                                  pattern = "\\.csv$",
                                  full.names = TRUE)

  cl <- snow::makeSOCKcluster(multicores)
  on.exit({snow::stopCluster(cl)})

  snow::clusterExport(cl, "cube", envir = environment())

  samples_lst <- .apply_cluster(cl, x = samples_csv_files, fun = function(file) {

    samples_outfile <- paste0(sub("^(.*)\\.csv$", "\\1.rds", file))

    if (file.exists(samples_outfile))
      return(samples_outfile)

    samples <- sits::sits_get_data(cube = cube, file = file)

    saveRDS(samples, file = samples_outfile)
    samples_outfile
  })

  samples <- dplyr::bind_rows(lapply(samples_lst, readRDS))
  saveRDS(samples, file = samples_out)

  samples_out
}


# ---- script run ----

# proj_dir <- "/Public/cerrado_v2"
#
# # CHECK for BDC_ACCESS_TOKEN environment variable
#
# library(sits)
# lc8_cube <- sits_cube(type        = "BDC",
#                       url         = "http://datacube-005.dpi.inpe.br:8010/stac/",
#                       name        = "cerrado",
#                       bands       = c("BAND1", "BAND2", "BAND3", "BAND4",
#                                       "BAND5", "BAND6", "BAND7", "EVI",
#                                       "NDVI", "FMASK4"),
#                       collection  = "LC8_30_16D_STK-1",
#                       start_date  = "2017-09-01",
#                       end_date    = "2018-08-31")
#
# samples <- do_get_ts(proj_dir = proj_dir, cube = lc8_cube, multicores = 40)
