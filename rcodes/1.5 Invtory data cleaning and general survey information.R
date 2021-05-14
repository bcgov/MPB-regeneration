rm(list=ls())
library(data.table)
library(tidyr)
library(reshape2)
library(dplyr)

invdata <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Eraforcompile_InvTable_VRI0319.csv"))

##Remove plots dont have post survey information (some plots has GPS record but no survey record)

tmp <- invdata[,.(unique(Layer)),by = id]
plt <- NULL
for (i in unique(tmp$id)){
  layers <- tmp[id %in% i, V1]
  if(is.element("L1/L2", layers)|is.element("L3/L4", layers)|is.element("Dead", layers)){
    plt <- c(plt,i)
  }
}
invdata <- invdata[id %in% plt]

##only retain plot that have regeneration information ("L3/L4" in the Layer column)

#regenplot <- invdata[Layer %in% "L3/L4", unique(id)]
#invdata <- invdata[id %in% regenplot]

#remove duplicated rows

invdata <- distinct(invdata)

##Unify SP code

unique(invdata$SP)

# [1] "PL"  "Pli" "Sb"  "Sx"  "PLI" "SX"  "SW"  "SB"  "AT"  "Ep"  "At"  "Bl"  "FDI" "Fdi" "FD"  " "   "X2"  "BL"  "Ac"  "AC"  "EP"  "S"
# [23] "SXW"

invdata[SP %in% c("PL","PLI","Pli"),SP := "PL"]
invdata[SP %in% c("SX","Sx", "SXW"),SP := "SX"]
invdata[SP %in% c("SB","Sb"), SP := "SB"]
invdata[SP %in% c("At","AT"),SP := "AT"]
invdata[SP %in% c("EP","Ep"),SP := "EP"]
invdata[SP %in% c("Bl","BL"),SP := "BL"]
invdata[SP %in% c("FDI","Fdi","FD"),SP := "FD"]
invdata[SP %in% c("Ac","AC"),SP := "AC"]
invdata[SP %in% " ",SP := "UNK"]

##What is "X2"?
##check from raw data :93G044-158 Plot K1 & 93G045-570 Plot K1: "X2" should be "PL"

invdata[SP %in% "X2"]
invdata[SP %in% c("X2"),SP := "PL"]


##How many plots in each BEC & subBEC combination?

unique(invdata$vaBEC)
#[1]  3  2 NA  1

class(invdata$vaBEC)
invdata$vaBEC <- as.character(invdata$vaBEC)
invdata[vaBEC %in% NA, vaBEC := ""]
invdata[,BEC_sub_va := paste0(BEC,subBEC, vaBEC)]
invdata_BEC <- distinct(invdata[,.(id,BEC_sub_va)])
invdata_BEC[, .N, by = BEC_sub_va]

# BEC_sub_va   N
# 1:     SBSmc3   3
# 2:     SBSdw2 144
# 3:      SBSmw   6
# 4:     SBSmc2   5
# 5:     SBPSdc   4
# 6:     SBSdw3  41
# 7:     SBSmk1 117

##ALL SP comp before MPB (year 2003)

data <- invdata[Layer %in% "2003",.(SP = paste(SP,PCT)),by= id]
data[, SPcomp := Reduce(paste, SP), by=id]
data[,SP := NULL]
data <- unique(data)
data <- data[, .N, by = SPcomp]
setorder(data,-N)

