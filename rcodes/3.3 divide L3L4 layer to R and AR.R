rm(list=ls())
library(data.table)
library(dplyr)
library(ggplot2)

invlayer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_layer.csv"))
invpoly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_poly.csv"))

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

write.csv(invlayer, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_layer.csv", row.names = FALSE)
