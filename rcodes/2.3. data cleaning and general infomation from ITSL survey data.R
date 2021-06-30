###########################
#####ITSL data summary#####
###########################

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

data <- ITSL_layer[Layer %in% "2003", .(id, SP, PCT)]
data[SP %in% "PL" & PCT >= 70 & PCT != 100]
pid <- data[SP %in% "PL" & PCT >= 70, unique(id)]
data1 <- data[! id %in% pid]
data1 <- data1[,.(SP = paste(SP,PCT)),by= id]
data1[, SPcomp := Reduce(paste, SP), by=id]
data1[,SP := NULL]
data1 <- unique(data1)
data1 <- data1[, .N, by = SPcomp]
setorder(data1,-N)
data1

ITSL_poly[Layer %in% "L1/L2",.N, by = BEC_sub_va]

# BEC      N
# IDFdk1  46
# IDFdk2  11
# IDFdk3 112
# IDFdk4  29
# SBSmc1  23
# SBSmc2  11
# SBSmm   22    SBSmm01   1
# SBSdw1  67
# SBSdw2   4
# ICHdk    1
# ICHmk3   4
# ICHmw3   2
# ESSFwk1  4
# ESSFxc  22
# ESSFdc2  9
# MSdm2   19
# MSdc1    4
# MSxk   155   MSxk1    1
# MSxk2   22
# MSxv     7
# SBPSmk  77   SBPS mk 01   2
# SBPS mk 04   1
# SBPSxc  56   SBSPxc   1   SBPxc   1
# SBPSdc   2
# SBPSxk   2


ITSL_poly[BEC %in% "SBSmm01", BEC := "SBSmm"]
ITSL_poly[BEC %in% c("SBPS mk 01", "SBPS mk 04"), BEC := "SBPSmk"]
ITSL_poly[BEC %in% c("SBSPxc", "SBPxc"), BEC := "SBPSxc"]
ITSL_poly[BEC %in% "MSxk", BEC := "MSxk1"]

ITSL_poly[,.N, by = BEC]
ITSL_poly[,.N, by = TSA]

#                 TSA   N
# 1: Okanagan-Shuswap   6
# 2:         100 Mile 301
# 3:         Kamloops 200
# 4:          Merritt  64
# 5:         Lillooet  32
# 6:    Williams Lake 115


#####abundance and distribution of regeneration

regen <- ITSL_layer[Layer %in% "L3/L4"]

a <- regen[,.(N1 = sum(PCT, na.rm = TRUE)), by = .(SP, BEC_sub_va)]
a[,N2 := sum(N1), by = BEC_sub_va]
a[,PCT := round(100*N1/N2, digits = 0)]

a <- a[order(a$BEC_sub_va)]
print(a, nrows = 103)


write.csv(ITSL_poly, "//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly_VRI0319.csv", row.names = FALSE, na = "")
write.csv(ITSL_layer, "//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer_VRI0319.csv", row.names = FALSE, na = "")

