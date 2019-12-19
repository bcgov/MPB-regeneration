#####read FFT data########

rm(list=ls())
#library(data.table)
library(openxlsx)
library(tidyr)
options(stringsAsFactors = FALSE)
##load all functions
source("./rcodes/2. readdata from fft_function.R")

## this is the path to all the raw data
datapath <- "\\\\orbital\\s63016\\!Workgrp\\Inventory\\MPB regeneration_WenliGrp\\raw data"
## this is the path to the compiled data at intermediate stage
## for example, count table you have extracted
datapath_compiled <- "\\\\orbital\\s63016\\!Workgrp\\Inventory\\MPB regeneration_WenliGrp\\compiled data"

fftdatapath <- file.path(datapath, "fft")
fftdatapath_compiled<-file.path(datapath_compiled,"fft")
file_list <- dir(fftdatapath, full.names = TRUE)

####RUN File Check first: check if all files are valid for compliation##########

FileCheck(file_list)

####Summarise tables from all avaliable fft files########
####Extract and rashape tables from FFT survey data:
#1. opening information -- Opening_Info;
#2. count table -- CounTable_T / CounTable_Silvi;
#3. ht-age table -- HtAgeTable_T / HtAgeTable_Silvi;
#4. baf table -- BafTable_All;
#5. forest health table -- HealTable_All

  Opening_Info <- NULL
  CounTable_T <- NULL
  CounTable_Silvi <- NULL
  HtAgeTable_T <- NULL
  HtAgeTable_Silvi <- NULL
  BafTable_All <- NULL
  HealTable_All <- NULL
  for (i in 1:length(file_list)){
    indifile <- file_list[i]
    reportTable <- read.xlsx(indifile,
                             sheet = "Report",
                             detectDates = TRUE) #extract the summary table of this opening
    ####extract opening information###
    opening_tmp<-data.frame(cbind(Opening = reportTable[1,5],
                                  Openingid = reportTable[2,5],
                                  Region = reportTable[3,5],
                                  District = reportTable[4,5],
                                  Location = reportTable[5,5],
                                  Date = reportTable[1,10],
                                  Lat = reportTable[3,16],
                                  Long = reportTable[4,16],
                                  Plot_size_m2 = reportTable[5,16],
                                  Area_ha = reportTable[8,5],
                                  plot_Number = reportTable[9,5],
                                  BEC = reportTable[8,10],
                                  SI = reportTable[22,18],
                                  Mortality = reportTable[57,3]))
    opening_tmp$Lat<-gsub(" ","",opening_tmp$Lat)
    opening_tmp$Lat<-gsub("º","°",opening_tmp$Lat)
    opening_tmp$Long<-gsub(" ","",opening_tmp$Long)
    opening_tmp$Long<-gsub("º","°",opening_tmp$Long)
    opening_tmp$Area_ha <- as.numeric(gsub(" ha", "", opening_tmp$Area_ha))
    opening_tmp$Plot_size_m2 <- as.numeric(gsub("m2","",opening_tmp$Plot_size_m2))
    opening_tmp$plot_Number <- as.numeric(opening_tmp$plot_Number)
    opening_tmp$SI <- round(as.numeric(opening_tmp$SI),digits = 0)
    opening_tmp$Mortality <- round(as.numeric(opening_tmp$Mortality),digits = 2)
    Opening_Info<- rbind(Opening_Info,opening_tmp)
    ####extract ht and age
    over<-reportTable[22,6]
    htage_over<-CreaHATable(over)
    OVER<-data.frame(Opening = reportTable[1,5],
                     Layer = "L1/L2",
                     htage_over)
    under<-reportTable[23,6]
    htage_under<-CreaHATable(under)
    UNDER<-data.frame(Opening = reportTable[1,5],
                      Layer = "L3/L4",
                      htage_under)
    htage_all<-rbind(OVER,UNDER)
    HtAgeTable_T<-rbind(HtAgeTable_T,htage_all)

    ####extract 1. count table 2. silvi ht-age table 3. baf table 4. forest health table
    NoPlot <- reportTable[9, 5]
    for (indiplot in 1:NoPlot) {
      indiplotdata <- read.xlsx(indifile,
                                sheet = as.character(indiplot),
                                colNames = FALSE,
                                detectDates = TRUE) #extract the table for each plot

      ## extract count table
      tmp_countdata <- CreaCounTable(indiplotdata)
      CounTable_T <- rbind(CounTable_T,tmp_countdata[tmp_countdata$Status=="T",])
      row.names(CounTable_T)<-NULL
      CounTable_Silvi <- rbind(CounTable_Silvi,tmp_countdata[tmp_countdata$Status!="T",])
      row.names(CounTable_Silvi)<-NULL

      ####2. Silvi Ht-Age table
      tmp_htagedata <- CreaHATable_Silvi(indiplotdata)
      HtAgeTable_Silvi <- rbind(HtAgeTable_Silvi, tmp_htagedata)

      ####3. BAF count table
      tmp_bafdata <- CreaBafTable(indiplotdata,reportTable)
      BafTable_All <- rbind(BafTable_All, tmp_bafdata)

      ####4. Forest health table
      tmp_helthdata <- CreaHealTable(indiplotdata)
      HealTable_All <- rbind(HealTable_All, tmp_helthdata)

    }
    rm(tmp_countdata, tmp_helthdata, tmp_bafdata, tmp_htagedata, opening_tmp,over,OVER,under,UNDER,htage_over,htage_under,htage_all)
  }

####save output to .csv or .drs#############################

  output <- list(Opening_Info = Opening_Info,
                 CounTable_T = CounTable_T,
                 CounTable_Silvi = CounTable_Silvi,
                 HtAgeTable_T = HtAgeTable_T,
                 HtAgeTable_Silvi = HtAgeTable_Silvi,
                 BafTable_All = BafTable_All,
                 HealTable_All = HealTable_All)
  save.file(output,
          savename = "fftcompile_2opening",
          saveformat = "rds")