data
#   SPcomp   N
#  1:            PL 100 152
#  2:       PL 90 SW 10  31
#  3:        PL 95 AT 5  22
#  4:       PL 90 AT 10   8
#  5:   PL 90 AT 5 SW 5   6
#  6:       PL 70 SB 30   5
#  7: PL 60 AT 30 SW 10   5
#  8: SW 40 FD 30 PL 25   5
#  9:  AT 50 PL 30 S 20   5
# 10:       PL 70 SW 30   4
# 11:       PL 85 SW 15   4
# 12:       PL 80 SW 20   3
# 13: PL 60 SW 30 AT 10   3
# 14:        PL 95 SW 5   3
# 15: PL 80 SW 10 AT 10   3
# 16:  PL 75 SW 20 AT 5   3
# 17: PL 70 SW 20 AT 10   3
# 18:  PL 85 AT 10 SW 5   3
# 19:       PL 80 AT 20   3
# 20:  PL 80 S 10 AT 10   3
# 21:       SW 70 PL 30   2
# 22:       PL 89 SW 11   2
# 23:       PL 69 SW 31   2
# 24:       PL 90 SB 10   2
# 25:  PL 85 SW 10 AT 5   2
# 26:  PL 70 AT 20 S 10   2
# 27:       PL 50 AT 50   2
# 28:       AT 60 PL 40   2
# 29:        PL 90 S 10   2
# 30:       PL 60 SB 40   1
# 31:       SW 60 PL 40   1
# 32: FD 50 PL 30 SW 20   1
# 33: PL 70 FD 20 SW 10   1
# 34:  FD 55 SW 38 PL 7   1
# 35: PL 70 SW 20 FD 10   1
# 36:   SW 90 PL 5 AT 5   1
# 37:   PL 90 SW 5 AT 5   1
# 38: PL 60 SW 30 SB 10   1
# 39:  PL 71 SW 21 AT 8   1
# 40: PL 60 SW 20 AT 20   1
# 41:            FD 100   1
# 42:  PL 85 AT 10 SB 5   1
# 43: SW 70 PL 20 AC 10   1
# 44: SW 70 PL 20 EP 10   1
# 45: AC 60 SW 20 AT 20   1
# 46:       AT 90 PL 10   1
# 47:  AT 50 PL 40 S 10   1
# 48:    PL 90 S 5 AT 5   1
# 49: PL 40 SW 30 AT 20   1
# 50:  PL 80 S 10 FD 10   1
# 51: PL 55 AT 30 AC 15   1
# 52:        PL 80 S 20   1
# 53:  PL 50 AT 30 S 20   1
# 54:  PL 80 AT 10 S 10   1
# 55: SW 40 PL 40 BL 10   1
# 56: PL 80 AT 10 SW 10   1
# 57:       SW 80 BL 20   1

#Divide the Invdata into two files
#1. tree level #NOTE: BA is ba/ha

InvTree <- invdata[,.(Opening, Plot,id, Layer, Inventory_Standard, BEC, subBEC, vaBEC, BEC_sub_va, SP, PCT, Age, Ht, Count, BAF, Prismcount)]

##There might have duplicated species in one layer due to species name unify. Merge the same species in the same layer together

tree2003 <- InvTree[Layer %in% "2003"]
tree2019 <- InvTree[Layer %in% "2019"]
treeps <- InvTree[Layer %in% "L1/L2",.(Opening = unique(Opening), Plot = unique(Plot), Layer = unique(Layer), Inventory_Standard = unique(Inventory_Standard), BEC = unique(BEC), subBEC = unique(subBEC), vaBEC = unique(vaBEC), BEC_sub_va = unique(BEC_sub_va), PCT = NA, Age = mean(Age, na.rm = TRUE), Ht = mean(Ht, na.rm = TRUE), Count = sum(Count, na.rm = TRUE), BAF = 5, Prismcount = sum(Prismcount, na.rm = TRUE)), by=.(id,SP)]
treeps[Age %in% NaN, Age := NA]
treeps[Ht %in% NaN, Ht := NA]
treeregen <- InvTree[Layer %in% "L3/L4",.(Opening = unique(Opening), Plot = unique(Plot), Layer = unique(Layer), Inventory_Standard = unique(Inventory_Standard), BEC = unique(BEC), subBEC = unique(subBEC), vaBEC = unique(vaBEC), BEC_sub_va = unique(BEC_sub_va),PCT = NA, Age = mean(Age, na.rm = TRUE), Ht = mean(Ht, na.rm = TRUE), Count = sum(Count, na.rm = TRUE),BAF = 5, Prismcount = sum(Prismcount, na.rm = TRUE)), by=.(id,SP)]
treeregen[Age %in% NaN, Age := NA]
treeregen[Ht %in% NaN, Ht := NA]
treedead <- InvTree[Layer %in% "Dead",.(Opening = unique(Opening), Plot = unique(Plot), Layer = unique(Layer), Inventory_Standard = unique(Inventory_Standard), BEC = unique(BEC), subBEC = unique(subBEC), vaBEC = unique(vaBEC), BEC_sub_va = unique(BEC_sub_va), PCT = 100, Age = NA, Ht = NA, Count = NA, BAF = 5, Prismcount = sum(Prismcount, na.rm = TRUE)), by=.(id,SP)]

