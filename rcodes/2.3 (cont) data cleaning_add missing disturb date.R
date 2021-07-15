rm(list=ls())
library(data.table)
library(tidyr)
library(reshape2)
library(dplyr)
library(plotly)

ITSL_poly <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly_VRI0319.csv"))
ITSL_layer <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer_VRI0319_cleaned.csv"))

##fill NA using neighbor's value
setnames(ITSL_poly, "SurveyDate", "Survey_Date")
distdate <- ITSL_poly[,.(id,Long,Lat,Dist_year = as.character(Dist_year), Dist_Type, Survey_Date)]
distplot <- ggplot(data = distdate, aes(x = Long, y = Lat, color = Dist_year, label = Survey_Date, label2 = Dist_Type, label3 = id))+
  geom_point()+
  geom_text(data = distdate[!Dist_Type %in% "IBM"], aes(label = id), nudge_y = 150)+
  theme_bw()

ggplotly(distplot)

###A lot show that disturbance date from VRI2019 is later than survey date
###check with FORSITE for the disturbance date: 2005 (+-1/2years)
###convert all ITSL's dist date to 2005?
