#!/usr/bin/env Rscript
#script2.R
args = commandArgs(trailingOnly=TRUE)
# R script to create tabular output for for pia_cols synthetic csv data held in the dataverse system
# part 2 processing the column subset files from the dataverse download 
#
cat('********************\n')
cat('*Loading libraries:*\n')
cat('********************\n')

cat('*feather\n')
if(!require("feather")) {
install.packages("feather", repos = "https://cran.csiro.au")
library(feather)
}

cat('*plyr\n')
if(!require("plyr")) {
install.packages("plyr", repos = "https://cran.csiro.au")
library(plyr)
}

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  # default output benefit type
  args[1] = "NSA"
}

cat('\n****************************************************************\n')
cat(paste0("*Reading in file from part 1, processing records for ",args[1]," from the tables subdirectory*\n"))
cat('*****************************************************************\n')

pia_cols <- read_feather(paste0(getwd(),"/tables/synthetic_pia_R_qtr_2015-04-01.feather"), columns = c("QTR_START_DATE" , "POSTCODE", "BEN_TYPE_CODE", "PRMY_MED_CODE", "DOB_SHORT", "PTNR_DOB_SHORT","YGEST_FTB_CHD_DOB_SHORT","YGEST_RCC_CHD_DOB_SHORT"))
attach(pia_cols)

cat('\n****************************************************************\n')
cat('*Subsetting the pia_cols data frame by the BEN_TYPE_CODE value*\n')
cat('***************************************************************\n')

pia_cols_sub <- subset(pia_cols,BEN_TYPE_CODE == args[1] )

rm(pia_cols)


cat('\n*********************************************\n')
cat('*Adding two digit postcode to pia data frame*\n')
cat('*********************************************\n')

pia_cols_sub$D2PC <- round(pia_cols_sub$POSTCODE/100, digits = 0)

cat('min and max value\n')
print(range(pia_cols_sub$D2PC,na.rm=TRUE))
cat('\n')

cat('*NSW non delivery areas mapped back to delivery area 20xx (2000-2099)\n')
pia_cols_sub$D2PC[pia_cols_sub$D2PC > 9 & pia_cols_sub$D2PC < 20] = 20

cat('*ACT non delivery areas mapped back to delivery area 26xx (2600-2699)\n')
pia_cols_sub$D2PC[pia_cols_sub$D2PC == 2] = 26

cat('*VIC non delivery areas mapped back to delivery area 30xx (3000-3099)\n')
pia_cols_sub$D2PC[pia_cols_sub$D2PC > 79 & pia_cols_sub$D2PC < 90] = 30

cat('*QLD non delivery areas mapped back to delivery area 40xx (4000-4099)\n')
pia_cols_sub$D2PC[pia_cols_sub$D2PC > 89 & pia_cols_sub$D2PC < 100] = 40

cat('*SA non delivery areas mapped back to delivery area 50xx (5000-5099)\n')
pia_cols_sub$D2PC[pia_cols_sub$D2PC > 57 & pia_cols_sub$D2PC < 60] = 50

cat('*WA non delivery areas mapped back to delivery area 60xx (6000-6099)\n')
pia_cols_sub$D2PC[pia_cols_sub$D2PC > 67 & pia_cols_sub$D2PC < 70] = 60

cat('*TAS non delivery areas mapped back to delivery area 70xx (7000-7099)\n')
pia_cols_sub$D2PC[pia_cols_sub$D2PC > 77 & pia_cols_sub$D2PC < 80] = 70

cat('*NT non delivery areas mapped back to delivery area 8xx (0800-0899)\n')
pia_cols_sub$D2PC[pia_cols_sub$D2PC == 9] = 8

cat('*Other non standard delivery areas mapped to non mapped areas\n')
pia_cols_sub$D2PC[pia_cols_sub$D2PC > 9 & pia_cols_sub$D2PC < 19] = 1

cat('min and max value\n')
print(range(pia_cols_sub$D2PC,na.rm=TRUE))
cat('\n')

