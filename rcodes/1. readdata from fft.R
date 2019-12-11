#####read FFT data########
rm(list=ls())
#library(data.table)
library(openxlsx)
library(tidyr)
fftdatapath <- file.path(".", "data", "rawdata", "fft")

####number of plots in [9,5] from the summarty table######
####FUNCTION for creating count table#####################

CreaCounTable<-function(fftfile){
  xlsxfile<-file.path(fftdatapath,fftfile)
  sumtable<-read.xlsx(xlsxfile) #extract the summary table of this opening
  counttable<-NULL
  for (i in 1:sumtable[9,5]){
    tmp <- read.xlsx(xlsxfile,
                     sheet=as.character(i),
                     colNames = FALSE,
                     detectDates = TRUE) #extract the table for each plot
    test<-tmp[2:11,1:8] #extract the count table from the measure table
    names(test)<-as.character(test[1,]) #set the column names to be the first row of count table
    test<-test[-1,] #remove first row as it is now the column names
    test<-test[,!apply(is.na(test),2,all)] #remove na columns
    test1<-reshape(test,
                   varying = 2:dim(test)[2],
                   v.names = "number",
                   times=names(test)[2:dim(test)[2]],
                   direction="long") #reshape the count table to long table
    row.names(test1)<-NULL #set NUll to row names
    test1<-subset(test1,select = -id) #remove unnecessary id column, which is creating from "reshape" step
    test2<-separate(test1,
                    col = "Spp",
                    into = c("Layer","Status"),
                    sep = " ") #split the old "Layer (Status)" data in "Spp" to two new columns called "Layer" and "Status"
    test2$Status<-rep(c("T","W","F"),dim(test2)[1]/3) #remove brackets in "Status" column
    names(test2)<-c("Layer","Status","SPP","Count") #rename the columns
    openingid<-tmp[1,3] #add opening id
    plotid<-tmp[1,9] #add plot id
    date<-tmp[1,11] #add measure date
    test3<-cbind(openingid,date,plotid,test2)
    test4<-test3[!apply(is.na(test3),1,any),] #remove rows that contain na
    counttable<- rbind(counttable, test4) #bind the reshaped count table for each plot together
  }
  row.names(counttable)<-NULL
  return(counttable)
}


####FUNCTION for creating ht-age table################

CreaHATable<-function(fftfile){
  xlsxfile<-file.path(fftdatapath, fftfile)
  sumtable<-read.xlsx(xlsxfile)
  hatable<-NULL
  for (i in 1:sumtable[9,5]){
    tmp <- read.xlsx(xlsxfile,
                     sheet=as.character(i),
                     colNames = FALSE,
                     detectDates = TRUE) #extract the table for each plot
    test<-tmp[12:18,1:8] #extract the ht-age table from the measure table
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
        test4<-test3[!apply(is.na(test3),1,any),]
        openingid<-tmp[1,3] #add opening id
        plotid<-tmp[1,9] #add plot id
        date<-tmp[1,11] #add measure date
        test5<-cbind(openingid,date,plotid,test4)
      }else{
        test5<-NULL
      }
    hatable<-rbind(hatable,test5)
}
  row.names(hatable)<-NULL
  return(hatable)
}

####Create BAF count table#########################

CreaBafTable<-function(fftfile){
  xlsxfile<-file.path(fftdatapath, fftfile)
  sumtable<-read.xlsx(xlsxfile)
  baftable<-NULL
  for (i in 1:sumtable[9,5]){
    tmp <- read.xlsx(xlsxfile,
                     sheet=as.character(i),
                     colNames = FALSE,
                     detectDates = TRUE)
    test<-tmp[19:20,1:8]
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
      openingid<-tmp[1,3] #add opening id
      plotid<-tmp[1,9] #add plot id
      date<-tmp[1,11] #add measure date
      test3<-cbind(openingid,date,plotid,test2)
    }else{
      test3<-NULL
    }
    baftable<-rbind(baftable,test3)
  }
  row.names(baftable)<-NULL
  return(baftable)
}



######TEST RUN for one opening and one plot#######
FFT_93G_045_568<-read.xlsx(file.path(fftdatapath, "93G_045_568_MPB_Recce_Survey_Strat2.xlsx"))
for (i in 1:FFT_93G_045_568[9,5]){
  i<-6
  tmp <- read.xlsx(file.path(fftdatapath, "93G_045_568_MPB_Recce_Survey_Strat2.xlsx"),
                   sheet=as.character(i),
                   colNames = FALSE,
                   detectDates = TRUE)
}
test<-tmp[19:20,1:8]
names(test)<-as.character(test[1,])
names(test)[1]<-"BAF"
test<-test[-1,]
test[is.na(test$BAF),"BAF"]<-"5"
test<-test[,!apply(is.na(test),2,all)] #remove na columns
test1<-reshape(test,varying = 2:dim(test)[2],v.names = "count",times=names(test)[2:dim(test)[2]],direction="long") #reshape to long table##
test2<-separate(test1,
                col = "time",
                into = c("SPP","Layer"),
                sep = " ",
                fill = "left")
test2<-subset(test2,select = -id)
row.names(test2)<-NULL
openingid<-tmp[1,3] #add opening id
plotid<-tmp[1,9] #add plot id
date<-tmp[1,11] #add measure date
test3<-cbind(openingid,date,plotid,test2)

###save for later memo#####
FFT_93J_073_077<-read.xlsx(file.path(fftdatapath, "93J_073_077_2018_MPB_Recce_Summary.xlsx"))



