library(sp)
library(rgdal)
library(data.table)

pointdata <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Eraforcompile_InvTable.csv"))

pointdata <- pointdata[!is.na(Lat)]

pointmap <- SpatialPointsDataFrame(pointdata[,.(Long, Lat)],
                                   data = pointdata,
                                   proj4string = CRS("+proj=longlat"))


pointmap_convert <- spTransform(pointmap,
                                "+proj=aea +lat_1=50
                                 +lat_2=58.5 +lat_0=45
                                 +lon_0=-126 +x_0=1000000
                                 +y_0=0 +ellps=GRS80
                                 +towgs84=0,0,0,0,0,0,0
                                 +units=m +no_defs")

bcalbers <- data.frame(pointmap_convert@coords)
setnames(pointdata,"Lat","GPSlat")
setnames(pointdata,"Long","GPSlong")
Yourdata <- cbind(pointdata, bcalbers)

write.csv(Yourdata, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/From Erafor/Eraforcompile_InvTable_bcalbers.csv", row.names = FALSE)
