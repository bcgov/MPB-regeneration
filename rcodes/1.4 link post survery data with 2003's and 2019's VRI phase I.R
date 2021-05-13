rm(list=ls())
library(data.table)
library(dplyr)
library(tidyr)

##VRI 2003 data cleaning

invdata_2003 <- data.table(read.table("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvTable_VRI2003.txt", sep = ",", header = TRUE))
inv2003_SP1 <- data.table(Opening = invdata_2003$Opening,
                          Plot = invdata_2003$Plot,
                          Layer = 2003,
                          Inventory_Standard = "F",
                          SP = invdata_2003$SPECIES_CD,
                          PCT = invdata_2003$SPECIES_PC,
                          Age = invdata_2003$PROJ_AGE_1,
                          Ht = invdata_2003$PROJ_HEIGH,
                          Stand_SI = invdata_2003$SITE_INDEX,
                          Stand_CC = invdata_2003$CROWN_CLOS,
                          Stand_QMD125 = invdata_2003$QUAD_DIAM_,
                          Stand_TPH = invdata_2003$VRI_LIVE_S,
                          Stand_BA = invdata_2003$BASAL_AREA,
                          Stand_VOL125 = invdata_2003$LIVE_STAND)

inv2003_SP2 <- data.table(Opening = invdata_2003$Opening,
                          Plot = invdata_2003$Plot,
                          Layer = 2003,
                          Inventory_Standard = "F",
                          SP = invdata_2003$SPECIES__1,
                          PCT = invdata_2003$SPECIES__2,
                          Age = invdata_2003$PROJ_AGE_2,
                          Ht = invdata_2003$PROJ_HEI_1,
                          Stand_SI = invdata_2003$SITE_INDEX,
                          Stand_CC = invdata_2003$CROWN_CLOS,
                          Stand_QMD125 = invdata_2003$QUAD_DIAM_,
                          Stand_TPH = invdata_2003$VRI_LIVE_S,
                          Stand_BA = invdata_2003$BASAL_AREA,
                          Stand_VOL125 = invdata_2003$LIVE_STAND)

inv2003_SP2 <- inv2003_SP2[!SP %in% " "]

inv2003_SP3 <- data.table(Opening = invdata_2003$Opening,
                          Plot = invdata_2003$Plot,
                          Layer = 2003,
                          Inventory_Standard = "F",
                          SP = invdata_2003$SPECIES__3,
                          PCT = invdata_2003$SPECIES__4,
                          Age = NA,
                          Ht = NA,
                          Stand_SI = invdata_2003$SITE_INDEX,
                          Stand_CC = invdata_2003$CROWN_CLOS,
                          Stand_QMD125 = invdata_2003$QUAD_DIAM_,
                          Stand_TPH = invdata_2003$VRI_LIVE_S,
                          Stand_BA = invdata_2003$BASAL_AREA,
                          Stand_VOL125 = invdata_2003$LIVE_STAND)

inv2003_SP3 <- inv2003_SP3[!SP %in% " "]

inv2003_SP4 <- data.table(Opening = invdata_2003$Opening,
                          Plot = invdata_2003$Plot,
                          Layer = 2003,
                          Inventory_Standard = "F",
                          SP = invdata_2003$SPECIES__5,
                          PCT = invdata_2003$SPECIES__6,
                          Age = NA,
                          Ht = NA,
                          Stand_SI = invdata_2003$SITE_INDEX,
                          Stand_CC = invdata_2003$CROWN_CLOS,
                          Stand_QMD125 = invdata_2003$QUAD_DIAM_,
                          Stand_TPH = invdata_2003$VRI_LIVE_S,
                          Stand_BA = invdata_2003$BASAL_AREA,
                          Stand_VOL125 = invdata_2003$LIVE_STAND)
inv2003_SP4 <- inv2003_SP4[!SP %in% " "]

inv2003 <- unique(rbind(inv2003_SP1,inv2003_SP2,inv2003_SP3, inv2003_SP4))
setorder(inv2003, Opening, Plot)

