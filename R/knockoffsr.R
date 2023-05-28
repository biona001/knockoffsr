#' Setup knockoffsr
#'
#' This function initializes Julia and the Knockoffs.jl package.
#' This will install Julia and the required packages
#' if they are missing.
#'
#' @param pkg_check logical, check if Knockoffs.jl package exist and install if necessary
#' @param ... Parameters are passed down to JuliaCall::julia_setup
#'
#' @examples
#'
#' knockoffsr::knockoff_setup()
#'
#' @export
knockoff_setup <- function (pkg_check=TRUE,...){
  julia <- JuliaCall::julia_setup(installJulia=TRUE,...)
  if(pkg_check) JuliaCall::julia_install_package_if_needed("Knockoffs")
  JuliaCall::julia_library("Knockoffs")

  functions <- JuliaCall::julia_eval("filter(isascii, replace.(string.(propertynames(Knockoffs)),\"!\"=>\"_bang\"))")
  ko <- julia_pkg_import("Knockoffs",functions)
  JuliaCall::autowrap("GaussianKnockoff", fields = c("X̃","s","method","m"))
  JuliaCall::autowrap("GaussianGroupKnockoff", fields = c("X", "groups", "S", "method", "m", "obj"))
  JuliaCall::autowrap("LassoKnockoffFilter", fields = c("y","X", "m", "ko", "selected", "W"))
  JuliaCall::autowrap("MarginalKnockoffFilter", fields = c("y","X","m", "ko", "selected", "W"))
  ko
}

