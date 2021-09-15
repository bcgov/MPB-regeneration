rm(list = ls())
library(data.table)

under <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory_cleaned_SI_Cl1Updated.csv"))
vri <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory_VRI2019_AddDistDate.csv"))
dist <- vri[,.(Plot, Dist_year,Survey_Date)]

##Extract regen from understory
##Based on the criteria: regen started after MPB disturbance
##give 5 year buffer for disturbance

newunder <- merge(under, dist, by = "Plot")
newunder[,interval := Survey_Date-Dist_year]
newunder[,max := interval+5]

newunder$Class <- as.character(newunder$Class)
newunder[Age < max, Class := "R"]
newunder[Class %in% 2, Class := "U2"]
newunder[Class %in% 3, Class := "U3"]
newunder[Class %in% 1, Class := "U1"]

####3 points plot
####calculate avearge count, DBH, age, ht for each plot

newunder[FHQ %in% "H", Count := Count*2]
newunder[FHQ %in% "Q", Count := Count*4]
newunder[,FHQ := NULL]

newunder1 <- newunder[,.(Count = round(sum(Count, na.rm = TRUE)/3, digits = 2),
                         DBH = round(mean(DBH, na.rm=TRUE), digits = 2),
                         Age = round(mean(Age, na.rm = TRUE), digits = 0),
                         Ht = round(mean(Ht, na.rm = TRUE), digits = 2),
                         OVER_CC = round(mean(OVER_CC), digits = 0),
                         BEC = unique(BEC),
                         subBEC = unique(subBEC),
                         vaBEC = unique(vaBEC),
                         Dist_year = unique(Dist_year),
                         Survey_Date = unique(Survey_Date),
                         interval = unique(interval)),
                      by = .(Plot, Class, SP)]
newunder1[DBH %in% NaN, DBH := NA]

write.csv(newunder1, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory_cleaned_SI_Cl1Updated_regen.csv", row.names = FALSE)