##Combine post-MPB survey data with VRI 2003

invdata <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Eraforcompile_InvTable_bcalbers.csv",header = TRUE))

invdata[,c("GPSlat","GPSlong","Long","Lat") := NULL]

# invdata[Layer %in% "L1/L2", Layer := "Post-survey"]
# invdata[Layer %in% "L3/L4", Layer := "Regen"]
# setnames(invdata,"Layer", "Status")

invdata$Inventory_Standard = "Erafor"

inv_post2003_com <- rbind(inv2003, invdata, fill= TRUE)

setorder(inv_post2003_com, Opening, Plot)

inv_post2003_com <- relocate(inv_post2003_com, Count, .before = Stand_SI)

##VRI 2019 data cleaning

invdata_2019 <- data.table(read.table("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvTable_VRI2019.txt", sep = ",", header = TRUE))

inv2019_SP1 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Layer = 2019,
                          Inventory_Standard = invdata_2019$INVENTORY_,
                          BEC = invdata_2019$BEC_ZONE_C,
                          subBEC = invdata_2019$BEC_SUBZON,
                          vaBEC = invdata_2019$BEC_VARIAN,
                          SP = invdata_2019$SPECIES_CD,
                          PCT = invdata_2019$SPECIES_PC,
                          Age = invdata_2019$PROJ_AGE_1,
                          Ht = invdata_2019$PROJ_HEIGH,
                          Stand_SI = invdata_2019$SITE_INDEX,
                          Stand_CC = invdata_2019$CROWN_CLOS,
                          Stand_QMD125 = invdata_2019$QUAD_DIAM_,
                          Stand_TPH = invdata_2019$VRI_LIVE_S,
                          Stand_BA = invdata_2019$BASAL_AREA,
                          Stand_VOL125 = invdata_2019$LIVE_STAND,
                          Dist_Type = invdata_2019$EARLIEST_N,
                          Dist_year = invdata_2019$EARLIEST_1,
                          Kill_PCT = invdata_2019$STAND_PERC)

inv2019_SP2 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Layer = 2019,
                          Inventory_Standard = invdata_2019$INVENTORY_,
                          BEC = invdata_2019$BEC_ZONE_C,
                          subBEC = invdata_2019$BEC_SUBZON,
                          vaBEC = invdata_2019$BEC_VARIAN,
                          SP = invdata_2019$SPECIES__1,
                          PCT = invdata_2019$SPECIES__2,
                          Age = invdata_2019$PROJ_AGE_2,
                          Ht = invdata_2019$PROJ_HEI_2,
                          Stand_SI = invdata_2019$SITE_INDEX,
                          Stand_CC = invdata_2019$CROWN_CLOS,
                          Stand_QMD125 = invdata_2019$QUAD_DIAM_,
                          Stand_TPH = invdata_2019$VRI_LIVE_S,
                          Stand_BA = invdata_2019$BASAL_AREA,
                          Stand_VOL125 = invdata_2019$LIVE_STAND,
                          Dist_Type = invdata_2019$EARLIEST_N,
                          Dist_year = invdata_2019$EARLIEST_1,
                          Kill_PCT = invdata_2019$STAND_PERC)

inv2019_SP2 <- inv2019_SP2[!SP %in% " "]

inv2019_SP3 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Layer = 2019,
                          Inventory_Standard = invdata_2019$INVENTORY_,
                          BEC = invdata_2019$BEC_ZONE_C,
                          subBEC = invdata_2019$BEC_SUBZON,
                          vaBEC = invdata_2019$BEC_VARIAN,
                          SP = invdata_2019$SPECIES__3,
                          PCT = invdata_2019$SPECIES__4,
                          Age = NA,
                          Ht = NA,
                          Stand_SI = invdata_2019$SITE_INDEX,
                          Stand_CC = invdata_2019$CROWN_CLOS,
                          Stand_QMD125 = invdata_2019$QUAD_DIAM_,
                          Stand_TPH = invdata_2019$VRI_LIVE_S,
                          Stand_BA = invdata_2019$BASAL_AREA,
                          Stand_VOL125 = invdata_2019$LIVE_STAND,
                          Dist_Type = invdata_2019$EARLIEST_N,
                          Dist_year = invdata_2019$EARLIEST_1,
                          Kill_PCT = invdata_2019$STAND_PERC)

