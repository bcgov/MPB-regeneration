rm(list=ls())
library(data.table)
library(tidyr)
library(reshape2)
library(dplyr)
library(ggplot2)
library(quickPlot)
library(gridExtra)

invlayer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_layer.csv"))
invpoly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_poly.csv"))

#####abundance and distribution of regeneration
#####ITSL uses bec info from postMPB survey

regen <- invlayer[Layer %in% "L3/L4"]

a <- regen[,.(N1 = sum(PCT, na.rm = TRUE)), by = .(SP, BEC_sub_va)]
a[,N2 := sum(N1), by = BEC_sub_va]
a[,PCT := round(100*N1/N2, digits = 0)]

a <- a[order(a$BEC_sub_va)]
print(a, nrows = 132)

######Pine leading stands in 2003

pid <- invlayer[Layer %in% "2003" & SP %in% "PL" & PCT >= 70, unique(id)]
length(pid)
p <- invpoly[id %in% pid]
p1 <- distinct(p[Data_Source %in% "Erafor", .(id, BEC_sub_va)])
p1[,.N, by = BEC_sub_va]
p2 <- distinct(p[Data_Source %in% "ITSL" & Layer %in% "L1/L2", .(id, BEC_sub_va)])
p2 <- p2[order(p2$BEC_sub_va)]
p2[,.N, by = BEC_sub_va]

#####list data based on beczones

layer <- list()
poly <- list()
allbec <- unique(invlayer$BEC_sub_va)
allbec <- sort(allbec)
for ( i in 1:length(allbec)){
  bec <- allbec[i]
  layer[[i]] <- invlayer[BEC_sub_va %in% bec]
  names(layer)[[i]] <- bec
  poly[[i]] <- invpoly[BEC_sub_va %in% bec]
  names(poly)[[i]] <- bec
}

#####sp comp: Overstory vs Understory

SPcolor <- data.table(PL = "#56B4E9",
                      S = "#E69F00",
                      AT = "#D55E00",
                      E = "#999999",
                      B = "#F0E442",
                      F = "#009E73",
                      AC = "#CC79A7",
                      C = "cornsilk2",
                      PY = "#0072B2",
                      PA = "navyblue",
                      H = "magenta3",
                      L = "chocolate4",
                      PW = "purple4",
                      UNK = "#000000")

fig_spcomp <- list()
for ( i in 1:length(layer)){
#  i<-1
  indibec <- layer[[i]]
  bec <- unique(indibec$BEC_sub_va)

  a <- indibec[Layer %in% "L3/L4", .(sumPCT = sum(PCT, na.rm = TRUE), Layer = "L3/L4"), by = SP0]
  b <- indibec[Layer %in% "L1/L2", .(sumPCT = sum(PCT, na.rm = TRUE), Layer = "L1/L2"), by = SP0]

  c <- rbind(a, b)

  fig_spcomp[[i]] <- ggplot(data = c)+
    geom_bar(aes(x = as.character(Layer), y = sumPCT, fill = SP0), stat = "identity", position = "fill", width = 0.8)+
    scale_fill_manual(values = SPcolor)+
    labs(title = paste(bec), x = "Layer", y = "sp composition")+
    theme(panel.background = element_blank(),
          panel.grid = element_blank())

  names(fig_spcomp)[[i]] <- bec
}

dev(2)
grid.arrange(fig_spcomp$ESSFdc2, fig_spcomp$ESSFwk1, fig_spcomp$ESSFxc, ncol = 2)
dev(3)
grid.arrange(fig_spcomp$ICHdk, fig_spcomp$ICHmk3, fig_spcomp$ICHmw3, ncol = 2)
dev(4)
grid.arrange(fig_spcomp$IDFdk1, fig_spcomp$IDFdk2, fig_spcomp$IDFdk3, fig_spcomp$IDFdk4, ncol=2)
dev(5)
grid.arrange(fig_spcomp$MSdc1, fig_spcomp$MSdm2, fig_spcomp$MSxk1, fig_spcomp$MSxk2, fig_spcomp$MSxv, ncol=2)
dev(6)
grid.arrange(fig_spcomp$SBPSdc, fig_spcomp$SBPSmk, fig_spcomp$SBPSxc, fig_spcomp$SBPSxk, ncol=2)
dev(7)
grid.arrange(fig_spcomp$SBSdw1, fig_spcomp$SBSdw2, fig_spcomp$SBSdw3, fig_spcomp$SBSmc1, fig_spcomp$SBSmc2, fig_spcomp$SBSmc3, fig_spcomp$SBSmk1, fig_spcomp$SBSmm, fig_spcomp$SBSmw, ncol=2)
