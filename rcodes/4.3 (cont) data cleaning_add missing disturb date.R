rm(list = ls())
library(data.table)
library(tidyr)

###Dist year from VRI2019

vri2019 <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory_VRI2019.txt"))
vri2019_poly <- unique(data.table(Plot = vri2019$Call_Num,
                                  BEC = vri2019$BEC_ZONE_CODE,
                                  subBEC = vri2019$BEC_SUBZONE,
                                  vaBEC = vri2019$BEC_VARIANT,
                                  SI2019 = vri2019$SITE_INDEX,
                                  CC2019 = vri2019$CROWN_CLOSURE,
                                  TPH2019 = vri2019$VRI_LIVE_STEMS_PER_HA,
                                  BA2019 = vri2019$BASAL_AREA_1,
                                  VOL125_2019 = vri2019$LIVE_STAND_VOLUME_125,
                                  Dist_Type = vri2019$EARLIEST_NONLOGGING_DIST_TYPE,
                                  Dist_year = vri2019$EARLIEST_NONLOGGING_DIST_DATE,
                                  Kill_PCT = vri2019$STAND_PERCENTAGE_DEAD))
vri2019_poly <- separate(data = vri2019_poly,
                         col = Dist_year,
                         into = "Dist_year",
                         sep = "-",
                         extra = "drop")
distdate <- vri2019_poly[,.(Plot, Dist_Type, Dist_year, Survey_Date = 2020)]

over <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory.csv"))
gps <- unique(over[,.(Plot = Call_Num,
                      Easting,
                      Northing)])

distdate <- merge(distdate, gps, by = "Plot", all = TRUE)
distdate[Dist_year %in% "", Note := "Missing"]
distdate[!Note %in% "Missing", Note := ""]
write.csv(distdate, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/distdate.csv")

##missing dist year updated in arcMap

newdistdate <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/distdate_updated.txt"))
newdistdate_1 <- newdistdate[,.(Plot, Dist_year, Survey_Date)]
vri2019_poly[,Dist_year := NULL]
vri2019_poly_1 <- merge(vri2019_poly, newdistdate_1, by = "Plot", all = TRUE)
write.csv(vri2019_poly_1, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory_VRI2019_AddDistDate.csv")
