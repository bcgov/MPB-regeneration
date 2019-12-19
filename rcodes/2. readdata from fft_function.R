#############################################################
####FUNCTIONS################################################
####File Check###############################################

FileCheck <- function (file_list){
  invalid_file<-NULL
  valid_file<-NULL
  for (i in 1:length(file_list)){
    indifile <- file_list[i]
    if (any(is.element(c("Report",1:20), getSheetNames(indifile)) == FALSE)){
      invalid_file <- c(invalid_file, indifile)
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
      if (is.element("FALSE",test1)){
        invalid_file <- c(invalid_file, indifile)
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
            invplot <- c(invplot, paste0(indifile, "_", indiplot))
          } else{
            vplot <- c(vplot,indiplot)
          }
        }
        if (length(vplot) == NoPlot){
          valid_file <- c(valid_file, indifile)
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
}

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

####2.1 FUNCTION for creating ht-age table##############################

CreaHATable<-function(label){
  test1<-data.frame(matrix(unlist(strsplit(label," - ")),ncol = 6, byrow = TRUE))[1:3]
  test2<-separate(test1,
                  col = X1,
                  into = paste0("spp",c(1,2,3,4)),
                  sep = "\\d",
                  extra = "drop")
  test3<-separate(test2,
                  col = X2,
                  into = c("Age1","Age2"),
                  sep = "/",
                  extra = "drop",
                  fill = "right")
  test4<-separate(test3,
                  col = X3,
                  into = c("Ht1","Ht2"),
                  sep = "/",
                  extra = "drop",
                  fill = "right")
  sub_sp1<-data.frame(Spp = test4$spp1,
                      Age = test4$Age1,
                      Ht = test4$Ht1)
  sub_sp2<-data.frame(Spp = test4$spp3,
                      Age = test4$Age2,
                      Ht = test4$Ht2)
  test5<-rbind(sub_sp1,sub_sp2)
  test5<-test5[!apply(is.na(test5),1,any),]
  return(test5)
}

####2.2 FUNCTION for creating SILVICULTURAL ht-age table################

CreaHATable_Silvi<-function(indiplotdata){

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

CreaBafTable<-function(indiplotdata, reportTable){

  test<-indiplotdata[19:20,1:8]
  names(test)<-as.character(test[1,])
  names(test)[1]<-"BAF"
  test<-test[-1,]
  test[is.na(test$BAF),"BAF"]<-reportTable[42,6]
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

####5. FUNCTION for file saving#####################

save.file<-function(output,savename,saveformat){
  if (saveformat == "csv"){
    write.csv(output$Opening_Info,file.path(fftdatapath_compiled,paste0(savename,"_opening_info.csv")),row.names = FALSE)
    write.csv(output$CounTable_T,file.path(fftdatapath_compiled,paste0(savename,"_countable_T.csv")),row.names = FALSE)
    write.csv(output$CounTable_Silvi,file.path(fftdatapath_compiled,paste0(savename,"_countable_silvi.csv")),row.names = FALSE)
    write.csv(output$HtAgeTable_T,file.path(fftdatapath_compiled,paste0(savename,"_HtAge_T.csv")),row.names = FALSE)
    write.csv(output$HtAgeTable_Silvi,file.path(fftdatapath_compiled,paste0(savename,"_HtAge_silvi.csv")),row.names = FALSE)
    write.csv(output$BafTable_All,file.path(fftdatapath_compiled,paste0(savename,"_BafTable.csv")),row.names = FALSE)
    write.csv(output$HealTable_All,file.path(fftdatapath_compiled,paste0(savename,"_HealTable.csv")),row.names = FALSE)
  }
  if (saveformat == "rds"){
    saveRDS(output$Opening_Info,file.path(fftdatapath_compiled,paste0(savename,"_opening_info.rds")))
    saveRDS(output$CounTable_T,file.path(fftdatapath_compiled,paste0(savename,"_countable_T.rds")))
    saveRDS(output$CounTable_Silvi,file.path(fftdatapath_compiled,paste0(savename,"_countable_silvi.rds")))
    saveRDS(output$HtAgeTable_T,file.path(fftdatapath_compiled,paste0(savename,"_HtAge_T.rds")))
    saveRDS(output$HtAgeTable_Silvi,file.path(fftdatapath_compiled,paste0(savename,"_HtAge_silvi.rds")))
    saveRDS(output$BafTable_All,file.path(fftdatapath_compiled,paste0(savename,"_BafTable.rds")))
    saveRDS(output$HealTable_All,file.path(fftdatapath_compiled,paste0(savename,"_HealTable.rds")))
  }
}
