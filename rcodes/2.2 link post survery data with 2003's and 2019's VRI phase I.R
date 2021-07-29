rm(list=ls())
library(data.table)
library(dplyr)
library(tidyr)

###ITSL survey

ITSL_layer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_Layer.csv"))
ITSL_poly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly.csv"))

ITSL_layer$Inventory_Standard <- "ITSL"

##VRI 2003 data cleaning

invdata_2003 <- data.table(read.table("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_VRI2003.txt", sep = ",", header = TRUE))
inv2003_poly <- data.table(id = invdata_2003$id,
                           TPH2003 = invdata_2003$VRI_LIVE_STEMS_PER_HA,
                           BA2003 = invdata_2003$BASAL_AREA)
invpoly <- merge(ITSL_poly, inv2003_poly, by= "id")

inv2003_SP1 <- data.table(id = invdata_2003$id,
                          Layer = 2003,
                          Inventory_Standard = invdata_2003$INVENTORY_STANDARD_CD,
                          SP = invdata_2003$SPECIES_CD_1,
                          PCT = invdata_2003$SPECIES_PCT_1,
                          Age = invdata_2003$PROJ_AGE_1,
                          Ht = invdata_2003$PROJ_HEIGHT_1)

inv2003_SP2 <- data.table(id = invdata_2003$id,
                          Layer = 2003,
                          Inventory_Standard = invdata_2003$INVENTORY_STANDARD_CD,
                          SP = invdata_2003$SPECIES_CD_2,
                          PCT = invdata_2003$SPECIES_PCT_2,
                          Age = invdata_2003$PROJ_AGE_2,
                          Ht = invdata_2003$PROJ_HEIGHT_2)

inv2003_SP2 <- inv2003_SP2[!SP %in% ""]

inv2003_SP3 <- data.table(id = invdata_2003$id,
                          Layer = 2003,
                          Inventory_Standard = invdata_2003$INVENTORY_STANDARD_CD,
                          SP = invdata_2003$SPECIES_CD_3,
                          PCT = invdata_2003$SPECIES_PCT_3,
                          Age = NA,
                          Ht = NA)

inv2003_SP3 <- inv2003_SP3[!SP %in% ""]

inv2003_SP4 <- data.table(id = invdata_2003$id,
                          Layer = 2003,
                          Inventory_Standard = invdata_2003$INVENTORY_STANDARD_CD,
                          SP = invdata_2003$SPECIES_CD_4,
                          PCT = invdata_2003$SPECIES_PCT_4,
                          Age = NA,
                          Ht = NA)

inv2003_SP4 <- inv2003_SP4[!SP %in% ""]

inv2003_SP5 <- data.table(id = invdata_2003$id,
                          Layer = 2003,
                          Inventory_Standard = invdata_2003$INVENTORY_STANDARD_CD,
                          SP = invdata_2003$SPECIES_CD_5,
                          PCT = invdata_2003$SPECIES_PCT_5,
                          Age = NA,
                          Ht = NA)

inv2003_SP5 <- inv2003_SP5[!SP %in% ""]

inv2003_layer <- rbind(inv2003_SP1,inv2003_SP2,inv2003_SP3, inv2003_SP4, inv2003_SP5)

setnames(ITSL_layer, "AGE", "Age")
setnames(ITSL_layer, "HT", "Ht")
invlayer <- rbind(ITSL_layer, inv2003_layer, fill=TRUE)

##VRI 2019 data cleaning

invdata_2019 <- data.table(read.table("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_VRI2019.txt", sep = ",", header = TRUE))
inv2019_poly <- distinct(data.table(id = invdata_2019$id,
                                    SI2019 = invdata_2019$SITE_INDEX,
                                    CC2019 = invdata_2019$CROWN_CLOSURE,
                                    TPH2019 = invdata_2019$VRI_LIVE_STEMS_PER_HA,
                                    BA2019 = invdata_2019$BASAL_AREA,
                                    VOL125_2019 = invdata_2019$LIVE_STAND_VOLUME_125,
                                    DeadVol125_2019 = invdata_2019$DEAD_STAND_VOLUME_125,
                                    Dist_Type = invdata_2019$EARLIEST_NONLOGGING_DIST_TYPE,
                                    Dist_year = invdata_2019$EARLIEST_NONLOGGING_DIST_DATE,
                                    Kill_PCT = invdata_2019$STAND_PERCENTAGE_DEAD))
inv2019_poly <- separate(data = inv2019_poly,
                         col = Dist_year,
                         into = "Dist_year",
                         sep = "-",
                         extra = "drop")
invpoly <- merge(invpoly, inv2019_poly, by = "id")

inv2019_SP1 <- data.table(id = invdata_2019$id,
                          Layer = 2019,
                          Inventory_Standard = invdata_2019$INVENTORY_STANDARD_CD,
                          SP = invdata_2019$SPECIES_CD_1,
                          PCT = invdata_2019$SPECIES_PCT_1,
                          Age = invdata_2019$PROJ_AGE_1,
                          Ht = invdata_2019$PROJ_HEIGHT_1)

inv2019_SP2 <- data.table(id = invdata_2019$id,
                          Layer = 2019,
                          Inventory_Standard = invdata_2019$INVENTORY_STANDARD_CD,
                          SP = invdata_2019$SPECIES_CD_2,
                          PCT = invdata_2019$SPECIES_PCT_2,
                          Age = invdata_2019$PROJ_AGE_2,
                          Ht = invdata_2019$PROJ_HEIGHT_2)

inv2019_SP2 <- inv2019_SP2[!SP %in% ""]

inv2019_SP3 <- data.table(id = invdata_2019$id,
                          Layer = 2019,
                          Inventory_Standard = invdata_2019$INVENTORY_STANDARD_CD,
                          SP = invdata_2019$SPECIES_CD_3,
                          PCT = invdata_2019$SPECIES_PCT_3,
                          Age = NA,
                          Ht = NA)

inv2019_SP3 <- inv2019_SP3[!SP %in% ""]

inv2019_SP4 <- data.table(id = invdata_2019$id,
                          Layer = 2019,
                          Inventory_Standard = invdata_2019$INVENTORY_STANDARD_CD,
                          SP = invdata_2019$SPECIES_CD_4,
                          PCT = invdata_2019$SPECIES_PCT_4,
                          Age = NA,
                          Ht = NA)

inv2019_SP4 <- inv2019_SP4[!SP %in% ""]

inv2019_SP5 <- data.table(id = invdata_2019$id,
                          Layer = 2019,
                          Inventory_Standard = invdata_2019$INVENTORY_STANDARD_CD,
                          SP = invdata_2019$SPECIES_CD_5,
                          PCT = invdata_2019$SPECIES_PCT_5,
                          Age = NA,
                          Ht = NA)

inv2019_SP5 <- inv2019_SP5[!SP %in% ""]

inv2019_layer <- rbind(inv2019_SP1,inv2019_SP2,inv2019_SP3, inv2019_SP4, inv2019_SP5)

invlayer <- rbind(invlayer, inv2019_layer)

##Add bec for layer

bec <- distinct(invpoly[,.(id, BEC, subBEC, vaBEC, BEC_sub_va)])
invlayer <- merge(invlayer, bec, by = "id")

write.csv(invlayer,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer_VRI0319.csv", row.names = FALSE, na = "")
write.csv(invpoly,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly_VRI0319.csv", row.names = FALSE, na = "")
