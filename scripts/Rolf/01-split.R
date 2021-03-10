
do_split <- function(proj_dir, num_splits) {

  stopifnot(dir.exists(proj_dir))
  samples_dir <- paste0(proj_dir, "/samples")

  samples_csv_file <- paste0(samples_dir, "/samples.csv")
  stopifnot(file.exists(samples_csv_file))

  samples_out_dir <- paste0(samples_dir, "/splits")

  if (!dir.exists(samples_out_dir))
    dir.create(samples_out_dir)
  stopifnot(dir.exists(samples_out_dir))

  samples <- read.csv(samples_csv_file)

  samples <- dplyr::arrange(samples, longitude)
  samples <- dplyr::arrange(samples, latitude)

  if (num_splits > nrow(samples))
    num_splits <- nrow(samples)

  index <- cut(seq_len(nrow(samples)), num_splits, labels = FALSE)

  lapply(seq_len(num_splits), function(g, index) {
    filename <- tempfile(tmpdir = samples_out_dir, fileext = ".csv")
    write.csv(samples[index == g,], file = filename,
              row.names = FALSE)
    filename
  }, index = index)
}

# ---- script run ----

# proj_dir <- "/Public/cerrado_v2"
#
# do_split(proj_dir = proj_dir, num_splits = 1000)
