library(googlesheets)
library(ggplot2)
library(jpeg)
library(grid)

# Load function to capitalize words 
# NOTE: It is easier to match between visited and location worksheets, 
# if strings are in the same case (upper or lower)
source("capWords.R")

# NOTE: The coordinates are "correct" relative to each other, but not to the map.  
# These values are use to translate the coordinates.
plotAxisLimitsWorksheet <- "plot_axis_limits"

# Load data from Google Spreadsheets
## Google Spreadsheet worksheets
visitedWorksheet <- "fountains"
locationWorksheet <- "fountains_loc"

## Google Spreadsheet
title <- "botw_public"

# Output image name
outputFile <- paste0(visitedWorksheet, ".jpg")

# Read data
ss <- gs_title(title)

## Get list of visits
visited <- gs_read(ss, ws=visitedWorksheet)
visited$name <- tolower(visited$name)

## Get list of locations
locations <- gs_read(ss, ws=locationWorksheet)
locations$name <- tolower(locations$name)

## Get plot axis limits
plotAxisLimits <- gs_read(ss, ws=plotAxisLimitsWorksheet)
xmin <- as.numeric(plotAxisLimits[plotAxisLimits$name == visitedWorksheet, "xmin"])
ymin <- as.numeric(plotAxisLimits[plotAxisLimits$name == visitedWorksheet, "ymin"])
xmax <- as.numeric(plotAxisLimits[plotAxisLimits$name == visitedWorksheet, "xmax"])
ymax <- as.numeric(plotAxisLimits[plotAxisLimits$name == visitedWorksheet, "ymax"])

# Merge visited and locations 
tmp <- merge(locations, visited, all.x = TRUE)

# Capital-case names
tmp$name <- capWords(tmp$name)

# Make two categories for plotting
tmp$visited[is.na(tmp$visited)] <- "FALSE"
tmp$visited <- as.factor(tmp$visited)

# Read map
img <- readJPEG("fullMap_1024.jpg")

# Plot on map
p1 <- ggplot(tmp, aes(x,y)) + 
  annotation_custom(rasterGrob(img, width=unit(1,"npc"), height=unit(1,"npc"))) +
  geom_point(aes(color=visited), size=5) +
  scale_color_manual(values = c("magenta", "cyan")) +
  xlim(xmin, xmax) +
  ylim(ymin, ymax) +
  theme_bw() +
  theme(legend.position = "none", 
        axis.title = element_blank(), 
        axis.text = element_blank(), 
        axis.ticks = element_blank())

# Display image
p1

# Save image to file
ggsave(outputFile, width = 11, height = 11)
