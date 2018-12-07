#!/usr/bin/env Rscript
#scriptp1.R
# R script to create tabular output for for PIA synthetic csv data held in the dataverse system
# library for blind read of csv file vs R base version that has issues. the remainder of the R 
# libraries are installed at the end of the script.

args = commandArgs(trailingOnly=TRUE)

cat('********************\n')
cat('*Loading libraries:*\n')
cat('********************\n')

cat('*csvread\n')
if(!require("csvread")) {
install.packages("csvread", repos = "https://cran.csiro.au")
library(csvread)
}

cat('*feather\n')
if(!require("feather")) {
install.packages("feather", repos = "https://cran.csiro.au")
library(feather)
}

# for simple frequency tables
cat('*plyr\n')
if (!require("plyr")) {
install.packages("plyr", repos = "https://cran.csiro.au")
library(plyr)
}

cat('*dataverse\n') 

if(!require("dataverse")) {
install.packages("dataverse", repos = "https://cran.csiro.au")
library(dataverse)
}

cat('\n***************************************************************\n')
cat('*Settings for ADA Dataverse server http://dataverse.ada.edu.au*\n')
cat('***************************************************************\n')

cat('*Server name\n')
Sys.setenv("DATAVERSE_SERVER" ="dataverse.ada.edu.au")

cat('*Server key\n')
Sys.setenv("DATAVERSE_KEY" ="YOUR-KEY")

cat('\n*********************\n')
cat('\n*Directory structure*\n')
cat('\n*********************\n')

cat('*tables: source and intermediate tables\n')
if (file.exists(paste0(getwd(),"/tables"))){	
} else {
dir.create("tables")
}

cat('*images: screenshots, plots and maps\n')
if (file.exists(paste0(getwd(),"/images"))){	
} else {
dir.create("images")
}

cat('*shapefiles: mapping reference files\n')
if (file.exists(paste0(getwd(),"/shapefiles"))){	
} else {
dir.create("shapefiles")
}

cat('*dataset xlsx data dictionary and other documents\n')
if (file.exists(paste0(getwd(),"/documentation"))){	
} else {
dir.create("documentation")
}

cat('\nSearching dataverse for the word approach\n')
dataverse_search("Approach")[c("name")]

cat('\nListing available files in the PIA Synthtetic data set\n')
(dataset <- get_dataset("doi:10.4225/87/FASD1J"))

cat('\nViewing metadata for PIA Synthetic data set\n')
str(dataset_metadata("doi:10.4225/87/FASD1J"),1)

cat('\nDownloading one of the csv files from the data set doi:10.4225/87/FASD1J\n')
piadata <- get_file("synthetic_pia_csv_qtr_2015-04-01.csv.zip", "doi:10.4225/87/FASD1J")
writeBin(piadata,"synthetic_pia_csv_qtr_2015-04-01.csv.zip")

cat('\nUnziping the files\n')
unzip("synthetic_pia_csv_qtr_2015-04-01.csv.zip", exdir="tables")

at('\nDownloading the mapping files from the data set doi:10.4225/87/FASD1J\n')
piadata <- get_file("d2poareg.zip", "doi:10.4225/87/FASD1J")
writeBin(piadata,"d2poareg.zip")

cat('\nUnziping the files\n')
unzip("d2poareg.zip",exdir="shapefiles")

cat('\n**********************************************************************\n')
cat('*Loading file converted from csv to R format from tables subdirectory*\n')
cat('**********************************************************************\n')

pia <- csvread(file="tables/synthetic_pia_csv_qtr_2015-04-01.csv", 
coltypes = c(
"string",
"string",
"integer",
"integer",
"string",
"string",
"string",
"string",
"integer",
"string",
"string",
"string",
"string",
"string",
"string",
"string",
"string",
"string",
"string",
"string",
"string",
"string",
"string",
"integer",
"integer",
"string",
"string",
"string",
"string",
"string",
"string" ),
header = T,
delimiter = ",",
na.strings = "EMPTY")

attach(pia)

cat('\nStarting off with the original 31 columns\n')
names(pia)
cat('\n****************\n')
cat('*Trimming data:*\n')
cat('****************\n')

cat('*QTR_START_DATE as date values\n')
pia$QTR_START_DATE <- as.Date(pia$QTR_START_DATE, format = "%Y-%m-%d")
print(count(pia, 'QTR_START_DATE'))
cat('\n')

cat('*QTR_END_DATE as date values\n')
pia$QTR_END_DATE <- as.Date(pia$QTR_END_DATE, format = "%Y-%m-%d")
print(count(pia, 'QTR_END_DATE'))
cat('\n')

