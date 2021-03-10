library(sits)

source("/home/alber-d005/Documents/bdc_access_key.R")

bands <- c("BAND13", "EVI",    "BAND14", "NDVI",   "BAND16", "BAND15")

cbers_cube <- sits_cube(
    type = "BDC",
    name = "cbers_022024",
    satellite = "CBERS-4",
    sensor = "AWFI",
    bands = bands,
    tiles = "022024",
    collection = "CB4_64_16D_STK-1",
    start_date = "2018-08-29",
    end_date = "2019-08-13"
)
