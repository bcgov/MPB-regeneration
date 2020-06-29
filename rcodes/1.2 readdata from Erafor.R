####Data from Erafor
rm(list=ls())
library(data.table)
library(openxlsx)
library(tidyr)
library(splitstackshape)
library(zoo)
options(stringsAsFactors = FALSE)

source("./rcodes/2. readdata from fft_function.R")

datapath <- "\\\\orbital\\s63016\\!Workgrp\\Inventory\\MPB regeneration_WenliGrp\\raw data"
datapath_compiled <- "\\\\orbital\\s63016\\!Workgrp\\Inventory\\MPB regeneration_WenliGrp\\compiled data"

Erafordatapath <- file.path(datapath, "From Erafor")
Erafordatapath_compiled<-file.path(datapath_compiled,"From Erafor")

file_list <- dir(Erafordatapath, pattern = ".xlsx", full.names = FALSE)

file_list <- file_list[substr(file_list, 1, 2) != "~$"] # remove this file

####File Check##########

invalid_file<-NULL
valid_file<-NULL
cat("Check files. \n")
for (i in 1:length(file_list)){
  indifile <- file.path(Erafordatapath, file_list[i])

  cat("   File: ", file_list[i], "\n")
  NoPlot <- suppressWarnings(as.numeric(getSheetNames(indifile)))
  NoPlot <- NoPlot[!is.na(NoPlot)]
  invplot <- NULL
  vplot <- NULL

  for (indiplot in NoPlot){
    indiplotdata <- read.xlsx(indifile,
                              sheet = as.character(indiplot),
                              colNames = FALSE,
                              detectDates = TRUE)

    if(!is.na(indiplotdata[1,3])){
      if(!is.element("BASAL Data",indiplotdata[21,9])){
        test2 <- c(indiplotdata[1:19,1] == c("Opening #:", "Spp", "L1 (T)", "L1 (W)",
                                             "L1 (F)", "L2 (T)", "L2 (W)", "L2 (F)",
                                             "L3/4 (T)", "L3/4 (W)", "L3/4 (F)", NA,
                                             "L1 Ht", "L1 Age", "L2 Ht", "L2 Age",
                                             "L3/4 Ht", "L3/4 Age", "BAF #"),
                   indiplotdata[1,8] == "Plot #:",
                   indiplotdata[1,10] == "Date:",
                   indiplotdata[2,9] == "FOREST HEALTH")
      }else{
        test2 <- c(indiplotdata[1:19,1] == c("Opening #:", "Spp", "L1 (T)", "L1 (W)",
                                             "L1 (F)", "L2 (T)", "L2 (W)", "L2 (F)",
                                             "L3/4 (T)", "L3/4 (W)", "L3/4 (F)", NA,
                                             "L1 Ht", "L1 Age", "L2 Ht", "L2 Age",
                                             "L3/4 Ht", "L3/4 Age", "BAF #"),
                   indiplotdata[1,8] == "Plot #:",
                   indiplotdata[1,11] == "Date:",
                   indiplotdata[2,10] == "FOREST HEALTH")
      }

      if (is.element("FALSE",test2)){
        invplot <- c(invplot,
                     paste0(gsub(".xlsx", "", file_list[i]),
                            "_sheet", indiplot))
      } else{
        vplot <- c(vplot,indiplot)
      }
      cat("      Sheet:", indiplot, " ... done. \n")
    }

    if (length(vplot) == NoPlot){
      valid_file <- c(valid_file, file_list[i])
    }else {
      invalid_file <- c(invalid_file,invplot)
    }
  }
}


if (length(invalid_file != 0)){
  print(unique(invalid_file))
}else {
  message ("all files pass file check")
}
## need manual check for these two sheets
## for both the 93G045-573_2018_Recce_Plot_Data Sheet5
## 93J004-179_2019_Recce_Plot_Data Sheet5
## the species in row 12 is missing
## Manually typed in Unknown for the species, need to check back
## with the source

#########################
####RUN##################
#########################

