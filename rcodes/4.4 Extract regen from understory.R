rm(list = ls())
library(data.table)

under <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory_cleaned_SI_Cl1Updated.csv"))
vri <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory_VRI2019_AddDistDate.csv"))
dist <- vri[,.(Plot, Dist_year,Survey_Date)]

newunder <- merge(under, dist, by = "Plot")
newunder[,interval := Survey_Date-Dist_year]
newunder[,max := interval+5]

regen <- newunder[Age < max]

####3 points plot
####calculate avearge count, DBH, age, ht for each plot

regen[FHQ %in% "H", Count := Count*2]
regen[FHQ %in% "Q", Count := Count*4]
regen[,FHQ := NULL]

regen1 <- regen[,.(Count = round(sum(Count, na.rm = TRUE)/3, digits = 2),
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
regen1[DBH %in% NaN, DBH := NA]

write.csv(regen1, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory_cleaned_SI_Cl1Updated_regen.csv", row.names = FALSE)