cat('\n********************************\n')
cat('*Adding STATE to pia data frame*\n')
cat('********************************\n')
pia_cols_sub$STATE = NA

cat('*New South Wales (NSW)             *\n')
cat('*between 2000 and 2599\n')
pia_cols_sub$STATE[pia_cols_sub$POSTCODE>1999 & pia_cols_sub$POSTCODE <2600] = 1
cat('*between 2619 and 2899\n')
pia_cols_sub$STATE[pia_cols_sub$POSTCODE>2618 & pia_cols_sub$POSTCODE <2900] = 1
cat('*between 2921 and 2999\n')
pia_cols_sub$STATE[pia_cols_sub$POSTCODE>2920 & pia_cols_sub$POSTCODE <3000] = 1

cat('*Australian Capital Territory (ACT)*\n')
cat('*between 2600 and 2618\n')
pia_cols_sub$STATE[pia_cols_sub$POSTCODE>2599 & pia_cols_sub$POSTCODE <2619] = 8
cat('*between 2900 and 2920\n')
pia_cols_sub$STATE[pia_cols_sub$POSTCODE>2899 & pia_cols_sub$POSTCODE <2921] = 8

cat('*Victoria (VIC)                    *\n')
cat('*between 3000 and 3999\n')
pia_cols_sub$STATE [pia_cols_sub$POSTCODE>2999 & pia_cols_sub$POSTCODE <4000] = 2

cat('*Queensland (QLD)                  *\n')
cat('*between 4000 and 4999\n')
pia_cols_sub$STATE[pia_cols_sub$POSTCODE>3999 & pia_cols_sub$POSTCODE <5000] =3

cat('*South Australia (SA)              *\n')
cat('*between 5000 and 5999\n')
pia_cols_sub$STATE[pia_cols_sub$POSTCODE>4999 & pia_cols_sub$POSTCODE <6000] = 4

cat('*Western Australia (WA)            *\n')
cat('*between 6000 and 6999\n')
pia_cols_sub$STATE[pia_cols_sub$POSTCODE>5999 & pia_cols_sub$POSTCODE <7000] = 5

cat('*Tasmania (TAS)                    *\n')
cat('*between 7000 and 7999\n')
pia_cols_sub$STATE[pia_cols_sub$POSTCODE>6999 & pia_cols_sub$POSTCODE <8000] = 6

cat('*Northern Territory (NT)           *\n')
pia_cols_sub$STATE[pia_cols_sub$POSTCODE>799 & pia_cols_sub$POSTCODE <1000] = 7

print(count(pia_cols_sub, 'STATE'))
cat('\n')
#running out of memory here
gc()
cat('\n**********************************************\n')
cat('*Adding age based variables to pia data frame*\n')
cat('**********************************************\n')

cat('*The year value from the QTR_START_DATE to QTR_YEAR\n')
pia_cols_sub$QTR_YEAR <- as.numeric(format(pia_cols_sub$QTR_START_DATE, "%Y"))
print(range(pia_cols_sub$QTR_YEAR,na.rm=TRUE))
cat('\n')

cat('*The year value from QTR_START_DATE and DOB_SHORT to QTR_AGE\n')
pia_cols_sub$QTR_AGE<- pia_cols_sub$QTR_YEAR-pia_cols_sub$DOB_SHORT
print(range(pia_cols_sub$QTR_AGE,na.rm=TRUE))
cat('\n')

cat('*The year value from QTR_START_DATE and PTNR_DOB_SHORT to QTR_PTNR_AGE\n')
pia_cols_sub$QTR_PTNR_AGE<- pia_cols_sub$QTR_YEAR-pia_cols_sub$PTNR_DOB_SHORT
print(range(pia_cols_sub$QTR_PTNR_AGE,na.rm=TRUE))
cat('\n')

