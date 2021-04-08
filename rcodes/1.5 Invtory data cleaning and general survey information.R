rm(list=ls())
library(data.table)
library(tidyr)
library(reshape2)
library(dplyr)

invdata <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Eraforcompile_InvTable_VRI0319.csv"))

##only retain plot that have regeneration information ("L3/L4" in the Layer column)

#regenplot <- invdata[Layer %in% "L3/L4", unique(PlotNum)]
#invdata <- invdata[PlotNum %in% regenplot]

##Unify SP code

unique(invdata$SP)

# [1] "PL"  "PLI" "SX"  "Pli" "Sb"  "Sx"  "SW"  "SB"  "AT"  "Ep"  "At"  "Bl"  "FDI" "Fdi" "FD"  " "   "X2"  "BL"  "Ac"
# [20] ""    "AC"  "EP"  "S"   "SXW"

invdata[SP %in% c("PL","PLI","Pli"),SP := "PL"]
invdata[SP %in% c("SX","Sx", "SXW"),SP := "SX"]
invdata[SP %in% c("SB","Sb"), SP := "SB"]
invdata[SP %in% c("At","AT"),SP := "AT"]
invdata[SP %in% c("EP","Ep"),SP := "EP"]
invdata[SP %in% c("Bl","BL"),SP := "BL"]
invdata[SP %in% c("FDI","Fdi","FD"),SP := "FD"]
invdata[SP %in% c("Ac","AC"),SP := "AC"]
invdata[SP %in% c(""," "),SP := "UNK"]

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
invdata_BEC <- distinct(invdata[,.(PlotNum,BEC_sub_va)])
invdata_BEC[, .N, by = BEC_sub_va]

#    BEC_sub_va   N
# 1:     SBSmc3   3
# 2:     SBSdw2 133
# 3:      SBSmw   5
# 4:     SBSmc2   4
# 5:     SBPSdc   4
# 6:     SBSdw3  35
# 7:     SBSmk1 111

##ALL SP comp before MPB (year 2003)

data <- invdata[Layer %in% "2003",.(SP = paste(SP,PCT)),by= PlotNum]
data[, SPcomp := Reduce(paste, SP), by=PlotNum]
data[,SP := NULL]
data <- unique(data)
data <- data[, .N, by = SPcomp]
setorder(data,-N)

data
#               SPcomp   N
# 1:            PL 100 144
# 2:        PL 90 S 10  32
# 3:        PL 95 AT 5  21
# 4:        PL 70 S 30   8
# 5:       PL 90 AT 10   7
# 8:  PL 80 S 10 AT 10   5
# 9:    PL 90 AT 5 S 5   4
# 10:   PL 85 AT 10 S 5   4
# 12:        PL 80 S 20   3
# 14:         PL 95 S 5   3
# 15:   PL 75 S 20 AT 5   3
# 16:  PL 70 S 20 AT 10   3
# 17:       PL 80 AT 20   3
# 19:        PL 89 S 11   2
# 21:   PL 85 S 10 AT 5   2
# 22:    PL 90 S 5 AT 5   2
# 23:  PL 70 AT 20 S 10   2
# 26:  PL 80 AT 10 S 10   2
# 30:   PL 70 F 20 S 10   1
# 32:   PL 70 S 20 F 10   1
# 35:   PL 71 S 21 AT 8   1
# 36:        PL 85 S 15   1
# 43:   PL 80 S 10 F 10   1

# 44: PL 55 AT 30 AC 15   1
# 24:       PL 50 AT 50   2
# 25:       AT 60 PL 40   2
# 42:       AT 90 PL 10   1

# 6:  PL 60 AT 30 S 10   5
# 11:  AT 50 PL 30 S 20   4
# 13:  PL 60 S 30 AT 10   3
# 33:    S 90 PL 5 AT 5   1
# 37:  PL 60 S 20 AT 20   1
# 39:  S 70 PL 20 AC 10   1

# 7:   S 40 F 30 PL 25   5
# 29:   F 50 PL 30 S 20   1
# 31:    F 55 S 38 PL 7   1

# 45:   S 40 PL 40 B 10   1

# 46:         S 80 B 20   1

# 18:        S 70 PL 30   2
# 20:        PL 69 S 31   2
# 27:        PL 60 S 40   1
# 28:        S 60 PL 40   1
# 34:   PL 60 S 30 S 10   1

# 38:             F 100   1

# 40:   S 70 PL 20 E 10   1

# 41:  AC 60 S 20 AT 20   1


#Divide the Invdata into two files
#1. tree level #NOTE: BA is ba/ha

InvTree <- invdata[,.(Opening, Plot,PlotNum, Layer, Inventory_Standard, BEC, BEC_sub_va, SP, PCT, Age, Ht, Count, BAF, Prismcount)]

##There might have duplicated species in one layer due to species name unify. Merge the same species in the same layer together

