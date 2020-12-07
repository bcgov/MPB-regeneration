rm(list=ls())
library(data.table)
library(quickPlot)
library(ggplot2)

InvTree <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvTree.csv"))
InvStand <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvStand.csv"))

##remove non-regeneration plots in InvTree and InvStand

n <- InvStand[Regen %in% "0", PlotNum]
InvStand <- InvStand[Regen %in% "1"]
InvTree <- InvTree[!PlotNum %in% n]

##set color for species

SPcolor <- data.table(PL = "#56B4E9",
                      S = "#E69F00",
                      AT = "#D55E00",
                      E = "#999999",
                      B = "#F0E442",
                      F = "#009E73",
                      AC = "#CC79A7")

##############
## SBSmk #####
##############

SBSmkTree <- InvTree[BEC_sub_all %in% "SBSmk"]
SBSmkStand <- InvStand[BEC_sub_all %in% "SBSmk"]

SBSmk_Pine_PlotNum <- SBSmkTree[Status %in% 2003 & SP %in% "PL" & PCT >= 70, PlotNum]
SBSmkTree_Pine <- SBSmkTree[PlotNum %in% SBSmk_Pine_PlotNum]
SBSmkStand_Pine <- SBSmkStand[PlotNum %in% SBSmk_Pine_PlotNum]

SBSmkStand_Pine[, mean(TPH_R,na.rm = TRUE)]
#[1] 1928.713

SBSmkStand_Pine[, range(TPH_R,na.rm = TRUE)]
#[1] 200 9200

SBSmkStand_Pine[,sqrt(var(TPH_R, na.rm = TRUE))]
#[1] 1651.565

#Plot species combination

