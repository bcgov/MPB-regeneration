###Estimate Age and Ht for Class 1
###Step 3 Estimate Class 1 Age and Ht using estiamted SI
###Age: estimate Age at 1.3m Ht
###Use median age of estimate age at 1.3m ht
###Ht: estimate Ht at median age
###Use Nigh (2004) Juvenile Height Models for Lodgepole Pine and Interior Spruce
###Other species use Sindex 1.52 / Site Tool 4.1

##some Class 1 have age and height
##estimate Age and height for those dont have age and height
##newcl1 is from RcOde 4.3.2

noah <- newcl1[Age %in% NA]
unique(noah$SP)
# [1] "PL" "BL" "PA" "FD" "SE" "PY" "PW"

##Age

for (i in 1:dim(noah)[1]){
  tmp <- noah[i]
  sp <- tmp$SP
  SI <- tmp$SI
  H <- 1.3
  if(sp == "PL" | sp == "SE" | sp == "PA"){
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
    if(sp == "PL" | sp == "PA"){
      f_A <- function(A){
        (0.001424 - 0.0009260 * (IDF + SBPS) + 0.0008032 * SBS) * SI * A^(1.801 + 0.07098 * (BWBS + MS) + 0.3509 * (ICH + SBPS) + (0.01820 - 0.003024 * ESSF - 0.01257 * ICH + 0.01581 * IDF) * SI) * (0.9537 - 0.01083 * (BWBS + ICH + MS) - 0.02025 * SBS)^A - H
      }
    }
    if(sp == "SE"){
      f_A <- function(A){
        (0.0009952 + 0.0005208 * ICH - 0.0006785 * IDF - 0.0008774 * (MS + SBPS)) * SI * A^(0.9842 + 0.2521 * BWBS - 0.2893 * (ESSF + IDF) + 0.5893 * (ICH + MS + SBPS + SBS) + (0.02943 - 0.008403 * BWBS - 0.01388 * ICH + 0.02672 * (IDF + MS) - 0.03586 * SBS) * SI) * (1.017 + 0.03818 * (ESSF + SBS) - 0.04231 * ICH - 0.07806 * MS)^A - H
      }
    }
    a <- uniroot(f_A, c(0, 50))$root
  }

  if(sp == "BL"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("BL", "D"))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    a <- SIndexR_HtSIToAge(curve = sicurve, height = H, ageType = 0, siteIndex = SI, y2bh = y)$output
  }

  if(sp == "FD"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("FD", "D"))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    a <- SIndexR_HtSIToAge(curve = sicurve, height = H, ageType = 0, siteIndex = SI, y2bh = y)$output
  }
  if(sp == "PY"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("PY", "D"))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    a <- SIndexR_HtSIToAge(curve = sicurve, height = H, ageType = 0, siteIndex = SI, y2bh = y)$output
  }
  if(sp == "PW"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("PW", "D"))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    a <- SIndexR_HtSIToAge(curve = sicurve, height = H, ageType = 0, siteIndex = SI, y2bh = y)$output
  }
  noah[i]$Age <- round(a/2, digits = 0)
}

##Height

for (i in 1:dim(noah)[1]){
  tmp <- noah[i]
  sp <- tmp$SP
  SI <- tmp$SI
  A <- tmp$Age
  if(sp == "PL" | sp == "SE" | sp == "PA"){
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
    if(sp == "PL" | sp == "PA"){
      f_H <- function(H){
        (0.001424 - 0.0009260 * (IDF + SBPS) + 0.0008032 * SBS) * SI * A^(1.801 + 0.07098 * (BWBS + MS) + 0.3509 * (ICH + SBPS) + (0.01820 - 0.003024 * ESSF - 0.01257 * ICH + 0.01581 * IDF) * SI) * (0.9537 - 0.01083 * (BWBS + ICH + MS) - 0.02025 * SBS)^A - H
      }
    }
    if(sp == "SE"){
      f_H <- function(H){
        (0.0009952 + 0.0005208 * ICH - 0.0006785 * IDF - 0.0008774 * (MS + SBPS)) * SI * A^(0.9842 + 0.2521 * BWBS - 0.2893 * (ESSF + IDF) + 0.5893 * (ICH + MS + SBPS + SBS) + (0.02943 - 0.008403 * BWBS - 0.01388 * ICH + 0.02672 * (IDF + MS) - 0.03586 * SBS) * SI) * (1.017 + 0.03818 * (ESSF + SBS) - 0.04231 * ICH - 0.07806 * MS)^A - H
      }
    }
    H <- uniroot(f_H, c(0, 20))$root
  }

  if(sp == "BL"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("BL", "D"))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    H <- SIndexR_AgeSIToHt(curve = sicurve, age = A, ageType = 0, siteIndex = SI, y2bh = y)$output
  }

  if(sp == "FD"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("FD", "D"))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    H <- SIndexR_AgeSIToHt(curve = sicurve, age = A, ageType = 0, siteIndex = SI, y2bh = y)$output
  }
  if(sp == "PY"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("PY", "D"))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    H <- SIndexR_AgeSIToHt(curve = sicurve, age = A, ageType = 0, siteIndex = SI, y2bh = y)$output
  }
  if(sp == "PW"){
    sicurve <- SIndexR_DefCurve(SIndexR_SpecRemap("PW", "D"))
    y <- SIndexR_Y2BH(curve = sicurve, siteIndex = SI)$output
    H <- SIndexR_AgeSIToHt(curve = sicurve, age = A, ageType = 0, siteIndex = SI, y2bh = y)$output
  }
  noah[i]$Ht <- round(H, digits = 2)
}

