rm(list=ls())
library(data.table)
library(tidyr)
library(reshape2)
library(dplyr)

invlayer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_layer.csv"))
invpoly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_poly.csv"))

#Add SP0 for all plots?

unique(invlayer$SP)

for (i in 1:dim(invlayer)[1]){
  if(invlayer[i, SP] == "PL"){
    invlayer[i, SP0 := "PL"]
  }
  if(invlayer[i, SP] == "SB"|invlayer[i, SP] == "SX"|invlayer[i, SP] == "SW"|invlayer[i, SP] == "S"|invlayer[i, SP] == "SE"){
    invlayer[i, SP0 := "S"]
  }
  if(invlayer[i, SP] == "AT"){
    invlayer[i, SP0 := "AT"]
  }
  if(invlayer[i, SP] == "EP" | invlayer[i, SP] == "E"){
    invlayer[i, SP0 := "E"]
  }
  if(invlayer[i, SP] == "BL" | invlayer[i, SP] == "B"){
    invlayer[i, SP0 := "B"]
  }
  if(invlayer[i, SP] == "FD"){
    invlayer[i, SP0 := "F"]
  }
  if(invlayer[i, SP] == "AC"){
    invlayer[i, SP0 := "AC"]
  }
  if(invlayer[i, SP] == "CW"){
    invlayer[i, SP0 := "C"]
  }
  if(invlayer[i, SP] == "PY"){
    invlayer[i, SP0 := "PY"]
  }
  if(invlayer[i, SP] == "PA"){
    invlayer[i, SP0 := "PA"]
  }
  if(invlayer[i, SP] == "H" | invlayer[i, SP] == "HW"){
    invlayer[i, SP0 := "H"]
  }
  if(invlayer[i, SP] == "LW"){
    invlayer[i, SP0 := "L"]
  }
  if(invlayer[i, SP] == "PW"){
    invlayer[i, SP0 := "PW"]
  }
  if(invlayer[i, SP] == "UNK"){
    invlayer[i, SP0 := "UNK"]
  }
}


##bec zones in ITSL's survey can be different from VRI2019's
##unify ITSL survey's bec zone
##use bec zone from ITSL to replace 2019's and 2003's

bec <- distinct(invlayer[Data_Source %in% "ITSL" & Layer %in% c("L1/L2", "L3/L4"), .(id, BEC, subBEC, vaBEC, BEC_sub_va)])
lid <- invlayer[Data_Source %in% "ITSL", .(id)]
lbec <- merge(lid, bec, by ="id", all.x = TRUE)
invlayer[Data_Source %in% "ITSL", ':=' (BEC = lbec$BEC,
                                        subBEC = lbec$subBEC,
                                        vaBEC = lbec$vaBEC,
                                        BEC_sub_va = lbec$BEC_sub_va)]

pid <- invpoly[Data_Source %in% "ITSL", .(id)]
pbec <- merge(pid, bec, by = "id", all.x = TRUE)
setorder(invpoly, id)
setorder(pbec,id)
invpoly[Data_Source %in% "ITSL", ':=' (BEC = pbec$BEC,
                                       subBEC = pbec$subBEC,
                                       vaBEC = pbec$vaBEC,
                                       BEC_sub_va = pbec$BEC_sub_va)]

##Add survey date for ITSL data

ITSL_poly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly.csv",header = TRUE))
sd <- distinct(ITSL_poly[,.(id, SurveyDate)])
sd[,id := id + 326]
for ( i in unique(invpoly[Data_Source %in% "ITSL",id])){
  surveydate <- sd[id %in% i, SurveyDate]
  invpoly[id %in% i & Layer %in% "L1/L2", Survey_Date := surveydate]
  invpoly[id %in% i & Layer %in% "L3/L4", Survey_Date := surveydate]
}

write.csv(invlayer, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_layer.csv", row.names = FALSE, na = "")
write.csv(invpoly, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_poly.csv", row.names = FALSE, na = "")
















