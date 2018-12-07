#!/usr/bin/env Rscript
#script3d_ggplot2Rcontinuous.R
args = commandArgs(trailingOnly=TRUE)
# R script to create tabular output for for PIA synthetic csv data held in the dataverse system
# part 3 visualisation of data files

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  # default output benefit type
  args[1] = "NSA"
}

cat('\n*********************************************************\n')
cat(paste0("*Reading in file from part 2, processing records for ",args[1],"*\n"))
cat('*********************************************************\n')

cat('\n*********************\n')
cat('*Loading R Libraries*\n')
cat('*********************\n')

cat('*feather\n')
if (!require("feather")) {
install.packages("feather", repos = "https://cran.csiro.au")
library(feather)
}

#fortify statement
cat('*rgeos\n')
if(!require("rgeos")) {
install.packages("rgeos", repos = "https://cran.csiro.au")
library(rgeos)
}

cat('*rgdal\n')
if (!require("rgdal")) {
install.packages("rgdal", repos = "https://cran.csiro.au")
library(rgdal)
}

cat('*ggplot2\n')
if(!require("ggplot2")) {
install.packages("ggplot2", repos = "https://cran.csiro.au")
library(ggplot2)
}

cat('*scales\n')
if (!require("scales")) {
install.packages("scales", repos = "https://cran.csiro.au")
library(scales)
}

cat('*maptools\n')
if (!require("maptools")) {
install.packages("maptools", repos = "https://cran.csiro.au")
library(maptools)
}

cat('\n***************************\n')
cat('*Loading table from step 2*\n')
cat('***************************\n')
pia_cols_rows_table_output <- read_feather(paste0(getwd(),"/tables/pia_cols_rows_output_",args[1],"_2015-04-01.feather"))

cat('*done\n')

cat('\n*************************************************************\n')
cat('*Loading the reference file from the shapefiles subdirectory*\n') 
cat('*************************************************************\n')            
d2poareg <- readOGR(dsn = paste0(getwd(),"/shapefiles"), layer="d2poareg")


cat('\n************************************************************\n')
cat('*Merging reference mapping layer and step 2 dataset on D2PC*\n') 
cat('************************************************************\n') 
m <- merge(d2poareg, pia_cols_rows_table_output, by='D2PC')

cat(paste0("*Merge reference mapping layer (merged_",args[1],".shp) to shapefiles subdirectory\n"))
writeOGR(m, dsn = paste0(getwd(),"/shapefiles"), layer=paste0("merged_",args[1]),driver="ESRI Shapefile", overwrite_layer = TRUE) # overwrites

cat('\n*******************************************\n')
cat('*Converting the reference file for mapping*\n') 
cat('*******************************************\n') 
m.fort <- fortify(m, region = "D2PC")
cat('*Fortifying a map makes the data frame ggplot uses to draw the map outlines.\n')
cat('*D2PC identifies those polygons, and links them to your data.\n') 
cat('*Your data frame needs a column with matching ids to set as the map_id aesthetic in ggplot.\n')
idList <- m@data$D2PC
cat('*coordinates extracts centroids of the polygons, in the order listed at m@data\n')
centroids.df <- as.data.frame(coordinates(m))
names(centroids.df) <- c("Longitude", "Latitude")  #more sensible column names
popList <- m@data$max
pop.df <- data.frame(id = idList, population = popList, centroids.df)





cat('\n********************************************************************************\n')
cat(paste0("Making a map file output: map_plot_d_",args[1],".png file in the images subdirectory\n"))
cat('********************************************************************************\n')


cat('\n********************\n')
cat('*Building map with:*\n')
cat('********************\n') 
# Trim off excess margin space (bottom, left, top, right)
#par(mar=c(2, 1, 2, 1))

cat('*ggplot statement\n') 
ggplot(pop.df, aes(map_id = id)) + #"id" is col in your df, not in the map object 
  geom_map(aes(fill = population), colour= "grey", map = m.fort) +
  expand_limits(x = m.fort$long, y = m.fort$lat) +
  scale_fill_gradient(high = "red", low = "white", guide = "colorbar", labels = comma) +
  geom_text(aes(label = id, x = Longitude, y = Latitude)) + #add labels at centroids
  coord_equal(xlim = c(160,110), ylim = c(-48, -10)) + #let's view Australia
  labs(x = "Longitude", y = "Latitude", title = paste0("Max Primary Medical Code by 2 Digit Postcode for ",args[1]," Benefit")) +
  theme_bw() 

cat('*Committing final map image to file\n')
ggsave(file = paste0("map_plot_d_",args[1],".png"), path=paste0(getwd(),"/images"),scale = 3, width = 15, height = 10, units = "cm" ,dpi = 400)


# Restore default margins
#par(mar=c(5, 4, 4, 2) + 0.1)

#will remove ALL objects 
rm(list=ls()) 
        
cat('\nThe End\n')
