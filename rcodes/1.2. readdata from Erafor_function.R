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

  if (!is.element("BASAL Data",indiplotdata[21,9])){

    test3 <- cbind(Opening = indiplotdata[1,3],
                   Plotid = indiplotdata[1,9],
                   Survey_Date = indiplotdata[1,11],
                   test2)
  }else{

    test3 <- cbind(Opening = indiplotdata[1,3],
                   Plotid = indiplotdata[1,10],
                   Survey_Date = indiplotdata[1,12],
                   test2)
  }

  test3 <- test3[!is.na(test3$Count),] #remove rows that contain na
  setnames(test3,"Species","Spp")
  test3[Layer %in% c("L1","L2","L1/2"), Layer := "L1/L2"]
  test3[Layer %in% c("L3", "L4", "L3/4"), Layer := "L3/L4"]
  return(test3)
}

####2. FUNCTION for extracting age and ht###############################

CreaAgeHtTable <- function(indiplotdata){
  test <- indiplotdata[12:18,1:8] %>% data.table
  names(test) <- as.character(test[1,])
  test <- test[-1,]
  test <- test[,which(apply(is.na(test),2,all)) := NULL]
  if(dim(test)[2]>1){
    test1 <- reshape(test,
                     varying = 2:dim(test)[2],
                     v.names = "Count",
                     times=names(test)[2:dim(test)[2]],
                     timevar = "Species",
                     direction="long")
    test1 <- subset(test1,select = -id)
    test2 <- separate(test1,
                      col = "X1",
                      into = c("Layer","Status"),
                      sep = " ")
    test2 <- test2[!Count %in% NA]
    test3 <- spread(test2, Status, Count)
    test3[Layer %in% c("L1","L2","L1/2"), Layer := "L1/L2"]
    test3[Layer %in% c("L3", "L4", "L3/4"), Layer := "L3/L4"]
    if (!is.element("BASAL Data",indiplotdata[21,9])){

      test4 <- cbind(Opening = indiplotdata[1,3],
                     Plotid = indiplotdata[1,9],
                     test3)
    }else{

      test4 <- cbind(Opening = indiplotdata[1,3],
                     Plotid = indiplotdata[1,10],
                     test3)
    }
  }
  else{
    test4 <- NULL
  }
  return(test4)
}


####3.FUNCTION for creating BAF count table#########################

CreaBafTable<-function(indiplotdata){

  test <- indiplotdata[19:20,1:8] %>% data.table
  names(test) <- as.character(test[1,])
  setnames(test,"BAF #","BAF")
  test<-test[-1,]
  test[is.na(test$BAF),BAF := 5]
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
    if (!is.element("BASAL Data",indiplotdata[21,9])){

      test3 <- cbind(Opening = indiplotdata[1,3],
                     Plotid = indiplotdata[1,9],
                     Survey_Date = indiplotdata[1,11],
                     test2)
    }else{

      test3 <- cbind(Opening = indiplotdata[1,3],
                     Plotid = indiplotdata[1,10],
                     Survey_Date = indiplotdata[1,12],
                     test2)
    }
    test3$Count<-as.numeric(test3$Count)
    test3[is.na(test3$Spp), Spp := "Missing"]
  }else{
    test3<-NULL
  }
  test3 <- test3[!is.na(test3$Count)]

  if (is.data.table(test3)){
    test3[Layer %in% c("L1","L2","L1/2"), Layer := "L1/L2"]
    test3[Layer %in% c("L3","L4","L3/4"), Layer := "L3/L4"]
  }

  return(test3)
}

####4.FUNCTION for Forest Health table###########################

