rm(list = ls())
library(data.table)
library(tidyr)

##understory

under <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory_cleaned_SI_Cl1Updated_regen.csv"))
setnames(under, "Class", "Layer")
sumcount <- under[,.(sumcount = sum(Count)), by = .(Plot, Layer)]
under1 <- merge(under, sumcount, by = c("Plot", "Layer"))
under1[,PCT := round(100 * Count/sumcount, digits = 0)]

setcolorder(under1, c("Plot", "Layer", "SP", "PCT"))
under1[,sumcount := NULL]

p <- unique(under1$Plot)

##overstory

over <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory.csv"))
over <- over[Call_Num %in% p]
over_sp1 <- over[,.(Plot = Call_Num,
                   Layer,
                   SP = Spcs_1,
                   PCT = Sp1_pct,
                   Age = Sp1_Age,
                   Ht = Sp1_Ht)]
over_sp1 <- over_sp1[!SP %in% NA]
over_sp2 <- over[,.(Plot = Call_Num,
                    Layer,
                    SP = Spcs_2,
                    PCT = Sp2_pct,
                    Age = Sp2_Age,
                    Ht = Sp2_Ht)]
over_sp2 <- over_sp2[!SP %in% NA]
over_sp2 <- over_sp2[!PCT %in% 0]
over_sp3 <- over[,.(Plot = Call_Num,
                    Layer,
                    SP = Spcs_3,
                    PCT = Sp3_pct)]
over_sp3 <- over_sp3[!SP %in% NA]
over_sp3 <- over_sp3[!PCT %in% 0]
over_sp4 <- over[,.(Plot = Call_Num,
                    Layer,
                    SP = Spcs_4,
                    PCT = Sp4_pct)]
over_sp4 <- over_sp4[!SP %in% NA]
over_sp4 <- over_sp4[!PCT %in% 0]

over_layer <- rbind(over_sp1, over_sp2, over_sp3, over_sp4, fill = TRUE)
setorder(over_layer, Plot)
over_layer[Layer %in% "1", Layer := "O"]
over_layer[SP %in% "PLI", SP := "PL"]
over_layer[SP %in% "FDI", SP := "FD"]



over_poly <- over[,.(Plot = Call_Num,
                     Layer,
                     BA = Basal_Area,
                     TPH = Density)]
over_poly[Layer %in% "1", Layer := "O"]
deadba <- over_poly[Layer %in% "D",.(Plot,BA)]
deadtph <- over_poly[Layer %in% "D", .(Plot, TPH)]

##fill NAs in TPH for dead layer
##TPH can be found at the Comments column

over[Call_Num %in% "4903U_3PT", Comments]
deadtph[Plot %in% "4903U_3PT", TPH := 1140.3]
over[Call_Num %in% "505U_3PT", Comments]
deadtph[Plot %in% "505U_3PT", TPH := 189.6]
over[Call_Num %in% "525U_3PT", Comments]
deadtph[Plot %in% "525U_3PT", TPH := 330]
over[Call_Num %in% "539U_3PT", Comments]
deadtph[Plot %in% "539U_3PT", TPH := 512.9]
over[Call_Num %in% "541U_3PT", Comments]
deadtph[Plot %in% "541U_3PT", TPH := 283.5]
over[Call_Num %in% "542U_3PT", Comments]
deadtph[Plot %in% "542U_3PT", TPH := 187.7]

over_poly1 <- over_poly[!Layer %in% "D"]
setnames(deadba, "BA", "deadBA")
over_poly1 <- merge(over_poly1, deadba, by = "Plot", all = TRUE)
setnames(deadtph, "TPH", "deadTPH")
over_poly1 <- merge(over_poly1, deadtph, by = "Plot", all = TRUE)
over_poly1[,Layer:=NULL]
setnames(over_poly1, "BA", "overBA")
setnames(over_poly1, "TPH", "overTPH")

###vri2003

vri2003 <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory_VRI2003.txt"))
vri2003 <- vri2003[Call_Num %in% p]
vri2003_poly <- unique(data.table(Plot = vri2003$Call_Num,
                                  TPH2003 = vri2003$VRI_LIVE_STEMS_PER_HA,
                                  BA2003 = vri2003$BASAL_AREA_1))


vri2003_sp1 <- unique(data.table(Plot = vri2003$Call_Num,
                                 Layer = 2003,
                                 Inv_Standard = "F",
                                 SP = vri2003$SPECIES_CD_1,
                                 PCT = vri2003$SPECIES_PCT_1,
                                 Age = vri2003$PROJ_AGE_1,
                                 Ht = vri2003$PROJ_HEIGHT_1))
vri2003_sp2 <- unique(data.table(Plot = vri2003$Call_Num,
                                 Layer = 2003,
                                 Inv_Standard = "F",
                                 SP = vri2003$SPECIES_CD_2,
                                 PCT = vri2003$SPECIES_PCT_2,
                                 Age = vri2003$PROJ_AGE_2,
                                 Ht = vri2003$PROJ_HEIGHT_2))
