library(tidyverse)

#Read NFCS 2021 State by State and Investor Data
state_2021 <- read_csv("NFCS state by state.csv")
investor_2021 <- read_csv("NFCS 2021 Investor Data 221121.csv")

#Read NFCS 2018 State by State and Investor Data
state_2018 <- read_csv("NFCS 2018 State Data 190603.csv")
investor_2018 <- read_csv("NFCS 2018 Investor Data 191107.csv")

#Inner merge investor and state dataset
combine_2021 <- merge(investor_2021, state_2021, by="NFCSID")
combine_2018 <- merge(investor_2018, state_2018, by="NFCSID")

#Add a "Year" column to the datasets
combine_2021["Year"] <- 2021
combine_2018["Year"] <- 2018

#Standardize column names
combine_2018 <- combine_2018 %>%
  rename(
    A3 = A3.x,                # Non-retirement investment
    S_Gender2 = S_Gender,     # Gender
    A8_2021 = A8,             # Income (scale changed)
    A50A = A3.y,              # Gender
    A50B = A3B,               # Gender/Age Net
    G23.y = G23,              # Debt concern
    B31.y = B31,              # Mobile payment method
    G20 = G20.y,              # Unpaid medical bills
    G30_1.y = G30_1,          # Student loan for yourself
    G30_2.y = G30_2,          # Spouse
    G30_3.y = G30_3,          # Children
    G30_4.y = G30_4,          # Grandchildren
    G30_5.y = G30_5,          # Other
    F2_1 = F2_1.y,            # Always paid in full
    F2_2 = F2_2.y,            # Carried balance with interest
    F2_5 = F2_5.y,            # Over limit fee
    F2_6 = F2_6.y             # Used cash advance
  )

#Bind rows of the 2 data sets; keep all columns & fill with NAs
NFCS_data <- bind_rows(combine_2018, combine_2021)

#Standardize for income question A8, change option 8, 9, 10 to 8
NFCS_data$A8_2021[NFCS_data$A8_2021 %in% c(8,9,10)] <- 8

#Export to data file
write_csv(NFCS_data,"dataset.csv")

#__________________________________________________________________
#Match NFCS data with Covid stringency

# Create a look up table to match state name with code
state_lookup <- tibble(
  NFCS_State_Code = 1:51,
  State_Name = c(
    "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
    "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", 
    "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky",
    "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
    "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
    "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota",
    "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
    "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
    "West Virginia", "Wisconsin", "Wyoming"
  )
)
# Join state_lookup with NFCS survey data
NFCS_data <- NFCS_data %>% left_join(state_lookup, by=c("STATEQ" = "NFCS_State_Code"))
# Join NFCS survey data with Covid stringency
NFCS_data <- NFCS_data %>% left_join(covid_2021, by=c("State_Name" = "RegionName", "Year"="Year"))

#Export to data file
write_csv(NFCS_data,"NFCS_stringency_data.csv")
