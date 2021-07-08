rm(list=ls())
library(data.table)
library(tidyr)
library(reshape2)
library(dplyr)

invlayer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_layer.csv"))
invpoly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_poly.csv"))

##Fill the missing disturbance date using its neighborhood's disturbance date
#1.add gps for arcGIS
#Using ArcGIS to get the neighbohood's disturbance date

distdate <- invpoly[Layer %in% "2019", .(id, Dist_year)]
valid <- date[!Dist_year %in% NA, id]
novalid <- date[Dist_year %in% NA, id]

eraforgps <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Eraforcompile_InvTable_bcalbers.csv"))
eraforgps <- distinct(eraforgps[,.(Opening, Plot, Long, Lat)])

eraforpoly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly.csv"))
id <- distinct(eraforpoly[,.(Opening, Plot, id)])

gps <- merge(eraforgps, id, by = c("Opening", "Plot"))

ITSLgps <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/latlong.csv"))
ITSLgps[, id := id+326]

gps[,c("Opening", "Plot") := NULL]
gps <- rbind(gps, ITSLgps)

validgps <- gps[id %in% valid]
validgps <- merge(validgps, date, by = "id", all.x = TRUE, all.y = FALSE)
setnames(validgps,"Dist_year", "dist")

novalidpgs <- gps[id %in% novalid]

write.csv(validgps, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/distyear.csv", row.names = FALSE)
write.csv(novalidpgs, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/nodistyear.csv", row.names = FALSE)

#2.calculate the interval between the disturbance date and survey date

surveydate <- distinct(invpoly[Layer %in% "L1/L2" | Layer %in% "L3/L4",.(id, Survey_Date)])
year <- merge(distdate, surveydate, by = "id")

nodist <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/nodistyear_adddistyear.txt"))
for ( i in unique(year[Dist_year %in% NA, id])){
  distyear <- nodist[id %in% i, distyear]
  year[id %in% i, Dist_year := distyear]
}

year[,interval := Survey_Date - Dist_year]

#3. Check ids that disturbance date is later than survey date in arcGIS

novalid2 <- year[interval <= 0, id]
novalidgps2 <- gps[id %in% novalid2]
#novalidgps2 <- merge(novalidgps2, year, by = "id", all.x = TRUE, all.y = FALSE)

write.csv(novalidgps2, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/nodistyear2.csv", row.names = FALSE)

ITSLdata <- data.table(read.xlsx("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/raw data/ITSL/BCTS ITSL summary TOR 2020-12-16ch.xlsx",
                                 sheet = "Scrape",
                                 detectDates = TRUE))
novalid4 <- novalid2[novalid2 %in% valid]
novalid5 <- novalid4-326
ITSL <- ITSLdata[id %in% novalid5]
tmpyear <- year[id %in% novalid4]
tmpyear[, id := id-326]
ITSL <- merge(ITSL, tmpyear, by = "id")
write.csv(ITSL,"J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/raw data/ITSL/ITSL_surveydate.csv", row.names = FALSE, na = "")

#4.Fill Erafor's missing disturbance date using neighborhood's value

eraforid <- novalid[novalid %in% 1:326]
for(i in eraforid){
  distyear <- year[id %in% i, Dist_year]
  invpoly[id %in% i & Layer %in% "2019", Dist_year := distyear]
}

#5.ITSL
#use 2005 as disturbance date if Dist_Type is not IBM
#Use 2005 if Survey date is later than disturbance date

test <- invpoly[Data_Source %in% "ITSL" & Layer %in% "2019",.(id,Dist_Type)]
test <- merge(year, test, by = "id", all.x = FALSE, all.y = TRUE)

invpoly[Data_Source %in% "ITSL" & Layer %in% 2019 & Dist_year %in% NA, Dist_year := 2005]

tmpid <- test[!Dist_Type %in% "IBM",id]
invpoly[id %in% tmpid & Layer %in% "2019", Dist_year := 2005]
test2 <- test[id %in% tmpid, Dist_year := 2005]
test2[,interval := Survey_Date - Dist_year]
tmpid2 <- test2[interval <0, id]
invpoly[id %in% tmpid2 & Layer %in% "2019", Dist_year := 2005]
test2[id %in% tmpid2, Dist_year := 2005]

write.csv(invpoly, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_poly_addistyear.csv", row.names = FALSE)