cat('*The year value from QTR_START_DATE and YGEST_RCC_CHD_DOB_SHORT to QTR_YGEST_RCC_CHD_AGE\n')
pia_cols_sub$QTR_YGEST_RCC_CHD_AGE<- pia_cols_sub$QTR_YEAR-pia_cols_sub$YGEST_RCC_CHD_DOB_SHORT
print(range(pia_cols_sub$QTR_YGEST_RCC_CHD_AGE,na.rm=TRUE))
cat('\n')

cat('*The year value from QTR_START_DATE and YGEST_FTB_CHD_DOB_SHORT to QTR_YGEST_FTB_CHD_AGE\n')
pia_cols_sub$QTR_YGEST_FTB_CHD_AGE<- pia_cols_sub$QTR_YEAR-pia_cols_sub$YGEST_FTB_CHD_DOB_SHORT
print(range(pia_cols_sub$QTR_YGEST_FTB_CHD_AGE,na.rm=TRUE))
cat('\n')


cat('/n************************\n')
cat('*create the first table*\n')
cat('************************\n')

pia_cols_rows_table <- as.data.frame(unclass(table(pia_cols_sub$D2PC,pia_cols_sub$PRMY_MED_CODE)))

colnames(pia_cols_rows_table)[1] <- "D2PC"
pia_cols_rows_table$D2PC <- rownames(pia_cols_rows_table)

cat('*See what the first table looks like\n')
names(pia_cols_rows_table)

cat('*create joining table\n')
cat('*grab the first column name and values\n') 
pia_cols_rows_table_xtra <- pia_cols_rows_table["D2PC"]

# change the first column name back to D2PC
names(pia_cols_rows_table_xtra) <- c( "D2PC")

cat('*Add ID column to joining table (pia_cols_rows_table_xtra)\n')
pia_cols_rows_table_xtra$ID <- seq.int(nrow(pia_cols_rows_table_xtra))

# return the two digit postcodes to the D2PC column values
pia_cols_rows_table_xtra$D2PC <- rownames(pia_cols_rows_table)

#cat('*Remove the two digit postcode column to allow for the next process
pia_cols_rows_table$D2PC <- NULL

cat('\n*****************************\n')
cat('*Processing the second table*\n')
cat('*****************************\n')

pia_cols_rows_table_out <- as.data.frame(unclass(cbind(pia_cols_rows_table, max=apply(pia_cols_rows_table,1,max),
max.col.num= apply(pia_cols_rows_table,1,which.max) , 
max.col.name= names(pia_cols_rows_table)[apply(pia_cols_rows_table,1,which.max)] )))

cat('*Add sequence number to pia_cols_rows_table_out (table 2)')
pia_cols_rows_table_out$ID <- seq.int(nrow(pia_cols_rows_table_out))

cat('\n*******************************\n')
cat('*Merge D2PC to second table results*\n')
cat('*******************************\n')
pia_cols_rows_table_merge <- pia_cols_rows_table_out
pia_cols_rows_table_merge <- merge(pia_cols_rows_table_merge,pia_cols_rows_table_xtra, by.x="ID",by.y="ID",allx="T")


cat('\n*********************************************************************\n')
cat('*second table columns reduced to what is needed for the next scripts*\n')
cat('*********************************************************************\n')

pia_cols_rows_table_output <- data.frame(pia_cols_rows_table_merge$D2PC,
pia_cols_rows_table_merge$max, pia_cols_rows_table_merge$max.col.name)

names(pia_cols_rows_table_output)[1] <- "D2PC"
names(pia_cols_rows_table_output)[2] <- "max"
names(pia_cols_rows_table_output)[3] <- "max.col.name"

cat('*Results to screen\n')
pia_cols_rows_table_output

cat(paste0("\n*Writing output to file pia_cols_output_",args[1],"_2015-04-01.feather to the tables subdirectory\n"))
write_feather(pia_cols_rows_table_output, paste0(getwd(),"/tables/pia_cols_rows_output_",args[1],"_2015-04-01.feather")) 

#will remove ALL objects 
rm(list=ls()) 
        
cat('\nThe End\n')

