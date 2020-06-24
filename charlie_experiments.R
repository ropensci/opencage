library("tidyverse")
opencage_forward("12 Westerleigh Road, Bristol")

multi_addresses <- oc_forward(c("12 Westerleigh Road, Bristol", "6 Corunna Crescent, Oxford"), add_request = TRUE)

class(multi_addresses)




my_data <- tribble(
  ~oc_query, ~oc_confidence, ~oc_town,
  "12 Corrunna Crescent, Oxford", 10, "Oxford",
  # "12 Corrunna Crescent, Oxford", 7, "Cowley",
  "12 Westerleigh Road, Bristol", 4, "Bristol"
)


my_data %>%
  nest(data = oc_confidence:oc_town)



oc_forward(c("12 Westerleigh Road, Bristol", "22 Renfrew Close, Birmingham"), return = "tibble")



# =========== df versions

df <- tibble(id = 1:3,
             locations = c("Nantes", "Hamburg", "Los Angeles"))

# Return lat, lng, and formatted address
forwards_FALSE_bind_cols <- oc_forward_df(df, placename = locations, bind_cols = FALSE, output = "short")

forwards_FALSE_bind_cols


df <- tibble(id = 1:3,
             silly = letters[21:23],
             names_of_places = c("Nantes", "Hamburg", "Los Angeles"))
df2 <- add_column(df,
                  bounds = oc_bbox(xmin = c(-2, 9, -119),
                                   ymin = c(47, 53, 34),
                                   xmax = c(0, 10, -117),
                                   ymax = c(48, 54, 35)),
                  limit = 1:3,
                  countrycode = c("ca", "us", "co"),
                  language = c("fr", "de", "en"))

oc_forward_df(df2, placename = names_of_places,
              bounds = bounds,
              language = language,
              bind_cols = FALSE,
              output = "all") %>%
  unnest(cols = data)


df2 <- df2 %>%
  mutate(oc_political_union = c("d", "e", "k"))

{forwards_TRUE_bind_cols <- oc_forward_df(df, placename = names_of_places, bind_cols = TRUE, output = "all")}

forwards_TRUE_bind_cols %>%
  unnest() %>%
  colnames()


foobar_1

foobar_1 %>%
  nest(data = 2:ncol(foobar_1))

df <- tibble(id = 1:4,
             lat = c(-36.85007, 47.21864, 53.55034, 34.05369),
             lng = c(174.7706, -1.554136, 10.000654, -118.242767))

reverse_FALSE_bind_cols <- oc_reverse_df(df, latitude = lat, longitude = lng, bind_cols = FALSE, output = "all")

reverse_FALSE_bind_cols

reverse_TRUE_bind_cols <- oc_reverse_df(df, latitude = lat, longitude = lng, bind_cols = TRUE, output = "short")


test_rev_df %>%
  nest(data = 2:ncol(test_rev_df))




