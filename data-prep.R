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

df_clean %>% 
  group_by(currency) %>% 
  mutate(end = close[which(date == max(df_clean$date))]) %>% 
  ungroup() %>% 
  mutate(currency = fct_rev(fct_reorder(currency, end))) %>% 
  ggplot(aes(date, close, color = currency)) +
  geom_line(size = .8, alpha = .8) + 
  scale_x_date(expand = c(0, 0), date_breaks = "3 months", date_labels = "%m/%y") +
  scale_y_continuous(labels = scales::dollar_format()) +
  scale_color_manual(values = c("#4d4d4e", "#00aeff", "#F0B90B", "#810080"),
                     labels = c("Bitcoin SV", "Litecoin", "Binance", "EOS")) +
  labs(x = NULL, y = "Closing Price", color = "Cryptocurrency:") +
  theme_light(base_size = 18) + 
  theme(panel.grid.minor = element_blank(), axis.title.y = element_text(margin = margin(r = 12)))

ggsave(here::here("slides", "img", "data.png"), width = 16, height = 7)
