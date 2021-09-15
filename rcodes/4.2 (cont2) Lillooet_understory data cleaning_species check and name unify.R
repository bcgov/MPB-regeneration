rm(list=ls())
library(data.table)

under <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory_cleaned.csv"))
##Unify sp

under1 <- under[!Class %in% "O"]
unique(under1$SP)
#[1] "PLI" "BL"  "SX"  "PA"  "SE"  "FDI" "PY"  "HW"  "BA"  "PW"
#[11] "JR"

under[SP %in% "PLI", SP := "PL"]
under[SP %in% "FDI", SP := "FD"]

under[SP %in% "JR"]
under[Plot %in% "9010U_3PT"]

write.csv(under, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory_cleaned.csv", row.names = FALSE, na = "")