inv2019_SP3 <- inv2019_SP3[!SP %in% " "]

inv2019_SP4 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Layer = 2019,
                          Inventory_Standard = invdata_2019$INVENTORY_,
                          BEC = invdata_2019$BEC_ZONE_C,
                          subBEC = invdata_2019$BEC_SUBZON,
                          vaBEC = invdata_2019$BEC_VARIAN,
                          SP = invdata_2019$SPECIES__5,
                          PCT = invdata_2019$SPECIES__6,
                          Age = NA,
                          Ht = NA,
                          Stand_SI = invdata_2019$SITE_INDEX,
                          Stand_CC = invdata_2019$CROWN_CLOS,
                          Stand_QMD125 = invdata_2019$QUAD_DIAM_,
                          Stand_TPH = invdata_2019$VRI_LIVE_S,
                          Stand_BA = invdata_2019$BASAL_AREA,
                          Stand_VOL125 = invdata_2019$LIVE_STAND,
                          Dist_Type = invdata_2019$EARLIEST_N,
                          Dist_year = invdata_2019$EARLIEST_1,
                          Kill_PCT = invdata_2019$STAND_PERC)

inv2019_SP4 <- inv2019_SP4[!SP %in% " "]

inv2019_SP5 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Layer = 2019,
                          Inventory_Standard = invdata_2019$INVENTORY_,
                          BEC = invdata_2019$BEC_ZONE_C,
                          subBEC = invdata_2019$BEC_SUBZON,
                          vaBEC = invdata_2019$BEC_VARIAN,
                          SP = invdata_2019$SPECIES__7,
                          PCT = invdata_2019$SPECIES__8,
                          Age = NA,
                          Ht = NA,
                          Stand_SI = invdata_2019$SITE_INDEX,
                          Stand_CC = invdata_2019$CROWN_CLOS,
                          Stand_QMD125 = invdata_2019$QUAD_DIAM_,
                          Stand_TPH = invdata_2019$VRI_LIVE_S,
                          Stand_BA = invdata_2019$BASAL_AREA,
                          Stand_VOL125 = invdata_2019$LIVE_STAND,
                          Dist_Type = invdata_2019$EARLIEST_N,
                          Dist_year = invdata_2019$EARLIEST_1,
                          Kill_PCT = invdata_2019$STAND_PERC)

inv2019_SP5 <- inv2019_SP5[!SP %in% " "]

inv2019 <- unique(rbind(inv2019_SP1,inv2019_SP2,inv2019_SP3, inv2019_SP4, inv2019_SP5))
setorder(inv2019, Opening, Plot)

##Combine post-survy, 2003 and 2019 all together

inv_allyr <- rbind(inv_post2003_com,inv2019, fill = TRUE)

##Assign a new plot number for each plot in each opening

plotn <- distinct(inv_allyr[, .(Opening, Plot)])
plotn[, id := 1:326]
inv_allyr <- merge(inv_allyr, plotn, by = c("Opening", "Plot"), all.x = TRUE)
inv_allyr <- relocate(inv_allyr,
                      id,
                      .before = Layer)

##add BEC for all rows

bec <- distinct(inv_allyr[Layer %in% "2019", .(id, BEC, subBEC, vaBEC)])
inv_allyr[, c("BEC", "subBEC", "vaBEC") := NULL]
inv_allyr <- merge(inv_allyr, bec, by = "id", all.x = TRUE)

inv_allyr <- relocate(inv_allyr,BEC, subBEC, vaBEC, .before = SP)

inv_allyr <- separate(data = inv_allyr,
                      col = Dist_year,
                      into = "Dist_year",
                      sep = "-",
                      extra = "drop")


write.csv(inv_allyr,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Eraforcompile_InvTable_VRI0319.csv", row.names = FALSE, na = "")



