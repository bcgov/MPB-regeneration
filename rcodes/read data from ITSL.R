#######################
##read data from ITSL##
#######################

rm(list=ls())
library(data.table)
library(openxlsx)
library(sp)
library(rgdal)
library(tidyr)
library(dplyr)
options(stringsAsFactors = FALSE)

datapath <- "\\\\orbital\\s63016\\!Workgrp\\Inventory\\MPB regeneration_WenliGrp\\raw data"
datapath_compiled <- "\\\\orbital\\s63016\\!Workgrp\\Inventory\\MPB regeneration_WenliGrp\\compiled data"

ITSLdatapath <- file.path(datapath, "ITSL")
ITSLdatapath_compiled<-file.path(datapath_compiled,"ITSL")

ITSLdata <- data.table(read.xlsx(file.path(ITSLdatapath, "BCTS ITSL summary TOR 2020-12-04ch.xlsx"),
                                 sheet = "Scrape",
                                 detectDates = TRUE))

##Polygon information, this includes:
##survey date
##TSA, location
##Lat, Long
##survey area, #plots in the polygon
##BEC zone
##site index for Pine
##% nonpine ba, % pine attacked ba
##BAF
##nonpine ba/ha, dead pine ba/ha, live pine ba/ha

ITSL_poly <- ITSLdata[,.(id = 1:dim(ITSLdata)[1],
                         SurveyDate = Survey.date,
                         TSA,
                         Location,
                         Lat = `Latitude.(DD)`,
                         Long = `Longitude.(DD)`,
                         Area = Survey.Area,
                         BEC,
                         PliSI = Pli.SI,
                         PCTnonPba = `%.Estimated.non.pine.conifers.by.basal.area`,
                         PCTPliKillba = `%.Pli.attack.by.basal.area`,
                         BAF,
                         TF = 200,
                         NPlots = Plots,
                         NPlidead = `#.Pli.dead`,
                         nonPliba = BA.non.Pli,
                         DeadPliba = BA.Pli.Dead,
                         LivePliba = BA.Pli.Live)]

###convert gps lat long to bcalbers

is.element(TRUE, is.na(ITSL_poly[,.(Lat)]))
is.element(TRUE, is.na(ITSL_poly[,.(Long)]))

pointmap <- SpatialPointsDataFrame(ITSL_poly[,.(Long, Lat)],
                                   data = ITSLdata,
                                   proj4string = CRS("+proj=longlat"))

