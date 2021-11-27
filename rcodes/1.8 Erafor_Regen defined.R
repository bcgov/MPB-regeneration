rm(list=ls())
library(data.table)
library(ggplot2)
library(cowplot)
library(randomForest)


invlayer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer_cleaned.csv"))
invpoly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly_cleaned_addistdate.csv"))

dist <- invpoly[,.(id, Dist_year, Survey_Date)]
dist[,interval := Survey_Date - Dist_year]
dist[,max := interval+ 5]

invlayer2 <- merge(invlayer, dist, by = "id", all = TRUE)

regen <- invlayer2[Layer %in% "L3/L4" & Age < max]
invlayer2[Layer %in% "L3/L4" & Age < max, Layer := "R"]


invlayer2[Layer %in% "R", sumCount := sum(Count), by = id]
invlayer2[Layer %in% "R", PCT := round(100*Count/sumCount, digits = 0)]
invlayer2[Layer %in% "R"]

write.csv(invlayer2, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer_cleaned_regendefined.csv", row.names = FALSE)