CreaHealTable<-function(indiplotdata){
  if (!is.element("BASAL Data",indiplotdata[21,9])){
    test <- indiplotdata[3:26,9:12] %>% data.table
  }else{
    test <- indiplotdata[3:20,10:13] %>% data.table
  }

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
    if (!is.element("BASAL Data",indiplotdata[21,9])){

      test2 <- cbind(Opening = indiplotdata[1,3],
                     Plotid = indiplotdata[1,9],
                     Survey_Date = indiplotdata[1,11],
                     test1)
    }else{

      test2 <- cbind(Opening = indiplotdata[1,3],
                     Plotid = indiplotdata[1,10],
                     Survey_Date = indiplotdata[1,12],
                     test1)
    }
    test2$Count<-as.numeric(test2$Count)
  }else{
    test2<-NULL
  }
  return(test2)
}


########2.1 FUNCTION for extracting overstory and understory label##############################
####ht and age are coming from the overtory and understory label
####site index (SI), crown closure (CC) and TPH in the OPENING INFORMATION TABLE are coming from the overstory and understory lable
# CreaLabel<-function(label){
#   test1<-data.table(matrix(unlist(strsplit(label," - ")),ncol = 6, byrow = TRUE))
#   test2<-separate(test1,
#                   col = V1,
#                   into = paste0("spp",c(1,2,3,4)),
#                   sep = "\\d",
#                   extra = "drop")
#   test3<-separate(test2,
#                   col = V2,
#                   into = c("Age1","Age2"),
#                   sep = "/",
#                   extra = "drop",
#                   fill = "right")
#   test4<-separate(test3,
#                   col = V3,
#                   into = c("Ht1","Ht2"),
#                   sep = "/",
#                   extra = "drop",
#                   fill = "right")
#   test5<-separate(test4,
#                   col = V4,
#                   into = c("SI","DIR"),
#                   sep = "/",
#                   extra = "drop")
#   setnames(test5,"V5","CC")
#   test6<-separate(test5,
#                   col = V6,
#                   into = c("TPH","YR"),
#                   sep = "\\(",
#                   extra = "drop")
#   test6$YR<-gsub("\\)","",test6$YR)
#   return(test6)
# }
#
# ####2.2 FUNCTION for creating AGE and HT table from the Inv sheet if there is no label####
#
# CreaAgeht <- function(indiplotdata){
#   indiplotdata <- indiplotdata %>% data.table
#   colnames(indiplotdata)[1] <- "Layer"
#   indiplotdata[, Layer := zoo::na.locf0(Layer, fromLast = FALSE)]
#
#   if (is.element("L2", indiplotdata$Layer)){
#     over <- indiplotdata[Layer %in% "L1"]
#   }else{
#     over <- indiplotdata[Layer %in% "L1/L2"]
#   }
#
#   over <- over[-c(1,2)]
#
#   colnames(over) <- c("Layer","Plot","CC","SP1","PCT1","Age1","Ht1","SP2","PCT2","Age2","Ht2","SP3","PCT3","SP4","PCT4","SP5","PCT5","SP6","PCT6")
#
#   over <- over[!is.na(Plot)]
#
#   over<-melt(over,
#              id.vars = c("Layer","Plot","CC","PCT1","Age1","Ht1","PCT2","Age2","Ht2","PCT3","PCT4","PCT5","PCT6"),
#              measure.vars = c("SP1","SP2","SP3","SP4","SP5","SP6"),
#              variable.name = "SP_order",
#              value.name = "SP")
#
#   over[SP_order %in% "SP1", PCT := PCT1]
#   over[SP_order %in% "SP1", Age := Age1]
#   over[SP_order %in% "SP1", Ht := round(as.numeric(Ht1), digits = 2)]
#   over[SP_order %in% "SP2", PCT := PCT2]
#   over[SP_order %in% "SP2", Age := Age2]
#   over[SP_order %in% "SP2", Ht := round(as.numeric(Ht2), digits = 2)]
#   over[SP_order %in% "SP3", PCT := PCT3]
#   over[SP_order %in% "SP4", PCT := PCT4]
#   over[SP_order %in% "SP5", PCT := PCT5]
#   over[SP_order %in% "SP6", PCT := PCT6]
#
#   over[,c("SP_order","PCT1","Age1","Ht1","PCT2","Age2","Ht2","PCT3","PCT4","PCT5","PCT6") := NULL]
#   over <- over[!is.na(SP)]
#   over <- over[order(over$Plot)]
#
#   under <- indiplotdata[Layer %in% "L3/L4"]
#   under <- under[-c(1,2)]
#
#   colnames(under) <- c("Layer","Plot","CC","SP1","PCT1","Age1","Ht1","SP2","PCT2","Age2","Ht2","SP3","PCT3","SP4","PCT4","SP5","PCT5","SP6","PCT6")
#
#   under <- under[!is.na(Plot)]
#
#   under<-melt(under,
#               id.vars = c("Layer","Plot","CC","PCT1","Age1","Ht1","PCT2","Age2","Ht2","PCT3","PCT4","PCT5","PCT6"),
#               measure.vars = c("SP1","SP2","SP3","SP4","SP5","SP6"),
#               variable.name = "SP_order",
#               value.name = "SP")
#
#   under[SP_order %in% "SP1", PCT := PCT1]
#   under[SP_order %in% "SP1", Age := Age1]
#   under[SP_order %in% "SP1", Ht := round(as.numeric(Ht1), digits = 2)]
#   under[SP_order %in% "SP2", PCT := PCT2]
#   under[SP_order %in% "SP2", Age := Age2]
#   under[SP_order %in% "SP2", Ht := round(as.numeric(Ht2),digits = 2)]
#   under[SP_order %in% "SP3", PCT := PCT3]
#   under[SP_order %in% "SP4", PCT := PCT4]
#   under[SP_order %in% "SP5", PCT := PCT5]
#   under[SP_order %in% "SP6", PCT := PCT6]
#
#   under[,c("SP_order","PCT1","Age1","Ht1","PCT2","Age2","Ht2","PCT3","PCT4","PCT5","PCT6") := NULL]
#   under <- under[!is.na(SP)]
#   under <- under[order(under$Plot)]
#
#   ageht <- rbind(over,under)
#   ageht <- ageht[order(ageht$Plot)]
#
#   ageht[Layer %in% c("L1","L2","L1/2"), Layer := "L1/L2"]
#
#   return(ageht)
# }

