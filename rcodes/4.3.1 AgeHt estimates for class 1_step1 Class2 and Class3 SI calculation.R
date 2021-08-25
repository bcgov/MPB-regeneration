###Estimate Age and Ht for Class 1
###Step 1 estimate SI for Class 2 and Class 3
###Use Nigh (2004) Juvenile Height Models for Lodgepole Pine and Interior Spruce
###Other species use Sindex 1.52 / Site Tool 4.1
###If Age or Height missing, use lookup tables

rm(list=ls())
library(data.table)
library(SIndexR)

under <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory_cleaned.csv"))
cc <- under[Class %in% "O",.(Plot, Point, OVER_CC)]
under2 <- under[!Class %in% "O"]
under2[,OVER_CC := NULL]
under2 <- merge(under2, cc, by = c("Plot", "Point"), all.x = TRUE)

vri2019 <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/overstory_VRI2019_AddDistDate.csv"))
bec <- vri2019[,.(Plot, BEC, subBEC, vaBEC)]
under3 <- merge(under2, bec, by = "Plot", all.x = TRUE)

unique(under3$SP)
#[1] "PL" "BL" "SX" "PA" "SE" "FD" "PY" "HW" "BA" "PW" "JR"

#calculate class 2 or class 3 PL SI

cl23 <- under3[Class %in% 2 | Class %in% 3]
pcl23 <- cl23[SP %in% "PL"]
pcl23_1 <- pcl23[!is.na(Age)]

