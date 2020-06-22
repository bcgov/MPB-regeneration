library(data.table)
library(dplyr)
invdata_2003 <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvTable_2003.csv", header = TRUE))

##VRI 2003 data cleaning

inv2003_SP1 <- data.table(Opening = invdata_2003$Opening,
                          Plot = invdata_2003$Plot,
                          Status = 2003,
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
                          Status = 2003,
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
                          Status = 2003,
                          Inventory_Standard = "F",
                          SP = invdata_2003$SPECIES__3,
                          PCT = invdata_2003$SPECIES__4,
                          Age = 0,
                          Ht = 0,
                          Stand_SI = invdata_2003$SITE_INDEX,
                          Stand_CC = invdata_2003$CROWN_CLOS,
                          Stand_QMD125 = invdata_2003$QUAD_DIAM_,
                          Stand_TPH = invdata_2003$VRI_LIVE_S,
                          Stand_BA = invdata_2003$BASAL_AREA,
                          Stand_VOL125 = invdata_2003$LIVE_STAND)

inv2003_SP3 <- inv2003_SP3[!SP %in% " "]

inv2003 <- unique(rbind(inv2003_SP1,inv2003_SP2,inv2003_SP3))
setorder(inv2003, Opening, Plot)

##Combine post-MPB survey data with VRI 2003

invdata <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Eraforcompile_InvTable_bcalbers.csv",header = TRUE))

invdata[,c("Plot_status","GPSlat","GPSlong","Long","Lat") := NULL]

invdata[Layer %in% "L1/L2", Layer := "Post-survey"]
invdata[Layer %in% "L3/L4", Layer := "Regen"]
setnames(invdata,"Layer", "Status")
setnames(invdata,"CC","Stand_CC")

invdata$Inventory_Standard = "FFT survey from Erafor"

inv_post2003_com <- rbind(inv2003, invdata, fill= TRUE)

setorder(inv_post2003_com, Opening, Plot)

inv_post2003_com <- relocate(inv_post2003_com, Count, .before = Stand_SI)

##VRI 2019 data cleaning

invdata_2019 <- data.table(read.table("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvTable_2019.txt", sep = ",", header = TRUE))

inv2019_SP1 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Status = 2019,
                          Inventory_Standard = "V",
                          BEC = invdata_2019$BEC_ZONE_C,
                          BEC_sub = invdata_2019$BEC_SUBZON,
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
                          Status = 2019,
                          Inventory_Standard = "V",
                          BEC = invdata_2019$BEC_ZONE_C,
                          BEC_sub = invdata_2019$BEC_SUBZON,
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
                          Status = 2019,
                          Inventory_Standard = "V",
                          BEC = invdata_2019$BEC_ZONE_C,
                          BEC_sub = invdata_2019$BEC_SUBZON,
                          SP = invdata_2019$SPECIES__3,
                          PCT = invdata_2019$SPECIES__4,
                          Age = 0,
                          Ht = 0,
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
                          Status = 2019,
                          Inventory_Standard = "V",
                          BEC = invdata_2019$BEC_ZONE_C,
                          BEC_sub = invdata_2019$BEC_SUBZON,
                          SP = invdata_2019$SPECIES__5,
                          PCT = invdata_2019$SPECIES__6,
                          Age = 0,
                          Ht = 0,
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
                          Status = 2019,
                          Inventory_Standard = "V",
                          BEC = invdata_2019$BEC_ZONE_C,
                          BEC_sub = invdata_2019$BEC_SUBZON,
                          SP = invdata_2019$SPECIES__7,
                          PCT = invdata_2019$SPECIES__8,
                          Age = 0,
                          Ht = 0,
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
setorder(inv_allyr, Opening, Plot, Status)

##Remove all plots which disturbance type shown in year 2019 is not "IBM"

test <- inv_allyr[Status %in% "2019" & Dist_Type %in% "IBM", c("Opening", "Plot")]

test <- unique(test)

sub_inv_allyr <- NULL
for ( i in 1:dim(test)[1]){
  opening <- test$Opening[i]
  plot <- test$Plot[i]
  sub <- inv_allyr[Opening %in% opening & Plot %in% plot]
  bec <- sub[Status %in% "2019",unique(BEC)]
  subbec <- sub[Status %in% "2019",unique(BEC_sub)]
  sub$BEC <- bec
  sub$BEC_sub <- subbec
  sub_inv_allyr <- rbind(sub_inv_allyr, sub)
  rm(sub, bec, subbec)
}

sub_inv_allyr <- relocate(sub_inv_allyr,BEC, BEC_sub, .before = SP)

write.csv(sub_inv_allyr,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvTable_post0319.csv", row.names = FALSE, na = "")