tree2003 <- InvTree[Layer %in% "2003"]
tree2019 <- InvTree[Layer %in% "2019"]
treeps <- InvTree[Layer %in% "L1/L2",.(Opening = unique(Opening), Plot = unique(Plot), Layer = unique(Layer), Inventory_Standard = unique(Inventory_Standard), BEC = unique(BEC), BEC_sub_va = unique(BEC_sub_va), PCT = NA, Age = mean(Age, na.rm = TRUE), Ht = mean(Ht, na.rm = TRUE), Count = sum(Count, na.rm = TRUE), BAF = 5, Prismcount = sum(Prismcount, na.rm = TRUE)), by=.(PlotNum,SP)]
treeps[Age %in% NaN, Age := NA]
treeps[Ht %in% NaN, Ht := NA]
treeregen <- InvTree[Layer %in% "L3/L4",.(Opening = unique(Opening), Plot = unique(Plot), Layer = unique(Layer), Inventory_Standard = unique(Inventory_Standard), BEC = unique(BEC), BEC_sub_va = unique(BEC_sub_va),PCT = NA, Age = mean(Age, na.rm = TRUE), Ht = mean(Ht, na.rm = TRUE), Count = sum(Count, na.rm = TRUE),BAF = 5, Prismcount = sum(Prismcount, na.rm = TRUE)), by=.(PlotNum,SP)]
treeregen[Age %in% NaN, Age := NA]
treeregen[Ht %in% NaN, Ht := NA]
treedead <- InvTree[Layer %in% "Dead",.(Opening = unique(Opening), Plot = unique(Plot), Layer = unique(Layer), Inventory_Standard = unique(Inventory_Standard), BEC = unique(BEC), BEC_sub_va = unique(BEC_sub_va), PCT = 100, Age = NA, Ht = NA, Count = NA, BAF = 5, Prismcount = sum(Prismcount, na.rm = TRUE)), by=.(PlotNum,SP)]

invtree <- rbind(tree2003,tree2019,treeps,treedead,treeregen)


# invtree[,TPH := Count *200]

invtree[Layer %in% "L1/L2", PCT := round(100*Count/sum(Count, na.rm = TRUE), digits = 1), by = PlotNum]
invtree[Layer %in% "L3/L4", PCT := round(100*Count/sum(Count, na.rm = TRUE), digits = 1), by = PlotNum]
# setorder(invtree, PlotNum)

write.csv(InvTree,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer.csv", row.names = FALSE)

#2. stand level

##Calculate density for each post-survey plot (3.99m radius)

invdata[Layer %in% "L1/L2",Stand_TPH := sum(Count, na.rm = TRUE)*200, by = PlotNum]
invdata[Layer %in% "L3/L4",Stand_TPH := sum(Count, na.rm = TRUE)*200, by = PlotNum]

##Calculate ba per ha for each post-survey plot

invdata[Layer %in% "L1/L2", Stand_BA := sum(BAF*Prismcount, na.rm = TRUE), by = PlotNum]
invdata[Layer %in% "L3/L4", Stand_BA := sum(BAF*Prismcount, na.rm = TRUE), by = PlotNum]


Invstand <- distinct(invdata[,.(Opening, Plot,PlotNum, Layer, Inventory_Standard, BEC, BEC_sub_va, Stand_SI, Stand_CC, Stand_QMD125, Stand_TPH, Stand_BA, Stand_VOL125, Survey_Date, Dist_year, Kill_PCT)])

write.csv(Invstand,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly.csv", row.names = FALSE)

####THE FOLLOWING CODES CONVERT INVSTAND TABLE FROM LONG TABLE TO WIDE TABLE

InvStand <- data.table()
for (i in unique(invdata$PlotNum)){
  tmp <- invdata[PlotNum %in% i]
  opening <- unique(tmp$Opening)
  plot <- unique(tmp$Plot)
  plotn <- i
  bec <- unique(tmp$BEC_sub_all)
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
  kill <- tmp[Layer %in% "2019", unique(Kill_PCT)]
  invtmp <- data.table(Opening = opening,
                       Plot = plot,
                       PlotNum = plotn,
                       BEC_sub_all = bec,
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
                       Kill_PCT = kill)
  InvStand <- rbind(InvStand,invtmp)
}

#Add 2003's age using Pine's age in VRI2003

test <- InvTree[Layer %in% 2003 & SP %in% "PL",.(PlotNum,Age)]
InvStand <- merge(InvStand, test, by = "PlotNum")
setnames(InvStand, "Age", "Age_2003")
InvStand[, Age_Dist := Age_2003 + Dist_Year - 2003]

#Add 2003's height using Pine's height in VRI2003

test <- InvTree[Layer %in% 2003 & SP %in% "PL",.(PlotNum,Ht)]
InvStand <- merge(InvStand, test, by = "PlotNum")
setnames(InvStand, "Ht", "PL_Ht_2003")

#Add 0 for stand absence from regen, 1 for presence of regen

InvStand[is.na(TPH_PS_Under), Regen := 0]
InvStand[!is.na(TPH_PS_Under), Regen := 1]

##invTable update
##Add dummy variable for the presence or absense of each species in understory

Nplot <- unique(InvStand$PlotNum)
invdata2 <- data.table()
for (i in Nplot){
  tmp <- InvStand[PlotNum %in% i]
  tmptree <- invtree[PlotNum %in% i & Layer %in% "L3/L4"]
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


