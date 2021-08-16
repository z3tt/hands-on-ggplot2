library(tidyverse)

df <- rio::import(here::here("data", "consolidated_coin_data.csv"))

df_clean <- df %>% 
  as_tibble() %>% 
  janitor::clean_names() %>% 
  filter(!is.na(currency)) %>% 
  dplyr::select(-volume, -market_cap) %>% 
  mutate(
    across(c("open", "high", "low", "close"), as.numeric),
    date = lubridate::mdy(date),
    year = lubridate::year(date),
    month = lubridate::month(date),
    yday = lubridate::yday(date)
  ) %>% 
  filter(currency %in% c("litecoin", "bitcoin-sv", "binance-coin", "eos")) %>% 
  # mutate(
  #   currency = case_when(
  #     currency == "binance-coin" ~ "Binance",
  #     currency == "bitcoin-sv" ~ "Bitcoin SV",
  #     currency == "eos" ~ "EOS",
  #     currency == "litecoin" ~ "Litecoin"
  #   )
  # ) %>% 
  filter(date >= lubridate::date("2017-08-01"))

write_rds(df_clean, here::here("data", "crypto_cleaned.rds"))
write_csv(df_clean, here::here("data", "crypto_cleaned.csv"))
xlsx::write.xlsx(df_clean, here::here("data", "crypto_cleaned.xlsx"), 
                 sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)
json <- jsonlite::toJSON(df_clean)
write(json, here::here("data", "crypto_cleaned.json"))

