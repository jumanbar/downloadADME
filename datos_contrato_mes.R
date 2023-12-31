require(magrittr)
require(tibble)
require(httr)

# Será que hay que configurar al servidor para que tenga un cors??
# https://youtu.be/4KHiSt0oLJ0?si=RS4g7NC9fazL-ZNR

mklink <- function(id_contrato, anio, mes) {
  paste0(
    "https://172.20.0.30/visor_interno/index.php/Data/getDatosBoyaMes?id_contrato=", id_contrato,
    "&anio=", anio, "&mes=", mes
  )
}

# Se puede usar este de prueba
# link <- "https://172.20.0.30/visor_interno/index.php/Data/getDatosBoyaMes?id_contrato=714&anio=2023&mes=2"

link <- mklink(714, 2023, 2)
if (exists("res")) rm(res)
res <- httr::GET(link, httr::content_type("text/csv"))

# Funciona en R3.5.1  pero no en R4.2.1:
res <- httr::GET(link, httr::content_type("text/csv"),
                 config = httr::config(ssl_verifypeer = 0))

res <- httr::GET(link, httr::content_type("text/csv"),
                 config = httr::config(doh_ssl_verifypeer = FALSE))

message_for_status(res)

d <- res %>%
  httr::content("text") %>%
  read.csv(text = ., stringsAsFactors = FALSE) %>%
  tibble::as_tibble()

print(d)

httr_options("ssl") %>% dplyr::filter(libcurl == "CURLOPT_SSL_VERIFYPEER")
