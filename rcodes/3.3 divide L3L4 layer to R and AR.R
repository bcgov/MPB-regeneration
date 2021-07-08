rm(list=ls())
library(data.table)
library(dplyr)
library(ggplot2)

invlayer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_layer.csv"))
invpoly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_poly_addistyear.csv"))

tmp <- invpoly[Layer %in% "2019",.(id, Dist_year)]
tmp2 <- invpoly[Layer %in% c("L1/L2","L3/L4"),.(id, Survey_Date)]
tmp2 <- distinct(tmp2)
tmp3 <- merge(tmp,tmp2, by = "id")
tmp3[,interval := Survey_Date - Dist_year]

# tmp4 <- invlayer[Layer %in% "L3/L4",.(id,SP, Age)]
# tmp4 <- tmp4[!is.na(Age)]
# tmp5 <- merge(tmp3,tmp4, by = "id")
# tmp5[Age <= interval]

invlayer <- merge(invlayer, tmp3, by = "id", all.x = TRUE)
invlayer[Layer %in% "L3/L4" & Age <= interval, Layer := "R"]
invlayer[Layer %in% "L3/L4" & Age > interval, Layer := "AR"]

invlayer[Layer %in% "AR"]

##Species without age was left at layer L3/L4
##Change the layer of these species to AR

invlayer[Layer %in% "L3/L4", Layer := "AR"]

write.csv(invlayer, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_layer_RAR.csv", row.names = FALSE)

layer <- invlayer[Layer %in% "R" | Layer %in% "AR",]
layer2 <- layer[,.(Inventory_Standard = unique(Inventory_Standard),
                   BEC = unique(BEC),
                   subBEC = unique(subBEC),
                   vaBEC = unique(vaBEC),
                   BEC_sub_va = unique(BEC_sub_va),
                   Count = sum(Count, na.rm = TRUE),
                   Prismcount = sum(Prismcount, na.rm = TRUE),
                   Survey_Date = unique(Survey_Date),
                   Data_Source = unique(Data_Source)),
                by = .(id, Layer)]
poly <- layer2[,.(id,
                  Layer,
                  Inventory_Standard,
                  BEC,
                  subBEC,
                  vaBEC,
                  BEC_sub_va,
                  Stand_TPH = Count *200,
                  Survey_Date,
                  Data_Source)]

invpoly <- invpoly[!Layer %in% "L3/L4"]
invpoly <- rbind(invpoly,poly, fill= TRUE)
invpoly <- invpoly[order(id)]

write.csv(invpoly, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_poly_RAR.csv", row.names = FALSE)