vri2003_sp2 <- vri2003_sp2[!PCT %in% NA]
vri2003_sp3 <- unique(data.table(Plot = vri2003$Call_Num,
                                 Layer = 2003,
                                 Inv_Standard = "F",
                                 SP = vri2003$SPECIES_CD_3,
                                 PCT = vri2003$SPECIES_PCT_3))
vri2003_sp3 <- vri2003_sp3[!PCT %in% NA]

vri2003_layer <- rbind(vri2003_sp1, vri2003_sp2, vri2003_sp3, fill = TRUE)
setorder(vri2003_layer, Plot)

###vri2019

vri2019_poly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory_VRI2019_AddDistDate.csv"))
vri2019_poly <- vri2019_poly[Plot %in% p]

vri2019 <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory_VRI2019.txt"))
vri2019 <- vri2019[Call_Num %in% p]
vri2019_sp1 <- data.table(Plot = vri2019$Call_Num,
                          Layer = 2019,
                          Inv_Standard = vri2019$INVENTORY_STANDARD_CD,
                          BEC = vri2019$BEC_ZONE_CODE,
                          subBEC = vri2019$BEC_SUBZONE,
                          vaBEC = vri2019$BEC_VARIANT,
                          SP = vri2019$SPECIES_CD_1,
                          PCT = vri2019$SPECIES_PCT_1,
                          Age = vri2019$PROJ_AGE_1,
                          Ht = vri2019$PROJ_HEIGHT_1)
vri2019_sp2 <- data.table(Plot = vri2019$Call_Num,
                          Layer = 2019,
                          Inv_Standard = vri2019$INVENTORY_STANDARD_CD,
                          BEC = vri2019$BEC_ZONE_CODE,
                          subBEC = vri2019$BEC_SUBZONE,
                          vaBEC = vri2019$BEC_VARIANT,
                          SP = vri2019$SPECIES_CD_2,
                          PCT = vri2019$SPECIES_PCT_2,
                          Age = vri2019$PROJ_AGE_2,
                          Ht = vri2019$PROJ_HEIGHT_2)
vri2019_sp2 <- vri2019_sp2[!PCT %in% NA]
vri2019_sp3 <- data.table(Plot = vri2019$Call_Num,
                          Layer = 2019,
                          Inv_Standard = vri2019$INVENTORY_STANDARD_CD,
                          BEC = vri2019$BEC_ZONE_CODE,
                          subBEC = vri2019$BEC_SUBZONE,
                          vaBEC = vri2019$BEC_VARIANT,
                          SP = vri2019$SPECIES_CD_3,
                          PCT = vri2019$SPECIES_PCT_3)
vri2019_sp3 <- vri2019_sp3[!PCT %in% NA]
vri2019_layer <- rbind(vri2019_sp1, vri2019_sp2, vri2019_sp3, fill = TRUE)
setorder(vri2019_layer, Plot)

##combine layers together
##Layer: under1, over_layer, vri2003_layer, vri2019_layer

layer <- rbind(under1, over_layer, fill = TRUE)
layer <- rbind(layer, vri2003_layer, fill = TRUE)
layer[Layer %in% c("U1", "U2", "U3", "O", "D", "R"), Inv_Standard := "Lillooet"]
layer <- rbind(layer, vri2019_layer, fill=TRUE)

bec <- unique(layer[!BEC %in% NA,.(Plot, BEC, subBEC,vaBEC)])
layer[,c("BEC", "subBEC", "vaBEC") := NULL]
layer <- merge(layer,bec, by= "Plot")
layer$vaBEC <- as.character(layer$vaBEC)
layer[vaBEC %in% NA, vaBEC := ""]
layer[, allBEC := paste0(BEC, subBEC, vaBEC)]

dist <- unique(layer[!Dist_year%in%NA,.(Plot, Dist_year)])
layer[,Dist_year:=NULL]
layer <- merge(layer, dist, by = "Plot")

layer[Layer %in% c("O", "D"), Survey_Date := 2020]
layer[Layer %in% 2003, Survey_Date := 2003]
layer[Layer %in% 2019, Survey_Date := 2019]

poly <- merge(over_poly1, vri2003_poly, by = "Plot")
undertph <- under1[,.(underTPh = sum(Count)*200), by = Plot]
poly <- merge(poly,undertph,by="Plot")
regentph <- under1[Layer %in% "R",.(regenTPH = sum(Count)*200), by = Plot]
poly <- merge(poly, regentph, by = "Plot", all.x = TRUE)
poly[regenTPH %in% NA, regenTPH := 0]
poly <- merge(poly, vri2019_poly, by = "Plot")

write.csv(layer, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/Lilooet_layer.csv", row.names = FALSE)
write.csv(poly, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/Lilooet_poly.csv", row.names = FALSE)
