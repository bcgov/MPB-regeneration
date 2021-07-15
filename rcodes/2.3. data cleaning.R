
rm(list=ls())
library(data.table)
library(tidyr)
library(reshape2)
library(dplyr)

ITSL_poly <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly_VRI0319.csv"))
ITSL_layer <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer_VRI0319.csv"))

unique(ITSL_layer$SP)

# [1] "PL"  "FD"  "S"   ""    "SE"  "AT"  "CW"  "PLI" "BL"  "B"   "H"   "SW"  "SX"  "AC"
# [15] "EP"  "F"   "E"   "C"   "PA"  "FDI" "HW"  "SXL" "LW"  "PY"  "PW"  "ACT"

ITSL_layer[SP %in% c("PL", "PLI"), SP := "PL"]
ITSL_layer[SP %in% c("FD", "FDI", "F"), SP := "FD"]
ITSL_layer[SP %in% c("CW", "C"), SP := "CW"]
ITSL_layer[SP %in% c("SX", "SXL"), SP := "SX"]
ITSL_layer[SP %in% c("AC", "ACT"), SP := "AC"]
ITSL_layer[SP %in% "", SP := "UNK"]

##There might have duplicated species in one id's one layer due to species name unify
##check if there is any

dupid <- NULL
for(i in unique(ITSL_layer$id)){
  tmp <- ITSL_layer[id %in% i]
  tmp1 <- tmp[Layer %in% "1", SP]
  tmp2 <- tmp[Layer %in% "2", SP]
  tmp3 <- tmp[Layer %in% "3", SP]
  tmp4 <- tmp[Layer %in% "4", SP]
  tmp03 <- tmp[Layer %in% "2003", SP]
  tmp19 <- tmp[Layer %in% "2019", SP]
  dup <- c(duplicated(tmp1), duplicated(tmp2), duplicated(tmp4), duplicated(tmp4), duplicated(tmp03), duplicated(tmp19))
  if(is.element(TRUE, dup)){
    dupid <- c(dupid, i)
  }
}


write.csv(ITSL_layer, "//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer_VRI0319_cleaned.csv", row.names = FALSE, na = "")

