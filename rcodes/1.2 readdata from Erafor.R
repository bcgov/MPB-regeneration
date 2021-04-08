####Data from Erafor

rm(list=ls())
library(data.table)
library(openxlsx)
library(tidyr)
library(splitstackshape)
library(zoo)
library(dplyr)
options(stringsAsFactors = FALSE)

source("./rcodes/1.1 readdata from Erafor_function.R")

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
## for both the 93G045-573_2018_Recce_Plot_Data Sheet5 (DONE, has been modified: Sx was added for the live stem tallied)
## 93J004-179_2019_Recce_Plot_Data Sheet5 (No live species tallied, below ##RUN## has been modified to roll that sheet out)


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

  NoPlot <- suppressWarnings(as.numeric(getSheetNames(indifile)))
  NoPlot <- NoPlot[!is.na(NoPlot)]

  cat("Extracting data from opening", file_list[i], "\n")

  for (indiplot in NoPlot) {

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

####6. combine invtable with baftable 2020.Dec.11
### Correction: check the raw data to correct the uncorrect lables ("SxL1" and "X3") in Layer column

unique(BafTable$Layer)
#[1] "Dead"  "L1/L2" "SxL1"  "X3"

BafTable[Layer %in% "SxL1", Spp := "SX"]
BafTable[Layer %in% "SxL1", Layer := "L1/L2"]
BafTable <- BafTable[!Layer %in% "X3"]

##### Species labeled as "Missing" in dead layer in baftable change to be "Pli"
##### COrrection: the same species in the same layer should be added together in baftable

BafTable[Spp %in% "Missing" & Layer %in% "Dead", Spp := "Pli"]
BafTable <- BafTable[,.(Prismcount = sum(Count)), by= .(Opening, Plotid, Spp, Layer, BAF)]

InvTable <- merge(InvTable, BafTable, by.x = c("Opening", "Plot", "Layer", "SP"), by.y = c("Opening", "Plotid", "Layer", "Spp"), all = TRUE)

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

####fill NA value in SURVEY_DATE

opening <- InvTable_1[is.na(SURVEY_DATE), unique(Opening)]
test <- distinct(InvTable_1[Opening %in% opening, .(Opening, SURVEY_DATE)])
test <- test[!is.na(test$SURVEY_DATE)]
test1 <- InvTable_1[is.na(SURVEY_DATE), .(Opening, SURVEY_DATE)]
test1 <- merge(test1, test, by = "Opening")
InvTable_1[is.na(SURVEY_DATE), SURVEY_DATE := test1$SURVEY_DATE.y]

InvTable_1[,c("FID", "OBJECTID", "OPENING_ID", "SURVEY_TYP", "SOURCE", "Survey_Date", "Plot_status") := NULL]
setnames(InvTable_1, "PLOT_STATU", "Plot_status")
setnames(InvTable_1, "SURVEY_DATE", "Survey_Date")

####file save######

write.csv(HealTable,
          file.path(Erafordatapath_compiled,
                    "Eraforcompile_HealTable.csv"),
          row.names = FALSE)
write.csv(InvTable_1,
          file.path(Erafordatapath_compiled,
                    "Eraforcompile_InvTable.csv"),
          row.names = FALSE)