invtree <- rbind(tree2003,tree2019,treeps,treedead,treeregen)


# invtree[,TPH := Count *200]

invtree[Layer %in% "L1/L2", PCT := round(100*Count/sum(Count, na.rm = TRUE), digits = 1), by = id]
invtree[Layer %in% "L3/L4", PCT := round(100*Count/sum(Count, na.rm = TRUE), digits = 1), by = id]
# setorder(invtree, id)

write.csv(invtree,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer.csv", row.names = FALSE)

#2. stand level

##Calculate density for each post-survey plot (3.99m radius)

invdata[Layer %in% "L1/L2",Stand_TPH := sum(Count, na.rm = TRUE)*200, by = id]
invdata[Layer %in% "L3/L4",Stand_TPH := sum(Count, na.rm = TRUE)*200, by = id]

##Calculate ba per ha for each post-survey plot

invdata[Layer %in% "L1/L2", Stand_BA := sum(BAF*Prismcount, na.rm = TRUE), by = id]
invdata[Layer %in% "L3/L4", Stand_BA := sum(BAF*Prismcount, na.rm = TRUE), by = id]
invdata[Layer %in% "Dead", Stand_BA := sum(BAF*Prismcount, na.rm = TRUE), by = id]

Invstand <- distinct(invdata[,.(Opening, Plot,id, Layer, Inventory_Standard, BEC, subBEC, vaBEC, BEC_sub_va, Stand_SI, Stand_CC, Stand_QMD125, Stand_TPH, Stand_BA, Stand_VOL125, Survey_Date, Dist_year, Kill_PCT)])

write.csv(Invstand,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly.csv", row.names = FALSE)

####THE FOLLOWING CODES CONVERT INVSTAND TABLE FROM LONG TABLE TO WIDE TABLE

InvStand <- data.table()
for (i in unique(invdata$id)){
  tmp <- invdata[id %in% i]
  opening <- unique(tmp$Opening)
  plot <- unique(tmp$Plot)
  plotn <- i
  bec <- unique(tmp$BEC_sub_va)
  si2003 <- tmp[Layer %in% "2003", unique(Stand_SI)]
  si2019 <- tmp[Layer %in% "2019", unique(Stand_SI)]
  cc2003 <- tmp[Layer %in% "2003", unique(Stand_CC)]
  cc2019 <- tmp[Layer %in% "2019", unique(Stand_CC)]
  qmd2003 <- tmp[Layer %in% "2003", unique(Stand_QMD125)]
  qmd2019 <- tmp[Layer %in% "2019", unique(Stand_QMD125)]
  ba2003 <- tmp[Layer %in% "2003", unique(Stand_BA)]
  ba2019 <- tmp[Layer %in% "2019", unique(Stand_BA)]
  baps <- tmp[Layer %in% "L1/L2", unique(Stand_BA)]
  tph2003 <- tmp[Layer %in% "2003", unique(Stand_TPH)]
  tph2019 <- tmp[Layer %in% "2019", unique(Stand_TPH)]
  tphps <- tmp[Layer %in% "L1/L2", unique(Stand_TPH)]
  tphregen <- tmp[Layer %in% "L3/L4", unique(Stand_TPH)]
  surveydate <- tmp[Layer %in% "L1/L2", unique(Survey_Date)]
  distdate <- tmp[Layer %in% "2019", unique(Dist_year)]
  deadpBA <- tmp[Layer %in% "Dead", unique(Stand_BA)]
  kill <- tmp[Layer %in% "2019", unique(Kill_PCT)]
  invtmp <- data.table(Opening = opening,
                       Plot = plot,
                       id = plotn,
                       BEC_sub_va = bec,
                       SI_2003 = si2003,
                       SI_2019 = si2019,
                       CC_2003 = cc2003,
                       CC_2019 = cc2019,
                       QMD125_2003 = qmd2003,
                       QMD125_2019 = qmd2019,
                       BA_2003 = ba2003,
                       BA_2019 = ba2019,
                       BA_PS_Over = baps,
                       TPH_2003 = tph2003,
                       TPH_2019 = tph2019,
                       TPH_PS_Over = tphps,
                       TPH_PS_Under = tphregen,
                       Survey_Date = surveydate,
                       Dist_Year = distdate,
                       Dead_PliBA = deadpBA,
                       Kill_PCT = kill)
  InvStand <- rbind(InvStand,invtmp)
}

#Add 2003's age using Pine's age in VRI2003

test <- InvTree[Layer %in% 2003 & SP %in% "PL",.(id,Age)]
InvStand <- merge(InvStand, test, by = "id")
setnames(InvStand, "Age", "Age_2003")
InvStand[, Age_Dist := Age_2003 + Dist_Year - 2003]

#Add 2003's height using Pine's height in VRI2003

test <- InvTree[Layer %in% 2003 & SP %in% "PL",.(id,Ht)]
InvStand <- merge(InvStand, test, by = "id")
setnames(InvStand, "Ht", "PL_Ht_2003")

#Add 0 for stand absence from regen, 1 for presence of regen

InvStand[is.na(TPH_PS_Under), Regen := 0]
InvStand[!is.na(TPH_PS_Under), Regen := 1]

##invTable update
##Add dummy variable for the presence or absense of each species in understory

Nplot <- unique(InvStand$id)
invdata2 <- data.table()
for (i in Nplot){
  tmp <- InvStand[id %in% i]
  tmptree <- invtree[id %in% i & Layer %in% "L3/L4"]
  if(is.element("PL", tmptree$SP)){
    pct <- tmptree[SP %in% "PL", PCT]
    tmp[,':='(PL = 1,
              PL_PCT = pct)]
  }
  if(is.element("S", tmptree$SP)|is.element("SX", tmptree$SP)|is.element("SB", tmptree$SP)|is.element("SW", tmptree$SP)){
    pct <- tmptree[SP %in% "S"|SP %in% "SX"|SP %in% "SW"|SP %in% "SB", sum(PCT, na.rm = TRUE)]
    tmp[,':='(S = 1,
              S_PCT = pct)]
  }
  if(is.element("BL", tmptree$SP)){
    pct <- tmptree[SP %in% "BL", PCT]
    tmp[,':='(B = 1,
              B_PCT = pct)]
  }
  if(is.element("F", tmptree$SP)){
    pct <- tmptree[SP %in% "FD", PCT]
    tmp[,':='(F = 1,
              F_PCT = pct)]
  }
  if(is.element("AT", tmptree$SP)|is.element("AC", tmptree$SP)|is.element("EP", tmptree$SP)){
    pct <- tmptree[SP %in% "AC"|SP %in% "AT"|SP %in% "EP", sum(PCT, na.rm = TRUE)]
    tmp[,':='(HW = 1,
              HW_PCT = pct)]
  }

  invdata2 <- rbind(invdata2, tmp, fill = TRUE)
}

invdata2[PL %in% NA, PL := 0]
invdata2[S %in% NA, S := 0]
invdata2[B %in% NA, B := 0]
invdata2[F %in% NA, F := 0]
invdata2[HW %in% NA, HW := 0]


invdata2[PL %in% "0", PL_PCT := 0]
invdata2[S %in% "0", S_PCT := 0]
invdata2[B %in% "0", B_PCT := 0]
invdata2[F %in% "0", F_PCT := 0]
invdata2[HW %in% "0", HW_PCT := 0]


write.csv(invdata2,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly_widetable.csv", row.names = FALSE)


