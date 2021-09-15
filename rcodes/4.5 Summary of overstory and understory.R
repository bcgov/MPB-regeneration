rm(list = ls())
library(data.table)
library(ggplot2)
library(quickPlot)

under <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory_cleaned_SI_Cl1Updated_regen.csv"))
regen <- under[Class %in% "R"]

regen[,.(sum(Count)*200/28), by = SP]

SPcolor <- data.table(BA = "indianred1",
                      BL = "goldenrod3",
                      FD = "olivedrab4",
                      HW = "springgreen3",
                      PA = "turquoise",
                      PL = "deepskyblue2",
                      PW = "blue",
                      PY = "mediumorchid",
                      SE = "maroon1")

regen1 <- regen[!Plot %in% "8903U_3PT"]
regenden <- ggplot(data = regen1)+
  geom_bar(aes(x = as.character(Plot), y = Count, fill = SP), stat = "identity")+
  labs(x = "Plot", y = "Stems")+
  scale_fill_manual(values = SPcolor)+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

regensp <- ggplot(data = regen)+
  geom_bar(aes(x = as.character(Plot), y = Count, fill = SP), stat = "identity")+
  labs(x = "Plot", y = "composition")+
  scale_fill_manual(values = SPcolor)+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

vri <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory_VRI2019_AddDistDate.csv"))
unique(vri$Dist_year)

over <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory.csv"))
over_sp1 <- over[,.(Plot = Call_Num,
                    Layer,
                    SP = Spcs_1,
                    PCT = Sp1_pct,
                    Age = Sp1_Age,
                    Ht = Sp1_Ht)]
over_sp1 <- over_sp1[!SP %in% NA]
over_sp2 <- over[,.(Plot = Call_Num,
                    Layer,
                    SP = Spcs_2,
                    PCT = Sp2_pct,
                    Age = Sp2_Age,
                    Ht = Sp2_Ht)]
over_sp2 <- over_sp2[!SP %in% NA]
over_sp2 <- over_sp2[!PCT %in% 0]
over_sp3 <- over[,.(Plot = Call_Num,
                    Layer,
                    SP = Spcs_3,
                    PCT = Sp3_pct)]
over_sp3 <- over_sp3[!SP %in% NA]
over_sp3 <- over_sp3[!PCT %in% 0]
over_sp4 <- over[,.(Plot = Call_Num,
                    Layer,
                    SP = Spcs_4,
                    PCT = Sp4_pct)]
over_sp4 <- over_sp4[!SP %in% NA]
over_sp4 <- over_sp4[!PCT %in% 0]

over_layer <- rbind(over_sp1, over_sp2, over_sp3, over_sp4, fill = TRUE)
setorder(over_layer, Plot)
over_layer[Layer %in% "1", Layer := "O"]
over_layer[SP %in% "PLI", SP := "PL"]
over_layer[SP %in% "FDI", SP := "FD"]
over_poly <- over[,.(Plot = Call_Num,
                     Layer,
                     BA = Basal_Area,
                     TPH = Density)]

p <- unique(regen1$Plot)
regen_over <- over_layer[Plot %in% p]
regen_over <- regen_over[!Layer %in% "D"]

oversp <- ggplot(data = regen_over)+
  geom_bar(aes(x = as.character(Plot), y = PCT, fill = SP), stat = "identity")+
  labs(x = "Plot", y = "composition")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

tph <- over_poly[,.(Plot,
                    TPH)]
tph <- tph[!TPH %in% NA]

regen_over <- merge(regen_over, tph, by = "Plot", all.x = TRUE)

regen_over[, TPH_SP := round(PCT *TPH/100, digits = 2)]

overden <- ggplot(data = regen_over)+
  geom_bar(aes(x = as.character(Plot), y = TPH_SP, fill = SP), stat = "identity")+
  labs(x = "Plot", y = "TPH")+
  scale_fill_manual(values = SPcolor)+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

regen1$vaBEC <- as.character(regen1$vaBEC)
regen1[vaBEC %in% NA, vaBEC := ""]
regen1[,allBEC := paste0(BEC,subBEC,vaBEC)]

ageht <- regen1[,.(MeanAge = round(mean(Age), digits = 0),
                   MeanHt = round(mean(Ht), digits = 2)),
                by = .(SP,allBEC)]
setorder(ageht, allBEC, SP)

bec1 <- unique(regen1[,.(Plot, allBEC)])
setorder(bec1, allBEC)
NP <- bec1[,.N, by = allBEC]

bec2 <- unique(regen1[,.(Plot, SP, allBEC)])
setorder(bec2, allBEC, SP)
bec2[,.N, by = .(allBEC,SP)]

regen2 <- merge(regen1, NP, by = "allBEC", all = TRUE)
count <- regen2[,.(MeanCount = round(sum(Count)/N, digits = 2)),
                by = .(SP, allBEC)]
test <- regen2[,.(sumCount = sum(Count),
                  N=unique(N)), by = .(SP,allBEC)]
test[, meanCount := round(sumCount/N, digits = 2)]
setorder(test, allBEC, SP)
