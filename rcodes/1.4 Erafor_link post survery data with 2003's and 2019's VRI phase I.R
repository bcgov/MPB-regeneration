rm(list=ls())
library(data.table)
library(dplyr)
library(tidyr)

##Erafor survey

invdata <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Eraforcompile_InvTable_bcalbers.csv",header = TRUE))
invdata$Inventory_Standard = "Erafor"

erafor_layer <- invdata[,.(Opening,
                           Plot,
                           Layer,
                           Inventory_Standard = "Erafor",
                           SP,
                           Age,
                           Ht,
                           Count,
                           BAF = 5,
                           Prismcount)]

erafor_poly <- unique(invdata[,.(Opening,
                                 Plot,
                                 Survey_Date,
                                 Long,
                                 Lat)])

##VRI 2003 data cleaning

invdata_2003 <- data.table(read.table("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvTable_VRI2003.txt", sep = ",", header = TRUE))
inv2003_poly <- unique(data.table(Opening = invdata_2003$Opening,
                                  Plot = invdata_2003$Plot,
                                  TPH2003 = invdata_2003$VRI_LIVE_S,
                                  BA2003 = invdata_2003$BASAL_AREA))

invpoly <- merge(erafor_poly, inv2003_poly, by = c("Opening", "Plot"))

inv2003_SP1 <- data.table(Opening = invdata_2003$Opening,
                          Plot = invdata_2003$Plot,
                          Layer = 2003,
                          Inventory_Standard = "F",
                          SP = invdata_2003$SPECIES_CD,
                          PCT = invdata_2003$SPECIES_PC,
                          Age = invdata_2003$PROJ_AGE_1,
                          Ht = invdata_2003$PROJ_HEIGH)

inv2003_SP2 <- data.table(Opening = invdata_2003$Opening,
                          Plot = invdata_2003$Plot,
                          Layer = 2003,
                          Inventory_Standard = "F",
                          SP = invdata_2003$SPECIES__1,
                          PCT = invdata_2003$SPECIES__2,
                          Age = invdata_2003$PROJ_AGE_2,
                          Ht = invdata_2003$PROJ_HEI_1)

inv2003_SP2 <- inv2003_SP2[!SP %in% " "]

inv2003_SP3 <- data.table(Opening = invdata_2003$Opening,
                          Plot = invdata_2003$Plot,
                          Layer = 2003,
                          Inventory_Standard = "F",
                          SP = invdata_2003$SPECIES__3,
                          PCT = invdata_2003$SPECIES__4,
                          Age = NA,
                          Ht = NA)

inv2003_SP3 <- inv2003_SP3[!SP %in% " "]

inv2003_SP4 <- data.table(Opening = invdata_2003$Opening,
                          Plot = invdata_2003$Plot,
                          Layer = 2003,
                          Inventory_Standard = "F",
                          SP = invdata_2003$SPECIES__5,
                          PCT = invdata_2003$SPECIES__6,
                          Age = NA,
                          Ht = NA)
inv2003_SP4 <- inv2003_SP4[!SP %in% " "]

inv2003_layer <- unique(rbind(inv2003_SP1,inv2003_SP2,inv2003_SP3, inv2003_SP4))

invlayer <- rbind(erafor_layer, inv2003_layer, fill = TRUE)

##VRI 2019 data cleaning

invdata_2019 <- data.table(read.table("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvTable_VRI2019.txt", sep = ",", header = TRUE))

inv2019_poly <- unique(data.table(Opening = invdata_2019$Opening,
                                  Plot = invdata_2019$Plot,
                                  BEC = invdata_2019$BEC_ZONE_C,
                                  subBEC = invdata_2019$BEC_SUBZON,
                                  vaBEC = invdata_2019$BEC_VARIAN,
                                  SI2019 = invdata_2019$SITE_INDEX,
                                  CC2019 = invdata_2019$CROWN_CLOS,
                                  TPH2019 = invdata_2019$VRI_LIVE_S,
                                  BA2019 = invdata_2019$BASAL_AREA,
                                  VOL125_2019 = invdata_2019$LIVE_STAND,
                                  Dist_Type = invdata_2019$EARLIEST_N,
                                  Dist_year = invdata_2019$EARLIEST_1,
                                  Kill_PCT = invdata_2019$STAND_PERC))
inv2019_poly <- separate(data = inv2019_poly,
                         col = Dist_year,
                         into = "Dist_year",
                         sep = "-",
                         extra = "drop")
invpoly <- merge(invpoly, inv2019_poly, by = c("Opening", "Plot"))

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
                          Ht = invdata_2019$PROJ_HEIGH)

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
                          Ht = invdata_2019$PROJ_HEI_2)

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
                          Ht = NA)

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
                          Ht = NA)

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
                          Ht = NA)

inv2019_SP5 <- inv2019_SP5[!SP %in% " "]

inv2019_layer <- unique(rbind(inv2019_SP1,inv2019_SP2,inv2019_SP3, inv2019_SP4, inv2019_SP5))

invlayer <- rbind(invlayer, inv2019_layer, fill = TRUE)

##Assign a new plot number for each plot in each opening

plotn <- distinct(invlayer[, .(Opening, Plot)])
plotn[, id := 1:326]
invlayer <- merge(invlayer, plotn, by = c("Opening", "Plot"), all.x = TRUE)
invlayer <- relocate(invlayer,
                      id,
                      .before = Opening)

invpoly <- merge(invpoly, plotn, by = c("Opening", "Plot"), all.x = TRUE)
invpoly <- relocate(invpoly,
                     id,
                     .before = Opening)

##add BEC for all rows

bec <- distinct(invlayer[Layer %in% "2019", .(id, BEC, subBEC, vaBEC)])
invlayer[, c("BEC", "subBEC", "vaBEC") := NULL]
invlayer <- merge(invlayer, bec, by = "id", all.x = TRUE)

write.csv(invlayer,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer.csv", row.names = FALSE, na = "")
write.csv(invpoly,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly.csv", row.names = FALSE, na = "")


