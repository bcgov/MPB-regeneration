
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
id[8] <- "541U_3PT"
id[!id %in% "1908U_3PTQC"]

newover <- over[Call_Num %in% id]

under[`PLOT.#` %in% "4210U_3PT", `PLOT.#` := "4210U_R3"]
under[`PLOT.#` %in% "4209U_3PT", `PLOT.#` := "4209U_R3"]
under[`PLOT.#` %in% "4212_U3PT", `PLOT.#` := "4212U_3PT"]
under[`PLOT.#` %in% "540U_3PT", `PLOT.#` := "541U_3PT"]
newunder <- under[!`PLOT.#` %in% "1908U_3PTQC"]


write.csv(newover, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory.csv", row.names = FALSE)
write.csv(newunder, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory.csv", row.names = FALSE)
