###################
## Tim Boudreau
## Pitch Stuff
## May 2018
###################



##### libraries #####


library(DBI)
library(flexclust)
library(ggplot2)
library(dplyr)



##### Call Database & Query #####


db <- dbConnect(RSQLite::SQLite(), "/Users/timb/Etc./Notebooks/Data/mlb_data.db")
datalist = list()

for (year in c(2015, 2016, 2017, 2018)){
  query <- paste("SELECT MLB_", year, ".*, ID_Key.mlb_id, ID_Key.mlb_team
                 FROM MLB_", year,
                 " JOIN ID_Key ON ID_Key.mlb_id = MLB_", year, ".pitcher",
                 sep = "")

  datalist[[year]] <- dbGetQuery(db, query)
  datalist[[year]]$season <- year
}

dbDisconnect(db)
df = do.call(rbind, datalist)



##### Data Manipulation #####


## add percentage of pitch type per team pitches, per season
## and grab unique ()

df <- df %>%
  group_by(season, mlb_team, balls, strikes) %>%
  mutate(count_n = n()) %>%
  group_by(pitch_type, add = TRUE) %>%
  mutate(count = n(),
         percent = count/count_n)
pitches <- unique(subset(df, balls == 3 & strikes == 2)[, 
                      c('season', 'mlb_team', 'pitch_type', 'percent', 'count')])


## full count averages, per team and season

statcast_fullcount <- subset(df, balls == 3 & strikes == 2) %>%
  group_by(balls, strikes, mlb_team, season) %>%
  summarize(count = n(),
            la = mean(launch_angle, na.rm = TRUE),
            ev = mean(launch_speed, na.rm = TRUE),
            zone_x = mean(plate_x, na.rm = TRUE),
            zone_y = mean(plate_z, na.rm = TRUE),
            woba = mean(woba_value, na.rm = TRUE))


## all of 2018 pitches & average pitch location per team and pitch type

full2018 <- subset(df, balls == 3 & strikes == 2 & season == 2018)

pitch_means <- full2018 %>%
  group_by(mlb_team,pitch_type) %>%
  summarize(plate_x = mean(plate_x, na.rm = TRUE),
            plate_z = mean(plate_z, na.rm = TRUE),
            count = n())
pitch_means <- subset(pitch_means, count >= 10)


## Houston & rest of mlb 2018 full count

pitches$houston <- ifelse(pitches$mlb_team == 'HOU', 'HOU', 'Rest of League')

export2018 <- subset(pitches, season == 2018) %>%
  group_by(houston, pitch_type) %>%
  summarize(total = sum(count)) %>%
  mutate(percent = total / sum(total))



##### Plot preparation #####


ltblue = rgb(red=216, green=232, blue=246, maxColorValue=255)
dkblue = rgb(red=58, green=102, blue=188, maxColorValue=255)
aqua = rgb(red=171, green=191, blue=227, maxColorValue=255)
tan = rgb(red=255, green=240, blue=197, maxColorValue=255)

gridline <- element_line(color = aqua, size = .5)

gen_theme <- theme(
  panel.background = element_rect(fill = ltblue, color = dkblue, size = 2),
  panel.grid.minor = element_blank(), panel.grid.major = gridline,
  plot.background = element_rect(color = dkblue, size = 1.5, fill = tan),
  plot.title = element_text(hjust = .5),
  plot.margin = unit(c(.5, .5, .5, .5), "cm")
)



##### team furthest and closest to center #####

## assume center of zone is (0, 2.5)
statcast_fullcount$distance <- sqrt(
  (statcast_fullcount$zone_x)**2 + (statcast_fullcount$zone_y - 2.5)**2)
# through inspecting the DF, we notice houston is by far the furthest form center
# and boston is the closest

min_team = statcast_fullcount$mlb_team[
  statcast_fullcount$distance == min(statcast_fullcount$distance)]


##### Plot defining #####


# all full counts in statcast era 2015-2018
# assume zone is (17/12, 2) and centered on (0, 2.5)

all_full <- ggplot(statcast_fullcount, aes(x = zone_x)) + 
  geom_point(aes(y = zone_y, color = 'grey'), alpha = .9) +
  geom_point(data = subset(statcast_fullcount, season == 2018 & mlb_team == 'HOU'),
                aes(x = zone_x, y = zone_y, color = dkblue)) +
  geom_rect(aes(xmin = -8.5/12, xmax = 8.5/12, ymin = 1.5, ymax = 3.5),
            color = dkblue, fill = NA) +
  scale_x_continuous(limits = c(-1, 1)) +
  scale_y_continuous(limits = c(.5, 4.5)) +
  gen_theme +
  labs(title = 'Full Count Pitch Locations, Each Team 2015 to 2018',
       x = 'Horizontal Location (Catcher View)', y = 'Vertical Location') +
  scale_color_manual('Teams', labels = c('Houston 2018', 'Teams 2015-2018'), 
                     values = c(dkblue, 'grey')) +
  theme(legend.background = element_rect(fill = tan), legend.key = element_rect(colour = dkblue))


# houston 2018, the abnormality

