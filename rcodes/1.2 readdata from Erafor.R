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


####RUN##################

CounTable <- NULL
AgeHtTable <- NULL
BafTable <- NULL
HealTable <- NULL
InvTable <- NULL
for (i in 1:length(file_list)){
  indifile <- file.path(Erafordatapath,file_list[i])
  cat("Extract data from file", file_list[i], "\n")

  NoPlot <- length(getSheetNames(indifile))-2

  indinvdata <- read.xlsx(indifile,
                           sheet = "Inv",
                           colNames = FALSE,
                           detectDates = TRUE)
  tmp_agehtdata <- CreaAgeht(indinvdata)
  tmp_agehtdata <- cSplit(tmp_agehtdata,"Plot",sep = "&",direction = "long")
  tmp_agehtdata$Plot <- as.character(tmp_agehtdata$Plot)
  cat("  Age & Ht Table in opening", file_list[i], "is done. \n")


  for (indiplot in 1:NoPlot) {

    indiplotdata <- read.xlsx(indifile,
                              sheet = as.character(indiplot),
                              colNames = FALSE,
                              detectDates = TRUE) #extract the table for each plot


    if(!is.na(indiplotdata[1,3]) & is.element("BAF #", indiplotdata[19,1])){

        ####1. count table

        tmp_countdata <- CreaCounTable(indiplotdata)
        tmp_countdata[Layer %in% c("L1", "L2", "L1/2"), Layer := "L1/L2"]
        tmp_countdata[Layer %in% c("L3", "L4", "L3/4"), Layer := "L3/L4"]
        CounTable <- rbind(CounTable,tmp_countdata[tmp_countdata$Status=="T",])


        cat("    Count table in plot", indiplot, "is done. \n")

        ####2. BAF count table

        tmp_bafdata <- CreaBafTable(indiplotdata)
        BafTable <- rbind(BafTable, tmp_bafdata)

        cat("    BA measurement in plot", indiplot, "is done. \n")

        ####3. Forest health table

        tmp_helthdata <- CreaHealTable(indiplotdata)
        HealTable <- rbind(HealTable, tmp_helthdata)
        cat("    Health table in plot", indiplot, "is done. \n")

        indiopen <- indiplotdata[1,3]
    }
  }


  indiopen_countdata <- CounTable[Opening %in% indiopen]
  tmp_invdata <- merge(tmp_agehtdata,indiopen_countdata,by.x = c("Layer","Plot","SP"), by.y = c("Layer", "Plotid","Spp"), all = TRUE)
  setcolorder(tmp_invdata,c("Opening","Plot","Layer","CC","SP","PCT","Age","Ht","Count","Status"))
  tmp_invdata <- tmp_invdata[order(tmp_invdata$Plot)]
  tmp_invdata[, Opening := unique(Opening[!is.na(Opening)])]
  tmp_invdata[, Survey_Date := unique(Survey_Date[!is.na(Survey_Date)])[1]]
  tmp_invdata[, CC := unique(CC[!is.na(CC)]), by = c("Layer","Plot")]
  tmp_invdata[, Status := NULL]


  InvTable <- rbind(InvTable, tmp_invdata)

  cat("   Inv table in opening", file_list[i], "is done. \n")

}


####file save######

output <- list(BafTable = BafTable,
               HealTable = HealTable,
               InvTable = InvTable)

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