cat('*BEN_TYPE_CODE as character length of 3\n')
pia$BEN_TYPE_CODE <- substr(pia$BEN_TYPE_CODE, start = 1, stop = 3)
print(count(pia, 'BEN_TYPE_CODE'))
cat('\n')

cat('*BIRTH_SACC_CODE as numeric values\n')
pia$BIRTH_SACC_CODE <- as.numeric(as.character(pia$BIRTH_SACC_CODE))
print(summary(pia$BIRTH_SACC_CODE))
cat('\n')

cat('*POSTCODE as numeric values\n')
pia$POSTCODE <- as.numeric(substr(pia$POSTCODE, start = 1, stop = 4))
print(summary(pia$POSTCODE))
cat('\n')

cat('*DOB_SHORT as numeric values\n')
pia$DOB_SHORT <- as.numeric(substr(pia$DOB_SHORT, start = 1, stop = 4))
print(summary(pia$DOB_SHORT))
cat('\n')

cat('*ADDR_SACC_CODE as numeric values\n')
pia$ADDR_SACC_CODE <- as.numeric(as.character(pia$ADDR_SACC_CODE))
print(summary(pia$ADDR_SACC_CODE))
cat('\n')

cat('*INDIG_STS as character length of 1\n')
pia$INDIG_STS <- substr(pia$INDIG_STS, start = 1, stop = 1)
print(count(pia, 'INDIG_STS'))
cat('\n')

cat('*GENDER as character length of 1\n')
pia$GENDER <- substr(pia$GENDER, start = 1, stop = 1)
print(count(pia, 'GENDER'))
cat('\n')

cat('*BEN_STS_CODE as character length of 1\n')
pia$BEN_STS_CODE <- substr(pia$BEN_STS_CODE, start = 1, stop = 1)
print(count(pia, 'BEN_STS_CODE'))
cat('\n')

cat('*REFUGEE_STS as character length of 1\n')
pia$REFUGEE_STS <- substr(pia$REFUGEE_STS, start = 1, stop = 1)
print(count(pia, 'REFUGEE_STS'))
cat('\n')

cat('*MARITAL_STS_CODE as character length 3\n')
pia$MARITAL_STS_CODE <- substr(pia$MARITAL_STS_CODE, start = 1, stop = 3)
print(count(pia, 'MARITAL_STS_CODE'))
cat('\n')

cat('*PTNR_DOB_SHORT as numeric values\n')
pia$PTNR_DOB_SHORT <- as.numeric(substr(pia$PTNR_DOB_SHORT, start = 1, stop = 4))
print(summary(pia$PTNR_DOB_SHORT))
cat('\n')

cat('*PTNR_BIRTH_SACC_CODE as numeric\n')
pia$PTNR_BIRTH_SACC_CODE <- as.numeric(as.character(pia$PTNR_BIRTH_SACC_CODE))
print(summary(pia$PTNR_BIRTH_SACC_CODE))
cat('\n')

cat('*PTNR_BEN_TYPE_CODE as character length of 3\n')
pia$PTNR_BEN_TYPE_CODE <- substr(pia$PTNR_BEN_TYPE_CODE, start = 1, stop = 3)
print(count(pia, 'PTNR_BEN_TYPE_CODE'))
cat('\n')

cat('*PTNR_GENDER as character length of 1\n')
pia$PTNR_GENDER <- substr(pia$PTNR_GENDER, start = 1, stop = 1)
print(count(pia, 'PTNR_GENDER'))
cat('\n')

cat('*PTNR_INDIG_STS as character length of 1\n')
pia$PTNR_INDIG_STS <- substr(pia$PTNR_INDIG_STS, start = 1, stop = 1)
print(count(pia, 'PTNR_INDIG_STS'))
cat('\n')

cat('*PTNR_REFUGEE_STS as character length of 1\n')
pia$PTNR_REFUGEE_STS <- substr(pia$PTNR_REFUGEE_STS, start = 1, stop = 1)
print(summary(pia$PTNR_REFUGEE_STS))
cat('\n')

cat('*LANG_CODE as character length of 3\n')
pia$LANG_CODE <- substr(pia$LANG_CODE, start = 1, stop = 3)
print(summary(pia$LANG_CODE))
cat('\n')

cat('*EDU_LVL_ATTAIN_CODE as character length of 3\n')
pia$EDU_LVL_ATTAIN_CODE <- substr(pia$EDU_LVL_ATTAIN_CODE, start = 1, stop = 3)
print(count(pia, 'EDU_LVL_ATTAIN_CODE'))
cat('\n')

