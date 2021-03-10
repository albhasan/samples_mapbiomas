
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
