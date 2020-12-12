rm(list=ls())
library(data.table)
library(tidyr)
library(reshape2)

invdata <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvTable_post0319.csv"))

##Assign a new plot number for each plot in each opening

Plot <- unique(invdata[,c("Opening", "Plot")])
for ( i in 1:241){
  opening <- Plot[i]$Opening
  plot <- Plot[i]$Plot
  invdata[Opening %in% opening & Plot %in% plot, PlotNum := i]
}

##Unify SP code and merge small species group into their general group (SP0 spcs)

unique(invdata$SP)

# [1] "PL"  "PLI" "SX"  "Pli" "Sb"  "Sx"  "SW"  "SB"  "At"  "AT"  "Ep"  "Bl"  "FDI" "Fdi" "FD"
# [16] "Ac"  "BL"  "X2" "" "EP"  "S"   "AC"  "SXW"

invdata[SP %in% c("PL","PLI","Pli","X2"),SP := "PL"]
invdata[SP %in% c("SX","Sx","S","SW","SB","SXW","Sb"),SP := "S"]
invdata[SP %in% c("At","AT"),SP := "AT"]
invdata[SP %in% c("EP","Ep"),SP := "E"]
invdata[SP %in% c("Bl","BL"),SP := "B"]
invdata[SP %in% c("FDI","Fdi","FD"),SP := "F"]
invdata[SP %in% c("Ac","AC"),SP := "AC"]

rmplot <- invdata[SP %in% "", unique(PlotNum)]
invdata <- invdata[!PlotNum %in% rmplot]

unique(invdata$SP)

# "PL" "S"  "AT" "E"  "B"  "F"  "AC"

##remove plot that do not have regeneration information (no "Regen" in the Status column)

## regenplot <- invdata[Status %in% "Regen", unique(PlotNum)]
##
## invdata <- invdata[PlotNum %in% regenplot]

##How many plots in each BEC & subBEC combination?

invdata[,BEC_sub_all := paste0(BEC,subBEC)]
invdata_BEC <- unique(invdata[,.(PlotNum,BEC_sub_all)])
invdata_BEC[, .N, by = BEC_sub_all]

# #  BEC_sub_all   N
# 1:       SBSmc   8
# 2:       SBSdw 110
# 3:       SBSmw   3
# 4:      SBPSdc   4
# 5:       SBSmk 111

##ALL SP comp before MPB (year 2003)

data <- invdata[Status %in% "2003",.(SP = paste(SP,PCT)),by= PlotNum]
data[, SPcomp := Reduce(paste, SP), by=PlotNum]
data[,SP := NULL]
data <- unique(data)
data <- data[, .N, by = SPcomp]
setorder(data,-N)

#Divide the Invdata into two files
#1. tree level #NOTE: BA is ba/ha

InvTree <- invdata[,.(Opening, Plot,PlotNum, Status, Inventory_Standard, BEC, BEC_sub_all, SP, PCT, Age, Ht, Count, BAF, Prismcount, Stand_BA)]

tree2003 <- InvTree[Status %in% "2003",.(Status = "2003", PCT = sum(PCT), Age = mean(Age, na.rm = TRUE), Ht = mean(Ht, na.rm = TRUE), Count = NA, BAPH = NA), by=.(PlotNum,SP)]
tree2019 <- InvTree[Status %in% "2019",.(Status = "2019", PCT = sum(PCT), Age = mean(Age, na.rm = TRUE), Ht = mean(Ht, na.rm = TRUE), Count = NA, BAPH = Stand_BA * PCT/100), by=.(PlotNum,SP)]
treeps <- InvTree[Status %in% "Post-survey",.(Status = "Post-survey", PCT = NA, Age = mean(Age, na.rm = TRUE), Ht = mean(Ht, na.rm = TRUE), Count = sum(Count, na.rm = TRUE), BAPH = BAF*Prismcount), by=.(PlotNum,SP)]
treeps[Age %in% NaN, Age := NA]
treeps[Ht %in% NaN, Ht := NA]
treeregen <- InvTree[Status %in% "Regen",.(Status = "Regen", PCT = NA, Age = mean(Age, na.rm = TRUE), Ht = mean(Ht, na.rm = TRUE), Count = sum(Count, na.rm = TRUE), BAPH = NA), by=.(PlotNum,SP)]
treeregen[Age %in% NaN, Age := NA]
treeregen[Ht %in% NaN, Ht := NA]

invtree <- rbind(tree2003,tree2019,treeps,treeregen)
stand <- unique(InvTree[,.(PlotNum, BEC_sub_all)])
InvTree <- merge(stand, invtree, by = "PlotNum")


InvTree[Count %in% "0", Count := NA]
InvTree[,TPH := Count *200]

InvTree[Status %in% "Post-survey", PCT := round(100*Count/sum(Count, na.rm = TRUE), digits = 1), by = PlotNum]
InvTree[Status %in% "Regen", PCT := round(100*Count/sum(Count, na.rm = TRUE), digits = 1), by = PlotNum]

