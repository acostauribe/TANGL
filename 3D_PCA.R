###AUG2021: Juliana Acosta-Uribe
###All rights reserved
### Copyright: UCSB

#R Script to plot PCA analyses on diverse human genomes

# Install / Load Packages

library(ggplot2) # makes pretty plots
#http://r-statistics.co/ggplot2-cheatsheet.html#Scatterplot
#http://r-statistics.co/Complete-Ggplot2-Tutorial-Part2-Customizing-Theme-With-R-Code.html

#install.packages("rgl")
library(rgl) # makes 3D plots
#https://rstudio-pubs-static.s3.amazonaws.com/179912_6fd52564f1e74653a4d7a3a2a37c9242.html #tutorial for rgl

# Set your working directory and Load your data
setwd("~/Documents/Population Stratification/PCA Unrelated/Reich2012/")
PCA <- read.delim("COL-900.unrelated.maf0.1.LD.pca.evec.txt", h = T)

#Load Theme for ggplot

theme<-theme(panel.background = element_blank(),
             panel.border=element_rect(fill=NA),
             panel.grid.major = element_blank(),
             panel.grid.minor = element_blank(),
             strip.background=element_blank(),
             axis.text.x=element_text(colour="black"),
             axis.text.y=element_text(colour="black"),
             axis.ticks=element_line(colour="black"),
             plot.margin=unit(c(1,1,1,1),"line"))


# Do an initial Scatterplot for each PC vs a given index
# This really helps to visualize how each PCA is clustering the populations 

indexPC1 <-ggplot(PCA, aes(x=INDEX, y=PC1)) +
  geom_point(aes(color=POP, shape=CONTINENT)) + theme 
print(indexPC1)
ggsave("index.png")

#You can plot single groups for better visualization

AMERICA <-ggplot(subset (PCA, CONTINENT %in% c("AMERICA")), 
                    aes(x=PC1, y=PC2)) +
                    geom_point(aes(color=POP, shape=SUPERPOP)) + 
                    theme
       print(AMERICA)
       ggsave("AMERICA.png")
       
# Plot PC1 vs PC2
       
PCA1 <- ggplot(PCA, aes(x=PC1, y=PC3)) +
  geom_point(aes(color=GROUP, shape=CONTINENT)) + theme 
labs(title="Principal Component Analysis")
print(PCA1)
ggsave("PC1vsPC2.png")

# Plot PC1 vs PC3

PCA2 <- ggplot(PCA, aes(x=PC1, y=PC3)) +
  geom_point(aes(color=SUPERPOP, shape=CONTINENT)) + theme 
labs(title="Principal Component Analysis")
print(PCA2)
ggsave("PC1vsPC3.png")

# Plot PC2 vs PC3

PCA3 <- ggplot(PCA, aes(x=PC2, y=PC3)) +
  geom_point(aes(color=SUPERPOP, shape=CONTINENT)) + theme 
labs(title="Principal Component Analysis")
print(PCA3)
ggsave("PC2vsPC3.png")


# Plot a 3D representation of the data

# Use similar colors to ggplot
mycolors <- c("#FF6347", "#DAA520", "#9ACD32", "#3CB371", "#00C5CD", "#00BFFF", "#6495ED", "#9F79EE", "#FF69B4")

plot3d (PCA$PC1, PCA$PC3, PCA$PC2,
        xlab = "PC1", ylab = "PC3", zlab = "PC2",
        type = "p", col=mycolors [as.numeric(PCA$GROUP)])

play3d(spin3d()) # Make it spin

movie3d(
  movie="3dAnimatedScatterplot", 
  spin3d(rpm = 7),
  duration = 10, 
  dir = "~/Documents/Population_Stratification/PCA_Unrelated/",
  type = "gif", 
  clean = TRUE )
