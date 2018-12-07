#!/usr/bin/env Rscript
#script3a_baseRgrapghics.R
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

cat('*rgdal\n')
if (!require("rgdal")) {
install.packages("rgeos", repos = "https://cran.csiro.au")
library(rgdal)
}

cat('*geosphere\n')
if (!require("geosphere")) {
install.packages("geosphere", repos = "https://cran.csiro.au")
library(geosphere)
}

cat('\n***************************\n')
cat('*Loading table from step 2*\n')
cat('***************************\n')
pia_cols_rows_table_output <- read_feather(paste0(getwd(),"/tables/pia_cols_rows_output_",args[1],"_2015-04-01.feather"))

cat('*done')

cat('\n**********************************************************************************\n')
cat(paste0("*Making a chart file output: chart_plot_a_",args[1],".png file in the images subdirectory*\n"))
cat('**********************************************************************************\n')
png(filename = paste0(getwd(),"/images/chart_plot_a_",args[1],".png")) 
 
cat('\n***********************\n')
cat('*Building chart with :*\n')
cat('***********************\n')

cat('*defined colors\n')
 colrs <- colorRampPalette(c(
'darkblue',
'darkcyan',
'darkgoldenrod',
'darkgray',
'darkgreen'
))(5)

cat('*chart and titles\n')
barplot(pia_cols_rows_table_output$max, col=colrs,names = pia_cols_rows_table_output$max.col.name,
main = paste0("Max Primary Medical Code by 2 Digit Postcode \nfor ",args[1]," Benefit"))

cat('*Committing final map image to file\n')
dev.off() 
cat('\n*************************************************************\n')          
cat('*Loading the reference file from the shapefiles subdirectory*\n') 
cat('*************************************************************\n')
d2poareg = readOGR(dsn=paste0(getwd(),"/shapefiles"), layer="d2poareg")

cat('\nMerging reference mapping layer and step 2 dataset on D2PC\n')
m <- merge(d2poareg, pia_cols_rows_table_output, by='D2PC')
cat('\n******************************************************************************\n')
cat(paste0("*Merge reference mapping layer (merged_",args[1],".shp) to shapefiles subdirectory*\n"))
cat('******************************************************************************\n')

writeOGR(m, dsn = paste0(getwd(),"/shapefiles"), layer = paste0("merged_",args[1]), driver = "ESRI Shapefile", overwrite_layer = T)

cat('\n**************************************\n')
cat('*Subsetting merged mapping layer for:*\n') 
cat('**************************************\n')

cat('*CIR\n') 
cir_reg <- m[m$max.col.name == 'CIR',]
cat('*MUS\n') 
mus_reg <- m[m$max.col.name == 'MUS',]
cat('*ABI\n') 
abi_reg <- m[m$max.col.name == 'ABI',]
cat('*PSY\n') 
psy_reg <- m[m$max.col.name == 'PSY',]
cat('*RES\n') 
res_reg <- m[m$max.col.name == 'RES',]
cat('*INT\n') 
int_reg <- m[m$max.col.name == 'INT',]
cat('*CHR\n') 
chr_reg <- m[m$max.col.name == 'CHR',]

cat('\n*******************************************************************************\n')
cat(paste0("*Making a map file output: map_plot_",args[1],".png file in the images subdirectory\n"))
cat('*******************************************************************************\n')
png(file = paste0(getwd(),"/images/map_plot_a_",args[1],".png") ,width = 20, height = 15, units ="cm", res =600)

cat('\n********************\n')
cat('*Building map with:*\n') 
cat('********************\n')

cat('*merged mapping base layer\n') 
plot(m, xlim=c(117.5,154),ylim=c(-42.5,-10.5), col="grey" )
box()

cat('*subset CIR mapping layer\n') 
plot(cir_reg, col="coral", add=T)

cat('*subset MUS mapping layer\n')
plot(mus_reg, col="blue", add=T)

cat('*subset PSY mapping layer\n')
plot(psy_reg, col="cyan", add=T)

cat('*subset RES mapping layer\n')
plot(res_reg, col="beige", add=T)

cat('*subset ABI mapping layer\n')
plot(abi_reg, col="green", add=T)

cat('*subset INT mapping layer\n')
plot(int_reg, col="chocolate", add=T)

cat('*subset CHR mapping layer\n')
plot(chr_reg, col="aquamarine", add=T)

cat('*labels mapping layer\n')
text(centroid(d2poareg), labels=as.character(d2poareg$D2PC), col="black", cex=0.6, font=8, offset=0.5, adj=c(0,0))

cat('*map titles\n')
title(paste0("Max Primary Medical Code \nby 2 Digit Postcode for ",args[1]," Benefit"), sub = "Data for the quarter starting 1st April 2015 ending 30th June 2015\n provided for the purpose of demonstrating the ADA Dataverse R capability only\nfor the Priority Investment Approach (PIA) Synthetic data set.\nSome regional areas have small counts of medical conditions influencing their prominence.",
      cex.main = 2,   font.main= 4, col.main= "blue",
      cex.sub = 0.75, font.sub = 3, col.sub = "red")

cat('*map legend\n')
legend("topright",bty = "n",title = "Primary Medical Code",legend = c("CIR", "MUS","PSY","RES","ABI","INT","CHR","Other"), fill = c("coral","blue","cyan","beige","green","chocolate","aquamarine","grey"))

cat('*Committing final map image to file\n')
# Turn off device driver (to flush output to PNG)
dev.off()


#will remove ALL objects 
rm(list=ls()) 
        
cat('\nThe End\n')
