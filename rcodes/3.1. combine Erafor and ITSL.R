#####Merge Erafor and ITSL#####

rm(list=ls())
library(data.table)
library(tidyr)
library(reshape2)
library(dplyr)

Erafor_layer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer.csv"))
Erafor_poly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly.csv"))
ITSL_poly <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly_VRI0319.csv"))
ITSL_layer <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer_VRI0319.csv"))

Erafor_layer[,c("Opening", "Plot") := NULL]
Erafor_layer[, Data_Source := "Erafor"]
unique(Erafor_layer$id)
ITSL_layer[, id := id+326]
ITSL_poly[, id := id+326]
ITSL_layer[, Data_Source := "ITSL"]

invlayer <- rbind(Erafor_layer, ITSL_layer, fill = TRUE)

write.csv(invlayer,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_layer.csv", row.names = FALSE)

# for (i in unique(ITSL_poly$id)){
#   indi <- ITSL_poly[id %in% i & Layer %in% "L1/L2"]
#   tmp <- data.table(id = i,
#                     Layer = "Dead",
#                     Inventory_Standard = "ITSL",
#                     BEC = unique(indi$BEC),
#                     subBEC = unique(indi$subBEC),
#                     vaBEC = unique(indi$vaBEC),
#                     BEC_sub_va = unique(indi$BEC_sub_va),
#                     Stand_BA = unique(indi$deadpBA),
#                     Kill_PCT = unique(indi$Kill_PCT))
# }

Erafor_poly[,c("Opening", "Plot") := NULL]
Erafor_poly[, Data_Source := "Erafor"]
for (i in unique(Erafor_poly$id)){
  ba <- Erafor_poly[id %in% i & Layer %in% "Dead", Stand_BA]
  if(length(ba)>0){
    Erafor_poly[id %in% i & Layer %in% "L1/L2", deadpBA := ba]
  }else{
    Erafor_poly[id %in% i & Layer %in% "L1/L2", deadpBA := NA]
  }
}

Erafor_poly <- Erafor_poly[!Layer %in% "Dead"]


for(i in unique(Erafor_poly$id)){
  layer <- Erafor_layer[id %in% i & Layer %in% "L1/L2"]
  if(is.element("PL", layer$SP)){
    n <- layer[SP %in% "PL", Prismcount]
    ba <- n*5
    Erafor_poly[id %in% i & Layer %in% "L1/L2", pBA := ba]
  }else{
    Erafor_poly[id %in% i & Layer %in% "L1/L2", pBA := 0]
  }
  npn <- layer[! SP %in% "PL", sum(Prismcount, na.rm = TRUE)]
  npba <- npn*5
  Erafor_poly[id %in% i & Layer %in% "L1/L2", npBA := npba]
}


ITSL_poly[, Data_Source := "ITSL"]

invpoly <- rbind(Erafor_poly, ITSL_poly, fill = TRUE)

write.csv(invpoly,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_poly.csv", row.names = FALSE)
