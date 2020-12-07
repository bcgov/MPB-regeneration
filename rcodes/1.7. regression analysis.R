#####################################
##Regeneration modeling development##
#####################################

rm(list=ls())
library(data.table)
library(quickPlot)
library(ggplot2)
library(MASS) #for negative binomial regression
library(pscl) # for zero inflected negative binomial regression

InvTree <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvTree.csv"))
InvStand <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/InvStand.csv"))

##remove non-regeneration plots in InvTree and InvStand

n <- InvStand[Regen %in% "0", PlotNum]
InvStand <- InvStand[Regen %in% "1"]
InvTree <- InvTree[!PlotNum %in% n]
InvStand[,PL_PCT := PL_PCT/100]
InvStand[,S_PCT := S_PCT/100]
InvStand[,B_PCT := B_PCT/100]
InvStand[,F_PCT := F_PCT/100]
InvStand[,HW_PCT := HW_PCT/100]
InvStand[,Interval := Dist_Year-2003]

##divided to SBSmk and SBSdw

SBSmkTree <- InvTree[BEC_sub_all %in% "SBSmk"]
SBSmkStand <- InvStand[BEC_sub_all %in% "SBSmk"]
SBSmk_Pine_PlotNum <- SBSmkTree[Status %in% 2003 & SP %in% "PL" & PCT >= 70, PlotNum]
SBSmkTree_Pine <- SBSmkTree[PlotNum %in% SBSmk_Pine_PlotNum]
SBSmkStand_Pine <- SBSmkStand[PlotNum %in% SBSmk_Pine_PlotNum]

SBSdwTree <- InvTree[BEC_sub_all %in% "SBSdw"]
SBSdwStand <- InvStand[BEC_sub_all %in% "SBSdw"]
SBSdw_Pine_PlotNum <- SBSdwTree[Status %in% 2003 & SP %in% "PL" & PCT >= 70, PlotNum]
SBSdwTree_Pine <- SBSdwTree[PlotNum %in% SBSdw_Pine_PlotNum]
SBSdwStand_Pine <- SBSdwStand[PlotNum %in% SBSdw_Pine_PlotNum]


##1. Prediction of tph of regeneration

lmtest <- lm(log(TPH_R) ~ BA_PS, data = SBSmkStand_Pine)
summary(lmtest)

lmtest <- lm(log(TPH_R) ~ BA_PS, data = SBSdwStand_Pine)
summary(lmtest)

a <- SBSmkStand_Pine[,.(BA_PS, TPH_R)]
a[,TPH_est := exp(coef(lmtest)[1] + coef(lmtest)[2]*BA_PS)]


##2. Model for species composition of regeneration


##PL

test <- glm(PL_PCT ~ BA_2003 + SI_2003 + TPH_R, data = SBSmkStand_Pine, family = "binomial")
summary(test)

test <- glm(PL_PCT ~ BA_2003 + SI_2003 + Interval + CC_2003 + Ht_2003 + QMD125_2003, data = SBSdwStand_Pine, family = "binomial")
summary(test)

ll.null <- test$null.deviance/-2
ll.proposed <- test$deviance/-2
R2 <- (ll.null - ll.proposed)/ll.null
p <- 1-pchisq(2*(ll.proposed - ll.null), df = (length(test$coefficients)-1))

##S

test <- glm(S_PCT ~ TPH_R, data = SBSmkStand_Pine, family = "binomial")
summary(test)

test <- glm(S_PCT ~ BA_2003 + SI_2003 + Interval + CC_2003 + Ht_2003 + QMD125_2003, data = SBSdwStand_Pine, family = "binomial")
summary(test)

##B

test <- glm(B_PCT ~ TPH_2003, data = SBSmkStand_Pine, family = "binomial")
summary(test)

test <- glm(B_PCT ~ TPH_2003, data = SBSdwStand_Pine, family = "binomial")
summary(test)

##F

test <- glm(F_PCT ~ BA_2003 + SI_2003 + Interval + CC_2003 + Ht_2003 + QMD125_2003, data = SBSdwStand_Pine, family = "binomial")
summary(test)

##HW

test <- glm(HW_PCT ~ BA_2003 + SI_2003 + Interval + CC_2003 + Ht_2003 + QMD125_2003, data = SBSdwStand_Pine, family = "binomial")
summary(test)

########
##test##
########

##1. SBSmk