SBSmk_spcomp2003 <- ggplot(data = SBSmkTree_Pine[Status %in% "2003"])+
  geom_bar(aes(x = as.character(PlotNum), y = PCT, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(x = "Plot", y = "PCT by volume")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

SBSmk_spcomp2019 <- ggplot(data = SBSmkTree_Pine[Status %in% "2019"])+
  geom_bar(aes(x = as.character(PlotNum), y = PCT, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "VRI 2019 overstory species composition (SBSmk)", x = "Plot", y = "PCT by basal area")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

SBSmk_spregen <- ggplot(data = SBSmkTree_Pine[Status %in% "Regen"])+
  geom_bar(aes(x = as.character(PlotNum), y = Count, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-survey regeneration composition (SBSmk)", x = "Plot", y = "PCT by stems tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

SBSdw_spcomp2019 <- ggplot(data = SBSdwTree_Pine[Status %in% "Post-survey"])+
  geom_bar(aes(x = as.character(PlotNum), y = Count, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-survey overstory species composition (SBSmk)", x = "Plot", y = "PCT by Stem tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

data <- SBSdw[Status %in% "2003",.(SP = paste(SP,PCT)),by= Plot2]
data[, SPcomp := Reduce(paste, SP), by=Plot2]
data[,SP := NULL]
data <- unique(data)
data <- data[, .N, by = SPcomp]
setorder(data,-N)


#density, age, height of regeneration

SBSmkTree_Pine[Status %in% "Regen", sum(TPH, na.rm = TRUE)/101, by = SP]
SBSmkTree_Pine[Status %in% "Regen", range(TPH, na.rm = TRUE), by = SP]
SBSmkTree_Pine[Status %in% "Regen", mean(Age, na.rm = TRUE), by = SP]
SBSmkTree_Pine[Status %in% "Regen", range(Age, na.rm = TRUE), by = SP]
SBSmkTree_Pine[Status %in% "Regen", mean(Ht, na.rm = TRUE), by = SP]
SBSmkTree_Pine[Status %in% "Regen", range(Ht, na.rm = TRUE), by = SP]



SBSmk_regenage <- ggplot(data = SBSmkTree_Pine[Status %in% "Regen"])+
  geom_histogram(aes(x = Age, color = SP), fill = "white")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Histogram of Regen age (SBSmk)", x = "Age", y = "Frequency")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

SBSmk_regenht <- ggplot(data = SBSmkTree_Pine[Status %in% "Regen"])+
  geom_histogram(aes(x = Ht, color = SP), fill = "white")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Histogram of Regen ht (SBSmk)", x = "Age", y = "Frequency")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())


##############
## SBSdw #####
##############


SBSdwTree <- InvTree[BEC_sub_all %in% "SBSdw"]
SBSdwStand <- InvStand[BEC_sub_all %in% "SBSdw"]


##Pine dominant stands

SBSdw_Pine_PlotNum <- SBSdwTree[Status %in% 2003 & SP %in% "PL" & PCT >= 70, PlotNum]
SBSdwTree_Pine <- SBSdwTree[PlotNum %in% SBSdw_Pine_PlotNum]
SBSdwStand_Pine <- SBSdwStand[PlotNum %in% SBSdw_Pine_PlotNum]

SBSdwStand_Pine[, mean(TPH_R,na.rm = TRUE)]
#[1] 2178.313

SBSdwStand_Pine[, range(TPH_R,na.rm = TRUE)]
#[1] 200 12600

SBSdwStand_Pine[,sqrt(var(TPH_R))]
#[1] 2156.784

#Plot species composition

SBSdw_spcomp2003 <- ggplot(data = SBSdwTree_Pine[Status %in% "2003"])+
  geom_bar(aes(x = as.character(PlotNum), y = PCT, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(x = "Plot", y = "PCT by volume")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

SBSdw_spcomp2019 <- ggplot(data = SBSdwTree_Pine[Status %in% "2019"])+
  geom_bar(aes(x = as.character(PlotNum), y = PCT, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "VRI 2019 overstory species composition (SBSdw)", x = "Plot", y = "PCT by basal area")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

SBSdw_spregen <- ggplot(data = SBSdwTree_Pine[Status %in% "Regen"])+
  geom_bar(aes(x = as.character(PlotNum), y = Count, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-survey regeneration composition (SBSdw)", x = "Plot", y = "PCT by stems tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())


SBSdw_spcomp2019 <- ggplot(data = SBSdwTree_Pine[Status %in% "Post-survey"])+
  geom_bar(aes(x = as.character(PlotNum), y = Count, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(x = "Plot", y = "PCT by Stem tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

#density, age, height of regeneration

SBSdwTree_Pine[Status %in% "Regen", sum(TPH, na.rm = TRUE)/83, by = SP]
SBSdwTree_Pine[Status %in% "Regen", range(TPH, na.rm = TRUE), by = SP]
SBSdwTree_Pine[Status %in% "Regen", mean(Age, na.rm = TRUE), by = SP]
SBSdwTree_Pine[Status %in% "Regen", range(Age, na.rm = TRUE), by = SP]
SBSdwTree_Pine[Status %in% "Regen", mean(Ht, na.rm = TRUE), by = SP]
SBSdwTree_Pine[Status %in% "Regen", range(Ht, na.rm = TRUE), by = SP]

SBSdw_regenage <- ggplot(data = SBSdwTree_Pine[Status %in% "Regen"])+
  geom_histogram(aes(x = Age, color = SP), fill = "white")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Histogram of Regen age (SBSdw)", x = "Age", y = "Frequency")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

SBSdw_regenht <- ggplot(data = SBSdwTree_Pine[Status %in% "Regen"])+
  geom_histogram(aes(x = Ht, color = SP), fill = "white")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Histogram of Regen ht (SBSdw)", x = "Age", y = "Frequency")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())


###post-MPB overstory species composition vs regeneration species composition
#SBSmk

a <- SBSmkTree_Pine[Status %in% "Regen", .(mean = sum(TPH, na.rm = TRUE)/101), by = SP]
b <- SBSmkTree_Pine[Status %in% "Post-survey", .(mean = sum(TPH, na.rm = TRUE)/101, Status = "Post-survey"), by = SP]
c <- rbind(a, b)

test <- ggplot(data = c)+
  geom_bar(aes(x = as.character(Status), y = mean, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-survey canopy versus regeneration species composition (SBSmk)", x = "Status", y = "PCT by stems tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

#SBSdw

d <- SBSdwTree_Pine[Status %in% "Regen", .(mean = sum(TPH, na.rm = TRUE)/101, Status = "Regen"), by = SP]
e <- SBSdwTree_Pine[Status %in% "Post-survey", .(mean = sum(TPH, na.rm = TRUE)/101, Status = "Post-survey"), by = SP]
f <- rbind(d,e)

test <- ggplot(data = f)+
  geom_bar(aes(x = as.character(Status), y = mean, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(title = "Post-survey canopy versus regeneration species composition (SBSdw)", x = "Status", y = "PCT by stems tallied")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())