####5. FUNCTION for file saving#####################
#
# save.file<-function(output,savename,saveformat){
#   if (saveformat == "csv"){
#     write.csv(output$Opening_Info,file.path(fftdatapath_compiled,paste0(savename,"_opening_info.csv")),row.names = FALSE)
#     write.csv(output$InvTable,file.path(fftdatapath_compiled,paste0(savename,"_InvTable.csv")),row.names = FALSE)
#     write.csv(output$HtAgeTable,file.path(fftdatapath_compiled,paste0(savename,"_StandHtAge.csv")),row.names = FALSE)
#     write.csv(output$BafTable,file.path(fftdatapath_compiled,paste0(savename,"_BafTable.csv")),row.names = FALSE)
#     write.csv(output$HealTable,file.path(fftdatapath_compiled,paste0(savename,"_HealTable.csv")),row.names = FALSE)
#     write.csv(output$Inventory_Sum,file.path(fftdatapath_compiled,paste0(savename,"_Inv_Sum.csv")),row.names = FALSE)
#   }
#   if (saveformat == "rds"){
#     saveRDS(output$Opening_Info,file.path(fftdatapath_compiled,paste0(savename,"_opening_info.rds")))
#     saveRDS(output$InvTable,file.path(fftdatapath_compiled,paste0(savename,"_InvTable.rds")))
#     saveRDS(output$HtAgeTable,file.path(fftdatapath_compiled,paste0(savename,"_StandHtAge.rds")))
#     saveRDS(output$BafTable,file.path(fftdatapath_compiled,paste0(savename,"_BafTable.rds")))
#     saveRDS(output$HealTable,file.path(fftdatapath_compiled,paste0(savename,"_HealTable.rds")))
#     saveRDS(output$Inventory_Sum,file.path(fftdatapath_compiled,paste0(savename,"_Inv_Sum.rds")))
#   }
# }
#




















