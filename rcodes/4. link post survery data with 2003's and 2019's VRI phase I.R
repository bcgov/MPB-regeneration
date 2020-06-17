library(data.table)
invdata_2019 <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvTable_2019.csv", header = TRUE))

##VRI 2019 data cleaning

inv2019_SP1 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Status = 2019,
                          CC = invdata_2019$CROWN_CLOS,
                          SP = invdata_2019$SPECIES_CD,
                          PCT = invdata_2019$SPECIES_PC,
                          Age = invdata_2019$PROJ_AGE_1,
                          Ht = invdata_2019$PROJ_HEIGH,
                          SI = invdata_2019$SITE_INDEX,
                          Stand_BA = invdata_2019$BASAL_AREA,
                          Stand_VOL125 = invdata_2019$LIVE_STAND)

inv2019_SP2 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Status = 2019,
                          CC = invdata_2019$CROWN_CLOS,
                          SP = invdata_2019$SPECIES__1,
                          PCT = invdata_2019$SPECIES__2,
                          Age = invdata_2019$PROJ_AGE_2,
                          Ht = invdata_2019$PROJ_HEI_1,
                          SI = invdata_2019$SITE_INDEX,
                          Stand_BA = invdata_2019$BASAL_AREA,
                          Stand_VOL125 = invdata_2019$LIVE_STAND)

inv2019_SP2 <- inv2019_SP2[!SP %in% " "]

inv2019_SP3 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Status = 2019,
                          CC = invdata_2019$CROWN_CLOS,
                          SP = invdata_2019$SPECIES__3,
                          PCT = invdata_2019$SPECIES__4,
                          Age = 0,
                          Ht = 0,
                          SI = invdata_2019$SITE_INDEX,
                          Stand_BA = invdata_2019$BASAL_AREA,
                          Stand_VOL125 = invdata_2019$LIVE_STAND)

inv2019_SP3 <- inv2019_SP3[!SP %in% " "]

inv2019 <- unique(rbind(inv2019_SP1,inv2019_SP2,inv2019_SP3))
setorder(inv2019, Opening, Plot)

##Combine post-MPB survey data with VRI 2019

invdata <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Eraforcompile_InvTable_bcalbers.csv",header = TRUE))

invdata[,c("Plot_status","GPSlat","GPSlong","Long","Lat") := NULL]

invdata[Layer %in% "L1/L2", Layer := "Post-survey"]
invdata[Layer %in% "L3/L4", Layer := "Regen"]
setnames(invdata,"Layer", "Status")

inv_post_2019 <- rbind(inv2019, invdata, fill= TRUE)

setorder(inv_post_2019, Opening, Plot)

##VRI 2019 data cleaning

invdata_2019 <- data.table(read.table("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvTable_2019.txt", sep = ",", header = TRUE))

inv2019_SP1 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Status = 2019,
                          CC = invdata_2019$CROWN_CLOS,
                          SP = invdata_2019$SPECIES_CD,
                          PCT = invdata_2019$SPECIES_PC,
                          Age = invdata_2019$PROJ_AGE_1,
                          Ht = invdata_2019$PROJ_HEIGH,
                          SI = invdata_2019$SITE_INDEX,
                          Stand_BA = invdata_2019$BASAL_AREA,
                          Stand_VOL125 = invdata_2019$LIVE_STAND,
                          Dist_Type = invdata_2019$EARLIEST_N,
                          Dist_year = invdata_2019$EARLIEST_1,
                          Kill_PCT = invdata_2019$STAND_PERC)

inv2019_SP2 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Status = 2019,
                          CC = invdata_2019$CROWN_CLOS,
                          SP = invdata_2019$SPECIES__1,
                          PCT = invdata_2019$SPECIES__2,
                          Age = invdata_2019$PROJ_AGE_2,
                          Ht = invdata_2019$PROJ_HEI_2,
                          SI = invdata_2019$SITE_INDEX,
                          Stand_BA = invdata_2019$BASAL_AREA,
                          Stand_VOL125 = invdata_2019$LIVE_STAND,
                          Dist_Type = invdata_2019$EARLIEST_N,
                          Dist_year = invdata_2019$EARLIEST_1,
                          Kill_PCT = invdata_2019$STAND_PERC)

inv2019_SP2 <- inv2019_SP2[!SP %in% " "]

inv2019_SP3 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Status = 2019,
                          CC = invdata_2019$CROWN_CLOS,
                          SP = invdata_2019$SPECIES__3,
                          PCT = invdata_2019$SPECIES__4,
                          Age = 0,
                          Ht = 0,
                          SI = invdata_2019$SITE_INDEX,
                          Stand_BA = invdata_2019$BASAL_AREA,
                          Stand_VOL125 = invdata_2019$LIVE_STAND,
                          Dist_Type = invdata_2019$EARLIEST_N,
                          Dist_year = invdata_2019$EARLIEST_1,
                          Kill_PCT = invdata_2019$STAND_PERC)

inv2019_SP3 <- inv2019_SP3[!SP %in% " "]

inv2019_SP4 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Status = 2019,
                          CC = invdata_2019$CROWN_CLOS,
                          SP = invdata_2019$SPECIES__5,
                          PCT = invdata_2019$SPECIES__6,
                          Age = 0,
                          Ht = 0,
                          SI = invdata_2019$SITE_INDEX,
                          Stand_BA = invdata_2019$BASAL_AREA,
                          Stand_VOL125 = invdata_2019$LIVE_STAND,
                          Dist_Type = invdata_2019$EARLIEST_N,
                          Dist_year = invdata_2019$EARLIEST_1,
                          Kill_PCT = invdata_2019$STAND_PERC)

inv2019_SP4 <- inv2019_SP4[!SP %in% " "]

inv2019_SP5 <- data.table(Opening = invdata_2019$Opening,
                          Plot = invdata_2019$Plot,
                          Status = 2019,
                          CC = invdata_2019$CROWN_CLOS,
                          SP = invdata_2019$SPECIES__7,
                          PCT = invdata_2019$SPECIES__8,
                          Age = 0,
                          Ht = 0,
                          SI = invdata_2019$SITE_INDEX,
                          Stand_BA = invdata_2019$BASAL_AREA,
                          Stand_VOL125 = invdata_2019$LIVE_STAND,
                          Dist_Type = invdata_2019$EARLIEST_N,
                          Dist_year = invdata_2019$EARLIEST_1,
                          Kill_PCT = invdata_2019$STAND_PERC)

inv2019_SP5 <- inv2019_SP5[!SP %in% " "]

inv2019 <- unique(rbind(inv2019_SP1,inv2019_SP2,inv2019_SP3, inv2019_SP4, inv2019_SP5))
setorder(inv2019, Opening, Plot)

inv_allyr <- rbind(inv_post_2003,inv2019, fill = TRUE)
setorder(inv_allyr, Opening, Plot, Status)

##Remove all plots which disturbance type shown in year 2019 is not "IBM"

test <- inv_allyr[Status %in% "2019" & Dist_Type %in% "IBM", c("Opening", "Plot")]

unique(test)

sub_inv_allyr <- NULL
for ( i in 1:dim(test)[1]){
  opening <- test$Opening[i]
  plot <- test$Plot[i]
  sub <- inv_allyr[Opening %in% opening & Plot %in% plot]
  sub_inv_allyr <- rbind(sub_inv_allyr, sub)
}

write.csv(sub_inv_allyr,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvTable_post0319.csv", row.names = FALSE, na = "")



