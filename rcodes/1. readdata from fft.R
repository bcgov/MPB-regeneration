#####read FFT data########

rm(list=ls())
#library(data.table)
library(openxlsx)
library(tidyr)
options(stringsAsFactors = FALSE)
fftdatapath <- file.path(".", "data", "rawdata", "fft")
file_list <- dir(fftdatapath, full.names = TRUE)

####Summarise tables from all avaliable fft files########
####Extract and rashape tables from FFT survey data: 1. count table; 2. Ht-Age table; 3. BAF count table; 4. Forest health table

Opening_Info <- NULL
CounTable_All <- NULL
HtAgeTable_All <- NULL
BafTable_All <- NULL
HealTable_All <- NULL
for (i in 1:length(file_list)){
  indifile <- file_list[i]
  reportTable <- read.xlsx(indifile,
                           sheet = "Report",
                           detectDates = TRUE) #extract the summary table of this opening
  opening_tmp<-data.frame(cbind(Opening = reportTable[1,5],
                                   Openingid = reportTable[2,5],
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

  NoPlot <- reportTable[9, 5]
  for (indiplot in 1:NoPlot) {
    indiplotdata <- read.xlsx(indifile,
                              sheet = as.character(indiplot),
                              colNames = FALSE,
                              detectDates = TRUE) #extract the table for each plot

    ## extract count table
    tmp_countdata <- CreaCounTable(indiplotdata)
    CounTable_All <- rbind(CounTable_All,tmp_countdata)

    ####2. Ht-Age table
    tmp_htagedata <- CreaHATable(indiplotdata)
    HtAgeTable_All <- rbind(HtAgeTable_All, tmp_htagedata)

    ####3. BAF count table
    tmp_bafdata <- CreaBafTable(indiplotdata)
    BafTable_All <- rbind(BafTable_All, tmp_bafdata)

    ####4. Forest health table
    tmp_helthdata <- CreaHealTable(indiplotdata)
    HealTable_All <- rbind(HealTable_All, tmp_helthdata)

  }
  rm(tmp_countdata, tmp_helthdata, tmp_bafdata, tmp_htagedata, opening_tmp)
}


####FUNCTIONS################################################
####1. FUNCTION for creating count table#####################

CreaCounTable <- function(indiplotdata){

  test <- indiplotdata[2:11,1:8] #extract the count table from the measure table
  names(test) <- as.character(test[1,]) #set the column names to be the first row of count table
  test <- test[-1,] #remove first row as it is now the column names
  test <- test[,!apply(is.na(test),2,all)] #remove na columns
  test1 <- reshape(test,
                 varying = 2:dim(test)[2],
                 v.names = "count",
                 times=names(test)[2:dim(test)[2]],
                 timevar = "Species",
                 direction="long") #reshape the count table to long table
  test1 <- subset(test1,select = -id) #remove unnecessary id column, which is creating from "reshape" step
  test1$count <- as.numeric(test1$count)
  ## before clean this column, it would be better to remove any space between letters
  test1$Spp <- gsub(" ", "", test1$Spp)
  test2 <- separate(test1,
                   col = "Spp",
                   into = c("Layer","Status"),
                   sep = "\\(") #split the old "Layer (Status)" data in "Spp" to two new columns called "Layer" and "Status"
                              # it is a little risky for using " " to seperate, as it is easy to
                              # have a space between letters by accident
                              # I would suggest using "("

  ## after using "(" to seperate, all we need to do is to remove ")"
  test2$Status <- gsub("\\)", "", test2$Status)

  test3 <- cbind(opening = indiplotdata[1,3],
                 plotid = indiplotdata[1,9],
                 test2)
  test4 <- test3[!apply(is.na(test3),1,any),] #remove rows that contain na
  row.names(test4)<-NULL
  return(test4)
}

####2.FUNCTION for creating ht-age table################

CreaHATable<-function(indiplotdata){

  test<-indiplotdata[12:18,1:8] #extract the ht-age table from the measure table
  names(test)<-as.character(test[1,])
  test<-test[-1,]
  test<-test[,!apply(is.na(test),2,all)] #remove na columns
  if (is.data.frame((test))){
    names(test)[1]<-"Attributes"  #replace NA to "Attributes" for first column's name
    test1<-separate(test,
                    col = "Attributes",
                    into = c("Layer","Attribute"),
                    sep = " ") #seperate layer and attributes
    test1<-reshape(test1,
                   varying = 3:dim(test1)[2],
                   v.names = "number",
                   times=names(test1)[3:dim(test1)[2]],
                   direction="long") #reshape to long table##
    sub_Ht<-test1[test1$Attribute=="Ht",]
    sub_Age<-test1[test1$Attribute=="Age",]
    test2<-merge(sub_Ht,sub_Age,by = c("Layer","time"),suffixes = c("Ht","Age"))
    test3<-subset(test2,select = c(Layer,time,numberHt,numberAge))
    names(test3)<-c("Layer","SPP","Ht","Age")
    test3<-test3[!apply(is.na(test3),1,any),]
    test4<-cbind(opening = indiplotdata[1,3],
                 plotid = indiplotdata[1,9],
                 test3)
    test4$Ht<-as.numeric(test4$Ht)
    test4$Age<-as.numeric(test4$Age)
  }else{
    test4<-NULL
  }
  row.names(test4)<-NULL
  return(test4)
}

####3.FUNCTION for creating BAF count table#########################

CreaBafTable<-function(indiplotdata){

  test<-indiplotdata[19:20,1:8]
  names(test)<-as.character(test[1,])
  names(test)[1]<-"BAF"
  test<-test[-1,]
  test[is.na(test$BAF),"BAF"]<-"5"
  test<-test[,!apply(is.na(test),2,all)]
  if (is.data.frame(test)){
    test1<-reshape(test,
                   varying = 2:dim(test)[2],
                   v.names = "count",
                   times=names(test)[2:dim(test)[2]],
                   direction="long") #reshape to long table##
    test2<-separate(test1,
                    col = "time",
                    into = c("SPP","Layer"),
                    sep = " ",
                    fill = "left")
    test2<-subset(test2,select = -id)
    row.names(test2)<-NULL
    test3<-cbind(opening = indiplotdata[1,3],
                 plotid = indiplotdata[1,9],
                 test2)
    test3$count<-as.numeric(test3$count)
  }else{
    test3<-NULL
  }
  row.names(test3)<-NULL
  return(test3)
}

####4.FUNCTION for Forest Health table###########################

CreaHealTable<-function(indiplotdata){

  test<-indiplotdata[3:26,9:12]
  names(test)<-as.character(test[1,])
  test<-test[-1,]
  test<-test[!apply(is.na(test),1,all),]
  if (dim(test)[1]!="0"){
    test1<-reshape(test,
                   varying = 3:4,
                   v.names = "count",
                   times=names(test)[3:4],
                   direction="long") #reshape to long table##
    test1<-subset(test1,select = -id)
    row.names(test1)<-NULL
    test1<-test1[!apply(is.na(test1),1,any),]
    names(test1)[3]<-"Status"
    test2<-cbind(opening = indiplotdata[1,3],
                 plotid = indiplotdata[1,9],
                 test1)
    test2$count<-as.numeric(test2$count)
  }else{
    test2<-NULL
  }
  row.names(test2)<-NULL
  return(test2)
}







##################################################
######TEST RUN for one opening and one plot#######
##################################################
for (i in file_list){
  i<-file_list[1]
  tmp <- read.xlsx(i,
                   sheet="Report",
                   colNames = TRUE,
                   detectDates = TRUE)
}