pointmap_convert <- spTransform(pointmap,
                                "+proj=aea +lat_1=50
                                 +lat_2=58.5 +lat_0=45
                                 +lon_0=-126 +x_0=1000000
                                 +y_0=0 +ellps=GRS80
                                 +towgs84=0,0,0,0,0,0,0
                                 +units=m +no_defs")

bcalbers <- data.frame(pointmap_convert@coords)
setnames(ITSL_poly,"Lat","GPSlat")
setnames(ITSL_poly,"Long","GPSlong")
ITSL_poly <- cbind(ITSL_poly, bcalbers)

write.csv(ITSL_poly,file.path(ITSLdatapath_compiled, "ITSL_poly.csv"), row.names = FALSE)

##layer information, this inlcude two tables:
##1.ITSL_layer: total tree tallied, total conifer tallied and crown closure by layers
##2.ITSL_layer_sp: species, species pct, age, ht by layers

###1. ITSL_layer
###convert wide table to long table
# The comment code below use sperate() for the conversion, the uncomment code use melt()
# ITSLdata_layer_tt <- ITSLdata[,.(id,
#                                  L1TT,
#                                  L2TT,
#                                  L3TT,
#                                  L4TT)]
# ITSLdata_layer_tt <- reshape(data = ITSLdata_layer_tt,
#                              varying = c("L1TT", "L2TT", "L3TT", "L4TT"),
#                              v.names = "TT",
#                              timevar = "Layer",
#                              idvar = "id",
#                              direction = "long")
#
# ITSLdata_layer_cc <- ITSLdata[,.(id,
#                                  L1CC,
#                                  L2CC,
#                                  L3CC,
#                                  L4CC)]
# ITSLdata_layer_cc <- reshape(data = ITSLdata_layer_cc,
#                              varying = c("L1CC", "L2CC", "L3CC", "L4CC"),
#                              v.names = "CC",
#                              timevar = "Layer",
#                              idvar = "id",
#                              direction ="long")
# ITSLdata_layer <- merge(ITSLdata_layer_cc, ITSLdata_layer_tt, by = c("id", "Layer"))

ITSL_layer <- ITSLdata[,.(id = 1:dim(ITSLdata)[1],
                          L1TT,
                          L2TT,
                          L3TT,
                          L4TT,
                          L1TC,
                          L2TC,
                          L3TC,
                          L4TC,
                          L1CC = `INVL1CC%`,
                          L2CC = `INVL2CC%`,
                          L3CC = `INVL3CC%`,
                          L4CC = `INVL4CC%`)]

ITSL_layer <- melt(data = ITSL_layer,
                   id.vars = "id",
                   measure.vars = list(c("L1TT", "L2TT", "L3TT", "L4TT"), c("L1TC", "L2TC","L3TC", "L4TC"), c("L1CC", "L2CC", "L3CC", "L4CC")),
                   variable.name = "Layer",
                   value.name = c("TT", "TC", "CC"),
                   variable.factor = FALSE)


###2. ITSL_layer_sp

ITSL_layer_sp <- ITSLdata[,.(id = 1:dim(ITSLdata)[1],
                             L1sp1 = INVL1Sp1,
                             L1sp1pct = `INVL1Sp1%`,
                             L1sp1age = INVL1Sp1Age,
                             L1sp1ht = INVL1sp1ht,
                             L1sp2 = INVL1Sp2,
                             L1sp2pct = `INVL1Sp2%`,
                             L1sp2age = INVL1Sp2Age,
                             L1sp2ht = INVL1Sp2ht,
                             L1sp3 = INVL1Sp3,
                             L1sp3pct = `INVL1Sp3%`,
                             L1sp3age = INVL1Sp3Age,
                             L1sp3ht = INVL1Sp3ht,
                             L1sp4 = INVL1Sp4,
                             L1sp4pct = `INVL1Sp4%`,
                             L1sp4age = INVL1Sp4Age,
                             L1sp4ht = INVL1Sp4ht,
                             L2sp1 = INVL2Sp1,
                             L2sp1pct = `INVL2Sp1%`,
                             L2sp1age = INVL2Sp1Age,
                             L2sp1ht = INVL2sp1ht,
                             L2sp2 = INVL2Sp2,
                             L2sp2pct = `INVL2Sp2%`,
                             L2sp2age = INVL2Sp2Age,
                             L2sp2ht = INVL2Sp2ht,
                             L2sp3 = INVL2Sp3,
                             L2sp3pct = `INVL2Sp3%`,
                             L2sp3age = INVL2Sp3Age,
                             L2sp3ht = INVL2Sp3ht,
                             L2sp4 = INVL2Sp4,
                             L2sp4pct = `INVL2Sp4%`,
                             L2sp4age = INVL2Sp4Age,
                             L2sp4ht = INVL2Sp4ht,
                             L3sp1 = INVL3Sp1,
                             L3sp1pct = `INVL3Sp1%`,
                             L3sp1age = INVL3Sp1Age,
                             L3sp1ht = INVL3sp1ht,
                             L3sp2 = INVL3Sp2,
                             L3sp2pct = `INVL3Sp2%`,
                             L3sp2age = INVL3Sp2Age,
                             L3sp2ht = INVL3Sp2ht,
                             L3sp3 = INVL3Sp3,
                             L3sp3pct = `INVL3Sp3%`,
                             L3sp3age = INVL3Sp3Age,
                             L3sp3ht = INVL3Sp3ht,
                             L3sp4 = INVL3Sp4,
                             L3sp4pct = `INVL3Sp4%`,
                             L3sp4age = INVL3Sp4Age,
                             L3sp4ht = INVL3Sp4ht,
                             L4sp1 = INVL4Sp1,
                             L4sp1pct = `INVL4Sp1%`,
                             L4sp1age = INVL4Sp1Age,
                             L4sp1ht = INVL4sp1ht,
                             L4sp2 = INVL4Sp2,
                             L4sp2pct = `INVL4Sp2%`,
                             L4sp2age = INVL4Sp2Age,
                             L4sp2ht = INVL4Sp2ht,
                             L4sp3 = INVL4Sp3,
                             L4sp3pct = `INVL4Sp3%`,
                             L4sp3age = INVL4Sp3Age,
                             L4sp3ht = INVL4Sp3ht,
                             L4sp4 = INVL4Sp4,
                             L4sp4pct = `INVL4Sp4%`,
                             L4sp4age = INVL4Sp4Age,
                             L4sp4ht = INVL4Sp4ht)]

###convert wide table to long table
# L1 <- ITSL_layer_sp[,c(1,grep("L1", names(ITSL_layer_sp))), with = FALSE]
# L1_sp <- NULL
# for ( i in unique(L1$id)){
#   sp1 <- L1[id %in% i, .(id = i, Layer = "1", SP = L1sp1, PCT = L1sp1pct, AGE = L1sp1age, HT = L1sp1ht)]
#   sp2 <- L1[id %in% i, .(id = i, Layer = "1", SP = L1sp2, PCT = L1sp2pct, AGE = L1sp2age, HT = L1sp2ht)]
#   sp3 <- L1[id %in% i, .(id = i, Layer = "1", SP = L1sp3, PCT = L1sp3pct, AGE = L1sp3age, HT = L1sp3ht)]
#   sp4 <- L1[id %in% i, .(id = i, Layer = "1", SP = L1sp4, PCT = L1sp4pct, AGE = L1sp4age, HT = L1sp4ht)]
#   sp <- rbind(sp1,sp2,sp3,sp4)
#   L1_sp <- rbind(L1_sp, sp)
# }
# L2 <- ITSL_layer_sp[,c(1,grep("L2", names(ITSL_layer_sp))), with = FALSE]
# L2_sp <- NULL
# for ( i in unique(L2$id)){
#   sp1 <- L2[id %in% i, .(id = i, Layer = "2", SP = L2sp1, PCT = L2sp1pct, AGE = L2sp1age, HT = L2sp1ht)]
#   sp2 <- L2[id %in% i, .(id = i, Layer = "2", SP = L2sp2, PCT = L2sp2pct, AGE = L2sp2age, HT = L2sp2ht)]
#   sp3 <- L2[id %in% i, .(id = i, Layer = "2", SP = L2sp3, PCT = L2sp3pct, AGE = L2sp3age, HT = L2sp3ht)]
#   sp4 <- L2[id %in% i, .(id = i, Layer = "2", SP = L2sp4, PCT = L2sp4pct, AGE = L2sp4age, HT = L2sp4ht)]
#   sp <- rbind(sp1,sp2,sp3,sp4)
#   L2_sp <- rbind(L2_sp, sp)
# }
# L3 <- ITSL_layer_sp[,c(1,grep("L3", names(ITSL_layer_sp))), with = FALSE]
# L3_sp <- NULL
# for ( i in unique(L3$id)){
#   sp1 <- L3[id %in% i, .(id = i, Layer = "3", SP = L3sp1, PCT = L3sp1pct, AGE = L3sp1age, HT = L3sp1ht)]
#   sp2 <- L3[id %in% i, .(id = i, layer = "3", SP = L3sp2, PCT = L3sp2pct, AGE = L3sp2age, HT = L3sp2ht)]
#   sp3 <- L3[id %in% i, .(id = i, Layer = "3", SP = L3sp3, PCT = L3sp3pct, AGE = L3sp3age, HT = L3sp3ht)]
#   sp4 <- L3[id %in% i, .(id = i, Layer = "3", SP = L3sp4, PCT = L3sp4pct, AGE = L3sp4age, HT = L3sp4ht)]
#   sp <- rbind(sp1,sp2,sp3,sp4)
#   L3_sp <- rbind(L3_sp, sp)
# }
# L4 <- ITSL_layer_sp[,c(1,grep("L4", names(ITSL_layer_sp))), with = FALSE]
# L4_sp <- NULL
# for ( i in unique(L4$id)){
#   sp1 <- L4[id %in% i, .(id = i, Layer = "4", SP = L4sp1, PCT = L4sp1pct, AGE = L4sp1age, HT = L4sp1ht)]
#   sp2 <- L4[id %in% i, .(id = i, layer = "4", SP = L4sp2, PCT = L4sp2pct, AGE = L4sp2age, HT = L4sp2ht)]
#   sp3 <- L4[id %in% i, .(id = i, Layer = "4", SP = L4sp3, PCT = L4sp3pct, AGE = L4sp3age, HT = L4sp3ht)]
#   sp4 <- L4[id %in% i, .(id = i, Layer = "4", SP = L4sp4, PCT = L4sp4pct, AGE = L4sp4age, HT = L4sp4ht)]
#   sp <- rbind(sp1,sp2,sp3,sp4)
#   L4_sp <- rbind(L4_sp, sp)
# }
#
# ITSL_sp <- rbind(L1_sp, L2_sp, L3_sp, L4_sp)

layer_sp <- data.table(expand.grid(id = unique(ITSL_layer_sp$id),
                                   Layer = 1:4,
                                   spn = 1:4))

sptable <- NULL
pcttable <- NULL
agetable <- NULL
httable <- NULL
for (indilayer in 1:4){
  sp <- reshape(data = ITSL_layer_sp[,c("id", paste0("L", indilayer, c("sp1", "sp2", "sp3", "sp4"))), with = FALSE],
                idvar = "id",
                varying = paste0("L", indilayer, c("sp1", "sp2", "sp3", "sp4")),
                v.names = "SP",
                timevar = "spn",
                direction = "long")
  sp[,Layer := indilayer]
  sptable <- rbind(sptable, sp)
  pct <- reshape(data = ITSL_layer_sp[,c("id", paste0("L", indilayer, c("sp1pct", "sp2pct", "sp3pct", "sp4pct"))), with = FALSE],
                 idvar = "id",
                 varying = paste0("L", indilayer, c("sp1pct", "sp2pct", "sp3pct", "sp4pct")),
                 v.names = "PCT",
                 timevar = "spn",
                 direction = "long")
  pct[,Layer := indilayer]
  pcttable <- rbind(pcttable, pct)
  age <- reshape(data = ITSL_layer_sp[,c("id", paste0("L", indilayer, c("sp1age", "sp2age", "sp3age", "sp4age"))), with = FALSE],
                 idvar = "id",
                 varying = paste0("L", indilayer, c("sp1age", "sp2age", "sp3age", "sp4age")),
                 v.names = "AGE",
                 timevar = "spn",
                 direction = "long")
  age[,Layer := indilayer]
  agetable <- rbind(agetable, age)
  ht <- reshape(data = ITSL_layer_sp[,c("id", paste0("L", indilayer, c("sp1ht", "sp2ht", "sp3ht", "sp4ht"))), with = FALSE],
                idvar = "id",
                varying = paste0("L", indilayer, c("sp1ht", "sp2ht", "sp3ht", "sp4ht")),
                v.names = "HT",
                timevar = "spn",
                direction = "long")
  ht[,Layer := indilayer]
  httable <- rbind(httable, ht)
}

layer_sp <- merge(layer_sp, sptable, by = c("id", "Layer", "spn"), all.x = TRUE)
layer_sp <- merge(layer_sp, pcttable, by = c("id", "Layer", "spn"), all.x = TRUE)
layer_sp <- merge(layer_sp, agetable, by = c("id", "Layer", "spn"), all.x = TRUE)
layer_sp <- merge(layer_sp, httable, by = c("id", "Layer", "spn"), all.x = TRUE)