hou <- ggplot(subset(full2018, mlb_team == 'HOU'), 
       aes(x = plate_x, y = plate_z)) +
  geom_point(colour=dkblue,alpha=0.2) +
  geom_rect(aes(xmin = -8.5/12, xmax = 8.5/12, ymin = 1.5, ymax = 3.4),
            color = dkblue, fill = NA, alpha = .8) +
  scale_x_continuous(limits = c(-1, 1)) +
  scale_y_continuous(limits = c(.5, 4.5)) +
  stat_density_2d(aes(alpha = ..level..), geom = "polygon", fill = 'dodgerblue4', 
                  show.legend = FALSE) +
  gen_theme +
  labs(title = 'Full Count Pitch Location Density, Houston Astros 2018',
       x = 'Horizontal Location (Catcher View)', y = 'Vertical Location')


# all 2018 not houston

not_hou <- ggplot(subset(full2018, mlb_team != 'HOU'), 
               aes(x = plate_x, y = plate_z)) +
  geom_rect(aes(xmin = -8.5/12, xmax = 8.5/12, ymin = 1.5, ymax = 3.4),
            color = dkblue, fill = NA, alpha = .8) +
  scale_x_continuous(limits = c(-1, 1)) +
  scale_y_continuous(limits = c(.5, 4.5)) +
  stat_density_2d(aes(alpha = ..level..), geom = "polygon", fill = 'dodgerblue4',
                  show.legend = FALSE) +
  gen_theme +
  labs(title = 'Full Count Pitch Locations, Rest of MLB 2018',
       x = 'Horizontal Location (Catcher View)', y = 'Vertical Location')


# seattle 2018, the most middle average

avg <- ggplot(subset(full2018, mlb_team == min_team), 
              aes(x = plate_x, y = plate_z)) +
  geom_point(colour=dkblue,alpha=0.2) +
  geom_rect(aes(xmin = -8.5/12, xmax = 8.5/12, ymin = 1.5, ymax = 3.4),
            color = dkblue, fill = NA, alpha = .8) +
  scale_x_continuous(limits = c(-1, 1)) +
  scale_y_continuous(limits = c(.5, 4.5)) +
  stat_density_2d(aes(alpha = ..level..), geom = "polygon", fill = 'dodgerblue4',
                  show.legend = FALSE) +
  gen_theme +
  labs(title = paste('Full Count Pitch Locations,', min_team, '2018', sep = ' '),
       x = 'Horizontal Location (Catcher View)', y = 'Vertical Location') 


## pitch distributions, 2018, Houston and rest of mlb

pitch_dist_2018 <- ggplot(export2018, aes(pitch_type, percent)) +
  geom_bar(stat = 'identity', aes(fill = houston), position = 'dodge') +
  gen_theme + scale_fill_manual("legend", values = c("HOU" = dkblue, "Rest of League" = aqua)) +
  labs(title = '2018 Pitch Frequencies, Houston & Rest of League',
       x = 'Pitch Type', y = 'Percentage') +
  gen_theme +
  labs(title = 'Full Count Pitch Distributions, Each Team 2015 to 2018',
       x = 'Pitch Type', y = 'Percentage') +
  scale_color_manual('Teams', labels = c('Houston 2018', 'Teams 2015-2018'), 
                     values = c(dkblue, 'grey')) +
  theme(legend.background = element_rect(fill = tan), legend.key = element_rect(colour = dkblue))


## for fun, can check by pitch or see every pitch by team and pitch type

# pitch <- ''
# ggplot(subset(pitch_means, pitch_type != pitch), 
#        aes(x = plate_x, y = plate_z)) +
#   geom_point(color = 'grey') +
#   geom_point(data = subset(pitch_means, pitch_type != pitch & mlb_team == 'HOU'),
#              aes(x = plate_x, y = plate_z, color = pitch_type)) +
#   geom_rect(aes(xmin = -8.5/12, xmax = 8.5/12, ymin = 1.5, ymax = 3.4),
#             color = 'black', fill = NA, alpha = .8) +
#   scale_x_continuous(limits = c(-1, 1)) +
#   scale_y_continuous(limits = c(.5, 4.5)) +
#   gen_theme +
#   labs(title = paste('Full Count Pitch Locations, Houston By Pitch:', pitch, sep = ' '),
#        x = 'Horizontal Location (Catcher View)', y = 'Vertical Location')
#   theme(legend.background = element_rect(fill = tan), legend.key = element_rect(colour = dkblue))



##### plots! #####


dir = 'Etc./Projects/Blog/Astros\ Full\ Count/'


## uncomment to plot and view all plots
# 
# all_full
# hou
# avg
# not_hou
# pitch_dist_2018


## uncomment to save all plots

# all full counts in statcast era 2015-2018

jpeg(paste(dir, 'all_full.jpeg', sep=''), units='in', width=5.5, height=4, res=300)
all_full
dev.off()


# houston 2018, the abnormality

jpeg(paste(dir, 'houston2018.jpeg', sep=''), units='in', width=5.5, height=4, res=300)
hou
dev.off()

# minimum team 2018, the most middle average
jpeg(paste(dir, min_team, '.jpeg', sep=''), units='in', width=5.5, height=4, res=300)
avg
dev.off()


# all 2018 not houston
jpeg(paste(dir, 'all_2018_not_hou.jpeg', sep=''), units='in', width=5.5, height=4, res=300)
not_hou
dev.off()

# pitch_distributions, 2018
jpeg(paste(dir, 'pitch_distributions_fullcount_2018.jpeg', sep=''),
     units='in', width=5.5, height=4, res=300)
pitch_dist_2018
dev.off()



##### data export for use #####


## export data to chosen directory

# write.csv(export2018, paste(dir, "astros_fullcount.csv", sep = ''), row.names = FALSE)