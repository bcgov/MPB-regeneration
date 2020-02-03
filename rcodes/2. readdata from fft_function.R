#############################################################
####FUNCTIONS################################################
####1. FUNCTION for creating count table#####################

CreaCounTable <- function(indiplotdata){

  test <- indiplotdata[2:11,1:8] %>% data.table #extract the count table from the measure table
  names(test) <- as.character(test[1,]) #set the column names to be the first row of count table
  test <- test[-1,] #remove first row as it is now the column names
  test <- test[,which(apply(is.na(test),2,all)) := NULL] #remove na columns
  test1 <- reshape(test,
                   varying = 2:dim(test)[2],
                   v.names = "Count",
                   times=names(test)[2:dim(test)[2]],
                   timevar = "Species",
                   direction="long") #reshape the count table to long table
  test1 <- subset(test1,select = -id) #remove unnecessary id column, which is creating from "reshape" step
  test1$Count <- as.numeric(test1$Count)
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

  test3 <- cbind(Opening = indiplotdata[1,3],
                 Plotid = indiplotdata[1,9],
                 test2)
  test3 <- test3[!is.na(test3$Count),] #remove rows that contain na
  setnames(test3,"Species","Spp")
  return(test3)
}

####2. FUNCTION for extracting overstory and understory label##############################
####ht and age are coming from the overtory and understory label
####site index (SI), crown closure (CC) and TPH in the OPENING INFORMATION TABLE are coming from the overstory and understory lable

CreaLabel<-function(label){
  test1<-data.table(matrix(unlist(strsplit(label," - ")),ncol = 6, byrow = TRUE))
  test2<-separate(test1,
                  col = V1,
                  into = paste0("spp",c(1,2,3,4)),
                  sep = "\\d",
                  extra = "drop")
  test3<-separate(test2,
                  col = V2,
                  into = c("Age1","Age2"),
                  sep = "/",
                  extra = "drop",
                  fill = "right")
  test4<-separate(test3,
                  col = V3,
                  into = c("Ht1","Ht2"),
                  sep = "/",
                  extra = "drop",
                  fill = "right")
  test5<-separate(test4,
                  col = V4,
                  into = c("SI","DIR"),
                  sep = "/",
                  extra = "drop")
  setnames(test5,"V5","CC")
  test6<-separate(test5,
                  col = V6,
                  into = c("TPH","YR"),
                  sep = "\\(",
                  extra = "drop")
  test6$YR<-gsub("\\)","",test6$YR)
  return(test6)
}

####3.FUNCTION for creating BAF count table#########################

CreaBafTable<-function(indiplotdata, reportTable){

  test <- indiplotdata[19:20,1:8] %>% data.table
  names(test) <- as.character(test[1,])
  setnames(test,"BAF #","BAF")
  test<-test[-1,]
  test[is.na(test$BAF),BAF := reportTable[42,6]]
  test[,which(apply(is.na(test),2,all)) := NULL]
  if (dim(test)[2] > 1){
    test1<-reshape(test,
                   varying = 2:dim(test)[2],
                   v.names = "Count",
                   times=names(test)[2:dim(test)[2]],
                   direction="long") #reshape to long table##
    test2<-separate(test1,
                    col = "time",
                    into = c("Spp","Layer"),
                    sep = " ",
                    fill = "left")
    test2<-subset(test2,select = -id)
    test3<-cbind(Opening = indiplotdata[1,3],
                 Plotid = indiplotdata[1,9],
                 test2)
    test3$Count<-as.numeric(test3$Count)
    test3[is.na(test3$Spp), Spp := "Missing"]
  }else{
    test3<-NULL
  }
  test3 <- test3[!is.na(test3$Count)]
  return(test3)
}

####4.FUNCTION for Forest Health table###########################

CreaHealTable<-function(indiplotdata){

  test<-indiplotdata[3:26,9:12] %>% data.table
  names(test)<-as.character(test[1,])
  test<-test[-1,]
  test<-test[!which(apply(is.na(test),1,all)),]
  if (dim(test)[1] != 0 ){
    test1<-reshape(test,
                   varying = 3:4,
                   v.names = "Count",
                   times=names(test)[3:4],
                   direction="long") #reshape to long table##
    test1<-subset(test1,select = -id)
#    test1<-test1[!which(apply(is.na(test1),1,any)),]
    setnames(test1,"time","Status")
    test2<-cbind(Opening = indiplotdata[1,3],
                 Plotid = indiplotdata[1,9],
                 test1)
    test2$Count<-as.numeric(test2$Count)
  }else{
    test2<-NULL
  }
  return(test2)
}

####5. FUNCTION for file saving#####################

save.file<-function(output,savename,saveformat){
  if (saveformat == "csv"){
    write.csv(output$Opening_Info,file.path(fftdatapath_compiled,paste0(savename,"_opening_info.csv")),row.names = FALSE)
    write.csv(output$CounTable,file.path(fftdatapath_compiled,paste0(savename,"_countable.csv")),row.names = FALSE)
    write.csv(output$HtAgeTable,file.path(fftdatapath_compiled,paste0(savename,"_HtAge.csv")),row.names = FALSE)
    write.csv(output$BafTable,file.path(fftdatapath_compiled,paste0(savename,"_BafTable.csv")),row.names = FALSE)
    write.csv(output$HealTable,file.path(fftdatapath_compiled,paste0(savename,"_HealTable.csv")),row.names = FALSE)
    write.csv(output$Inventory_Sum,file.path(fftdatapath_compiled,paste0(savename,"_Inv_Sum.csv")),row.names = FALSE)
  }
  if (saveformat == "rds"){
    saveRDS(output$Opening_Info,file.path(fftdatapath_compiled,paste0(savename,"_opening_info.rds")))
    saveRDS(output$CounTable,file.path(fftdatapath_compiled,paste0(savename,"_countable.rds")))
    saveRDS(output$HtAgeTable,file.path(fftdatapath_compiled,paste0(savename,"_HtAge.rds")))
    saveRDS(output$BafTable,file.path(fftdatapath_compiled,paste0(savename,"_BafTable.rds")))
    saveRDS(output$HealTable,file.path(fftdatapath_compiled,paste0(savename,"_HealTable.rds")))
    saveRDS(output$Inventory_Sum,file.path(fftdatapath_compiled,paste0(savename,"_Inv_Sum.rds")))
  }
}






















