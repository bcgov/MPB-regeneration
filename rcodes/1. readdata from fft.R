#####read FFT data########

rm(list=ls())
#library(data.table)
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

####RUN File Check first: check if all files are valid for compliation##########

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
    indifile <- file.path(fftdatapath, file_list[i])
    cat("Extract data from file", file_list[i], "\n")
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
    cat(" Opening table is done. \n")
    ####extract ht and age
    ## it may be a good idea to name this table as labelTable,
    ##
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
    cat(" Height and age table is done. \n")

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

      cat("   Count table in plot", indiplot, "is done. \n")

      ####2. Silvi Ht-Age table
      tmp_htagedata <- CreaHATable_Silvi(indiplotdata)
      HtAgeTable_Silvi <- rbind(HtAgeTable_Silvi, tmp_htagedata)
      cat("   HtAgeTable_Silvi in plot", indiplot, "is done. \n")
      ####3. BAF count table
      tmp_bafdata <- CreaBafTable(indiplotdata,reportTable)
      BafTable_All <- rbind(BafTable_All, tmp_bafdata)
      cat("   BA measurement in plot", indiplot, "is done. \n")

      ####4. Forest health table
      tmp_helthdata <- CreaHealTable(indiplotdata)
      HealTable_All <- rbind(HealTable_All, tmp_helthdata)
      cat("   Health table in plot", indiplot, "is done. \n")
    }
    rm(tmp_countdata, tmp_helthdata, tmp_bafdata, tmp_htagedata, opening_tmp,over,OVER,under,UNDER,htage_over,htage_under,htage_all,i,indifile,indiplot,indiplotdata,NoPlot,reportTable)
  }

####combine count data, baf data and htage data, and create a summary table#########
####1. calculate BA per ha by layer and species

  BafTable_All[is.na(BafTable_All$SPP),"SPP"] <- "Missing"
  BafTable_All$Layer[BafTable_All$Layer == "L1" | BafTable_All$Layer == "L2"] <- "L1/L2"

  BAsummary<- aggregate(BafTable_All$count,
                        by=list(Opening = BafTable_All$opening,
                                Layer = BafTable_All$Layer,
                                SPP = BafTable_All$SPP),
                        FUN = sum)

  for (i in 1:dim(BAsummary)[1]){
    opening<-BAsummary[i,"Opening"]
    Noplot<-length(unique(BafTable_All$plotid[BafTable_All$opening==opening]))
    BAsummary$BAPH[i]<-round(BAsummary[i,"x"]*5/Noplot, digits = 2) ## BAF should be dynamic with field measurement
  }
  BAsummary$x <- NULL


####2. calculate TPH by layer and species
  CounTable_T_process <- CounTable_T %>% data.table

  CounTable_T_process[Layer %in% c("L1", "L2", "L1/2"), Layer := "L1/L2"]
  CounTable_T_process[Layer %in% c("L3", "L4", "L3/4"), Layer := "L3/L4"]

  TPHsummary <- CounTable_T_process[,.(totalN = sum(count)),
                                    by = c("opening", "Layer", "Species")]

  # TPHsummary<- aggregate(a$count,
  #                        by=list(Opening = b$opening,
  #                                Layer = b$Layer,
  #                                SPP = b$Species),
  #                        FUN = sum)

  for (i in 1:dim(TPHsummary)[1]){
    opening<-TPHsummary[i,"Opening"]
    Noplot<-length(unique(CounTable_T$plotid[CounTable_T$opening==opening]))
    TPHsummary$TPH[i]<-round(TPHsummary[i,"x"]*10000/(50*Noplot)) # use plot size
  }

  TPHsummary<-TPHsummary[order(TPHsummary$Opening,TPHsummary$Layer),-4]


####3. combine count data, baf data and htage data

  tmp <- merge(TPHsummary,BAsummary,by = c("Opening","Layer","SPP"), all = TRUE)
  Inventory_Sum <- merge(tmp,HtAgeTable_T,by = c("Opening","Layer","SPP"),all = TRUE)
  row.names(Inventory_Sum) <- NULL

  rm(i,Noplot,opening,tmp)
####save output to .csv or .rds#############################

  output <- list(Opening_Info = Opening_Info,
                 CounTable_T = CounTable_T,
                 CounTable_Silvi = CounTable_Silvi,
                 HtAgeTable_T = HtAgeTable_T,
                 HtAgeTable_Silvi = HtAgeTable_Silvi,
                 BafTable_All = BafTable_All,
                 HealTable_All = HealTable_All,
                 Inventory_Sum = Inventory_Sum)
  save.file(output,
          savename = "fftcompile_2opening",
          saveformat = "csv")







