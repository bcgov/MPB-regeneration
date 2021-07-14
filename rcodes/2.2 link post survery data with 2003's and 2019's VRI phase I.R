rm(list=ls())
library(data.table)
library(dplyr)
library(tidyr)

##VRI 2003 data cleaning

invdata_2003 <- data.table(read.table("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_VRI2003.txt", sep = ",", header = TRUE))
inv2003_poly <- data.table(id = invdata_2003$id,
                           Layer = 2003,
                           Inventory_Standard = invdata_2003$INVENTORY_STANDARD_CD,
                           BEC = invdata_2003$BEC_ZONE_CODE,
                           subBEC = invdata_2003$BEC_SUBZONE,
                           vaBEC = invdata_2003$BEC_VARIANT,
                           Stand_SI = invdata_2003$SITE_INDEX,
                           Stand_CC = invdata_2003$CROWN_CLOSURE,
                           Stand_QMD125 = invdata_2003$QUAD_DIAM_125,
                           Stand_TPH = invdata_2003$VRI_LIVE_STEMS_PER_HA,
                           Stand_BA = invdata_2003$BASAL_AREA,
                           Stand_VOL125 = invdata_2003$LIVE_STAND_VOLUME_125)

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

##VRI 2019 data cleaning

invdata_2019 <- data.table(read.table("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_VRI2019.txt", sep = ",", header = TRUE))
inv2019_poly <- distinct(data.table(id = invdata_2019$id,
                                    Layer = 2019,
                                    Inventory_Standard = invdata_2019$INVENTORY_STANDARD_CD,
                                    BEC = invdata_2019$BEC_ZONE_CODE,
                                    subBEC = invdata_2019$BEC_SUBZONE,
                                    vaBEC = invdata_2019$BEC_VARIANT,
                                    Stand_SI = invdata_2019$SITE_INDEX,
                                    Stand_CC = invdata_2019$CROWN_CLOSURE,
                                    Stand_QMD125 = invdata_2019$QUAD_DIAM_125,
                                    Stand_TPH = invdata_2019$VRI_LIVE_STEMS_PER_HA,
                                    Stand_BA = invdata_2019$BASAL_AREA,
                                    Stand_VOL125 = invdata_2019$LIVE_STAND_VOLUME_125,
                                    Stand_DeadVol125 = invdata_2019$DEAD_STAND_VOLUME_125,
                                    Dist_Type = invdata_2019$EARLIEST_NONLOGGING_DIST_TYPE,
                                    Dist_year = invdata_2019$EARLIEST_NONLOGGING_DIST_DATE,
                                    Kill_PCT = invdata_2019$STAND_PERCENTAGE_DEAD))

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

##Combine post-survy, 2003 and 2019 all together

inv_layer <- rbind(inv_layer,inv2019_layer, fill = TRUE)
inv_poly <- rbind(inv_poly, inv2019_poly, fill = TRUE)

##BEC

unique(inv_poly[Layer %in% "2003"]$vaBEC)
#[1] "1" "3" NA  "2" "4"

unique(inv_poly[Layer %in% "2019"]$vaBEC)
#[1] "1" "3" NA  "2" "4"

inv_poly$vaBEC <- as.character(inv_poly$vaBEC)
inv_poly[Layer %in% "2003" & vaBEC %in% NA, vaBEC := ""]
inv_poly[Layer %in% "2019" & vaBEC %in% NA, vaBEC := ""]
inv_poly[Layer %in% "2003" | Layer %in% "2019",BEC_sub_va := paste0(BEC,subBEC, vaBEC)]

##ids that bec zone from ITSL survey is different from VRI

id <- NULL
for (i in unique(inv_poly$id)){
  bec03 <- inv_poly[id %in% i & Layer %in% "2003", unique(BEC_sub_va)]
  bec19 <- inv_poly[id %in% i & Layer %in% "2019", unique(BEC_sub_va)]
  bec <- inv_poly[id %in% i & Layer %in% "L1/L2", unique(BEC_sub_va)]

  if(bec03 == bec19 & bec19 == bec){
    tmpid <- NULL
    id <- c(id, tmpid)
  }else{
    tmpid <- i
    id <- c(id, tmpid)
  }
}

##Add bec for layer

bec <- distinct(inv_poly[,.(id, Layer, BEC, subBEC, vaBEC, BEC_sub_va)])
inv_layer <- merge(inv_layer, bec, by = c("id", "Layer"))

#inv_poly <- relocate(inv_poly,BEC, subBEC, vaBEC, .before = SP)

inv_poly <- separate(data = inv_poly,
                      col = Dist_year,
                      into = "Dist_year",
                      sep = "-",
                      extra = "drop")


write.csv(inv_layer,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer_VRI0319.csv", row.names = FALSE, na = "")
write.csv(inv_poly,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly_VRI0319.csv", row.names = FALSE, na = "")
