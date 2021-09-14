rm(list=ls())
library(data.table)

###itsl Species whithout age & ht?

itsll <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer_VRI0319_cleaned.csv"))
itslp <- data.table(read.csv("//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_poly_VRI0319_addistdate.csv"))

itslunder <- itsll[Layer %in% 3 | Layer %in% 4]
distdate <- unique(itslp[,.(id, Dist_year, Survey_Date)])
itslunder1 <- merge(itslunder, distdate, by = "id", all.x = TRUE)
itslunder1[,interval := Survey_Date - Dist_year]
itslunder1[,max := interval + 5]

itslunder1[Age < max]
itslunder1[Age %in% NA]

####Species without age & ht?
####choose itsl under in layer 4

i4na <- itslunder1[Layer %in% 4 & Age %in% NA]

#itslunder1[id %in% 21]

yesi <- NULL
nosi <- NULL
for (i in 1:dim(i4na)[1]){
  tmp <- i4na[i]
  tmpid <- tmp$id
  allclass <- itslunder1[id %in% tmpid]
  sp <- tmp$SP
  if(is.element(3, allclass$Layer)){
    if(is.element(sp, allclass[Layer %in% 3, SP])){
      tmp2 <- allclass[Layer %in% 3 & SP %in% sp]
      if(!is.na(tmp2$Age)){
        tmp3 <- allclass[SP %in% sp]
        yesi <- rbind(yesi,tmp3)
      }else{
        nosi <- rbind(nosi, tmp)
      }
    }else{
      nosi <- rbind(nosi, tmp)
    }
  }else{
    nosi <- rbind(nosi,tmp)
  }
}


unique(yesi$SP)
[1] "PL" "FD" "SX" "BL"

##PL

pl <- yesi[SP %in% "PL"]
pl2 <- NULL
for (i in unique(pl$id)){
  tmp <- pl[id %in% i]

  #SI

  l3 <- tmp[Layer %in% 3]
  A <- l3$Age
  H <- l3$Ht
  bec <- unique(tmp$BEC)
  if (bec == "IDF"){
    IDF <- 1
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "SBPS"){
    IDF <- 0
    SBPS <- 1
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "SBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 1
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "BWBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 1
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "MS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 1
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "ICH"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 1
    ESSF <- 0
  }
  if (bec == "ESSF"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 1
  }
  if (bec == "CWH"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 1
    ESSF <- 0
  }
  f_SI <- function(SI){
    (0.001424 - 0.0009260 * (IDF + SBPS) + 0.0008032 * SBS) * SI * A^(1.801 + 0.07098 * (BWBS + MS) + 0.3509 * (ICH + SBPS) + (0.01820 - 0.003024 * ESSF - 0.01257 * ICH + 0.01581 * IDF) * SI) * (0.9537 - 0.01083 * (BWBS + ICH + MS) - 0.02025 * SBS)^A - H
  }

  si <- round(uniroot(f_SI, c(0, 25))$root, digits = 2)
  tmp[,SI := si]

  #1.3m Age

  SI <- si
  H <- 1.3
  rm(A)
  f_A <- function(A){
    (0.001424 - 0.0009260 * (IDF + SBPS) + 0.0008032 * SBS) * SI * A^(1.801 + 0.07098 * (BWBS + MS) + 0.3509 * (ICH + SBPS) + (0.01820 - 0.003024 * ESSF - 0.01257 * ICH + 0.01581 * IDF) * SI) * (0.9537 - 0.01083 * (BWBS + ICH + MS) - 0.02025 * SBS)^A - H
  }

  A <- round(uniroot(f_A, c(0, 50))$root, digits = 2)
  a <- A/2
  tmp[Layer %in% 4, Age := round(a, digits = 0)]

  #1.3m median Age's ht

  A <- a
  rm(H)
  f_H <- function(H){
    (0.001424 - 0.0009260 * (IDF + SBPS) + 0.0008032 * SBS) * SI * A^(1.801 + 0.07098 * (BWBS + MS) + 0.3509 * (ICH + SBPS) + (0.01820 - 0.003024 * ESSF - 0.01257 * ICH + 0.01581 * IDF) * SI) * (0.9537 - 0.01083 * (BWBS + ICH + MS) - 0.02025 * SBS)^A - H
  }

  H <- round(uniroot(f_H, c(0, 10))$root, digits = 2)
  tmp[Layer %in% 4, Ht := H]

  pl2 <- rbind(pl2, tmp)
}

