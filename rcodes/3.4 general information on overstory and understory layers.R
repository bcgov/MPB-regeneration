rm(list=ls())
library(data.table)
library(tidyr)
library(reshape2)
library(dplyr)
library(ggplot2)
library(quickPlot)
library(gridExtra)

invlayer <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_layer.csv"))
invpoly <- data.table(read.csv("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/compiled data/Combined/combined_poly.csv"))

#####abundance and distribution of regeneration
#####ITSL uses bec info from postMPB survey

regen <- invlayer[Layer %in% "L3/L4"]

a <- regen[,.(N1 = sum(PCT, na.rm = TRUE)), by = .(SP, BEC_sub_va)]
a[,N2 := sum(N1), by = BEC_sub_va]
a[,PCT := round(100*N1/N2, digits = 0)]

a <- a[order(a$BEC_sub_va)]
print(a, nrows = 132)

######Pine leading stands in 2003

pid <- invlayer[Layer %in% "2003" & SP %in% "PL" & PCT >= 70, unique(id)]
length(pid)
p <- invpoly[id %in% pid]
p1 <- distinct(p[Data_Source %in% "Erafor", .(id, BEC_sub_va)])
p1[,.N, by = BEC_sub_va]
p2 <- distinct(p[Data_Source %in% "ITSL" & Layer %in% "L1/L2", .(id, BEC_sub_va)])
p2 <- p2[order(p2$BEC_sub_va)]
p2[,.N, by = BEC_sub_va]

#####list data based on beczones

layer <- list()
poly <- list()
allbec <- unique(invlayer$BEC_sub_va)
allbec <- sort(allbec)
for ( i in 1:length(allbec)){
  bec <- allbec[i]
  layer[[i]] <- invlayer[BEC_sub_va %in% bec]
  names(layer)[[i]] <- bec
  poly[[i]] <- invpoly[BEC_sub_va %in% bec]
  names(poly)[[i]] <- bec
}

#####sp comp: Overstory vs Understory
#####pre-disturbance pine-leading stand only (PL >=70% in VRI 2003)

pid <- invlayer[Layer %in% "2003" & SP %in% "PL" & PCT >= 70, unique(id)]
player <- invlayer[id %in% pid]
ppoly <- invpoly[id %in% pid]

SPcolor <- data.table(PL = "#56B4E9",
                      S = "#E69F00",
                      AT = "#D55E00",
                      E = "#999999",
                      B = "#F0E442",
                      F = "#009E73",
                      AC = "#CC79A7",
                      C = "cornsilk2",
                      PY = "#0072B2",
                      PA = "navyblue",
                      H = "magenta3",
                      L = "chocolate4",
                      PW = "purple4",
                      UNK = "#000000")

fig_spcomp <- list()
for(i in 1:length(unique(player$id))){
  #i<-50
  indid <- unique(player$id)[i]
  tmp <- player[id%in%indid]
  sp2003 <- tmp[Layer%in%"2003",.(sumPCT = sum(PCT, na.rm = TRUE), Layer = "2003"), by = SP0]
  if(is.element("L1/L2", tmp$Layer)){
    over <- tmp[Layer%in%"L1/L2",.(sumPCT = sum(PCT, na.rm = TRUE), Layer = "L1/L2"), by = SP0]
  }else{
    over <- tmp[Layer%in%"2019",.(sumPCT = sum(PCT, na.rm = TRUE), Layer = "L1/L2"), by = SP0]
  }
  under <- tmp[Layer%in%"L3/L4",.(sumPCT = sum(PCT, na.rm = TRUE), Layer = "L3/L4"), by = SP0]
  tmp2 <- rbind(sp2003,over, under)
  fig_spcomp[[i]] <- ggplot(data = tmp2)+
    geom_bar(aes(x = as.character(Layer), y = sumPCT, fill = SP0), stat = "identity", position = "fill", width = 0.8)+
    scale_fill_manual(values = SPcolor)+
    labs(title = paste("id =", indid), x = "Layer", y = "sp composition")+
    theme(panel.background = element_blank(),
          panel.grid = element_blank())

  names(fig_spcomp)[i] <- indid
}

for(i in 1:length(fig_spcomp)){
    print(fig_spcomp[[i]])
    id <- names(fig_spcomp)[i]
    readline(paste("id", id, "of total", length(fig_spcomp), ", Check next?"))
  }

#####classify by beczones

spcomp_bec <- list()
for(i in unique(player$BEC_sub_va)){
  tmplayer <- player[BEC_sub_va %in% i]
  fig_id <- list()
  for(j in 1:length(unique(tmplayer$id))){
    #i<-50
    indid <- unique(tmplayer$id)[j]
    tmp <- tmplayer[id%in%indid]
    sp2003 <- tmp[Layer%in%"2003",.(sumPCT = sum(PCT, na.rm = TRUE), Layer = "2003"), by = SP0]
    if(is.element("L1/L2", tmp$Layer)){
      over <- tmp[Layer%in%"L1/L2",.(sumPCT = sum(PCT, na.rm = TRUE), Layer = "L1/L2"), by = SP0]
    }else{
      over <- tmp[Layer%in%"2019",.(sumPCT = sum(PCT, na.rm = TRUE), Layer = "L1/L2"), by = SP0]
    }
    under <- tmp[Layer%in%"L3/L4",.(sumPCT = sum(PCT, na.rm = TRUE), Layer = "L3/L4"), by = SP0]
    tmp2 <- rbind(sp2003,over, under)
    fig_id[[j]] <- ggplot(data = tmp2)+
      geom_bar(aes(x = as.character(Layer), y = sumPCT, fill = SP0), stat = "identity", position = "fill", width = 0.8)+
      scale_fill_manual(values = SPcolor)+
      labs(title = paste("BEC =", i, "  id =", indid), x = "Layer", y = "sp composition")+
      theme(panel.background = element_blank(),
            panel.grid = element_blank())

    names(fig_id)[j] <- indid
  }
  spcomp_bec[[i]] <- fig_id
}