tmpmk <- SBSmkStand_Pine[,.(BA_2003, SI_2003, TPH_2003, TPH_R, S_PCT, PL_PCT, B_PCT, F_PCT, HW_PCT)]

plmk <- (1 + exp(-(-2.8804391 - 0.157407 * tmpmk$BA_2003 + 0.3197415 * tmpmk$SI_2003 + 0.0003847 * tmpmk$TPH_R)))^-1
smk <- (1 + exp(-(-0.0003484 * tmpmk$TPH_R)))^-1
bmk <- (1 + exp(-(-2.1643509 + 0.0008460 * tmpmk$TPH_2003)))^-1
fmk <- 0
hwmk <- 0
tmpmk[,S_est := smk/(smk+plmk+bmk+fmk+hwmk)]
tmpmk[,PL_est := plmk/(smk+plmk+bmk+fmk+hwmk)]
tmpmk[,B_est := bmk/(smk+plmk+bmk+fmk+hwmk)]
tmpmk[,F_est := fmk/(smk+plmk+bmk+fmk+hwmk)]
tmpmk[,HW_est := hwmk/(smk+plmk+bmk+fmk+hwmk)]

tmpmk[,N := 1:dim(tmpmk)[1]]
tmp1 <- tmpmk[,.(N, B_PCT, PL_PCT, S_PCT, F_PCT, HW_PCT)]
tmp2 <- tmpmk[,.(N, B_est, PL_est, S_est, F_est, HW_est)]

tmp1 <- melt(data = tmp1,
             id.vars = c("N"),
             measure.vars = c("B_PCT", "PL_PCT", "S_PCT", "F_PCT", "HW_PCT"),
             variable.name = "SP",
             value.name = "PCT")

tmp2 <- melt(data = tmp2,
             id.vars = c("N"),
             measure.vars = c("B_est", "PL_est", "S_est", "F_est", "HW_est"),
             variable.name = "SP",
             value.name = "Est")

tmp1[SP %in% "B_PCT", SP := "B"]
tmp1[SP %in% "PL_PCT", SP := "PL"]
tmp1[SP %in% "S_PCT", SP := "S"]
tmp1[SP %in% "F_PCT", SP := "F"]
tmp1[SP %in% "HW_PCT", SP := "HW"]

tmp2[SP %in% "B_est", SP := "B"]
tmp2[SP %in% "PL_est", SP := "PL"]
tmp2[SP %in% "S_est", SP := "S"]
tmp2[SP %in% "F_est", SP := "F"]
tmp2[SP %in% "HW_est", SP := "HW"]

tmp <- merge(tmp1,tmp2, by = c("N", "SP"))

SPcolor <- data.table(PL = "#56B4E9",
                      S = "#E69F00",
                      E = "#999999",
                      B = "#F0E442",
                      F = "#009E73",
                      HW = "#CC79A7")

