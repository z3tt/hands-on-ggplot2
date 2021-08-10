library(tidyverse)

df <- rio::import(here::here("data", "consolidated_coin_data.csv"))

df_clean <- df %>% 
  as_tibble() %>% 
  janitor::clean_names() %>% 
  dplyr::select(-volume, -market_cap) %>% 
  mutate(
    across(c("open", "high", "low", "close"), as.numeric),
    date = lubridate::mdy(date),
    year = lubridate::year(date),
    month = lubridate::month(date),
    yday = lubridate::yday(date)
  ) %>% 
  drop_na() %>% 
  filter(currency %in% c("litecoin", "bitcoin-sv", "binance-coin", "eos")) #, "tezos"

write_rds(df_clean, here::here("data", "currency_cleaned.rds"))
write_csv(df_clean, here::here("data", "currency_cleaned.csv"))
xlsx::write.xlsx(df_clean, here::here("data", "currency_cleaned.xlsx"), sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)

d_clean %>% 
  filter(year > 2016) %>% 
  ggplot(aes(date, close, color = currency)) +
  geom_line(size = .8, alpha = .8) + theme_gray(base_size = 18) + scale_x_date(expand = c(0, 0))

ggsave("slides", "img", "data.png", width = 16, height = 7)