##save

allfolder <- names(spcomp_bec)

allsavepath <- paste0("J:/!Workgrp/Inventory/MPB regeneration_WenliGrp/documents/figures/Combined/SPCOMP_OverVSUnder/", allfolder)

for (i in allsavepath){
  dir.create(i)
}

for (i in 1:length(spcomp_bec)){
  fig_indibec <- spcomp_bec[[i]]
  savepath <- allsavepath[i]
  folder <- allfolder[i]
  for (j in 1:length(fig_indibec)){
    figname <- paste0("id",names(fig_indibec)[j], ".tiff")
    ggsave(filename = file.path(savepath,figname), plot = fig_indibec[[j]], device = "tiff", dpi = 75)
  }
  cat(folder, "is done. \n")
}

bec <- unique(names(spcomp_bec))
bec <- sort(bec)
for(i in bec){
  cat(i)
  tmp <- spcomp_bec[[i]]
  for(j in 1:length(tmp)){
    id <- names(tmp)[j]
    print(tmp[[j]])
    if(is.element(j, seq(1,300, by = 10))){
      readline(paste0("id ", id," , ",j, "st plot of total ", length(tmp), " , Check next plot?"))
    }
    if(is.element(j, seq(2,300, by = 10))){
      readline(paste0("id ", id," , ",j, "nd plot of total ", length(tmp), " , Check next plot?"))
    }
    if(is.element(j, seq(3,300, by = 10))){
      readline(paste0("id ", id," , ",j, "rd plot of total ", length(tmp), " , Check next plot?"))
    }
    if(!is.element(j, seq(1,300, by = 10)) & !is.element(j, seq(2,300, by = 10)) & !is.element(j, seq(3,300, by = 10))){
      readline(paste0("id ", id," , ",j, "th plot of total ", length(tmp), " , Check next plot?"))
    }
  }
  if(i != bec[length(bec)]){
    readline(paste(i, "is done, Check next beczone?"))
  }else{
    readline(paste(i, "is done, this is the last beczone:)"))
  }
}


# fig_spcomp <- list()
# for ( i in 1:length(layer)){
# #  i<-1
#   indibec <- layer[[i]]
#   bec <- unique(indibec$BEC_sub_va)
#
#   a <- indibec[Layer %in% "L3/L4", .(sumPCT = sum(PCT, na.rm = TRUE), Layer = "L3/L4"), by = SP0]
#   b <- indibec[Layer %in% "L1/L2", .(sumPCT = sum(PCT, na.rm = TRUE), Layer = "L1/L2"), by = SP0]
#
#   c <- rbind(a, b)
#
#   fig_spcomp[[i]] <- ggplot(data = c)+
#     geom_bar(aes(x = as.character(Layer), y = sumPCT, fill = SP0), stat = "identity", position = "fill", width = 0.8)+
#     scale_fill_manual(values = SPcolor)+
#     labs(title = paste(bec), x = "Layer", y = "sp composition")+
#     theme(panel.background = element_blank(),
#           panel.grid = element_blank())
#
#   names(fig_spcomp)[[i]] <- bec
# }

# dev(2)
# grid.arrange(fig_spcomp$ESSFdc2, fig_spcomp$ESSFwk1, fig_spcomp$ESSFxc, ncol = 2)
# dev(3)
# grid.arrange(fig_spcomp$ICHdk, fig_spcomp$ICHmk3, fig_spcomp$ICHmw3, ncol = 2)
# dev(4)
# grid.arrange(fig_spcomp$IDFdk1, fig_spcomp$IDFdk2, fig_spcomp$IDFdk3, fig_spcomp$IDFdk4, ncol=2)
# dev(5)
# grid.arrange(fig_spcomp$MSdc1, fig_spcomp$MSdm2, fig_spcomp$MSxk1, fig_spcomp$MSxk2, fig_spcomp$MSxv, ncol=2)
# dev(6)
# grid.arrange(fig_spcomp$SBPSdc, fig_spcomp$SBPSmk, fig_spcomp$SBPSxc, fig_spcomp$SBPSxk, ncol=2)
# dev(7)
# grid.arrange(fig_spcomp$SBSdw1, fig_spcomp$SBSdw2, fig_spcomp$SBSdw3, fig_spcomp$SBSmc1, fig_spcomp$SBSmc2, fig_spcomp$SBSmc3, fig_spcomp$SBSmk1, fig_spcomp$SBSmm, fig_spcomp$SBSmw, ncol=2)
