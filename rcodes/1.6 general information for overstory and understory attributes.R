rm(list=ls())
library(data.table)
library(quickPlot)
library(ggplot2)

InvTree <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer.csv"))
InvStand <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly_widetable.csv"))

##remove non-regeneration plots in InvTree and InvStand

# n <- InvStand[Regen %in% "0", id]
# InvStand <- InvStand[Regen %in% "1"]
# InvTree <- InvTree[!id %in% n]

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

