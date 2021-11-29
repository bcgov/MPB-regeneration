rm(list=ls())
library(data.table)

invlayer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer_cleaned.csv"))
invpoly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly_cleaned_addistdate.csv"))

dist <- invpoly[,.(id, Dist_year, Survey_Date)]
dist[,interval := Survey_Date - Dist_year]
dist[,max := interval+ 5]

invlayer2 <- merge(invlayer, dist, by = "id", all = TRUE)

regen <- invlayer2[Layer %in% "L3/L4" & Age < max]
invlayer2[Layer %in% "L3/L4" & Age < max, Layer := "R"]


invlayer2[Layer %in% c("R", "L1/L2", "L3/L4")]
invlayer2[Layer %in% c("R", "L1/L2", "L3/L4"), sumCount := sum(Count), by = .(id, Layer)]
invlayer2[Layer %in% c("R", "L1/L2", "L3/L4"), PCT := round(100*Count/sumCount, digits = 0)]
invlayer2[,sumCount := NULL]

write.csv(invlayer2, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer_cleaned_regendefined.csv", row.names = FALSE)