cat('*PRMY_MED_CODE\n')
pia$PRMY_MED_CODE <- substr(pia$PRMY_MED_CODE, start = 1, stop = 3)
print(count(pia, 'PRMY_MED_CODE'))
cat('\n')

cat('*NUM_OF_IOP_EARN_SOURCE as numeric values\n')
pia$NUM_OF_IOP_EARN_SOURCE <- as.numeric(as.character(pia$NUM_OF_IOP_EARN_SOURCE))
print(summary(pia$NUM_OF_IOP_EARN_SOURCE))
cat('\n')

cat('*NUM_OF_CON_EARN_SOURCE as numeric values\n')
pia$NUM_OF_CON_EARN_SOURCE <- as.numeric(as.character(pia$NUM_OF_CON_EARN_SOURCE))
print(summary(pia$NUM_OF_CON_EARN_SOURCE))
cat('\n')

cat('*ACCOM_CODE as character length of 3\n')
ACCOM_CODE <- substr(pia$ACCOM_CODE, start = 1, stop = 3)
print(count(pia, 'ACCOM_CODE'))
cat('\n')

cat('*NUM_FTB_CHILD as numeric values\n')
pia$NUM_FTB_CHILD <- as.numeric(substr(pia$NUM_FTB_CHILD, start = 1, stop = 2))
print(summary(pia$NUM_FTB_CHILD))
cat('\n')

cat('*NUM_RCC_CHILD as numeric values\n')
pia$NUM_RCC_CHILD <- as.numeric(substr(pia$NUM_RCC_CHILD, start = 1, stop = 2))
print(summary(pia$NUM_RCC_CHILD))
cat('\n')

cat('*YGEST_FTB_CHD_DOB_SHORT as numeric values\n')
pia$YGEST_FTB_CHD_DOB_SHORT <- as.numeric(substr(pia$YGEST_FTB_CHD_DOB_SHORT, start = 1, stop = 4))
print(summary(pia$YGEST_FTB_CHD_DOB_SHORT))
cat('\n')

cat('*YGEST_RCC_CHD_DOB_SHORT as numeric values\n')
pia$YGEST_RCC_CHD_DOB_SHORT <- as.numeric(substr(pia$YGEST_RCC_CHD_DOB_SHORT, start = 1, stop = 4))
print(summary(pia$YGEST_RCC_CHD_DOB_SHORT))
cat('\n')

cat('*RSN_CODE as character length of 3\n')
pia$RSN_CODE <- substr(pia$RSN_CODE, start = 1, stop = 3)
print(count(pia, 'RSN_CODE'))
cat('\n')

cat('\nSaving as R format to tables subdirectory\n')
write_feather(pia, paste0(getwd(),"/tables/synthetic_pia_R_qtr_2015-04-01.feather"))

#will remove ALL objects 
rm(list=ls()) 

cat('\n***********************************\n')
cat('*Loading the rest of the R Libraries*\n')
cat('***********************************\n')


cat('\n***********************************\n')
cat('*Loading the rest of the R Libraries*\n')
cat('**********************************\n')

cat('*feather\n')
if (!require("feather")) {
install.packages("feather", repos = "https://cran.csiro.au")
}

# for nice tibble based frequency and progortion tables. Keep away from large data sets.
cat('*dplyr\n')
if (!require("dplyr")) {
install.packages("dplyr", repos = "https://cran.csiro.au")
}

#for reshaping spatial data sets and neededfor rgdal library
cat('*rgeos\n')
if (!require("rgeos")) {
install.packages("rgeos", repos = "https://cran.csiro.au")
library(rgeos)
}

#for loading/saving data sets and needed for sf library
cat('*rgdal\n')
if (!require("rgeos")) {
install.packages("rgeos", repos = "https://cran.csiro.au")
library(rgdal)
}

#for nicer maps than R base mapping
cat('*sf\n')
if (!require("sf")) {
install.packages("sf", repos = "https://cran.csiro.au")
library(sf)
}

#for nicer tibble based maps
cat('*ggplot2\n')
if (!require("ggplot2")) {
install.packages("ggplot2", repos = "https://cran.csiro.au")
library(ggplot2)
}

#for crop map image
cat('*raster\n')
if (!require("raster")) {
install.packages("raster", repos = "https://cran.csiro.au")
}

#for map labels base R mapping
cat('*geosphere\n')
if (!require("geosphere")) {
install.packages("geosphere", repos = "https://cran.csiro.au")
}


cat('\nThe End\n')

