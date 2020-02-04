#####read FFT data########

rm(list=ls())
library(data.table)
library(openxlsx)
library(tidyr)
options(stringsAsFactors = FALSE)

##load all functions

source("./rcodes/2. readdata from fft_function.R")

## this is the path to all raw data

datapath <- "\\\\orbital\\s63016\\!Workgrp\\Inventory\\MPB regeneration_WenliGrp\\raw data"

## this is the path to the compiled data at intermediate stage

datapath_compiled <- "\\\\orbital\\s63016\\!Workgrp\\Inventory\\MPB regeneration_WenliGrp\\compiled data"

fftdatapath <- file.path(datapath, "fft")
fftdatapath_compiled<-file.path(datapath_compiled,"fft")
file_list <- dir(fftdatapath, full.names = FALSE)

################################################################################
####RUN File Check first: check if all files are valid for compilation##########
################################################################################

invalid_file<-NULL
valid_file<-NULL
cat("Check files. \n")
for (i in 1:length(file_list)){
  indifile <- file.path(fftdatapath, file_list[i])

  cat("   File: ", file_list[i], "\n")

  if (any(is.element(c("Report",1:20),
                     getSheetNames(indifile)) == FALSE)){
    invalid_file <- c(invalid_file, file_list[i])
  }else{
    reportTable <- read.xlsx(indifile,
                             sheet="Report",
                             colNames = TRUE,
                             detectDates = TRUE)
    test1 <- c(names(reportTable)[1] == "Opening.Information",
               ncol(reportTable) == 20,
               reportTable[c(1:5,8,9),3] == c("OPENING:", "OPENING ID:", "REGION:", "DISTRICT:  ", "LOCATION:", "AREA:", "# OF PLOTS:"),
               reportTable[1,8] == "DATE:",
               reportTable[8,7] == "BEC ZONE:",
               reportTable[3:5,13] == c("LATITUDE:", "LONGITUDE:", "PLOT SIZE:"),
               reportTable[21,18] == "SI",
               reportTable[57,2]  == "% Host",
               reportTable[22:24,2] == c("OS INVENTORY LABEL:", "US INVENTORY LABEL:", "SILVICULTURE LABEL:"))
    cat("      Sheet: Report ... done. \n")
    if (is.element("FALSE",test1)){
      invalid_file <- c(invalid_file, paste0(file_list[i], "_", "Report"))
    } else{
      NoPlot <- reportTable[9, 5]
      invplot <- NULL
      vplot <- NULL
      for (indiplot in 1:NoPlot){

        indiplotdata <- read.xlsx(indifile,
                                  sheet = as.character(indiplot),
                                  colNames = FALSE,
                                  detectDates = TRUE)
        test2 <- c(indiplotdata[1:19,1] == c("Opening #:", "Spp", "L1 (T)", "L1 (W)", "L1 (F)", "L2 (T)", "L2 (W)", "L2 (F)", "L3/4 (T)", "L3/4 (W)", "L3/4 (F)", NA, "L1 Ht", "L1 Age", "L2 Ht", "L2 Age", "L3/4 Ht", "L3/4 Age", "BAF #"),
                   indiplotdata[1,8] == "Plot #:",
                   indiplotdata[1,10] == "Date:",
                   indiplotdata[2,9] == "FOREST HEALTH")
        if (is.element("FALSE",test2)){
          invplot <- c(invplot, paste0(file_list[i], "_", indiplot))
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
}

if (length(invalid_file != 0)){
  print(invalid_file)
}else {
  message ("all files pass file check")
}

rm(i,indifile,indiplot,indiplotdata,invplot,NoPlot,reportTable,test1,test2,vplot)

########################################################
####Data extraction from all avaliable fft files########
########################################################

#1. opening information -- Opening_Info;
#2. count table -- CounTable_T;
#3. ht-age table -- HtAgeTable_T;
#4. baf table -- BafTable_All;
#5. forest health table -- HealTable_All

Opening_Info <- NULL
CounTable <- NULL
HtAgeTable <- NULL
BafTable <- NULL
HealTable <- NULL
for (i in 1:length(file_list)){
  indifile <- file.path(fftdatapath, file_list[i])
  cat("Extract data from file", file_list[i], "\n")
  reportTable <- read.xlsx(indifile,
                           sheet = "Report",
                           detectDates = TRUE) #extract the summary table of this opening

  ####extrac overstory and understory label###
  over_tmp<-reportTable[22,6]
  over<-CreaLabel(over_tmp)
  under_tmp<-reportTable[23,6]
  under<-CreaLabel(under_tmp)

  ####extract opening information###

  opening_tmp<-data.table(Opening = reportTable[1,5],
                          Openingid = reportTable[2,5],
                          Region = reportTable[3,5],
                          District = reportTable[4,5],
                          Location = reportTable[5,5],
                          BEC = reportTable[8,10],
                          Area_ha = reportTable[5,10],
                          Date = reportTable[1,10],
                          Lat = reportTable[3,16],
                          Long = reportTable[4,16],
                          plot_Number = as.numeric(reportTable[9,5]),
                          Plot_size_m2 = reportTable[5,16],
                          BAF = as.numeric(reportTable[42,6]),
                          SI = as.numeric(over$SI),
                          Over_TPH = as.numeric(over$TPH),
                          Over_CC = as.numeric(over$CC),
                          Under_TPH = as.numeric(under$TPH),
                          Under_CC = as.numeric(under$CC),
                          Mortality = reportTable[57,3])
  opening_tmp$Lat<-gsub(" ","",opening_tmp$Lat)
  opening_tmp$Lat<-gsub("º","°",opening_tmp$Lat)
  opening_tmp$Long<-gsub(" ","",opening_tmp$Long)
  opening_tmp$Long<-gsub("º","°",opening_tmp$Long)
  opening_tmp$Area_ha <- as.numeric(gsub(" ha", "", opening_tmp$Area_ha))
  opening_tmp$Plot_size_m2 <- as.numeric(gsub("m2","",opening_tmp$Plot_size_m2))
  opening_tmp$Mortality <- round(as.numeric(opening_tmp$Mortality),digits = 2)
  Opening_Info<- rbind(Opening_Info,opening_tmp)
  cat(" Opening table is done. \n")

  ####extract ht and age
  ####overstory

  osub_sp1<-data.table(Spp = over$spp1,
                       Age = as.numeric(over$Age1),
                       Ht = as.numeric(over$Ht1))
  osub_sp2<-data.table(Spp = over$spp3,
                       Age = as.numeric(over$Age2),
                       Ht = as.numeric(over$Ht2))
  htage_over<-rbind(osub_sp1,osub_sp2)
  htage_over<-htage_over[which(!apply(is.na(htage_over),1,any)),]
  OVER<-data.table(Opening = reportTable[1,5],
                   Layer = "L1/L2",
                   htage_over)

  ####understory

  usub_sp1<-data.table(Spp = under$spp1,
                       Age = as.numeric(under$Age1),
                       Ht = as.numeric(under$Ht1))
  usub_sp2<-data.table(Spp = under$spp3,
                       Age = as.numeric(under$Age2),
                       Ht = as.numeric(under$Ht2))
  htage_under<-rbind(usub_sp1,usub_sp2)
  htage_under<-htage_under[which(!apply(is.na(htage_under),1,any)),]
  UNDER<-data.table(Opening = reportTable[1,5],
                    Layer = "L3/L4",
                    htage_under)

  ####combine overstory ht-age and understory ht-age

  htage_all<-rbind(OVER,UNDER)
  HtAgeTable<-rbind(HtAgeTable,htage_all)
  cat(" Height and age table is done. \n")

  ####extract 1. count table 2. baf table 3. forest health table

  NoPlot <- reportTable[9, 5]
  for (indiplot in 1:NoPlot) {
    indiplotdata <- read.xlsx(indifile,
                              sheet = as.character(indiplot),
                              colNames = FALSE,
                              detectDates = TRUE) #extract the table for each plot

    ####1. count table
    tmp_countdata <- CreaCounTable(indiplotdata)
    CounTable <- rbind(CounTable,tmp_countdata[tmp_countdata$Status=="T",])

    cat("   Count table in plot", indiplot, "is done. \n")

    ####2. BAF count table

    tmp_bafdata <- CreaBafTable(indiplotdata,reportTable)
    BafTable <- rbind(BafTable, tmp_bafdata)

    cat("   BA measurement in plot", indiplot, "is done. \n")

    ####3. Forest health table

    tmp_helthdata <- CreaHealTable(indiplotdata)
    HealTable <- rbind(HealTable, tmp_helthdata)
    cat("   Health table in plot", indiplot, "is done. \n")
  }
rm(tmp_countdata, tmp_helthdata, tmp_bafdata, opening_tmp,over,over_tmp,OVER,osub_sp1,osub_sp2,under,under_tmp,UNDER,usub_sp1,usub_sp2,htage_over,htage_under,htage_all,i,indifile,indiplot,indiplotdata,NoPlot,reportTable)
}

################################################################################################
####combine count data, baf data and htage data, and create a stand level summary table#########
################################################################################################

####1. calculate BA per ha by layer and species

BafTable_process <- copy(BafTable)

BafTable_process[Layer %in% c("L1","L2","L1/2"), Layer := "L1/L2"]

BAsummary <- BafTable_process[,.(BAF_Count = sum(Count)),
                              by = c("Opening","Layer","Spp")]
#BAsummary<- aggregate(BafTable_All$count,
#                      by=list(Opening = BafTable_All$Opening,
#                              Layer = BafTable_All$Layer,
#                              SPP = BafTable_All$Spp),
#                      FUN = sum)

for (i in 1:dim(BAsummary)[1]){
  opening<-BAsummary[i,Opening]
  Noplot<-length(unique(BafTable$Plotid[BafTable$Opening==opening]))
  baf<- as.numeric(Opening_Info$BAF[Opening_Info$Opening==opening])
  BAsummary[i,BAPH := round(BAF_Count*baf/Noplot, digits = 2)]
}

####2. calculate TPH by layer and species

CounTable_process <- copy(CounTable)

CounTable_process[Layer %in% c("L1", "L2", "L1/2"), Layer := "L1/L2"]
CounTable_process[Layer %in% c("L3", "L4", "L3/4"), Layer := "L3/L4"]

TPHsummary <- CounTable_process[,.(TotalN = sum(Count)),
                                by = c("Opening", "Layer", "Spp")]
# TPHsummary<- aggregate(a$count,
#                        by=list(Opening = b$opening,
#                                Layer = b$Layer,
#                                SPP = b$Species),
#                        FUN = sum)

for (i in 1:dim(TPHsummary)[1]){
  opening<-TPHsummary[i,Opening]
  Noplot<-length(unique(CounTable$Plotid[CounTable$Opening==opening]))
  size<-as.numeric(Opening_Info$Plot_size_m2[Opening_Info$Opening==opening])
  TPHsummary[i, TPH := round(TotalN*10000/(size*Noplot))]
}


####3. combine count data, baf data and htage data

tmp <- merge(TPHsummary,BAsummary,by = c("Opening","Layer","Spp"), all = TRUE)
Inventory_Sum <- merge(tmp,HtAgeTable,by = c("Opening","Layer","Spp"),all = TRUE)

rm(i,Noplot,opening,tmp,baf,size,BafTable_process,CounTable_process)


####save output to .csv or .rds#############################

output <- list(Opening_Info = Opening_Info,
               CounTable = CounTable,
               HtAgeTable = HtAgeTable,
               BafTable = BafTable,
               HealTable = HealTable,
               Inventory_Sum = Inventory_Sum)
save.file(output,
          savename = "fftcompile_2opening",
          saveformat = "csv")







