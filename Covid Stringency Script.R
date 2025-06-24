library(readr)
library(dplyr)
library(lubridate)

# Read the dataset
covid_data <- read_csv("OxCGRT_simplified_Covid stringency.csv")

# 2021 Covid stringency for each state
covid_2021 <- covid_data %>% 
  #Extract day, month, year from Date variable
  mutate(Date = ymd(Date),
         Year = year(Date),
         Month = month(Date)) %>%
  #Filter US states and 2021 year
  filter(CountryCode=="USA" & Year=="2021") %>%
  #Select to only show Region, Date, and the 4 indices
  select(RegionName, RegionCode, Date, Year,
                                    StringencyIndex_Average,
                                    GovernmentResponseIndex_Average,
                                    ContainmentHealthIndex_Average,
                                    EconomicSupportIndex) %>%
  #Mutate a region name to match NFCS data
  mutate(RegionName = ifelse(RegionName=="Washington DC","District of Columbia",RegionName)) %>%
  #Group by Region
  group_by(RegionName, Year) %>%
  #Mean 2021 indices by state
  summarise(StringencyIndex_Average = mean(StringencyIndex_Average, na.rm = TRUE),
            GovernmentResponseIndex_Average = mean(GovernmentResponseIndex_Average, na.rm = TRUE),
            ContainmentHealthIndex_Average = mean(ContainmentHealthIndex_Average, na.rm = TRUE),
            EconomicSupportIndex = mean(EconomicSupportIndex, na.rm = TRUE)) %>%
  ungroup()