yesi <- yesi[!SP %in% "PL"]
yesi <- rbind(yesi, pl2, fill = TRUE)

##FD

library(SIndexR)
##What is the FIZ zone

vri19 <- data.table(read.table("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_VRI2019.txt", sep = ",", header = TRUE))
fiz <- vri19[,.(id, FIZ_CD)]
yesi <- merge(yesi, fiz, by = "id", all.x = TRUE)

fd <- yesi[SP %in% "FD"]

fd2 <- NULL
for ( i in unique(fd$id)){
  tmp <- fd[id %in% i]
  A <- tmp[Layer %in% 3, Age]
  H <- tmp[Layer %in% 3, Ht]
  sicr <- SIndexR_DefCurve(SIndexR_SpecRemap("FD", "D"))
  si <- round(SIndexR_HtAgeToSI(curve = sicr, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  tmp[,SI := si]
  y <- SIndexR_Y2BH(curve = sicr, siteIndex = si)$output
  A <- round(SIndexR_HtSIToAge(curve = sicr, height = 1.3, ageType = 0, siteIndex = si, y2bh = y)$output, digits = 2)
  mA <- A/2
  mH <- round(SIndexR_AgeSIToHt(curve = sicr, age = mA, ageType = 0, siteIndex = si, y2bh = y)$output, digits = 2)
  tmp[Layer %in% 4, Age := round(mA, digits = 0)]
  tmp[Layer %in% 4, Ht := mH]

  fd2 <- rbind(fd2, tmp)
}

yesi <- yesi[!SP %in% "FD"]
yesi <- rbind(yesi, fd2)

##SX

s <- yesi[SP %in% "SX"]
s2 <- NULL
for (i in unique(s$id)){
  tmp <- s[id %in% i]

  #SI

  l3 <- tmp[Layer %in% 3]
  A <- l3$Age
  H <- l3$Ht
  bec <- unique(tmp$BEC)
  if (bec == "IDF"){
    IDF <- 1
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "SBPS"){
    IDF <- 0
    SBPS <- 1
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "SBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 1
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "BWBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 1
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "MS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 1
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "ICH"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 1
    ESSF <- 0
  }
  if (bec == "ESSF"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 1
  }
  if (bec == "CWH"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 1
    ESSF <- 0
  }
  f_SI <- function(SI){
    (0.0009952 + 0.0005208 * ICH - 0.0006785 * IDF - 0.0008774 * (MS + SBPS)) * SI * A^(0.9842 + 0.2521 * BWBS - 0.2893 * (ESSF + IDF) + 0.5893 * (ICH + MS + SBPS + SBS) + (0.02943 - 0.008403 * BWBS - 0.01388 * ICH + 0.02672 * (IDF + MS) - 0.03586 * SBS) * SI) * (1.017 + 0.03818 * (ESSF + SBS) - 0.04231 * ICH - 0.07806 * MS)^A - H
  }

  si <- round(uniroot(f_SI, c(0, 25))$root, digits = 2)
  tmp[,SI := si]

  #1.3m age

  SI <- si
  H <- 1.3
  rm(A)
  f_A <- function(A){
    (0.0009952 + 0.0005208 * ICH - 0.0006785 * IDF - 0.0008774 * (MS + SBPS)) * SI * A^(0.9842 + 0.2521 * BWBS - 0.2893 * (ESSF + IDF) + 0.5893 * (ICH + MS + SBPS + SBS) + (0.02943 - 0.008403 * BWBS - 0.01388 * ICH + 0.02672 * (IDF + MS) - 0.03586 * SBS) * SI) * (1.017 + 0.03818 * (ESSF + SBS) - 0.04231 * ICH - 0.07806 * MS)^A - H
  }

  A <- round(uniroot(f_A, c(0, 50))$root, digits = 2)
  a <- A/2
  tmp[Layer %in% 4, Age := round(a, digits = 0)]

  #1.3m median age's ht

  A <- a
  rm(H)
  f_H <- function(H){
    (0.0009952 + 0.0005208 * ICH - 0.0006785 * IDF - 0.0008774 * (MS + SBPS)) * SI * A^(0.9842 + 0.2521 * BWBS - 0.2893 * (ESSF + IDF) + 0.5893 * (ICH + MS + SBPS + SBS) + (0.02943 - 0.008403 * BWBS - 0.01388 * ICH + 0.02672 * (IDF + MS) - 0.03586 * SBS) * SI) * (1.017 + 0.03818 * (ESSF + SBS) - 0.04231 * ICH - 0.07806 * MS)^A - H
  }

  H <- round(uniroot(f_H, c(0, 10))$root, digits = 2)
  tmp[Layer %in% 4, Ht := H]

  s2 <- rbind(s2, tmp)
}

yesi <- yesi[!SP %in% "SX"]
yesi <- rbind(yesi, s2)

##BL

b <- yesi[SP %in% "BL"]
A <- b[Layer %in% 3, Age]
H <- b[Layer %in% 3, Ht]
sicr <- SIndexR_DefCurve(SIndexR_SpecRemap("BL", "D"))
si <- round(SIndexR_HtAgeToSI(curve = sicr, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
b[,SI := si]
y <- SIndexR_Y2BH(curve = sicr, siteIndex = si)$output
A <- round(SIndexR_HtSIToAge(curve = sicr, height = 1.3, ageType = 0, siteIndex = si, y2bh = y)$output, digits = 2)
mA <- A/2
mH <- round(SIndexR_AgeSIToHt(curve = sicr, age = mA, ageType = 0, siteIndex = si, y2bh = y)$output, digits = 2)
b[Layer %in% 4, Age := round(mA, digits = 0)]
b[Layer %in% 4, Ht := mH]

yesi <- yesi[!SP %in% "BL"]
yesi <- rbind(yesi,b)

itslunder2 <- itslunder1
for (i in 1:dim(yesi)[1]){
  tmp <- yesi[i]
  tmpid <- tmp$id
  tmplayer <- tmp$Layer
  tmpsp <- tmp$SP
  itslunder2 <- itslunder2[!c(id%in%tmpid & Layer%in%tmplayer & SP%in%tmpsp)]
  itslunder2 <- rbind(itslunder2,tmp, fill = TRUE)
}

##nosi?
##use lookup tables
##Calculate SI for ALL SP under Layer 3

l3 <- itslunder1[Layer %in% 3 & !Age %in% NA & !Ht %in% NA]
cc <- unique(vri19[,.(id, CROWN_CLOSURE, FIZ_CD)])
l3 <- merge(l3, cc, by = "id")

nosi <- merge(nosi, cc, by = "id")
a <- unique(nosi[,.(SP), by = .(BEC, CROWN_CLOSURE)])
setorder(a, BEC, CROWN_CLOSURE)

b <- unique(l3[,.(SP), by = .(BEC, CROWN_CLOSURE)])
setorder(b, BEC, CROWN_CLOSURE)
b[BEC %in% "IDF"]

l3si <- l3[,.(SP, Age, Ht, BEC, CROWN_CLOSURE,FIZ_CD)]

for (i in 1:dim(l3si)[1]){
  tmp <- l3si[i]
  sp <- tmp$SP
  A <- tmp$Age
  H <- tmp$Ht
  bec <- tmp$BEC
  fiz <- tmp$FIZ_CD
  if (bec == "IDF"){
    IDF <- 1
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "SBPS"){
    IDF <- 0
    SBPS <- 1
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "SBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 1
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "BWBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 1
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "MS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 1
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "ICH"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 1
    ESSF <- 0
  }
  if (bec == "ESSF"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 1
  }
  if (bec == "CWH"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 1
    ESSF <- 0
  }
  if(sp == "PL" | sp == "PA"){
    f_SI <- function(SI){
      (0.001424 - 0.0009260 * (IDF + SBPS) + 0.0008032 * SBS) * SI * A^(1.801 + 0.07098 * (BWBS + MS) + 0.3509 * (ICH + SBPS) + (0.01820 - 0.003024 * ESSF - 0.01257 * ICH + 0.01581 * IDF) * SI) * (0.9537 - 0.01083 * (BWBS + ICH + MS) - 0.02025 * SBS)^A - H
    }

    si <- round(uniroot(f_SI, c(0, 50))$root, digits = 2)
  }
  if(sp == "SX" | sp == "SE"){
    f_SI <- function(SI){
      (0.0009952 + 0.0005208 * ICH - 0.0006785 * IDF - 0.0008774 * (MS + SBPS)) * SI * A^(0.9842 + 0.2521 * BWBS - 0.2893 * (ESSF + IDF) + 0.5893 * (ICH + MS + SBPS + SBS) + (0.02943 - 0.008403 * BWBS - 0.01388 * ICH + 0.02672 * (IDF + MS) - 0.03586 * SBS) * SI) * (1.017 + 0.03818 * (ESSF + SBS) - 0.04231 * ICH - 0.07806 * MS)^A - H
    }

    si <- round(uniroot(f_SI, c(0, 50))$root, digits = 2)
  }
  if(sp == "FD"){
    sicrv <- SIndexR_DefCurve(SIndexR_SpecRemap("FD", fiz))
    si <- round(SIndexR_HtAgeToSI(curve = sicrv, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  if(sp == "BL"){
    sicrv <- SIndexR_DefCurve(SIndexR_SpecRemap("BL", fiz))
    si <- round(SIndexR_HtAgeToSI(curve = sicrv, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  if(sp == "AT"){
    sicrv <- SIndexR_DefCurve(SIndexR_SpecRemap("AT", fiz))
    si <- round(SIndexR_HtAgeToSI(curve = sicrv, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  if(sp == "EP"){
    sicrv <- SIndexR_DefCurve(SIndexR_SpecRemap("EP", fiz))
    si <- round(SIndexR_HtAgeToSI(curve = sicrv, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  if(sp == "CW"){
    sicrv <- SIndexR_DefCurve(SIndexR_SpecRemap("CW", fiz))
    si <- round(SIndexR_HtAgeToSI(curve = sicrv, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  if(sp == "HW"){
    sicrv <- SIndexR_DefCurve(SIndexR_SpecRemap("HW", fiz))
    si <- round(SIndexR_HtAgeToSI(curve = sicrv, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  l3si[i,SI := si]
}

lookup <- l3si[,.(aveSI = round(mean(SI), digits = 2)), by = .(SP, BEC, CROWN_CLOSURE)]
setorder(lookup, BEC, CROWN_CLOSURE, SP)
lookup[BEC %in% "IDF"]

##SET NA to -9
lookup[CROWN_CLOSURE %in% NA, CROWN_CLOSURE :=-9]
nosi[CROWN_CLOSURE %in% NA, CROWN_CLOSURE := -9]

##Find SI for nosi

for(i in 1:dim(nosi)[1]){
  tmp <- nosi[i]
  bec <- tmp$BEC
  cc <- tmp$CROWN_CLOSURE
  sp <- tmp$SP
  si <- lookup[BEC %in% bec & CROWN_CLOSURE %in% cc & SP %in% sp, aveSI]
  if(length(si) > 0){
    nosi[i, SI := si]
  }
}


##some still cannot find SI
##Use SP conversion

nosino <- nosi[SI %in% NA]

##SX

nosino[SP %in% "SX"]
##id21 SX MS 52

lookup[BEC %in% "MS" & CROWN_CLOSURE %in% 52]
##Use PL to SW equation

nosino[id %in% 21 & SP %in% "SX", SI := round(-2.14+1.09*20.84, digits = 2)]

##AT
##NO conversion equation for AT
##Use the CLOSEST CC from the same BECzone

unique(nosino[SP %in% "AT",.(BEC, CROWN_CLOSURE)])
#     BEC CROWN_CLOSURE
# 1:  IDF            50
# 2: SBPS            45
# 3:   MS            11
# 4:  SBS            40
# 5: SBPS            23

lookup[SP %in% "AT"]

#     BEC CROWN_CLOSURE
# 1:  IDF            50  ---45 --10.93
# 2: SBPS            45  ---50 --18
# 3:   MS            11  ---20 --24.22
# 4:  SBS            40  ---50 --21.92
# 5: SBPS            23  ---25 --5

nosino[SP %in% "AT"]

nosino[SP %in% "AT" & BEC %in% "IDF" & CROWN_CLOSURE %in% 50, SI := 10.93]
nosino[SP %in% "AT" & BEC %in% "SBPS" & CROWN_CLOSURE %in% 45, SI := 18]
nosino[SP %in% "AT" & BEC %in% "MS" & CROWN_CLOSURE %in% 11, SI := 24.22]
nosino[SP %in% "AT" & BEC %in% "SBS" & CROWN_CLOSURE %in% 40, SI := 21.92]
nosino[SP %in% "AT" & BEC %in% "SBPS" & CROWN_CLOSURE %in% 23, SI := 5]

##One strange SI noticed

l3[SP %in% "AT" & BEC %in% "MS" & CROWN_CLOSURE %in% 2]
#     id Layer SP PCT Age Ht Inventory_Standard BEC subBEC vaBEC BEC_sub_va Dist_year
# 1: 448     3 AT  10   3  6               ITSL  MS     xk    NA       MSxk      2011
#    Survey_Date interval max CROWN_CLOSURE FIZ_CD
# 1:        2014        3   8             2      D


##reverse age and height for this stem

itslunder2[id %in% 448 & SP %in% "AT", Age := 6]
itslunder2[id %in% 448 & SP %in% "AT", Ht := 3]

##BL

lookup[BEC %in% "MS" & CROWN_CLOSURE %in% 30]
lookup[BEC %in% "IDF" & CROWN_CLOSURE %in% c(10,11,25)]
##Use PL to BL equation

nosino[id %in% 242 & SP %in% "BL", SI := round(0.474+0.917*14.67, digits = 2)]
nosino[id %in% 247 & SP %in% "BL", SI := round(0.474+0.917*17.06, digits = 2)]
nosino[id %in% 248 & SP %in% "BL", SI := round(0.474+0.917*16.65, digits = 2)]
nosino[id %in% 307 & SP %in% "BL", SI := round(0.474+0.917*15.66, digits = 2)]

##PL

lookup[BEC %in% "SBS" & CROWN_CLOSURE %in% 30]
##Use FD to PL equation

nosino[id %in% 590 & SP %in% "PL", SI := round(-0.758+1.07*12.01, digits = 2)]

nosi <- nosi[!SI %in% NA]
nosi <- rbind(nosi, nosino)

##Calculate age and ht for nosi

for (i in 1:dim(nosi)[1]){
  tmp <- nosi[i]
  sp <- tmp$SP
  SI <- tmp$SI
  H <- 1.3
  bec <- tmp$BEC
  fizcd <- tmp$FIZ_CD
  if (bec == "IDF"){
    IDF <- 1
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "SBPS"){
    IDF <- 0
    SBPS <- 1
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "SBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 1
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "BWBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 1
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "MS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 1
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "ICH"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 1
    ESSF <- 0
  }
  if (bec == "ESSF"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 1
  }
  if (bec == "CWH"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 1
    ESSF <- 0
  }
  if(sp == "PL" | sp == "PA"){
    f_A <- function(A){
      (0.001424 - 0.0009260 * (IDF + SBPS) + 0.0008032 * SBS) * SI * A^(1.801 + 0.07098 * (BWBS + MS) + 0.3509 * (ICH + SBPS) + (0.01820 - 0.003024 * ESSF - 0.01257 * ICH + 0.01581 * IDF) * SI) * (0.9537 - 0.01083 * (BWBS + ICH + MS) - 0.02025 * SBS)^A - H
    }
    a <- uniroot(f_A, c(0, 50))$root
  }
  if(sp == "SX"){
    f_A <- function(A){
      (0.0009952 + 0.0005208 * ICH - 0.0006785 * IDF - 0.0008774 * (MS + SBPS)) * SI * A^(0.9842 + 0.2521 * BWBS - 0.2893 * (ESSF + IDF) + 0.5893 * (ICH + MS + SBPS + SBS) + (0.02943 - 0.008403 * BWBS - 0.01388 * ICH + 0.02672 * (IDF + MS) - 0.03586 * SBS) * SI) * (1.017 + 0.03818 * (ESSF + SBS) - 0.04231 * ICH - 0.07806 * MS)^A - H
    }
    a <- uniroot(f_A, c(0, 50))$root
  }
  if(sp == "BL"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("BL", fizcd))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    a <- SIndexR_HtSIToAge(curve = sicurve, height = H, ageType = 0, siteIndex = SI, y2bh = y)$output
  }
  if(sp == "FD"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("FD", fizcd))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    a <- SIndexR_HtSIToAge(curve = sicurve, height = H, ageType = 0, siteIndex = SI, y2bh = y)$output
  }
  if(sp == "AT"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("AT", fizcd))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    a <- SIndexR_HtSIToAge(curve = sicurve, height = H, ageType = 0, siteIndex = SI, y2bh = y)$output
  }
  if(sp == "EP"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("EP", fizcd))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    a <- SIndexR_HtSIToAge(curve = sicurve, height = H, ageType = 0, siteIndex = SI, y2bh = y)$output
  }
  nosi[i]$Age <- round(a/2, digits = 0)
  A <- a/2
  H <- NULL
  if(sp == "PL" | sp == "PA"){
    f_H <- function(H){
      (0.001424 - 0.0009260 * (IDF + SBPS) + 0.0008032 * SBS) * SI * A^(1.801 + 0.07098 * (BWBS + MS) + 0.3509 * (ICH + SBPS) + (0.01820 - 0.003024 * ESSF - 0.01257 * ICH + 0.01581 * IDF) * SI) * (0.9537 - 0.01083 * (BWBS + ICH + MS) - 0.02025 * SBS)^A - H
    }
    H <- uniroot(f_H, c(0, 20))$root
  }
  if(sp == "SX"){
    f_H <- function(H){
      (0.0009952 + 0.0005208 * ICH - 0.0006785 * IDF - 0.0008774 * (MS + SBPS)) * SI * A^(0.9842 + 0.2521 * BWBS - 0.2893 * (ESSF + IDF) + 0.5893 * (ICH + MS + SBPS + SBS) + (0.02943 - 0.008403 * BWBS - 0.01388 * ICH + 0.02672 * (IDF + MS) - 0.03586 * SBS) * SI) * (1.017 + 0.03818 * (ESSF + SBS) - 0.04231 * ICH - 0.07806 * MS)^A - H
    }
    H <- uniroot(f_H, c(0, 20))$root
  }
  if(sp == "BL"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("BL", fizcd))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    H <- SIndexR_AgeSIToHt(curve = sicurve, age = A, ageType = 0, siteIndex = SI, y2bh = y)$output
  }

  if(sp == "FD"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("FD", fizcd))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    H <- SIndexR_AgeSIToHt(curve = sicurve, age = A, ageType = 0, siteIndex = SI, y2bh = y)$output
  }
  if(sp == "AT"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("AT", fizcd))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    H <- SIndexR_AgeSIToHt(curve = sicurve, age = A, ageType = 0, siteIndex = SI, y2bh = y)$output
  }
  if(sp == "EP"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("EP", fizcd))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    H <- SIndexR_AgeSIToHt(curve = sicurve, age = A, ageType = 0, siteIndex = SI, y2bh = y)$output
  }
  nosi[i]$Ht <- round(H, digits = 2)
}

itslunder3 <- itslunder2
for (i in 1:dim(nosi)[1]){
  tmp <- nosi[i]
  tmpid <- tmp$id
  tmplayer <- tmp$Layer
  tmpsp <- tmp$SP
  itslunder3 <- itslunder3[!c(id%in%tmpid & Layer%in%tmplayer & SP%in%tmpsp)]
  itslunder3 <- rbind(itslunder3,tmp, fill = TRUE)
}

itslunder3[Layer %in% 4 & Age %in% NA]

itslregen <- itslunder3[Age <= max]


itslregen[PCT %in% 0]
itslregen <- itslregen[!PCT %in% 0]

unique(itslregen$Age)
#[1] 12 14  5  9  3  7 11 10  4 13  8 15  6 18 17  2  1 16  0

itslregen[Age %in% 0]
##Get SI then calculate Age and height like above

itslunder3[id %in% 712]
#for PL use the si from layer3
#PL

A <- itslunder3[id %in% 712 & Layer %in% 3 & SP %in% "PL", Age]
H <- itslunder3[id %in% 712 & Layer %in% 3 & SP %in% "PL", Ht]
f_SI <- function(SI){
  (0.001424 - 0.0009260 * (IDF + SBPS) + 0.0008032 * SBS) * SI * A^(1.801 + 0.07098 * (BWBS + MS) + 0.3509 * (ICH + SBPS) + (0.01820 - 0.003024 * ESSF - 0.01257 * ICH + 0.01581 * IDF) * SI) * (0.9537 - 0.01083 * (BWBS + ICH + MS) - 0.02025 * SBS)^A - H
}
plsi <- round(uniroot(f_SI, c(0, 50))$root, digits = 2)
itslregen[id %in% 712 & SP %in% "PL", SI := plsi]
SI <- plsi
H <- 1.3
f_A <- function(A){
  (0.001424 - 0.0009260 * (IDF + SBPS) + 0.0008032 * SBS) * SI * A^(1.801 + 0.07098 * (BWBS + MS) + 0.3509 * (ICH + SBPS) + (0.01820 - 0.003024 * ESSF - 0.01257 * ICH + 0.01581 * IDF) * SI) * (0.9537 - 0.01083 * (BWBS + ICH + MS) - 0.02025 * SBS)^A - H
}
a <- uniroot(f_A, c(0, 50))$root
itslregen[id %in% 712 & SP %in% "PL", Age := round(a/2, digits = 0)]
A <- a/2
f_H <- function(H){
  (0.001424 - 0.0009260 * (IDF + SBPS) + 0.0008032 * SBS) * SI * A^(1.801 + 0.07098 * (BWBS + MS) + 0.3509 * (ICH + SBPS) + (0.01820 - 0.003024 * ESSF - 0.01257 * ICH + 0.01581 * IDF) * SI) * (0.9537 - 0.01083 * (BWBS + ICH + MS) - 0.02025 * SBS)^A - H
}
H <- round(uniroot(f_H, c(0, 20))$root, digits = 2)
itslregen[id %in% 712 & SP %in% "PL", Ht := H]

#for SX use lookup

lookup[BEC %in% "IDF" & CROWN_CLOSURE %in% 11]
si <- lookup[BEC %in% "IDF" & CROWN_CLOSURE %in% 11 & SP %in% "SX", aveSI]
itslregen[id %in% 712 & SP %in% "SX", SI := si]
SI <- si
H <- 1.3
f_A <- function(A){
  (0.0009952 + 0.0005208 * ICH - 0.0006785 * IDF - 0.0008774 * (MS + SBPS)) * SI * A^(0.9842 + 0.2521 * BWBS - 0.2893 * (ESSF + IDF) + 0.5893 * (ICH + MS + SBPS + SBS) + (0.02943 - 0.008403 * BWBS - 0.01388 * ICH + 0.02672 * (IDF + MS) - 0.03586 * SBS) * SI) * (1.017 + 0.03818 * (ESSF + SBS) - 0.04231 * ICH - 0.07806 * MS)^A - H
}
a <- uniroot(f_A, c(0, 50))$root
itslregen[id %in% 712 & SP %in% "SX", Age := round(a/2, digits = 0)]
A <- a/2
f_H <- function(H){
  (0.0009952 + 0.0005208 * ICH - 0.0006785 * IDF - 0.0008774 * (MS + SBPS)) * SI * A^(0.9842 + 0.2521 * BWBS - 0.2893 * (ESSF + IDF) + 0.5893 * (ICH + MS + SBPS + SBS) + (0.02943 - 0.008403 * BWBS - 0.01388 * ICH + 0.02672 * (IDF + MS) - 0.03586 * SBS) * SI) * (1.017 + 0.03818 * (ESSF + SBS) - 0.04231 * ICH - 0.07806 * MS)^A - H
}
H <- round(uniroot(f_H, c(0, 50))$root, digits = 2)
itslregen[id %in% 712 & SP %in% "SX", Ht := H]

unique(itslregen$Ht)
# [1] 1.00 2.30 0.80 2.70 0.90 1.20 1.10 0.70 2.00 0.60 0.30 3.00 1.80 0.36 2.50 0.33 0.39 4.00 0.50
# [20] 1.50 0.41 0.27 0.40 0.32 0.28 1.40 1.30 0.26 0.34 0.46 0.29 1.70 0.31 2.40 0.38 0.25 0.42   NA
# [39] 0.10 0.35 1.60 0.44 0.24 2.20 1.90 2.80 2.10 2.60 2.90 8.40 0.20 0.15

itslregen[Ht %in% NA]
itslunder3[id %in% 475]
##layer 4 SX has age and ht
##same age
##Use height from layer 4

itslregen[Ht %in% NA, Ht := 1]

##Calculate site index for stems dont have site index

cc <- unique(vri19[,.(id, CROWN_CLOSURE, FIZ_CD)])
itslregen[,c("FIZ_CD", "CROWN_CLOSURE") := NULL]
itslregen <- merge(itslregen, cc, by = "id", all.x = TRUE)
nosi <- itslregen[SI %in% NA]

for (i in 1:dim(nosi)[1]){
  tmp <- nosi[i]
  sp <- tmp$SP
  A <- tmp$Age
  H <- tmp$Ht
  bec <- tmp$BEC
  fiz <- tmp$FIZ_CD
  if (bec == "IDF"){
    IDF <- 1
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "SBPS"){
    IDF <- 0
    SBPS <- 1
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "SBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 1
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "BWBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 1
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "MS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 1
    ICH <- 0
    ESSF <- 0
  }
  if (bec == "ICH"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 1
    ESSF <- 0
  }
  if (bec == "ESSF"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 1
  }
  if (bec == "CWH"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 1
    ESSF <- 0
  }
  if(sp == "PL" | sp == "PA"){
    f_SI <- function(SI){
      (0.001424 - 0.0009260 * (IDF + SBPS) + 0.0008032 * SBS) * SI * A^(1.801 + 0.07098 * (BWBS + MS) + 0.3509 * (ICH + SBPS) + (0.01820 - 0.003024 * ESSF - 0.01257 * ICH + 0.01581 * IDF) * SI) * (0.9537 - 0.01083 * (BWBS + ICH + MS) - 0.02025 * SBS)^A - H
    }

    si <- round(uniroot(f_SI, c(0, 50))$root, digits = 2)
  }
  if(sp == "SX" | sp == "SE"){
    f_SI <- function(SI){
      (0.0009952 + 0.0005208 * ICH - 0.0006785 * IDF - 0.0008774 * (MS + SBPS)) * SI * A^(0.9842 + 0.2521 * BWBS - 0.2893 * (ESSF + IDF) + 0.5893 * (ICH + MS + SBPS + SBS) + (0.02943 - 0.008403 * BWBS - 0.01388 * ICH + 0.02672 * (IDF + MS) - 0.03586 * SBS) * SI) * (1.017 + 0.03818 * (ESSF + SBS) - 0.04231 * ICH - 0.07806 * MS)^A - H
    }

    si <- round(uniroot(f_SI, c(0, 50))$root, digits = 2)
  }
  if(sp == "FD"){
    sicrv <- SIndexR_DefCurve(SIndexR_SpecRemap("FD", fiz))
    si <- round(SIndexR_HtAgeToSI(curve = sicrv, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  if(sp == "BL"){
    sicrv <- SIndexR_DefCurve(SIndexR_SpecRemap("BL", fiz))
    si <- round(SIndexR_HtAgeToSI(curve = sicrv, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  if(sp == "AT"){
    sicrv <- SIndexR_DefCurve(SIndexR_SpecRemap("AT", fiz))
    si <- round(SIndexR_HtAgeToSI(curve = sicrv, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  if(sp == "EP"){
    sicrv <- SIndexR_DefCurve(SIndexR_SpecRemap("EP", fiz))
    si <- round(SIndexR_HtAgeToSI(curve = sicrv, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  if(sp == "CW"){
    sicrv <- SIndexR_DefCurve(SIndexR_SpecRemap("CW", fiz))
    si <- round(SIndexR_HtAgeToSI(curve = sicrv, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  if(sp == "HW"){
    sicrv <- SIndexR_DefCurve(SIndexR_SpecRemap("HW", fiz))
    si <- round(SIndexR_HtAgeToSI(curve = sicrv, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  nosi[i,SI := si]
}

##ERROR
#     id Layer SP PCT Age Ht Inventory_Standard BEC subBEC vaBEC BEC_sub_va Dist_year Survey_Date
# 1: 126     4 SX  22  10  3               ITSL SBS     dw     1     SBSdw1      2011        2016
#    interval max SI CROWN_CLOSURE FIZ_CD
# 1:        5  10 NA            50      G
##Cant find root
##skip this

error1 <- nosi[c(id %in% 126 & SP %in% "SX")]
nosi <- nosi[!c(id %in% 126 & SP %in% "SX")]
##rerun above code

##ERROR
#     id Layer SP  PCT Age Ht Inventory_Standard BEC subBEC vaBEC BEC_sub_va Dist_year Survey_Date
# 1: 475     3 SX 10.0   7  1               ITSL SBS     dw     1     SBSdw1      2011        2013
# 2: 475     4 SX 22.5   7  1               ITSL SBS     dw     1     SBSdw1      2011        2013
#    interval max SI CROWN_CLOSURE FIZ_CD
# 1:        2   7 NA            NA      D
# 2:        2   7 NA            NA      D

error2 <- nosi[c(id %in% 475 & SP %in% "SX")]
nosi <- nosi[!c(id %in% 475 & SP %in% "SX")]
##rerun above code


nosi <- rbind(nosi, error1)
nosi <- rbind(nosi, error2)

itslregen <- itslregen[!SI %in% NA]
itslregen <- rbind(itslregen, nosi)
str(itslregen)
itslregen$Layer <- as.character(itslregen$Layer)
itslregen[, Layer := "R"]

itslunder4 <- itslunder3[Age > max | Age %in% NA]
itslunder4 <- rbind(itslunder4, itslregen)

itslunder4[PCT %in% 0]
itslunder4 <- itslunder4[!PCT %in% 0]

itslover <- itsll[Layer %in% c("1", "2", "2003", "2019")]
newitsl <- rbind(itslover, itslunder4, fill = TRUE)
setorder(newitsl, id)
cc <- unique(vri19[,.(id, CROWN_CLOSURE, FIZ_CD)])
newitsl[,c("FIZ_CD", "CROWN_CLOSURE") := NULL]
newitsl <- merge(newitsl, cc, by = "id", all.x = TRUE)

write.csv(newitsl, "//orbital/s63016/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/ITSL/ITSL_layer_VRI0319_cleaned_regen.csv", row.names = FALSE)
