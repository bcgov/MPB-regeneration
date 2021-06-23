
library(openxlsx)
library(data.table)

under1 <- data.table(read.xlsx("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/raw data/Lillooet undestory/Lillooet_2020_September_UNDERSTORY.xlsx" ,
                    sheet = "Data",
                    colNames = TRUE,
                    detectDates = TRUE))


under1 <- under1[1:108]

under2 <- data.table(read.xlsx("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/raw data/Lillooet undestory/Lillooet_2020_understory_All_Files.xlsx" ,
                               sheet = "Data",
                               colNames = TRUE,
                               detectDates = TRUE))
under2 <- under2[1:324]
under <- rbind(under1, under2, fill = TRUE)

over <- data.table(read.xlsx("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/raw data/Lillooet undestory/Lillooet_Combined_Field_Plots.xlsx" ,
                             sheet = "Sheet1",
                             colNames = TRUE,
                             detectDates = TRUE))


id <- unique(under$`PLOT.#`)

over$Call_Num <- gsub("-", "_", over$Call_Num)

id[!is.element(id, unique(over$Call_Num))]
#[1] "540U_3PT"    "4210U_3PT"   "4209U_3PT"   "1908U_3PTQC" "4212_U3PT"

id[15] <-"4210U_R3"
id[16] <- "4209U_R3"
id[29] <- "4212U_3PT"

#id[8] <- "541U_3PT"
#id[17] <- "1908U_3PT

newover <- over[Call_Num %in% id]

write.csv(newover, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory.csv", row.names = FALSE)
