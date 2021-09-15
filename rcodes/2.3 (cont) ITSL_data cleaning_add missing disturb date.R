rm(list=ls())
library(data.table)
library(tidyr)
library(reshape2)
library(dplyr)
library(plotly)

ITSL_poly <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly_VRI0319.csv"))
ITSL_layer <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer_VRI0319_cleaned.csv"))

##check neighbor's value
setnames(ITSL_poly, "SurveyDate", "Survey_Date")
distdate <- ITSL_poly[,.(id,Long,Lat,Dist_year = as.character(Dist_year), Dist_Type, Survey_Date)]
distplot <- ggplot(data = distdate, aes(x = Long, y = Lat, color = Dist_year, label = Survey_Date, label2 = Dist_Type, label3 = id))+
  geom_point()+
  geom_text(data = distdate[!Dist_Type %in% "IBM"], aes(label = id), nudge_y = 150)+
  theme_bw()

ggplotly(distplot)

distdate[!Dist_Type %in% "IBM", Note := 'Missing']
distdate[Dist_Type %in% "IBM", Note := ""]
write.csv(distdate, "//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_distdate.csv", row.names = FALSE, na = "")

###A lot show that disturbance date from VRI2019 is later than survey date
###check with FORSITE for the disturbance date: 2005 (+-1/2years)
###In arcMap
###fill missing disturbance date using the neighbor's disturbance date
###if Survey_Date - Dist_Date <= 0
###change the Dist_Date to 2005

newdistdate <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_distdate_updated.csv"))
tmp <- newdistdate[,.(id, Dist_year)]
ITSL_poly[,Dist_year := NULL]
ITSL_poly <- merge(ITSL_poly, tmp, by = "id")

write.csv(ITSL_poly, "//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly_VRI0319_addistdate.csv", row.names = FALSE, na = "")