##update noah to newcl1

newcl1 <- newcl1[!Age %in% NA]
newcl1 <- rbind(newcl1, noah)

##update newcl1 to under

newunder <- under[!Class %in% 1]
newunder <- rbind(newunder, newcl1)

write.csv(newunder, "J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Lillooet/understory_cleaned_SI_Cl1Updated.csv", row.names = FALSE)


###TEST
##compare estimate age and height to actual age and height

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

yesi_ye <- yesi[!Age %in% NA]

yesi_ye1 <- NULL
for (i in 1:dim(yesi_ye)[1]){
  tmp <- yesi_ye[i]
  A <- tmp$Age
  H <- tmp$Ht
  sp <- tmp$SP
  if(sp == "BA"){
    si <- round(SIndexR_HtAgeToSI(curve = 118, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  if(sp == "HW"){
    si <- round(SIndexR_HtAgeToSI(curve = 37, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  if(sp == "Bl"){
    si <- round(SIndexR_HtAgeToSI(curve = 93, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  if(sp == "FD"){
    si <- round(SIndexR_HtAgeToSI(curve = 96, age = A, ageType = 0, height = H, estType = 1)$output, digits = 2)
  }
  tmp[,SI_C1 := si]
  yesi_ye1 <- rbind(yesi_ye1, tmp)
}

yesi_ye2 <- NULL
for (i in 1:dim(yesi_ye1)[1]){
  tmp <- yesi_ye1[i]
  SI <- tmp$SI
  H <- 1.3
  sp <- tmp$SP
  if(sp == "BA"){
    y <- SIndexR_Y2BH(curve = 118, siteIndex = SI)$output
    A <- round(SIndexR_HtSIToAge(curve = 118, height = H, ageType = 0, siteIndex = SI, y2bh = y)$output, digits = 2)
    mA <- A/2
    mH <- round(SIndexR_AgeSIToHt(curve = 118, age = mA, ageType = 0, siteIndex = SI, y2bh = y)$output, digits = 2)
  }
  if(sp == "HW"){
    y <- SIndexR_Y2BH(curve = 37, siteIndex = SI)$output
    A <- round(SIndexR_HtSIToAge(curve = 37, height = H, ageType = 0, siteIndex = SI, y2bh = y)$output, digits = 2)
    mA <- A/2
    mH <- round(SIndexR_AgeSIToHt(curve = 37, age = mA, ageType = 0, siteIndex = SI, y2bh = y)$output, digits = 2)
  }
  if(sp == "Bl"){
    y <- SIndexR_Y2BH(curve = 93, siteIndex = SI)$output
    A <- round(SIndexR_HtSIToAge(curve = 93, height = H, ageType = 0, siteIndex = SI, y2bh = y)$output, digits = 2)
    mA <- A/2
    mH <- round(SIndexR_AgeSIToHt(curve = 93, age = mA, ageType = 0, siteIndex = SI, y2bh = y)$output, digits = 2)
  }
  if(sp == "FD"){
    y <- SIndexR_Y2BH(curve = 96, siteIndex = SI)$output
    A <- round(SIndexR_HtSIToAge(curve = 96, height = H, ageType = 0, siteIndex = SI, y2bh = y)$output, digits = 2)
    mA <- A/2
    mH <- round(SIndexR_AgeSIToHt(curve = 96, age = mA, ageType = 0, siteIndex = SI, y2bh = y)$output, digits = 2)
  }
  tmp[,Age_est := mA]
  tmp[,Ht_est := mH]
  yesi_ye2 <- rbind(yesi_ye2, tmp)
}


