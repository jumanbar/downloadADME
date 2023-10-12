library(magrittr)
library(dplyr)
dia0 <- as.Date("2023-09-01") - 4517

as.Date("2023-09-01") - dia0

dateToNumber <- function(date_string) {
  dt <- as.Date(date_string)
  out <- as.integer(dt - as.Date("1899-12-30"))
  return(out)
}
# add_headers("user-agent" = "Mozilla/5.0", "Cache-Control" = "no-cache")

dateToNumber("2023-09-01")
dateToNumber("2023-09-30")
idCentral <- "bon"


# res <- httr::GET(link, config = httr::config(ssl_verifypeer = FALSE)) #, httr::content_type("text/csv"), config = httr::config(ssl_verifypeer = FALSE))
# res <- httr::GET(link,
#                  httr::add_headers("user-agent" = "Mozilla/5.0", "Cache-Control" = "no-cache"),
#                  config = httr::config(ssl_verifypeer = FALSE)) #, httr::content_type("text/csv"), config = httr::confi
# browseURL(link)

downloadADME <- function(idCentral = c("bon", "pal", "bay"),
                         anio = 2023, mes = 06) {

  idCentral <- match.arg(idCentral)

  ini_date <- as.Date(paste(anio, mes, "01", sep = "-"))
  end_date <- seq(ini_date, length = 2, by = "months")[2] - 1

  link <- paste0(
    "https://pronos.adme.com.uy/cgi-bin/seriescentralhidro.cgi",
    "?idCentral=", idCentral,
    "&ts=ods",
    "&dtIni=", dateToNumber(ini_date),
    "&dtFin=", dateToNumber(end_date)
  )

  browseURL(link)

  invisible(link)
}



a <- downloadADME("pal", 2023, 2) # Error: should be one of “bon”, “pal”, “bay”

# Por qué no funciona??
download.file(a, "tmppp.ods")

for (mes in 6:8) {
  downloadADME("pal", 2022, mes)
}




find_ods_files <- function(download_dir = file.path(Sys.getenv("HOMEPATH"), "Downloads"), ini_dnd) {

  arch <- dir(download_dir, pattern = "\\.ods$", full.names = TRUE)
  da <- dplyr::filter(file.info(arch), ctime >= ini_dnd)
  return(da)
}

# arch


# str(da)



downloadADME_anio <- function(idCentral = c("bon", "pal", "bay"),
                              anio = 2023,
                              meses = 1:12,
                              timeout = 120) {

  ini_dnd <- Sys.time()
  # ini_dnd <- as.POSIXlt.character("2023-10-10 19:00:43 -03")
  #

  n_expected_files <- length(meses)

  arch <- data.frame(x = logical(0))
  ttotal <- 0

  out <- list(links = character(length(meses)),
              data = list())
  i <- 1L
  for (mes in meses) {
    out$links[[i]] <- downloadADME(idCentral, anio, mes)
    i <- i + 1L
  }

  Sys.sleep(1)

  while (nrow(arch) < n_expected_files && ttotal <= timeout) {
    Sys.sleep(1)
    arch <- find_ods_files(ini_dnd = ini_dnd)
    cat("Buscando entre los archivos descargados ...\n")
    ttotal <- difftime(Sys.time(), ini_dnd, units = "secs")
  }

  if (ttotal > timeout) {
    warning("Se detuvo la espera ya que se sobrepasó el tiempo de espera\n",
            "establecido (timeout = ", timeout, " segundos)\n",
            "Se encontraron ", nrow(arch), " archivos .ODS descargados:\n",
            paste0(paste0("\t", rownames(arch)), collapse = "\n"))

  }

  for (i in 1:nrow(arch)) {

    out$data[[i]] <- readODS::read_ods(rownames(arch)[i], col_types = readr::cols(.default = "c"))

  }


  return(out)
}

x <- downloadADME_anio("bon", 2023, 1:3)



