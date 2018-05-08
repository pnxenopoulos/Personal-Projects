###################
## Tim Boudreau
## Release Variance
## April 2018
###################



##### libraries #####

library(DBI)
library(dplyr)
library(reshape2)



##### Call Database & Query #####

db <- dbConnect(RSQLite::SQLite(), "Etc./Notebooks/Data/mlb_data.db")

season = '2017'

sql_query <- paste("
                   SELECT MLB_", season, ".*, ID_Key.mlb_id, ID_Key.mlb_name
                   FROM MLB_", season,
                   " JOIN ID_Key ON ID_Key.mlb_id = MLB_", season, ".pitcher", sep = "")

df <- dbGetQuery(db, sql_query)
dbDisconnect(db)



##### Group by to calculate Variance #####

test <- df %>%
  group_by(mlb_name) %>%
  summarize(count = n(),
            rx = var(release_pos_x, na.rm = TRUE),
            rz = var(release_pos_z, na.rm = TRUE),
            mx = mean(release_pos_x, na.rm = TRUE),
            mz = mean(release_pos_z, na.rm = TRUE))

test <- subset(test, test$count > 1000)
View(test)
