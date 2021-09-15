###Estimate Age and Ht for Class 1
###Step 2 Pair SI to Class 1
###Use estimated Class 2 or Class 3's SI
###If no estimates Class 2 or Class 3 SI, use lookup tables

rm(list=ls())
library(data.table)
library(SIndexR)

under <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory_cleaned_SI.csv"))

##Pair class 1 with the Class2 or Class3's SI of the same species in the same plot

cl1 <- under[Class %in% 1]

yesi <- NULL
nosi <- NULL
for (i in 1:dim(cl1)[1]){
  tmp <- cl1[i]
  plt <- tmp$Plot
  pot <- tmp$Point
  allclass <- under[Plot %in% plt & Point %in% pot]
  sp <- tmp$SP
  if(is.element(2, allclass$Class)| is.element(3, allclass$Class)){
    if(is.element(sp, allclass[Class %in% c(2,3), SP])){
      class <- min(allclass[Class %in% c(2,3) & SP %in% sp, Class])
      si <- allclass[Class %in% class & SP %in% sp, SI]
      #under[Plot %in% plt & Point %in% pot & Class %in% 1 & SP %in% sp, SI := si]
      tmp[,SI := si]
      yesi <- rbind(yesi,tmp)
    }else{
      nosi <- rbind(nosi, tmp)
    }
  }else{
    nosi <- rbind(nosi,tmp)
  }
}

###Find SI for class 1 that doesnt have a pair Class2 or Class3 (remove the ones that have measured age)
###use look up tables

allsi <- under[!SI %in% NA]
lookup <- allsi[,.(SI = round(mean(SI), digits = 2)), by = .(SP, BEC, OVER_CC)]
setorder(lookup, SP, BEC, OVER_CC)

nosi_no <- nosi[Age %in% NA]
for (i in 1:dim(nosi_no)[1]){
  tmp <- nosi_no[i]
  sp <- tmp$SP
  bec <- tmp$BEC
  cc <- tmp$OVER_CC
  if(nrow(lookup[SP %in% sp & BEC %in% bec & OVER_CC %in% cc]) == 1){
    si <- lookup[SP %in% sp & BEC %in% bec & OVER_CC %in% cc, SI]
  }else{
    si <- NA
  }
  nosi_no[i]$SI <- si
}

###Some still cannt find SI

nosi_nono <- nosi_no[SI %in% NA]
#         Plot Point Class SP FHQ Count DBH Age Ht OVER_CC  BEC subBEC vaBEC SI
# 1: 1909U_3PT     1     1 SE   F     2  NA  NA NA      30   MS     xv    NA NA
# 2:  4209U_R3     1     1 FD   F     1  NA  NA NA      20   PP     xh     2 NA
# 3:  4209U_R3     1     1 PY   F     1  NA  NA NA      20   PP     xh     2 NA
# 4:  4209U_R3     2     1 PY   F     1  NA  NA NA      20   PP     xh     2 NA
# 5:  4209U_R3     3     1 PY   F     1  NA  NA NA      20   PP     xh     2 NA
# 6: 8012U_3PT     3     1 PW   F     4  NA  NA NA      50  IDF     dc    NA NA
# 7: 8903U_3PT     2     1 BL   Q   118  NA  NA NA      10 ESSF     dv     2 NA

##1909U_3PT Point1 SE MS 30
###Convert PL MS 30 to SE

plsi <- lookup[SP %in% "PL" & BEC %in% "MS" & OVER_CC %in% 30, SI]
sesi <- -2.14+1.09*plsi

nosi_nono[1]$SI <- round(sesi, digits = 2)

##4209U_R3 Point1 FD PP 20

lookup[BEC %in% "PP" & OVER_CC %in% 20]
#Empty data.table (0 rows and 4 cols): SP,BEC,OVER_CC,SI
##Use FD SI in PP 30 for this stem

si <- lookup[SP %in% "FD" & BEC %in% "PP" & OVER_CC %in% 30, SI]
nosi_nono[2]$SI <- si

##4209U_R3 PY PP 20

si <- lookup[SP %in% "PY", SI]
nosi_nono[3:5]$SI <- si

##8012U_3PT Point3 PW IDF 50

lookup[BEC %in% "IDF" & OVER_CC %in% 50]
#    SP BEC OVER_CC   SI
# 1: BL IDF      50 7.50
# 2: FD IDF      50 5.09

##Use FD to PL conversion equation
fdsi <- lookup[SP %in% "FD" & BEC %in% "IDF" & OVER_CC %in% 50, SI]
pwsi <- -0.758 + 1.07*fdsi

nosi_nono[6]$SI <- round(pwsi, digits = 2)

##8903U_3PT Point2 BL

lookup[BEC %in% "ESSF" & OVER_CC %in% 10]
#Empty data.table (0 rows and 4 cols): SP,BEC,OVER_CC,SI

lookup[SP %in% "BL" & BEC %in% "ESSF"]
#    SP  BEC OVER_CC    SI
# 1: BL ESSF      15  3.78
# 2: BL ESSF      25 14.81
# 3: BL ESSF      30  2.36
# 4: BL ESSF      35  3.40
# 5: BL ESSF      45 15.82
##Use OVER_CC 15 SI

nosi_nono[7]$SI <- 3.78
nosi_no <- nosi_no[!SI %in% NA]
nosi_no <- rbind(nosi_no, nosi_nono)
nosi <- nosi[!Age %in% NA]
nosi <- rbind(nosi, nosi_no)

##update cl1 by combining updated yesi and nosi

newcl1 <- rbind(yesi, nosi)

