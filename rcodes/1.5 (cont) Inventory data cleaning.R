rm(list=ls())
library(data.table)
library(quickPlot)
library(ggplot2)
library(plotly)
library(ggrepel)
library(dplyr)

invlayer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_layer_cleaned.csv"))
invpoly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly_cleaned.csv"))

##fill NA dist_year using neighbour's value

distdate <- invpoly[,.(id,Dist_year,Dist_Type, Survey_Date, Long, Lat)]
distplot <- ggplot(data = distdate, aes(x = Long, y = Lat, color = as.character(Dist_year), label = Survey_Date))+
  geom_point()+
  geom_text(data = distdate[!Dist_Type %in% "IBM"], aes(label = id), nudge_y = 150)+
  theme_bw()

ggplotly(distplot)

distdate[id %in% c("298", "325", "291"), Dist_year := 2015]
distdate[id %in% "226", Dist_year := 2015]
distdate[id %in% c("177", "178", "182", "189", "186", "191", "193", "194", "195"), Dist_year := 2015]
distdate[id %in% c("241", "199"), Dist_year := 2014]
distdate[id %in% c("173", "164", "169", "168", "170", "171"), Dist_year := 2015]
distdate[id %in% c("118", "120", "108", "113", "111", "93", "94","95", "96", "100", "91", "92","89", "83", "84", "85", "82", "74","77","80","75", "76", "26", "32", "27", "28"), Dist_year := 2013]
distdate[id %in% c("39", "38", "40", "41", "151", "132", "155", "154", "42", "153", "135", "134", "133", "132", "151", "144", "143", "137", "140", "146", "147", "148"), Dist_year := 2013]
distdate[id %in% c("8", "4", "5", "16", "17", "21", "20"), Dist_year := 2013]
distdate[id %in% c("67", "68", "70", "66", "69"), Dist_year := 2013]
distdate[id %in% "58", Dist_year := 2012]
distdate[id %in% c("47", "45", "44", "43"), Dist_year := 2012]

invpoly[,Dist_year := NULL]
distdate1 <- distdate[,.(id, Dist_year)]
invpoly<-merge(invpoly, distdate1, by = "id", all.x=TRUE)

write.csv(invpoly, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Erafor_poly_cleaned_addistdate.csv", row.names = FALSE)
