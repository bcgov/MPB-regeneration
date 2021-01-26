###########################
#####ITSL data summary#####
###########################

rm(list=ls())
library(data.table)
library(tidyr)
library(reshape2)
library(dplyr)

ITSL_poly <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly.csv"))
ITSL_layer <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer.csv"))
ITSL_layer_sp <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer_sp.csv"))

ITSL_poly[,.N, by = BEC]

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

write.csv(ITSL_poly,file.path(ITSLdatapath_compiled, "ITSL_poly.csv"), row.names = FALSE)















