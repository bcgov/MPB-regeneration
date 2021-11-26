rm(list = ls())
library(data.table)
library(ggplot2)
library(cowplot)
library(randomForest)

layer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/Lilooet_layer.csv"))
poly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/Lilooet_poly.csv"))

unique(layer$SP)
#[1] "PL" "FD" "PA" "BL" "SX" "SE" "S"  "B"  "PY" "HW" "BA" "PW" "JR"

plt <- unique(poly$Plot)

wide <- NULL
for(i in plt){
  #i <- plt[1]
  poly_tmp <- poly[Plot %in% i]
  layer_tmp <- layer[Plot %in% i]
  ##Regen
  rsp <- layer_tmp[Layer %in% "R", SP]
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
  if(is.element("PA",rsp)){
    poly_tmp[,regenPA := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "PA", PCT]
    poly_tmp[,regenPA_PCT := pct]
  }else{
    poly_tmp[,regenPA := 0]
    poly_tmp[,regenPA_PCT := 0]
  }
  if(is.element("BL",rsp)){
    poly_tmp[,regenBL := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "BL", PCT]
    poly_tmp[,regenBL_PCT := pct]
  }else{
    poly_tmp[,regenBL := 0]
    poly_tmp[,regenBL_PCT := 0]
  }
  if(is.element("SX",rsp)){
    poly_tmp[,regenSX := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "SX", PCT]
    poly_tmp[,regenSX_PCT := pct]
  }else{
    poly_tmp[,regenSX := 0]
    poly_tmp[,regenSX_PCT := 0]
  }
  if(is.element("SE",rsp)){
    poly_tmp[,regenSE := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "SE", PCT]
    poly_tmp[,regenSE_PCT := pct]
  }else{
    poly_tmp[,regenSE := 0]
    poly_tmp[,regenSE_PCT := 0]
  }
  if(is.element("S",rsp)){
    poly_tmp[,regenS := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "S", PCT]
    poly_tmp[,regenS_PCT := pct]
  }else{
    poly_tmp[,regenS := 0]
    poly_tmp[,regenS_PCT := 0]
  }
  if(is.element("B",rsp)){
    poly_tmp[,regenB := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "B", PCT]
    poly_tmp[,regenB_PCT := pct]
  }else{
    poly_tmp[,regenB := 0]
    poly_tmp[,regenB_PCT := 0]
  }
  if(is.element("PY",rsp)){
    poly_tmp[,regenPY := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "PY", PCT]
    poly_tmp[,regenPY_PCT := pct]
  }else{
    poly_tmp[,regenPY := 0]
    poly_tmp[,regenPY_PCT := 0]
  }
  if(is.element("HW",rsp)){
    poly_tmp[,regenHW := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "HW", PCT]
    poly_tmp[,regenHW_PCT := pct]
  }else{
    poly_tmp[,regenHW := 0]
    poly_tmp[,regenHW_PCT := 0]
  }
  if(is.element("BA",rsp)){
    poly_tmp[,regenBA := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "BA", PCT]
    poly_tmp[,regenBA_PCT := pct]
  }else{
    poly_tmp[,regenBA := 0]
    poly_tmp[,regenBA_PCT := 0]
  }
  if(is.element("PW",rsp)){
    poly_tmp[,regenPW := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "PW", PCT]
    poly_tmp[,regenPW_PCT := pct]
  }else{
    poly_tmp[,regenPW := 0]
    poly_tmp[,regenPW_PCT := 0]
  }
  if(is.element("JR",rsp)){
    poly_tmp[,regenJR := 1]
    pct <- layer_tmp[Layer %in% "R" & SP %in% "JR", PCT]
    poly_tmp[,regenJR_PCT := pct]
  }else{
    poly_tmp[,regenJR := 0]
    poly_tmp[,regenJR_PCT := 0]
  }

  ##over
  osp <- layer_tmp[Layer %in% "O", SP]
  if(is.element("PL",osp)){
    poly_tmp[,overPL := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "PL", PCT]
    poly_tmp[,overPL_PCT := pct]
  }else{
    poly_tmp[,overPL := 0]
    poly_tmp[,overPL_PCT := 0]
  }
  if(is.element("FD",osp)){
    poly_tmp[,overFD := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "FD", PCT]
    poly_tmp[,overFD_PCT := pct]
  }else{
    poly_tmp[,overFD := 0]
    poly_tmp[,overFD_PCT := 0]
  }
  if(is.element("PA",osp)){
    poly_tmp[,overPA := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "PA", PCT]
    poly_tmp[,overPA_PCT := pct]
  }else{
    poly_tmp[,overPA := 0]
    poly_tmp[,overPA_PCT := 0]
  }
  if(is.element("BL",osp)){
    poly_tmp[,overBL := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "BL", PCT]
    poly_tmp[,overBL_PCT := pct]
  }else{
    poly_tmp[,overBL := 0]
    poly_tmp[,overBL_PCT := 0]
  }
  if(is.element("SX",osp)){
    poly_tmp[,overSX := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "SX", PCT]
    poly_tmp[,overSX_PCT := pct]
  }else{
    poly_tmp[,overSX := 0]
    poly_tmp[,overSX_PCT := 0]
  }
  if(is.element("SE",osp)){
    poly_tmp[,overSE := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "SE", PCT]
    poly_tmp[,overSE_PCT := pct]
  }else{
    poly_tmp[,overSE := 0]
    poly_tmp[,overSE_PCT := 0]
  }
  if(is.element("S",osp)){
    poly_tmp[,overS := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "S", PCT]
    poly_tmp[,overS_PCT := pct]
  }else{
    poly_tmp[,overS := 0]
    poly_tmp[,overS_PCT := 0]
  }
  if(is.element("B",osp)){
    poly_tmp[,overB := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "B", PCT]
    poly_tmp[,overB_PCT := pct]
  }else{
    poly_tmp[,overB := 0]
    poly_tmp[,overB_PCT := 0]
  }
  if(is.element("PY",osp)){
    poly_tmp[,overPY := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "PY", PCT]
    poly_tmp[,overPY_PCT := pct]
  }else{
    poly_tmp[,overPY := 0]
    poly_tmp[,overPY_PCT := 0]
  }
  if(is.element("HW",osp)){
    poly_tmp[,overHW := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "HW", PCT]
    poly_tmp[,overHW_PCT := pct]
  }else{
    poly_tmp[,overHW := 0]
    poly_tmp[,overHW_PCT := 0]
  }
  if(is.element("BA",osp)){
    poly_tmp[,overBA := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "BA", PCT]
    poly_tmp[,overBA_PCT := pct]
  }else{
    poly_tmp[,overBA := 0]
    poly_tmp[,overBA_PCT := 0]
  }
  if(is.element("PW",osp)){
    poly_tmp[,overPW := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "PW", PCT]
    poly_tmp[,overPW_PCT := pct]
  }else{
    poly_tmp[,overPW := 0]
    poly_tmp[,overPW_PCT := 0]
  }
  if(is.element("JR",osp)){
    poly_tmp[,overJR := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "JR", PCT]
    poly_tmp[,overJR_PCT := pct]
  }else{
    poly_tmp[,overJR := 0]
    poly_tmp[,overJR_PCT := 0]
  }

  ##VRI2003
  osp2003 <- layer_tmp[Layer %in% "2003", SP]
  if(is.element("PL",osp2003)){
    poly_tmp[,overPL2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "PL", PCT]
    poly_tmp[,overPL_PCT2003 := pct]
  }else{
    poly_tmp[,overPL2003 := 0]
    poly_tmp[,overPL_PCT2003 := 0]
  }
  if(is.element("FD",osp2003)){
    poly_tmp[,overFD2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "FD", PCT]
    poly_tmp[,overFD_PCT2003 := pct]
  }else{
    poly_tmp[,overFD2003 := 0]
    poly_tmp[,overFD_PCT2003 := 0]
  }
  if(is.element("PA",osp2003)){
    poly_tmp[,overPA2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "PA", PCT]
    poly_tmp[,overPA_PCT2003 := pct]
  }else{
    poly_tmp[,overPA2003 := 0]
    poly_tmp[,overPA_PCT2003 := 0]
  }
  if(is.element("BL",osp2003)){
    poly_tmp[,overBL2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "BL", PCT]
    poly_tmp[,overBL_PCT2003 := pct]
  }else{
    poly_tmp[,overBL2003 := 0]
    poly_tmp[,overBL_PCT2003 := 0]
  }
  if(is.element("SX",osp2003)){
    poly_tmp[,overSX2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "SX", PCT]
    poly_tmp[,overSX_PCT2003 := pct]
  }else{
    poly_tmp[,overSX2003 := 0]
    poly_tmp[,overSX_PCT2003 := 0]
  }
  if(is.element("SE",osp2003)){
    poly_tmp[,overSE2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "SE", PCT]
    poly_tmp[,overSE_PCT2003 := pct]
  }else{
    poly_tmp[,overSE2003 := 0]
    poly_tmp[,overSE_PCT2003 := 0]
  }
  if(is.element("S",osp2003)){
    poly_tmp[,overS2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "S", PCT]
    poly_tmp[,overS_PCT2003 := pct]
  }else{
    poly_tmp[,overS2003 := 0]
    poly_tmp[,overS_PCT2003 := 0]
  }
  if(is.element("B",osp2003)){
    poly_tmp[,overB2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "B", PCT]
    poly_tmp[,overB_PCT2003 := pct]
  }else{
    poly_tmp[,overB2003 := 0]
    poly_tmp[,overB_PCT2003 := 0]
  }
  if(is.element("PY",osp2003)){
    poly_tmp[,overPY2003 := 1]
    pct <- layer_tmp[Layer %in% "O" & SP %in% "PY", PCT]
    poly_tmp[,overPY_PCT2003 := pct]
  }else{
    poly_tmp[,overPY2003 := 0]
    poly_tmp[,overPY_PCT2003 := 0]
  }
  if(is.element("HW",osp2003)){
    poly_tmp[,overHW2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "HW", PCT]
    poly_tmp[,overHW_PCT2003 := pct]
  }else{
    poly_tmp[,overHW2003 := 0]
    poly_tmp[,overHW_PCT2003 := 0]
  }
  if(is.element("BA",osp2003)){
    poly_tmp[,overBA2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "BA", PCT]
    poly_tmp[,overBA_PCT2003 := pct]
  }else{
    poly_tmp[,overBA2003 := 0]
    poly_tmp[,overBA_PCT2003 := 0]
  }
  if(is.element("PW",osp2003)){
    poly_tmp[,overPW2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "PW", PCT]
    poly_tmp[,overPW_PCT2003 := pct]
  }else{
    poly_tmp[,overPW2003 := 0]
    poly_tmp[,overPw_PCT2003 := 0]
  }
  if(is.element("JR",osp2003)){
    poly_tmp[,overJR2003 := 1]
    pct <- layer_tmp[Layer %in% "2003" & SP %in% "JR", PCT]
    poly_tmp[,overJR_PCT2003 := pct]
  }else{
    poly_tmp[,overJR2003 := 0]
    poly_tmp[,overJR_PCT2003 := 0]
  }

  ##VRI2019
  osp2019 <- layer_tmp[Layer %in% "2019", SP]
  if(is.element("PL",osp2019)){
    poly_tmp[,overPL2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "PL", PCT]
    poly_tmp[,overPL_PCT2019 := pct]
  }else{
    poly_tmp[,overPL2019 := 0]
    poly_tmp[,overPL_PCT2019 := 0]
  }
  if(is.element("FD",osp2019)){
    poly_tmp[,overFD2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "FD", PCT]
    poly_tmp[,overFD_PCT2019 := pct]
  }else{
    poly_tmp[,overFD2019 := 0]
    poly_tmp[,overFD_PCT2019 := 0]
  }
  if(is.element("PA",osp2019)){
    poly_tmp[,overPA2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "PA", PCT]
    poly_tmp[,overPA_PCT2019 := pct]
  }else{
    poly_tmp[,overPA2019 := 0]
    poly_tmp[,overPA_PCT2019 := 0]
  }
  if(is.element("BL",osp2019)){
    poly_tmp[,overBL2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "BL", PCT]
    poly_tmp[,overBL_PCT2019 := pct]
  }else{
    poly_tmp[,overBL2019 := 0]
    poly_tmp[,overBL_PCT2019 := 0]
  }
  if(is.element("SX",osp2019)){
    poly_tmp[,overSX2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "SX", PCT]
    poly_tmp[,overSX_PCT2019 := pct]
  }else{
    poly_tmp[,overSX2019 := 0]
    poly_tmp[,overSX_PCT2019 := 0]
  }
  if(is.element("SE",osp2019)){
    poly_tmp[,overSE2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "SE", PCT]
    poly_tmp[,overSE_PCT2019 := pct]
  }else{
    poly_tmp[,overSE2019 := 0]
    poly_tmp[,overSE_PCT2019 := 0]
  }
  if(is.element("S",osp2019)){
    poly_tmp[,overS2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "S", PCT]
    poly_tmp[,overS_PCT2019 := pct]
  }else{
    poly_tmp[,overS2019 := 0]
    poly_tmp[,overS_PCT2019 := 0]
  }
  if(is.element("B",osp2019)){
    poly_tmp[,overB2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "B", PCT]
    poly_tmp[,overB_PCT2019 := pct]
  }else{
    poly_tmp[,overB2019 := 0]
    poly_tmp[,overB_PCT2019 := 0]
  }
  if(is.element("PY",osp2019)){
    poly_tmp[,overPY2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "PY", PCT]
    poly_tmp[,overPY_PCT2019 := pct]
  }else{
    poly_tmp[,overPY2019 := 0]
    poly_tmp[,overPY_PCT2019 := 0]
  }
  if(is.element("HW",osp2019)){
    poly_tmp[,overHW2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "HW", PCT]
    poly_tmp[,overHW_PCT2019 := pct]
  }else{
    poly_tmp[,overHW2019 := 0]
    poly_tmp[,overHW_PCT2019 := 0]
  }
  if(is.element("BA",osp2019)){
    poly_tmp[,overBA2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "BA", PCT]
    poly_tmp[,overBA_PCT2019 := pct]
  }else{
    poly_tmp[,overBA2019 := 0]
    poly_tmp[,overBA_PCT2019 := 0]
  }
  if(is.element("PW",osp2019)){
    poly_tmp[,overPW2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "PW", PCT]
    poly_tmp[,overPW_PCT2019 := pct]
  }else{
    poly_tmp[,overPW2019 := 0]
    poly_tmp[,overPW_PCT2019 := 0]
  }
  if(is.element("JR",osp2019)){
    poly_tmp[,overJR2019 := 1]
    pct <- layer_tmp[Layer %in% "2019" & SP %in% "JR", PCT]
    poly_tmp[,overJR_PCT2019 := pct]
  }else{
    poly_tmp[,overJR2019 := 0]
    poly_tmp[,overJR_PCT2019 := 0]
  }

  wide <- rbind(wide, poly_tmp)
}

write.csv(wide, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/Lilooet_wide.csv", row.names = FALSE)

