rm(list=ls())
library(data.table)
library(quickPlot)
library(ggplot2)

invlayer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer_cleaned.csv"))
invpoly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly_cleaned.csv"))

##remove non-regeneration plots in InvTree and InvStand

# n <- InvStand[Regen %in% "0", id]
# InvStand <- InvStand[Regen %in% "1"]
# InvTree <- InvTree[!id %in% n]

###BEC distribution

invdata_BEC <- distinct(invpoly[,.(id,BEC, BEC_sub_va)])
invdata_BEC[, .N, by = BEC_sub_va]
#    BEC_sub_va   N
# 1:     SBSmc3   3
# 2:     SBSdw2 144
# 3:      SBSmw   6
# 4:     SBSmc2   5
# 5:     SBPSdc   4
# 6:     SBSdw3  41
# 7:     SBSmk1 117

invdata_BEC[, .N, by = BEC]
#     BEC   N
# 1:  SBS 316
# 2: SBPS   4

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

#Add SP0 for all plots?
##Two plots (id 66 and 69 has no record for 2019's VRI, so the SP0 code for them are unkown)

for (i in 1:dim(InvTree)[1]){
  if(InvTree[i, SP] == "PL"){
    InvTree[i, SP0 := "PL"]
  }
  if(InvTree[i, SP] == "SB"|InvTree[i, SP] == "SX"|InvTree[i, SP] == "SW"|InvTree[i, SP] == "S"){
    InvTree[i, SP0 := "S"]
  }
  if(InvTree[i, SP] == "AT"){
    InvTree[i, SP0 := "AT"]
  }
  if(InvTree[i, SP] == "EP"){
    InvTree[i, SP0 := "E"]
  }
  if(InvTree[i, SP] == "BL"){
    InvTree[i, SP0 := "B"]
  }
  if(InvTree[i, SP] == "FD"){
    InvTree[i, SP0 := "F"]
  }
  if(InvTree[i, SP] == "AC"){
    InvTree[i, SP0 := "AC"]
  }
  if(InvTree[i, SP] == "UNK"){
    InvTree[i, SP0 := "UNK"]
  }
}

##set color for species

SPcolor <- data.table(PL = "#56B4E9",
                      S = "#E69F00",
                      AT = "#D55E00",
                      E = "#999999",
                      B = "#F0E442",
                      F = "#009E73",
                      AC = "#CC79A7")

##############
## SBSmk1 #####
##############

SBSmkTree <- InvTree[BEC_sub_va %in% "SBSmk1"]
SBSmkStand <- InvStand[BEC_sub_va %in% "SBSmk1"]

SBSmk_Pine_id <- SBSmkTree[Layer %in% 2003 & SP %in% "PL" & PCT >= 70, unique(id)]
SBSmkTree_Pine <- SBSmkTree[id %in% SBSmk_Pine_id]
SBSmkStand_Pine <- SBSmkStand[id %in% SBSmk_Pine_id]

SBSmkStand_Pine[, mean(TPH_PS_Under,na.rm = TRUE)]
#[1] 1594.286

SBSmkStand_Pine[, range(TPH_PS_Under,na.rm = TRUE)]
#[1] 200 7800

SBSmkStand_Pine[,sqrt(var(TPH_PS_Under, na.rm = TRUE))]
#[1] 1363.101

#Plot species combination

