rm(list = ls())
library(data.table)

itsll <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer_VRI0319_cleaned.csv"))
itslp <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly_VRI0319_addistdate.csv"))

unique(itslp$BEC_sub_va)

itslp$BEC_sub_va <- gsub(" ", "", itslp$BEC_sub_va)
itslp[BEC_sub_va %in% "SBPxc", BEC_sub_va := "SBPSxc"]
itslp[BEC_sub_va %in% "SBSPxc", BEC_sub_va := "SBPSxc"]

itslp[, BEC := gsub("[[:lower:]]+|([0-9]+).*", "", BEC_sub_va)]
itslp[, subBEC := gsub("[[:upper:]]+|([0-9]+).*", "", BEC_sub_va)]
itslp[, vaBEC := gsub("[[:upper:]]+|[[:lower:]]+", "", BEC_sub_va)]

bec <- unique(itslp[,.(id, BEC, subBEC, vaBEC, BEC_sub_va)])
unique(bec$BEC)

itsll[,c("BEC", "subBEC", "vaBEC", "BEC_sub_va"):=NULL]
itsll <- merge(itsll, bec, by = "id", all.x = TRUE)

write.csv(itsll, "//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer_VRI0319_cleaned.csv", row.names = FALSE)
write.csv(itslp, "//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly_VRI0319_addistdate.csv", row.names = FALSE)
