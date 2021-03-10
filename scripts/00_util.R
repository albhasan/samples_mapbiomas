#' Add coordinates as columns to an SF object.
#'
#' @param point_sf A sf object.
#' @return         A sf object.
add_coords <- function(point_sf){
    xy <- point_sf %>%
        sf::st_coordinates() %>%
        magrittr::set_colnames(c("longitude", "latitude")) %>%
        tidyr::as_tibble()
    point_sf %>%
        dplyr::bind_cols(xy) %>%
        return()
}


# Coded by Rolf Simoes.
.apply_cluster <- function(cl, x, fun, ..., .quiet = FALSE) {
    
    if (!.quiet)
        pb <- txtProgressBar(max = length(x) + 1, style = 3)
    
    argfun <- function(i){
        if (!.quiet)
            setTxtProgressBar(pb, i)
        c(list(x[[i]]), list(...))
    }
    
    if (!is.null(cl)) {
        res <- snow::dynamicClusterApply(cl, fun, length(x), argfun)
    } else {
        res <- lapply(seq_along(x), function(i) { do.call(fun, args = argfun(i)) })
    }
    
    
    if (!.quiet) {
        setTxtProgressBar(pb, length(x) + 1)
        close(pb)
    }
    
    return(res)
}



#' Define the get time series routine. Coded by Rolf Simoes.
#' 
#' @param in_dir A character. Path to a directory with CSV files.
#' @param out_file A character. Path to the file to be created by this function.
#' @reutrn A character. The out_file
do_get_ts <- function(in_dir, out_file, cube, multicores = 20) {
    stopifnot(inherits(cube, "raster_cube"))
    stopifnot(dir.exists(in_dir))
    stopifnot(!file.exists(out_file))
    
    samples_csv_files <- list.files(path = in_dir,
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
    saveRDS(samples, file = out_file)
    
    out_file
}