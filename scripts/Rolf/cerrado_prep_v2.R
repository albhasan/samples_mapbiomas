library(sits)
source("scripts/00-make_proj_dir.R")
source("scripts/01-split.R")
source("scripts/02-time_series.R")
source("scripts/03-train.R")
source("scripts/04-classify.R")

# ---- run script ----
Sys.setenv(SITS_USER_CONFIG_FILE = "~/.sits/config.yml")
proj_dir <- "/Public/cerrado_v2"

# ---- make project ----
samples_csv <- "~/samples/cerrado/cerrado_samples_v2.csv"
make_proj_dir(proj_dir = proj_dir, samples_file = samples_csv)

# ---- split samples ----
# split samples to speed-up the time series download
do_split(proj_dir = proj_dir, num_splits = 1000)

# ---- get time series ----
# CHECK for BDC_ACCESS_TOKEN environment variable
Sys.setenv(BDC_ACCESS_KEY = "0GEjUgyxEI7UYVcMxOJBWBWxOcTxCB1fMC89Y67biy")
lc8_cube <- sits_cube(type        = "BDC",
                      url         = "http://datacube-005.dpi.inpe.br:8010/stac/",
                      name        = "cerrado",
                      bands       = c("BAND1", "BAND2", "BAND3", "BAND4",
                                      "BAND5", "BAND6", "BAND7", "EVI",
                                      "NDVI", "FMASK4"),
                      collection  = "LC8_30_16D_STK-1",
                      start_date  = "2017-09-01",
                      end_date    = "2018-08-31")
samples <- do_get_ts(proj_dir = proj_dir, cube = lc8_cube, multicores = 40)

# ---- train model ----
do_train(proj_dir = proj_dir, ml_method = sits_rfor(num_trees = 2000))

