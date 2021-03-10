library(sits)

make_proj_dir <- function(proj_dir, samples_file) {

  if (!dir.exists(proj_dir))
    dir.create(proj_dir, recursive = TRUE)
  stopifnot(dir.exists(proj_dir))

  extension <- sub(".*\\.(.*)$", "\\1", samples_file)

  stopifnot(extension %in% c("csv", "rds"))
  stopifnot(file.exists(samples_file))

  samples_dir <- paste0(proj_dir, "/samples")
  samples_csv_outfile <- paste0(samples_dir, "/samples.csv")
  samples_rds_outfile <- paste0(samples_dir, "/samples.rds")
  model_dir <- paste0(proj_dir, "/model")
  class_dir <- paste0(proj_dir, "/class")

  if (!dir.exists(samples_dir))
    dir.create(samples_dir)
  stopifnot(dir.exists(samples_dir))

  if (!dir.exists(model_dir))
    dir.create(model_dir)
  stopifnot(dir.exists(model_dir))

  if (!dir.exists(class_dir))
    dir.create(class_dir)
  stopifnot(dir.exists(class_dir))

  stopifnot(!file.exists(samples_csv_outfile))
  stopifnot(!file.exists(samples_rds_outfile))

  if (extension == "rds") {
    samples <- readRDS(samples_file)
    sits::sits_metadata_to_csv(samples, file = samples_csv_outfile)
    file.copy(samples_file, samples_rds_outfile, overwrite = FALSE)
  } else {
    file.copy(samples_file, samples_csv_outfile, overwrite = FALSE)
  }

  proj_dir
}

# ---- script run ----

# proj_dir <- "/Public/cerrado_v2"
# samples_csv <- "~/samples_v2.csv"
# make_proj_dir(proj_dir = proj_dir, samples_csv = samples_csv)
