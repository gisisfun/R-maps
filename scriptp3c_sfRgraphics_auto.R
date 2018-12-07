#!/usr/bin/env Rscript
#script3c_sfRgraphics_auto.R
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

cat('*rgeos\n')
if (!require("rgeos")) {
install.packages("rgeos", repos = "https://cran.csiro.au")
library(rgeos)
}

cat('*sf\n')
if (!require("sf")) {
install.packages("sf", repos = "https://cran.csiro.au")
library(sf)
}

#for crop map image
cat('*raster\n')
if (!require("raster")) {
install.packages("raster", repos = "https://cran.csiro.au")
library(raster)
}

cat('\n***************************\n')
cat('*Loading table from step 2*\n')
cat('***************************\n')
pia_cols_rows_table_output <- read_feather(paste0(getwd(),"/tables/pia_cols_rows_output_",args[1],"_2015-04-01.feather"))

cat('*done\n')

#chart here
cat('\n*************************************************************\n')
cat('*Loading the reference file from the shapefiles subdirectory*\n') 
cat('*************************************************************\n')         
d2poareg = st_read(paste0(getwd(),"/shapefiles/d2poareg.shp"))

cat('\n**********************************************************\n')
cat('*Merge reference mapping layer and step 2 dataset on D2PC*\n')
cat('**********************************************************\n')
merged.sf <- merge(d2poareg, pia_cols_rows_table_output, by='D2PC')

cat('\n****************************************************************************\n')
cat(paste0("*Merged reference mapping layer (merged_",args[1],".shp) to shapefiles subdirectory*\n"))
cat('****************************************************************************\n')
st_write(merged.sf, paste0(getwd(),"/shapefiles/merged_",args[1],".shp"), delete_layer = TRUE) # overwrites

cat('\n**************\n')
cat('*Building map*\n')
cat('**************\n') 
png(file = paste0(getwd(),"/images/map_plot_c_",args[1],".png") ,width = 20, height = 15, units ="cm", res =600)

cat('*cropping to extent\n')
crop_custom <- function(poly.sf) {
  poly.sp <- as(poly.sf, "Spatial")
  poly.sp.crop <- crop(poly.sp, extent(c(110, 159, -44,-9)))
  st_as_sf(poly.sp.crop)
}
m <- crop_custom(merged.sf)

cat('*plotting statement\n')

plot(m["max.col.name"],main = paste0("Max Primary Medical Code by 2 Digit Postcode for ",args[1]," Benefit"),key.pos = 1, axes = FALSE, key.size = lcm(1.3))

cat('*adding labels\n')
text(st_coordinates(st_centroid(m)), labels=as.character(m$D2PC), cex=0.6)

cat('*committing final map image to file\n')
# Turn off device driver (to flush output to PNG)
dev.off()

#will remove ALL objects 
rm(list=ls()) 
     
cat('\nThe End\n')
