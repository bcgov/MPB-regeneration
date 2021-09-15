rm(list = ls())
library(data.table)
library(tidyr)

under <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory.csv"))

under_Sp1 <- data.table(Plot = under$PLOT..,
                        Point = under$Point_Number,
                        Class = under$Understory_Class,
                        FHQ = under$X.F.ull...H.alf...Q.uarter,
                        SP = under$Spcs_1,
                        Count = under$Spcs_1_Count,
                        DBH = under$Spcs_1_Ave_DBH)
under_Sp1 <- under_Sp1[!Class %in% "O"]

under_Sp2 <- data.table(Plot = under$PLOT..,
                        Point = under$Point_Number,
                        Class = under$Understory_Class,
                        FHQ = under$X.F.ull...H.alf...Q.uarter,
                        SP = under$Spcs_2,
                        Count = under$Spcs_2_Count,
                        DBH = under$Spcs_2_Ave_DBH)
under_Sp2 <- under_Sp2[!Class %in% "O"]

under_Sp3 <- data.table(Plot = under$PLOT..,
                        Point = under$Point_Number,
                        Class = under$Understory_Class,
                        FHQ = under$X.F.ull...H.alf...Q.uarter,
                        SP = under$Spcs_3,
                        Count = under$Spcs_3_Count,
                        DBH = under$Spcs_3_Ave_DBH)
under_Sp3 <- under_Sp3[!Class %in% "O"]

under_Sp4 <- data.table(Plot = under$PLOT..,
                        Point = under$Point_Number,
                        Class = under$Understory_Class,
                        FHQ = under$X.F.ull...H.alf...Q.uarter,
                        SP = under$Spcs_4,
                        Count = under$Spcs_4_Count,
                        DBH = under$Spcs_4_Ave_DBH)
under_Sp4 <- under_Sp4[!Class %in% "O"]

under_layer <- rbind(under_Sp1, under_Sp2, under_Sp3, under_Sp4)
under_layer <- under_layer[!SP %in% NA]

lead_sp <- data.table(Plot = under$PLOT..,
                      Point = under$Point_Number,
                      Class = under$Understory_Class,
                      SP = under$Leading_Species,
                      Age = under$Leading_Total_Age,
                      Ht = under$Leading_Total_Hgt)
lead_sp <- lead_sp[!SP %in% ",,,,,"]
lead_sp <- lead_sp[!Class %in% "O"]

test <- separate(lead_sp,
                 col = "SP",
                 into = c("SP1", "SP2"),
                 sep = ",",
                 extra = "drop")

test2 <- melt(test,
              id.vars = c("Plot", "Point", "Class", "Age", "Ht"),
              measure.vars = c("SP1", "SP2"),
              value.name = "SP") %>% data.table
test2 <- test2[!SP %in% ""]
test2 <- test2[!SP%in% NA]
test2[,variable := NULL]

under_layer1 <- merge(under_layer, test2, by = c("Plot", "Point", "Class", "SP"))

over_cc <- under[Understory_Class %in% "O",.(Plot = PLOT..,
                                             Point = Point_Number,
                                             Class = "O",
                                             OVER_CC = Overstory_Crown_Closure_.)]
under_layer2 <- rbind(under_layer1, over_cc, fill=TRUE)
under_layer2 <- under_layer2[order(under_layer2$Plot)]
write.csv(under_layer2, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory_cleaned.csv", row.names = FALSE, na = "")