pcl23_2 <- NULL
for (i in 1:dim(pcl23_1)[1]){
  tmp <- pcl23_1[i]
  A <- tmp$Age
  H <- tmp$Ht
  if (tmp$BEC == "IDF"){
    IDF <- 1
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "SBPS"){
    IDF <- 0
    SBPS <- 1
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "SBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 1
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "BWBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 1
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "MS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 1
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "ICH"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 1
    ESSF <- 0
  }
  if (tmp$BEC == "ESSF"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 1
  }
  if (tmp$BEC == "CWH"){
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

  pcl23_2 <- rbind(pcl23_2, tmp)
}

pl_lookup <- pcl23_2[,.(SI = round(mean(SI), digits = 2)), by = .(BEC, OVER_CC)]
setorder(pl_lookup,BEC,OVER_CC)

napli <- cl23[Age %in% NA]
napli[,SI := 11.44]

pcl23_3 <- rbind(pcl23_2, napli)

under4 <- under3[!(Class %in% 2 & SP %in% "PL")]
under4 <- under4[!(Class %in% 3 & SP %in% "PL")]
under4 <- rbind(under4, pcl23_3, fill = TRUE)
setorder(under4, Plot, Point, Class, SP)

##Calculate Interior Spruce (SX and SE)?

under4[SP %in% c("SX", "SE")]
under4[Plot %in% "1909U_3PT"]

scl23 <- cl23[SP %in% c("SX", "SE")]
scl23_1 <- NULL
for (i in 1:dim(scl23)[1]){
  tmp <- scl23[i]
  A <- tmp$Age
  H <- tmp$Ht
  if (tmp$BEC == "IDF"){
    IDF <- 1
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "SBPS"){
    IDF <- 0
    SBPS <- 1
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "SBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 1
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "BWBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 1
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "MS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 1
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "ICH"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 1
    ESSF <- 0
  }
  if (tmp$BEC == "ESSF"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 1
  }
  if (tmp$BEC == "CWH"){
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

  si <- round(uniroot(f_SI, c(0, 50))$root, digits = 2)
  tmp[,SI := si]

  scl23_1 <- rbind(scl23_1, tmp)
}

under5 <- under4[!(Class %in% 2 & SP %in% c("SX", "SE"))]
under5 <- under5[!(Class %in% 3 & SP %in% c("SX", "SE"))]
under5 <- rbind(under5, scl23_1, fill = TRUE)
setorder(under5, Plot, Point, Class, SP)

##Calculate Class 2 and Class 3 BL SI

under5[SP %in% "BL"]

blcl23 <- cl23[SP %in% "BL"]

SIndexR_SpecMap("BL")
#16

SIndexR_SpecRemap("BL", "D")
#16

SIndexR_DefCurve(16)
#93

SIndexR_CurveName(93)
#[1] "Chen and Klinka (2000ac)"

#SIndexR_HtAgeToSI(curve = 93, age = 45, ageType = 0, height = 2.1, estType = 1)

# A <- 13
# H <- 3.4
# f_SI <- function(SI){
#   1.3+(SI-1.3)*(1+exp(9.523-1.4945*log(50)-1.2159*log(SI-1.3)))/(1+exp(9.523-1.4945*log(A)-1.2159*log(SI-1.3))) - H
# }
#
#
# uniroot(f_SI, c(1.31, 20))
# 12.59

# A <- 13
# SI <- 12.59
# H <- 1.3+(SI-1.3)*(1+exp(9.523-1.4945*log(50)-1.2159*log(SI-1.3)))/(1+exp(9.523-1.4945*log(A)-1.2159*log(SI-1.3)))

blcl23_1 <- NULL
for ( i in 1:dim(blcl23)[1]){
  tmp <- blcl23[i]
  A <- tmp$Age
  H <- tmp$Ht
  si <- round(SIndexR_HtAgeToSI(curve = 93, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  tmp[,SI := si]


  blcl23_1 <- rbind(blcl23_1, tmp)

}

under6 <- under5[!(Class %in% c(2,3) & SP %in% "BL")]
under6 <- rbind(under6, blcl23_1)
setorder(under6, Plot, Point, Class, SP)

##Calculate Class 2 and Class 3 PA SI
##Based on Site Tool 4.1, use PL's formula for PA
##Use Nigh (2004) Juvenile Height Models
##Instead of Nigh 2017 in Sindex

under6[SP %in% "PA"]
pacl23 <- cl23[SP %in% "PA"]

pacl23_1 <- NULL
for (i in 1:dim(pacl23)[1]){
  tmp <- pacl23[i]
  A <- tmp$Age
  H <- tmp$Ht
  if (tmp$BEC == "IDF"){
    IDF <- 1
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "SBPS"){
    IDF <- 0
    SBPS <- 1
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "SBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 1
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "BWBS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 1
    MS <- 0
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "MS"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 1
    ICH <- 0
    ESSF <- 0
  }
  if (tmp$BEC == "ICH"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 1
    ESSF <- 0
  }
  if (tmp$BEC == "ESSF"){
    IDF <- 0
    SBPS <- 0
    SBS <- 0
    BWBS <- 0
    MS <- 0
    ICH <- 0
    ESSF <- 1
  }
  if (tmp$BEC == "CWH"){
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

  si <- round(uniroot(f_SI, c(0, 50))$root, digits = 2)
  tmp[,SI := si]

  pacl23_1 <- rbind(pacl23_1, tmp)
}

under7 <- under6[!(Class %in% c(2,3) & SP %in% "PA")]
under7 <- rbind(under7, pacl23_1)
setorder(under7, Plot, Point, Class, SP)

##Calculate Class 2 and Class 3 FD SI

under7[SP %in% "FD"]

fcl23 <- cl23[SP %in% "FD"]

SIndexR_SpecMap("FD")
#39

SIndexR_SpecRemap("FD", "D")
#41

SIndexR_DefCurve(39)
#-4

SIndexR_DefCurve(41)
#96

SIndexR_CurveName(96)
#[1] "Thrower and Goudie (1992ac)"

#SIndexR_HtAgeToSI(curve = 96, age = 15, ageType = 0, height = 2.2, estType = 1)

fcl23_1 <- NULL
for ( i in 1:dim(fcl23)[1]){
  tmp <- fcl23[i]
  A <- tmp$Age
  H <- tmp$Ht
  si <- round(SIndexR_HtAgeToSI(curve = 96, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  tmp[,SI := si]

  fcl23_1 <- rbind(fcl23_1, tmp)
}

##Plot 4310U_3PT, point 3, class 3 FD
##Something wrong with either age or height
##remove SI for that tree

fcl23_1[11]$SI <- NA

under8 <- under7[!(Class %in% c(2,3) & SP %in% "FD")]
under8 <- rbind(under8, fcl23_1)
setorder(under6, Plot, Point, Class, SP)

##Calculate Class 2 and Class 3 PY SI

under8[SP %in% "PY"]
pycl23 <- cl23[SP %in% "PY"]

SIndexR_SpecMap("PY")
#95

SIndexR_DefCurve(95)
#107

SIndexR_SpecRemap("PY", "D")
#95

SIndexR_CurveName(107)
#[1] "Nigh (2002)"

si <- round(SIndexR_HtAgeToSI(curve = 107, age = pycl23$Age, ageType = 0, height = pycl23$Ht, estType = 1)$output, digits = 2)
pycl23$SI <- si

under9 <- under8[!(Class %in% c(2,3) & SP %in% "PY")]
under9 <- rbind(under9, pycl23)
setorder(under9, Plot, Point, Class, SP)

##Calculate Class 2 and Class 3 HW SI

under9[SP %in% "HW"]
hcl23 <- cl23[SP %in% "HW"]

SIndexR_SpecMap("HW")
#47

SIndexR_DefCurve(47)
#-4

SIndexR_SpecRemap("HW", "D")
#49

SIndexR_DefCurve(49)
#37

SIndexR_CurveName(37)
#"Nigh (1998)"

hcl23_1 <- NULL
for ( i in 1:dim(hcl23)[1]){
  tmp <- hcl23[i]
  A <- tmp$Age
  H <- tmp$Ht
  si <- round(SIndexR_HtAgeToSI(curve = 37, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  tmp[,SI := si]

  hcl23_1 <- rbind(hcl23_1, tmp)
}

under10 <- under9[!(Class %in% c(2,3) & SP %in% "HW")]
under10 <- rbind(under10, hcl23_1)
setorder(under10, Plot, Point, Class, SP)


##Calculate Class 2 and Class 3 BA SI

under10[SP %in% "BA"]
bacl23 <- cl23[SP %in% "BA"]

SIndexR_SpecMap("BA")
#11

SIndexR_DefCurve(11)
#118

SIndexR_SpecRemap("BA", "D")
#11

SIndexR_CurveName(118)
#"Nigh (2009)"

bacl23_1 <- NULL
for ( i in 1:dim(bacl23)[1]){
  tmp <- bacl23[i]
  A <- tmp$Age
  H <- tmp$Ht
  si <- round(SIndexR_HtAgeToSI(curve = 118, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  tmp[,SI := si]

  bacl23_1 <- rbind(bacl23_1, tmp)
}

under11 <- under10[!(Class %in% c(2,3) & SP %in% "BA")]
under11 <- rbind(under11, bacl23_1)
setorder(under11, Plot, Point, Class, SP)

##Calculate Class 2 and Classs 3 PW SI

under11[SP %in% "PW"]
##Only has Class 1 PW

##Calculate Class 2 and Class 3 JR

under11[SP %in% "JR"]

under11[Plot %in% "9010U_3PT"]
##No need to calculate JR: no JR in understory

write.csv(under11, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory_cleaned_SI.csv", row.names = FALSE)