write.csv(InvTree,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer.csv", row.names = FALSE)

#2. stand level

##Calculate density for each post-survey plot (3.99m radius)

invdata[Status %in% "Regen",Stand_TPH := sum(Count, na.rm = TRUE)*200, by = PlotNum]
invdata[Status %in% "Post-survey",Stand_TPH := sum(Count, na.rm = TRUE)*200, by = PlotNum]

##Calculate ba per ha for each post-survey plot

invdata[Status %in% "Post-survey",Stand_BA := sum(BAF*Prismcount, na.rm = TRUE), by = PlotNum]

##MPB killed percentage

mean(invdata$Kill_PCT, na.rm = TRUE)
#[1] 50.57673

range(invdata$Kill_PCT, na.rm = TRUE)
#[1]  7 96


Invstand <- distinct(invdata[,.(PlotNum, Status, Inventory_Standard, BEC_sub_all, Stand_SI, Stand_CC, Stand_QMD125, Stand_TPH, Stand_BA, Stand_VOL125, Survey_Date, Dist_year, Kill_PCT)])
Invstand <- Invstand[!Status %in% "Dead"]

write.csv(Invstand,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly.csv", row.names = FALSE)

####THE FOLLOWING CODES CONVERT INVSTAND TABLE FROM LONG TABLE TO WIDE TABLE

InvStand <- data.table()
for (i in unique(invdata$PlotNum)){
  tmp <- invdata[PlotNum %in% i]
  opening <- unique(tmp$Opening)
  plot <- unique(tmp$Plot)
  plotn <- i
  bec <- unique(tmp$BEC_sub_all)
  si2003 <- tmp[Status %in% "2003", unique(Stand_SI)]
  si2019 <- tmp[Status %in% "2019", unique(Stand_SI)]
  cc2003 <- tmp[Status %in% "2003", unique(Stand_CC)]
  cc2019 <- tmp[Status %in% "2019", unique(Stand_CC)]
  qmd2003 <- tmp[Status %in% "2003", unique(Stand_QMD125)]
  qmd2019 <- tmp[Status %in% "2019", unique(Stand_QMD125)]
  ba2003 <- tmp[Status %in% "2003", unique(Stand_BA)]
  ba2019 <- tmp[Status %in% "2019", unique(Stand_BA)]
  baps <- tmp[Status %in% "Post-survey", unique(Stand_BA)]
  tph2003 <- tmp[Status %in% "2003", unique(Stand_TPH)]
  tph2019 <- tmp[Status %in% "2019", unique(Stand_TPH)]
  tphps <- tmp[Status %in% "Post-survey", unique(Stand_TPH)]
  tphregen <- tmp[Status %in% "Regen", unique(Stand_TPH)]
  surveydate <- tmp[Status %in% "Post-survey", unique(Survey_Date)]
  distdate <- tmp[Status %in% "2019", unique(Dist_year)]
  kill <- tmp[Status %in% "2019", unique(Kill_PCT)]
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
                       BA_PS = baps,
                       TPH_2003 = tph2003,
                       TPH_2019 = tph2019,
                       TPH_PS = tphps,
                       TPH_R = tphregen,
                       Survey_Date = surveydate,
                       Dist_Year = distdate,
                       Kill_PCT = kill)
  InvStand <- rbind(InvStand,invtmp)
}

#Add 2003's age using Pine's age in VRI2003

test <- InvTree[Status %in% 2003 & SP %in% "PL",.(PlotNum,Age)]
InvStand <- merge(InvStand, test, by = "PlotNum")
setnames(InvStand, "Age", "Age_2003")
InvStand[, Age_Dist := Age_2003 + Dist_Year - 2003]

#Add 2003's height using Pine's height in VRI2003

test <- InvTree[Status %in% 2003 & SP %in% "PL",.(PlotNum,Ht)]
InvStand <- merge(InvStand, test, by = "PlotNum")
setnames(InvStand, "Ht", "Ht_2003")

#Add 0 for stand absence from regen, 1 for presence of regen

InvStand[is.na(TPH_R), Regen := 0]
InvStand[!is.na(TPH_R), Regen := 1]

##invTable update
##Add dummy variable for the presence or absense of each species

Nplot <- unique(InvStand$PlotNum)
invdata2 <- data.table()
for (i in Nplot){
  tmp <- InvStand[PlotNum %in% i]
  tmptree <- InvTree[PlotNum %in% i & Status %in% "Regen"]
  if(is.element("PL", tmptree$SP)){
    pct <- tmptree[SP %in% "PL", PCT]
    tph <- tmptree2[SP %in% "PL", TPH]
    tmp[,':='(PL = 1,
              PL_PCT = pct)]
  }
  if(is.element("S", tmptree$SP)){
    pct <- tmptree[SP %in% "S", PCT]
    tph <- tmptree2[SP %in% "S", TPH]
    tmp[,':='(S = 1,
              S_PCT = pct)]
  }
  if(is.element("B", tmptree$SP)){
    pct <- tmptree[SP %in% "B", PCT]
    tph <- tmptree2[SP %in% "B", TPH]
    tmp[,':='(B = 1,
              B_PCT = pct)]
  }
  if(is.element("F", tmptree$SP)){
    pct <- tmptree[SP %in% "F", PCT]
    tph <- tmptree2[SP %in% "B", TPH]
    tmp[,':='(F = 1,
              F_PCT = pct)]
  }
  if(is.element("AT", tmptree$SP)|is.element("AC", tmptree$SP)|is.element("E", tmptree$SP)){
    pct <- tmptree[SP %in% "AC"|SP %in% "AT"|SP %in% "AE", sum(PCT, na.rm = TRUE)]
    tph <- tmptree2[SP %in% "AC"|SP %in% "AT"|SP %in% "AE", sum(TPH, na.rm = TRUE)]
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


write.csv(invdata2,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvStand.csv", row.names = FALSE)