SBSmk_spcomp2003 <- ggplot(data = SBSmkTree_Pine[Layer %in% "2003"])+
  geom_bar(aes(x = as.character(id), y = PCT, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(x = "Plot", y = "PCT by volume")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

SBSmk_spcomp2019 <- ggplot(data = SBSmkTree_Pine[Layer %in% "2019"])+
  geom_bar(aes(x = as.character(id), y = PCT, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "VRI 2019 species composition (SBSmk1)", x = "Plot", y = "PCT by basal area")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Spcomp_VRI2019_SBSmk1.tiff")

SBSmk_spcompPSO <- ggplot(data = SBSmkTree_Pine[Layer %in% "L1/L2"])+
  geom_bar(aes(x = as.character(id), y = Count, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-MPB survey overstory species composition (SBSmk1)", x = "Plot", y = "PCT by stem tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Spcomp_PS_overstory_SBSmk1.tiff")

SBSmk_spregen <- ggplot(data = SBSmkTree_Pine[Layer %in% "L3/L4"])+
  geom_bar(aes(x = as.character(id), y = Count, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-MPB survey understory composition (SBSmk1)", x = "Plot", y = "PCT by stems tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Spcomp_PS_understory_SBSmk1.tiff")


#density, age, height of regeneration

length(unique(SBSmkTree_Pine$id))

SBSmkTree_Pine[Layer %in% "L3/L4", .N, by = SP]
SBSmkTree_Pine[Layer %in% "L3/L4", sum(200*Count, na.rm = TRUE)/109, by = SP]
SBSmkTree_Pine[Layer %in% "L3/L4", range(200*Count, na.rm = TRUE), by = SP]
SBSmkTree_Pine[Layer %in% "L3/L4", median(200*Count, na.rm = TRUE), by = SP]
SBSmkTree_Pine[Layer %in% "L3/L4", mean(Age, na.rm = TRUE), by = SP]
SBSmkTree_Pine[Layer %in% "L3/L4", range(Age, na.rm = TRUE), by = SP]
SBSmkTree_Pine[Layer %in% "L3/L4", median(Age, na.rm = TRUE), by = SP]
SBSmkTree_Pine[Layer %in% "L3/L4", mean(Ht, na.rm = TRUE), by = SP]
SBSmkTree_Pine[Layer %in% "L3/L4", range(Ht, na.rm = TRUE), by = SP]
SBSmkTree_Pine[Layer %in% "L3/L4", median(Ht, na.rm = TRUE), by = SP]


SBSmk_regenage <- ggplot(data = SBSmkTree_Pine[Layer %in% "L3/L4"])+
  geom_histogram(aes(x = Age, color = SP0), fill = "white")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Histogram of understory age (SBSmk1)", x = "Age", y = "Frequency")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Hist_Age_understory_SBSmk1.tiff")

SBSmk_regenht <- ggplot(data = SBSmkTree_Pine[Layer %in% "L3/L4"])+
  geom_histogram(aes(x = Ht, color = SP), fill = "white")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Histogram of understory ht (SBSmk1)", x = "Age", y = "Frequency")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Hist_Ht_understory_SBSmk1.tiff")

###post-MPB overstory species composition vs regeneration species composition
#SBSmk

a <- SBSmkTree_Pine[Layer %in% "L3/L4", .(mean = sum(200*Count, na.rm = TRUE)/109, Layer = "L3/L4"), by = SP0]
b <- SBSmkTree_Pine[Layer %in% "L1/L2", .(mean = sum(200*Count, na.rm = TRUE)/109, Layer = "L1/L2"), by = SP0]
c <- rbind(a, b)

test <- ggplot(data = c)+
  geom_bar(aes(x = as.character(Layer), y = mean, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-survey overstory versus understory species composition (SBSmk1)", x = "Layer", y = "PCT by stems tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Spcomp_PS_OverVsUnder_SBSmk1.tiff")

##############
## SBSdw2 #####
##############


SBSdw2Tree <- InvTree[BEC_sub_va %in% "SBSdw2"]
SBSdw2Stand <- InvStand[BEC_sub_va %in% "SBSdw2"]


##Pine dominant stands

SBSdw2_Pine_id <- SBSdw2Tree[Layer %in% 2003 & SP %in% "PL" & PCT >= 70, unique(id)]
SBSdw2Tree_Pine <- SBSdw2Tree[id %in% SBSdw2_Pine_id]
SBSdw2Stand_Pine <- SBSdw2Stand[id %in% SBSdw2_Pine_id]

SBSdw2Stand_Pine[, mean(TPH_PS_Under,na.rm = TRUE)]
#[1] 1985.586

SBSdw2Stand_Pine[, range(TPH_PS_Under,na.rm = TRUE)]
#[1] 200 12600

SBSdw2Stand_Pine[,sqrt(var(TPH_PS_Under, na.rm = TRUE))]
#[1] 1729.469

#Plot species composition

SBSdw2_spcomp2003 <- ggplot(data = SBSdw2Tree_Pine[Layer %in% "2003"])+
  geom_bar(aes(x = as.character(id), y = PCT, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(x = "Plot", y = "PCT by volume")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

SBSdw2_spcomp2019 <- ggplot(data = SBSdw2Tree_Pine[Layer %in% "2019"])+
  geom_bar(aes(x = as.character(id), y = PCT, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "VRI 2019 species composition (SBSdw2)", x = "Plot", y = "PCT by basal area")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Spcomp_VRI2019_SBSdw2.tiff")

SBSdw2_spover <- ggplot(data = SBSdw2Tree_Pine[Layer %in% "L1/L2"])+
  geom_bar(aes(x = as.character(id), y = Count, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-MPB survey overstory composition (SBSdw2)", x = "Plot", y = "PCT by stems tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Spcomp_PS_overstory_SBSdw2.tiff")

SBSdw2_spregen <- ggplot(data = SBSdw2Tree_Pine[Layer %in% "L3/L4"])+
  geom_bar(aes(x = as.character(id), y = Count, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-MPB survey understory composition (SBSdw2)", x = "Plot", y = "PCT by stems tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Spcomp_PS_understory_SBSdw2.tiff")

#density, age, height of regeneration

SBSdw2Tree_Pine[Layer %in% "L3/L4", .N, by = SP]
SBSdw2Tree_Pine[Layer %in% "L3/L4", sum(200*Count, na.rm = TRUE)/122, by = SP]
SBSdw2Tree_Pine[Layer %in% "L3/L4", range(200*Count, na.rm = TRUE), by = SP]
SBSdw2Tree_Pine[Layer %in% "L3/L4", median(200*Count, na.rm = TRUE), by = SP]
SBSdw2Tree_Pine[Layer %in% "L3/L4", mean(Age, na.rm = TRUE), by = SP]
SBSdw2Tree_Pine[Layer %in% "L3/L4", range(Age, na.rm = TRUE), by = SP]
SBSdw2Tree_Pine[Layer %in% "L3/L4", median(Age, na.rm = TRUE), by = SP]
SBSdw2Tree_Pine[Layer %in% "L3/L4", mean(Ht, na.rm = TRUE), by = SP]
SBSdw2Tree_Pine[Layer %in% "L3/L4", range(Ht, na.rm = TRUE), by = SP]
SBSdw2Tree_Pine[Layer %in% "L3/L4", median(Ht, na.rm = TRUE), by = SP]

SBSdw_regenage <- ggplot(data = SBSdw2Tree_Pine[Layer %in% "L3/L4"])+
  geom_histogram(aes(x = Age, color = SP0), fill = "white")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Histogram of understory age (SBSdw2)", x = "Age", y = "Frequency")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Hist_Age_understory_SBSdw2.tiff")

SBSdw_regenht <- ggplot(data = SBSdw2Tree_Pine[Layer %in% "L3/L4"])+
  geom_histogram(aes(x = Ht, color = SP0), fill = "white")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Histogram of understory ht (SBSdw2)", x = "Age", y = "Frequency")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Hist_Ht_understory_SBSdw2.tiff")

###post-MPB overstory species composition vs regeneration species composition
#SBSdw2

a <- SBSdw2Tree_Pine[Layer %in% "L3/L4", .(mean = sum(Count, na.rm = TRUE)/122, Layer = "L3/L4"), by = SP0]
b <- SBSdw2Tree_Pine[Layer %in% "L1/L2", .(mean = sum(Count, na.rm = TRUE)/122, Layer = "L1/L2"), by = SP0]
c <- rbind(a,b)

test <- ggplot(data = c)+
  geom_bar(aes(x = as.character(Layer), y = mean, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-survey overstory versus understory species composition (SBSdw2)", x = "Layer", y = "PCT by stems tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Spcomp_PS_OverVsUnder_SBSdw2.tiff")


##############
## SBSdw3 #####
##############


SBSdw3Tree <- InvTree[BEC_sub_va %in% "SBSdw3"]
SBSdw3Stand <- InvStand[BEC_sub_va %in% "SBSdw3"]


##Pine dominant stands

SBSdw3_Pine_id <- SBSdw3Tree[Layer %in% 2003 & SP %in% "PL" & PCT >= 70, unique(id)]
SBSdw3Tree_Pine <- SBSdw3Tree[id %in% SBSdw3_Pine_id]
SBSdw3Stand_Pine <- SBSdw3Stand[id %in% SBSdw3_Pine_id]

SBSdw3Stand_Pine[, mean(TPH_PS_Under,na.rm = TRUE)]
#[1] 1552

SBSdw3Stand_Pine[, range(TPH_PS_Under,na.rm = TRUE)]
#[1] 200 4600

SBSdw3Stand_Pine[,sqrt(var(TPH_PS_Under, na.rm = TRUE))]
#[1] 1176.549

#Plot species composition

SBSdw3_spcomp2003 <- ggplot(data = SBSdw3Tree_Pine[Layer %in% "2003"])+
  geom_bar(aes(x = as.character(id), y = PCT, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(x = "Plot", y = "PCT by volume")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

SBSdw3_spcomp2019 <- ggplot(data = SBSdw3Tree_Pine[Layer %in% "2019"])+
  geom_bar(aes(x = as.character(id), y = PCT, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "VRI 2019 species composition (SBSdw3)", x = "Plot", y = "PCT by basal area")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Spcomp_VRI2019_SBSdw3.tiff")

SBSdw3_spover <- ggplot(data = SBSdw3Tree_Pine[Layer %in% "L1/L2"])+
  geom_bar(aes(x = as.character(id), y = Count, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-MPB survey overstory composition (SBSdw3)", x = "Plot", y = "PCT by stems tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Spcomp_PS_overstory_SBSdw3.tiff")

SBSdw3_spregen <- ggplot(data = SBSdw3Tree_Pine[Layer %in% "L3/L4"])+
  geom_bar(aes(x = as.character(id), y = Count, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-MPB survey understory composition (SBSdw3)", x = "Plot", y = "PCT by stems tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Spcomp_PS_understory_SBSdw3.tiff")

#density, age, height of regeneration

SBSdw3Tree_Pine[Layer %in% "L3/L4", .N, by = SP]
SBSdw3Tree_Pine[Layer %in% "L3/L4", sum(200*Count, na.rm = TRUE)/29, by = SP]
SBSdw3Tree_Pine[Layer %in% "L3/L4", range(200*Count, na.rm = TRUE), by = SP]
SBSdw3Tree_Pine[Layer %in% "L3/L4", median(200*Count, na.rm = TRUE), by = SP]
SBSdw3Tree_Pine[Layer %in% "L3/L4", mean(Age, na.rm = TRUE), by = SP]
SBSdw3Tree_Pine[Layer %in% "L3/L4", range(Age, na.rm = TRUE), by = SP]
SBSdw3Tree_Pine[Layer %in% "L3/L4", median(Age, na.rm = TRUE), by = SP]
SBSdw3Tree_Pine[Layer %in% "L3/L4", mean(Ht, na.rm = TRUE), by = SP]
SBSdw3Tree_Pine[Layer %in% "L3/L4", range(Ht, na.rm = TRUE), by = SP]
SBSdw3Tree_Pine[Layer %in% "L3/L4", median(Ht, na.rm = TRUE), by = SP]

SBSdw3_regenage <- ggplot(data = SBSdw3Tree_Pine[Layer %in% "L3/L4"])+
  geom_histogram(aes(x = Age, color = SP0), fill = "white")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Histogram of understory age (SBSdw3)", x = "Age", y = "Frequency")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Hist_Age_understory_SBSdw3.tiff")

SBSdw3_regenht <- ggplot(data = SBSdw3Tree_Pine[Layer %in% "L3/L4"])+
  geom_histogram(aes(x = Ht, color = SP0), fill = "white")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Histogram of understory ht (SBSdw3)", x = "Age", y = "Frequency")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Hist_Ht_understory_SBSdw3.tiff")

###post-MPB overstory species composition vs regeneration species composition
#SBSdw3

a <- SBSdw3Tree_Pine[Layer %in% "L3/L4", .(mean = sum(Count, na.rm = TRUE)/122, Layer = "L3/L4"), by = SP0]
b <- SBSdw3Tree_Pine[Layer %in% "L1/L2", .(mean = sum(Count, na.rm = TRUE)/122, Layer = "L1/L2"), by = SP0]
c <- rbind(a,b)

test <- ggplot(data = c)+
  geom_bar(aes(x = as.character(Layer), y = mean, fill = SP0), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-survey overstory versus understory species composition (SBSdw3)", x = "Layer", y = "PCT by stems tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

ggsave("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Spcomp_PS_OverVsUnder_SBSdw3.tiff")

