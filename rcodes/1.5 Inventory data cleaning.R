rm(list=ls())
library(data.table)
library(tidyr)
library(reshape2)
library(dplyr)

invlayer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer.csv"))
invpoly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly.csv"))

##Remove plots dont have post survey information (some plots has GPS record but no survey record)

tmp <- invlayer[,.(unique(Layer)),by = id]
plt <- NULL
for (i in unique(tmp$id)){
  layers <- tmp[id %in% i, V1]
  if(is.element("L1/L2", layers)|is.element("L3/L4", layers)|is.element("Dead", layers)){
    plt <- c(plt,i)
  }
}

invlayer <- invlayer[id %in% plt]
invpoly <- invpoly[id %in% plt]

##Unify SP code

unique(invlayer$SP)

# [1] "PL"  "Pli" "Sb"  "Sx"  "PLI" "SX"  "SW"  "SB"  "AT"  "Ep"  "At"  "Bl"  "FDI" "Fdi" "FD"  " "   "X2"  "BL"  "Ac"  "AC"  "EP"  "S"
# [23] "SXW"

invlayer[SP %in% c("PL","PLI","Pli"),SP := "PL"]
invlayer[SP %in% c("SX","Sx", "SXW"),SP := "SX"]
invlayer[SP %in% c("SB","Sb"), SP := "SB"]
invlayer[SP %in% c("At","AT"),SP := "AT"]
invlayer[SP %in% c("EP","Ep"),SP := "EP"]
invlayer[SP %in% c("Bl","BL"),SP := "BL"]
invlayer[SP %in% c("FDI","Fdi","FD"),SP := "FD"]
invlayer[SP %in% c("Ac","AC"),SP := "AC"]
invlayer[SP %in% " ",SP := "UNK"]

##What is "X2"?
##check from raw data :93G044-158 Plot K1 & 93G045-570 Plot K1: "X2" should be "PL"

invlayer[SP %in% "X2"]
invlayer[SP %in% c("X2"),SP := "PL"]

##There might have duplicated species in one layer due to species name unify. Merge the same species in the same layer together

tree2003 <- invlayer[Layer %in% "2003"]
tree2019 <- invlayer[Layer %in% "2019"]
treeps <- invlayer[Layer %in% "L1/L2",.(Opening = unique(Opening),
                                        Plot = unique(Plot),
                                        Layer = unique(Layer),
                                        Inventory_Standard = unique(Inventory_Standard),
                                        BEC = unique(BEC),
                                        subBEC = unique(subBEC),
                                        vaBEC = unique(vaBEC),
                                        PCT = NA,
                                        Age = mean(Age, na.rm = TRUE),
                                        Ht = mean(Ht, na.rm = TRUE),
                                        Count = sum(Count, na.rm = TRUE),
                                        BAF = 5,
                                        Prismcount = sum(Prismcount, na.rm = TRUE)),
                   by=.(id,SP)]
treeps[Age %in% NaN, Age := NA]
treeps[Ht %in% NaN, Ht := NA]
treeregen <- invlayer[Layer %in% "L3/L4",.(Opening = unique(Opening),
                                          Plot = unique(Plot),
                                          Layer = unique(Layer),
                                          Inventory_Standard = unique(Inventory_Standard),
                                          BEC = unique(BEC),
                                          subBEC = unique(subBEC),
                                          vaBEC = unique(vaBEC),
                                          PCT = NA,
                                          Age = mean(Age, na.rm = TRUE),
                                          Ht = mean(Ht, na.rm = TRUE),
                                          Count = sum(Count, na.rm = TRUE),
                                          BAF = 5,
                                          Prismcount = sum(Prismcount, na.rm = TRUE)),
                     by=.(id,SP)]
treeregen[Age %in% NaN, Age := NA]
treeregen[Ht %in% NaN, Ht := NA]
treedead <- invlayer[Layer %in% "Dead",.(Opening = unique(Opening),
                                        Plot = unique(Plot),
                                        Layer = unique(Layer),
                                        Inventory_Standard = unique(Inventory_Standard),
                                        BEC = unique(BEC),
                                        subBEC = unique(subBEC),
                                        vaBEC = unique(vaBEC),
                                        PCT = 100,
                                        Age = NA,
                                        Ht = NA,
                                        Count = NA,
                                        BAF = 5,
                                        Prismcount = sum(Prismcount, na.rm = TRUE)),
                    by=.(id,SP)]

invlayer <- rbind(tree2003,tree2019,treeps,treedead,treeregen)

##Calculate SP PCT

invlayer[Layer %in% "L1/L2", PCT := round(100*Count/sum(Count, na.rm = TRUE), digits = 1), by = id]
invlayer[Layer %in% "L3/L4", PCT := round(100*Count/sum(Count, na.rm = TRUE), digits = 1), by = id]

##Add BEC_sub_va

unique(invlayer$vaBEC)
#[1]  3  2 NA  1

class(invlayer$vaBEC)
invlayer$vaBEC <- as.character(invlayer$vaBEC)
invlayer[vaBEC %in% NA, vaBEC := ""]
invlayer[,BEC_sub_va := paste0(BEC,subBEC, vaBEC)]

unique(invpoly$vaBEC)
#[1]  3  2 NA  1

class(invpoly$vaBEC)
invpoly$vaBEC <- as.character(invpoly$vaBEC)
invpoly[vaBEC %in% NA, vaBEC := ""]
invpoly[,BEC_sub_va := paste0(BEC,subBEC, vaBEC)]

##Calculate density for each post-survey plot (3.99m radius)

over <- invlayer[Layer %in% "L1/L2", .(overTPH = sum(Count, na.rm = TRUE)*200,
                                       overBA = sum(BAF*Prismcount, na.rm = TRUE)), by = id]
under <- invlayer[Layer %in% "L3/L4", .(underTPH = sum(Count, na.rm = TRUE)*200), by = id]
dead <- invlayer[Layer %in% "Dead",.(deadBA = sum(BAF*Prismcount, na.rm = TRUE)), by = id]

invpoly1 <- merge(invpoly, over, by = "id", all.x = TRUE)
invpoly1 <- merge(invpoly1, under, by = "id", all.x = TRUE)
invpoly1 <- merge(invpoly1, dead, by = "id", all.x = TRUE)

write.csv(invlayer,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer_cleaned.csv", row.names = FALSE)
write.csv(invpoly1,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly_cleaned.csv", row.names = FALSE)

