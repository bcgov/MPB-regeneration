rm(list=ls())
library(data.table)
library(ggplot2)
library(cowplot)
library(randomForest)


layer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer_cleaned_regendefined.csv"))
poly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly_cleaned_addistdate.csv"))


unique(layer$SP)
#[1] "PL"  "SX"  "SB"  "SW"  "AT"  "EP"  "FD"  "BL"  "UNK" "AC"  "S"

#[1] "PL" "FD" "SX"  "SB"  "SW" "S" "BL" "AT"  "EP" "AC"     "UNK"
plt <- unique(poly$id)

wide <- NULL
for(i in plt){
  #i <- plt[1]
  poly_tmp <- poly[id %in% i]
  layer_tmp <- layer[id %in% i]

  ##Regen
  rsp <- layer_tmp[Layer %in% "R", unique(SP)]
  if(is.element("PL",rsp)){
    poly_tmp[,regenPL := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "PL", PCT]
    poly_tmp[,regenPL_PCT := pct]
  }else{
    poly_tmp[,regenPL := 0]
    poly_tmp[,regenPL_PCT := 0]
  }
  if(is.element("FD",rsp)){
    poly_tmp[,regenFD := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "FD", PCT]
    poly_tmp[,regenFD_PCT := pct]
  }else{
    poly_tmp[,regenFD := 0]
    poly_tmp[,regenFD_PCT := 0]
  }
  if(is.element("SX",rsp)){
    poly_tmp[,regenSX := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "SX", PCT]
    poly_tmp[,regenSX_PCT := pct]
  }else{
    poly_tmp[,regenSX := 0]
    poly_tmp[,regenSX_PCT := 0]
  }
  if(is.element("SB",rsp)){
    poly_tmp[,regenSB := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "SB", PCT]
    poly_tmp[,regenSB_PCT := pct]
  }else{
    poly_tmp[,regenSB := 0]
    poly_tmp[,regenSB_PCT := 0]
  }
  if(is.element("SW",rsp)){
    poly_tmp[,regenSW := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "SW", PCT]
    poly_tmp[,regenSW_PCT := pct]
  }else{
    poly_tmp[,regenSW := 0]
    poly_tmp[,regenSW_PCT := 0]
  }
  if(is.element("S",rsp)){
    poly_tmp[,regenS := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "S", PCT]
    poly_tmp[,regenS_PCT := pct]
  }else{
    poly_tmp[,regenS := 0]
    poly_tmp[,regenS_PCT := 0]
  }
  if(is.element("BL",rsp)){
    poly_tmp[,regenBL := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "BL", PCT]
    poly_tmp[,regenBL_PCT := pct]
  }else{
    poly_tmp[,regenBL := 0]
    poly_tmp[,regenBL_PCT := 0]
  }
  if(is.element("AT",rsp)){
    poly_tmp[,regenAT := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "AT", PCT]
    poly_tmp[,regenAT_PCT := pct]
  }else{
    poly_tmp[,regenAT := 0]
    poly_tmp[,regenAT_PCT := 0]
  }
  if(is.element("EP",rsp)){
    poly_tmp[,regenEP := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "EP", PCT]
    poly_tmp[,regenEP_PCT := pct]
  }else{
    poly_tmp[,regenEP := 0]
    poly_tmp[,regenEP_PCT := 0]
  }
  if(is.element("AC",rsp)){
    poly_tmp[,regenAC := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "AC", PCT]
    poly_tmp[,regenAC_PCT := pct]
  }else{
    poly_tmp[,regenAC := 0]
    poly_tmp[,regenAC_PCT := 0]
  }

  ##over
  osp <- layer_tmp[Layer %in% "L1/L2", unique(SP)]
  if(is.element("PL",osp)){
    poly_tmp[,overPL := 1]
    pct <- layer_tmp[Layer %in% "L1/L2" & SP %in% "PL", PCT]
    poly_tmp[,overPL_PCT := pct]
  }else{
    poly_tmp[,overPL := 0]
    poly_tmp[,overPL_PCT := 0]
  }
  if(is.element("FD",osp)){
    poly_tmp[,overFD := 1]
    pct <- layer_tmp[Layer %in% "L1/L2" & SP %in% "FD", PCT]
    poly_tmp[,overFD_PCT := pct]
  }else{
    poly_tmp[,overFD := 0]
    poly_tmp[,overFD_PCT := 0]
  }
  if(is.element("SX",osp)){
    poly_tmp[,overSX := 1]
    pct <- layer_tmp[Layer %in% "L1/L2" & SP %in% "SX", PCT]
    poly_tmp[,overSX_PCT := pct]
  }else{
    poly_tmp[,overSX := 0]
    poly_tmp[,overSX_PCT := 0]
  }
  if(is.element("SB",osp)){
    poly_tmp[,overSB := 1]
    pct <- layer_tmp[Layer %in% "L1/L2" & SP %in% "SB", PCT]
    poly_tmp[,overSB_PCT := pct]
  }else{
    poly_tmp[,overSB := 0]
    poly_tmp[,overSB_PCT := 0]
  }
  if(is.element("SW",osp)){
    poly_tmp[,overSW := 1]
    pct <- layer_tmp[Layer %in% "L1/L2" & SP %in% "SW", PCT]
    poly_tmp[,overSW_PCT := pct]
  }else{
    poly_tmp[,overSW := 0]
    poly_tmp[,overSW_PCT := 0]
  }
  if(is.element("S",osp)){
    poly_tmp[,overS := 1]
    pct <- layer_tmp[Layer %in% "L1/L2" & SP %in% "S", PCT]
    poly_tmp[,overS_PCT := pct]
  }else{
    poly_tmp[,overS := 0]
    poly_tmp[,overS_PCT := 0]
  }
  if(is.element("BL",osp)){
    poly_tmp[,overBL := 1]
    pct <- layer_tmp[Layer %in% "L1/L2" & SP %in% "BL", PCT]
    poly_tmp[,overBL_PCT := pct]
  }else{
    poly_tmp[,overBL := 0]
    poly_tmp[,overBL_PCT := 0]
  }
  if(is.element("AT",osp)){
    poly_tmp[,overAT := 1]
    pct <- layer_tmp[Layer %in% "L1/L2" & SP %in% "AT", PCT]
    poly_tmp[,overAT_PCT := pct]
  }else{
    poly_tmp[,overAT := 0]
    poly_tmp[,overAT_PCT := 0]
  }
  if(is.element("EP",osp)){
    poly_tmp[,overEP := 1]
    pct <- layer_tmp[Layer %in% "L1/L2" & SP %in% "EP", PCT]
    poly_tmp[,overEP_PCT := pct]
  }else{
    poly_tmp[,overEP := 0]
    poly_tmp[,overEP_PCT := 0]
  }
  if(is.element("AC",osp)){
    poly_tmp[,overAC := 1]
    pct <- layer_tmp[Layer %in% "L1/L2" & SP %in% "AC", PCT]
    poly_tmp[,overAC_PCT := pct]
  }else{
    poly_tmp[,overAC := 0]
    poly_tmp[,overAC_PCT := 0]
  }

  ##VRI2003
  osp2003 <- layer_tmp[Layer %in% "2003", unique(SP)]
  if(is.element("PL",osp2003)){
    poly_tmp[,overPL2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "PL", PCT]
    poly_tmp[,overPL2003_PCT := pct]
  }else{
    poly_tmp[,overPL2003 := 0]
    poly_tmp[,overPL2003_PCT := 0]
  }
  if(is.element("FD",osp2003)){
    poly_tmp[,overFD2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "FD", PCT]
    poly_tmp[,overFD2003_PCT := pct]
  }else{
    poly_tmp[,overFD2003 := 0]
    poly_tmp[,overFD2003_PCT := 0]
  }
  if(is.element("SX",osp2003)){
    poly_tmp[,overSX2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "SX", PCT]
    poly_tmp[,overSX2003_PCT := pct]
  }else{
    poly_tmp[,overSX2003 := 0]
    poly_tmp[,overSX2003_PCT := 0]
  }
  if(is.element("SB",osp2003)){
    poly_tmp[,overSB2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "SB", PCT]
    poly_tmp[,overSB2003_PCT := pct]
  }else{
    poly_tmp[,overSB2003 := 0]
    poly_tmp[,overSB2003_PCT := 0]
  }
  if(is.element("SW",osp2003)){
    poly_tmp[,overSW2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "SW", PCT]
    poly_tmp[,overSW2003_PCT := pct]
  }else{
    poly_tmp[,overSW2003 := 0]
    poly_tmp[,overSW2003_PCT := 0]
  }
  if(is.element("S",osp2003)){
    poly_tmp[,overS2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "S", PCT]
    poly_tmp[,overS2003_PCT := pct]
  }else{
    poly_tmp[,overS2003 := 0]
    poly_tmp[,overS2003_PCT := 0]
  }
  if(is.element("BL",osp2003)){
    poly_tmp[,overBL2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "BL", PCT]
    poly_tmp[,overBL2003_PCT := pct]
  }else{
    poly_tmp[,overBL2003 := 0]
    poly_tmp[,overBL2003_PCT := 0]
  }
  if(is.element("AT",osp2003)){
    poly_tmp[,overAT2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "AT", PCT]
    poly_tmp[,overAT2003_PCT := pct]
  }else{
    poly_tmp[,overAT2003 := 0]
    poly_tmp[,overAT2003_PCT := 0]
  }
  if(is.element("EP",osp2003)){
    poly_tmp[,overEP2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "EP", PCT]
    poly_tmp[,overEP2003_PCT := pct]
  }else{
    poly_tmp[,overEP2003 := 0]
    poly_tmp[,overEP2003_PCT := 0]
  }
  if(is.element("AC",osp2003)){
    poly_tmp[,overAC2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "AC", PCT]
    poly_tmp[,overAC2003_PCT := pct]
  }else{
    poly_tmp[,overAC2003 := 0]
    poly_tmp[,overAC2003_PCT := 0]
  }

  ##VRI2019
  osp2019 <- layer_tmp[Layer %in% "2019", SP]
  if(is.element("PL",osp2019)){
    poly_tmp[,overPL2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "PL", PCT]
    poly_tmp[,overPL2019_PCT := pct]
  }else{
    poly_tmp[,overPL2019 := 0]
    poly_tmp[,overPL2019_PCT := 0]
  }
  if(is.element("FD",osp2019)){
    poly_tmp[,overFD2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "FD", PCT]
    poly_tmp[,overFD2019_PCT := pct]
  }else{
    poly_tmp[,overFD2019 := 0]
    poly_tmp[,overFD2019_PCT := 0]
  }
  if(is.element("SX",osp2019)){
    poly_tmp[,overSX2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "SX", PCT]
    poly_tmp[,overSX2019_PCT := pct]
  }else{
    poly_tmp[,overSX2019 := 0]
    poly_tmp[,overSX2019_PCT := 0]
  }
  if(is.element("SB",osp2019)){
    poly_tmp[,overSB2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "SB", PCT]
    poly_tmp[,overSB2019_PCT := pct]
  }else{
    poly_tmp[,overSB2019 := 0]
    poly_tmp[,overSB2019_PCT := 0]
  }
  if(is.element("SW",osp2019)){
    poly_tmp[,overSW2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "SW", PCT]
    poly_tmp[,overSW2019_PCT := pct]
  }else{
    poly_tmp[,overSW2019 := 0]
    poly_tmp[,overSW2019_PCT := 0]
  }
  if(is.element("S",osp2019)){
    poly_tmp[,overS2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "S", PCT]
    poly_tmp[,overS2019_PCT := pct]
  }else{
    poly_tmp[,overS2019 := 0]
    poly_tmp[,overS2019_PCT := 0]
  }
  if(is.element("BL",osp2019)){
    poly_tmp[,overBL2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "BL", PCT]
    poly_tmp[,overBL2019_PCT := pct]
  }else{
    poly_tmp[,overBL2019 := 0]
    poly_tmp[,overBL2019_PCT := 0]
  }
  if(is.element("AT",osp2019)){
    poly_tmp[,overAT2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "AT", PCT]
    poly_tmp[,overAT2019_PCT := pct]
  }else{
    poly_tmp[,overAT2019 := 0]
    poly_tmp[,overAT2019_PCT := 0]
  }
  if(is.element("EP",osp2019)){
    poly_tmp[,overEP2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "EP", PCT]
    poly_tmp[,overEP2019_PCT := pct]
  }else{
    poly_tmp[,overEP2019 := 0]
    poly_tmp[,overEP2019_PCT := 0]
  }
  if(is.element("AC",osp2019)){
    poly_tmp[,overAC2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "AC", PCT]
    poly_tmp[,overAC2019_PCT := pct]
  }else{
    poly_tmp[,overAC2019 := 0]
    poly_tmp[,overAC2019_PCT := 0]
  }

  wide <- rbind(wide, poly_tmp)
}

write.csv(wide, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_wide.csv", row.names = FALSE)