test1 <- ggplot(data = tmp)+
  geom_bar(aes(x = as.character(N), y = PCT, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(x = "Plot", y = "PCT")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

test2 <- ggplot(data = tmp)+
  geom_bar(aes(x = as.character(N), y = Est, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(x = "Plot", y = "PCT")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

test3 <- ggplot(data = tmp[SP %in% "S"])+
  geom_bar(aes(x = as.character(N), y = PCT), stat = "identity")+
  geom_bar(aes(x = as.character(N), y = Est), stat = "identity", col = "red", fill = NA)+
  labs(title = "a    SBSmk S", x = "Plot", y = "PCT")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

test4 <- ggplot(data = tmp[SP %in% "PL"])+
  geom_bar(aes(x = as.character(N), y = PCT), stat = "identity")+
  geom_bar(aes(x = as.character(N), y = Est), stat = "identity", col = "red", fill = NA)+
  labs(title = "b    SBSmk PL", x = "Plot", y = "PCT")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

test5 <- ggplot(data = tmp[SP %in% "B"])+
  geom_bar(aes(x = as.character(N), y = PCT), stat = "identity")+
  geom_bar(aes(x = as.character(N), y = Est), stat = "identity", col = "red", fill = NA)+
  labs(title = "c    SBSmk B", x = "Plot", y = "PCT")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

##2.SBSdw

tmpdw <- SBSdwStand_Pine[,.(CC_2003, Kill_PCT, TPH_R, Ht_2003, S_PCT, PL_PCT, B_PCT, F_PCT, HW_PCT)]

pldw <- (1 + exp(-(-9.06630 + 0.11982 * tmpdw$CC_2003)))^-1
sdw <- (1 + exp(-(-0.018505 * tmpdw$Kill_PCT)))^-1
bdw <- 0
fdw <- (1 + exp(-(-12.7240 + 0.4187 * tmpdw$Ht_2003)))^-1
hwdw <- (1 + exp(-(-2.6637007 + 0.0002246 * tmpdw$TPH_R)))^-1

tmpdw[,S_est := sdw/(sdw+pldw+bdw+fdw+hwdw)]
tmpdw[,PL_est := pldw/(sdw+pldw+bdw+fdw+hwdw)]
tmpdw[,B_est := bdw/(sdw+pldw+bdw+fdw+hwdw)]
tmpdw[,F_est := fdw/(sdw+pldw+bdw+fdw+hwdw)]
tmpdw[,HW_est := hwdw/(sdw+pldw+bdw+fdw+hwdw)]

tmpdw[,N := 1:dim(tmpdw)[1]]
tmp1 <- tmpdw[,.(N, B_PCT, PL_PCT, S_PCT, F_PCT, HW_PCT)]
tmp2 <- tmpdw[,.(N, B_est, PL_est, S_est, F_est, HW_est)]

tmp1 <- melt(data = tmp1,
             id.vars = c("N"),
             measure.vars = c("B_PCT", "PL_PCT", "S_PCT", "F_PCT", "HW_PCT"),
             variable.name = "SP",
             value.name = "PCT")

tmp2 <- melt(data = tmp2,
             id.vars = c("N"),
             measure.vars = c("B_est", "PL_est", "S_est", "F_est", "HW_est"),
             variable.name = "SP",
             value.name = "Est")

tmp1[SP %in% "B_PCT", SP := "B"]
tmp1[SP %in% "PL_PCT", SP := "PL"]
tmp1[SP %in% "S_PCT", SP := "S"]
tmp1[SP %in% "F_PCT", SP := "F"]
tmp1[SP %in% "HW_PCT", SP := "HW"]

tmp2[SP %in% "B_est", SP := "B"]
tmp2[SP %in% "PL_est", SP := "PL"]
tmp2[SP %in% "S_est", SP := "S"]
tmp2[SP %in% "F_est", SP := "F"]
tmp2[SP %in% "HW_est", SP := "HW"]

tmp <- merge(tmp1,tmp2, by = c("N", "SP"))

SPcolor <- data.table(PL = "#56B4E9",
                      S = "#E69F00",
                      E = "#999999",
                      B = "#F0E442",
                      F = "#009E73",
                      HW = "#CC79A7")

test1 <- ggplot(data = tmp)+
  geom_bar(aes(x = as.character(N), y = PCT, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(x = "Plot", y = "PCT")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

test2 <- ggplot(data = tmp)+
  geom_bar(aes(x = as.character(N), y = Est, fill = SP), stat = "identity", position = "fill")+
  scale_fill_manual(values = SPcolor)+
  labs(x = "Plot", y = "PCT")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank())

test6 <- ggplot(data = tmp[SP %in% "S"])+
  geom_bar(aes(x = as.character(N), y = PCT), stat = "identity")+
  geom_bar(aes(x = as.character(N), y = Est), stat = "identity", col = "red", fill = NA)+
  labs(title = "d    SBSdw S", x = "Plot", y = "PCT")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

test7 <- ggplot(data = tmp[SP %in% "PL"])+
  geom_bar(aes(x = as.character(N), y = PCT), stat = "identity")+
  geom_bar(aes(x = as.character(N), y = Est), stat = "identity", col = "red", fill = NA)+
  labs(title = "e    SBSdw PL", x = "Plot", y = "PCT")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

test8 <- ggplot(data = tmp[SP %in% "F"])+
  geom_bar(aes(x = as.character(N), y = PCT), stat = "identity")+
  geom_bar(aes(x = as.character(N), y = Est), stat = "identity", col = "red", fill = NA)+
  labs(title = "f    SBSdw F", x = "Plot", y = "PCT")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

test9 <- ggplot(data = tmp[SP %in% "HW"])+
  geom_bar(aes(x = as.character(N), y = PCT), stat = "identity")+
  geom_bar(aes(x = as.character(N), y = Est), stat = "identity", col = "red", fill = NA)+
  labs(title = "g    SBSdw HW", x = "Plot", y = "PCT")+
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text.x = element_blank())

##3. Prediction of height of regeneration