CounTable <- NULL
AgeHtTable <- NULL
BafTable <- NULL
HealTable <- NULL
for (i in 1:length(file_list)){
  indifile <- file.path(Erafordatapath,file_list[i])
  cat("Extract data from file", file_list[i], "\n")

  NoPlot <- length(getSheetNames(indifile))-2

  cat("Extracting data from opening", file_list[i], "\n")

  for (indiplot in 1:NoPlot) {

    indiplotdata <- read.xlsx(indifile,
                              sheet = as.character(indiplot),
                              colNames = FALSE,
                              detectDates = TRUE) #extract the table for each plot


    if(!is.na(indiplotdata[1,3]) & is.element("BAF #", indiplotdata[19,1])){

      ####1. count table

      tmp_countdata <- CreaCounTable(indiplotdata)
      CounTable <- rbind(CounTable, tmp_countdata[Status %in% "T"])

      cat("    Count table in plot", indiplot, "is done. \n")

      ####2. Age-Ht table

      tmp_agehtdata <- CreaAgeHtTable(indiplotdata)
      AgeHtTable <-rbind(AgeHtTable, tmp_agehtdata)

      cat("  Age & Ht Table in plot", indiplot, "is done. \n")

      ####3. BAF count table

      tmp_bafdata <- CreaBafTable(indiplotdata)
      BafTable <- rbind(BafTable, tmp_bafdata)

      cat("    BA measurement in plot", indiplot, "is done. \n")

      ####4. Forest health table

      tmp_helthdata <- CreaHealTable(indiplotdata)
      HealTable <- rbind(HealTable, tmp_helthdata)
      cat("    Health table in plot", indiplot,  "is done. \n")

    }
  }
  cat("Data extraction for opening", file_list[i], "is finished. \n")
}



####5. combine count table and age-ht table together to create an inventory table

InvTable <- merge(CounTable,AgeHtTable, by.x = c("Opening","Plotid","Layer","Spp"), by.y = c("Opening","Plotid","Layer","Species"), all = TRUE)
InvTable[,Status := NULL]
setnames(InvTable,"Plotid","Plot")
setnames(InvTable,"Spp","SP")
setcolorder(InvTable,c("Opening","Plot","Layer","SP","Age","Ht","Count"))

####Add Lat and Long information in InvTable####

latlong <- as.data.table(read.table(file.path(Erafordatapath,"Plots information.txt"), sep = ",", header = TRUE))

InvTable_1 <- merge(InvTable, latlong, by.x = c("Opening","Plot"), by.y = c("OPENING_NU", "PLOT_LABEL"), all = TRUE)

InvTable_1$SURVEY_DAT <- gsub(" 0:00:00", "", InvTable_1$SURVEY_DAT)
InvTable_1 <- separate(InvTable_1,
                       col = SURVEY_DAT,
                       into = "SURVEY_DATE",
                       sep = "/",
                       extra = "drop")

InvTable_1[SURVEY_DATE %in% "1899", SURVEY_DATE := Survey_Date]
InvTable_1[SURVEY_DATE %in% "", SURVEY_DATE := Survey_Date]
InvTable_1[which(is.na(InvTable_1$SURVEY_DATE)), SURVEY_DATE := Survey_Date]
InvTable_1 <- separate(InvTable_1,
                       col = SURVEY_DATE,
                       into = "SURVEY_DATE",
                       sep = "-",
                       extra = "drop")
InvTable_1[SURVEY_DATE %in% "18/06/18", SURVEY_DATE := "2018"]
InvTable_1[SURVEY_DATE %in% NA, SURVEY_DATE := "2018"]

InvTable_1[,c("FID", "OBJECTID", "OPENING_ID", "SURVEY_TYP", "SOURCE", "Survey_Date") := NULL]
setnames(InvTable_1, "PLOT_STATU", "Plot_status")
setnames(InvTable_1, "SURVEY_DATE", "Survey_Date")

####file save######

output <- list(BafTable = BafTable,
               HealTable = HealTable,
               InvTable = InvTable_1)

write.csv(output$BafTable,
          file.path(Erafordatapath_compiled,
                    paste0("Eraforcompile_BafTable.csv")),
          row.names = FALSE)
write.csv(output$HealTable,
          file.path(Erafordatapath_compiled,
                    paste0("Eraforcompile_HealTable.csv")),
          row.names = FALSE)
write.csv(output$InvTable,
          file.path(Erafordatapath_compiled,
                    paste0("Eraforcompile_InvTable.csv")),
          row.names = FALSE)
