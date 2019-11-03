library (neonUtilities)
library(geoNEON)
library(raster)
library(rhdf5)

options(stringsAsFactors = F)

stackByTable("NEON_par.zip")

zipsByProduct(dpID = "DP1.10098.001", site="WREF", 
							package = "expanded", check.size = T,
							savepath = "~/Downloads")

stackByTable(filepath = "filesToStack10098", folder = T)

####
byTileAOP("DP3.30015.001", site = "WREF", year = "2017",
					easting = 580000, northing = 5075000, savepath="~/Downloads")

par30 <- read.delim("./NEON_par/stackedFiles/PARPAR_30min.csv", sep = ",")
View(par30)

parvar <- read.delim("./NEON_par/stackedFiles/variables.csv", sep = ",")
View(parvar)

par30$startDateTime <- as.POSIXct(par30$startDateTime, 
																	format = "%Y-%m-%d T %H:%M:%S Z", 
																	tz = "GMT")

plot(PARMean~startDateTime, 
		 data = par30[which(par30$verticalPosition == 60),],
		 type = "l")

### Navigating OS download data

vegmap <- read.delim("filesToStack10098/stackedFiles/vst_mappingandtagging.csv", sep = ",")
View(vegmap)

vegind <- read.delim("filesToStack10098/stackedFiles/vst_apparentindividual.csv", sep = ",")
View(vegind)


### https://www.neonscience.org/get-started-neon-series

vstvar <- read.delim("./filesToStack10098/stackedFiles/variables.csv")

vstval <- read.delim("./filesToStack10098/stackedFiles/validation.csv", sep = ",")
View(vstval)

names(vegmap)
vegmap <- geoNEON::def.calc.geo.os(vegmap, "vst_mappingandtagging")
names(vegmap)

veg <- merge(vegind, vegmap, by =c("individualID", "namedLocation", "domainID", "siteID", "plotID") )
View(veg)

symbols(veg$adjEasting[which(veg$plotID == "WREF_085")], 
				veg$adjNorthing[which(veg$plotID == "WREF_085")], 
				circles = veg$stemDiameter[which(veg$plotID == "WREF_085")]/100, 
				xlab = "Easting", ylab = "Northing", inches = F)

chm <- raster("/Users/chong/Desktop/NEON/NEON_par/stackedFiles/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")

plot(chm, col = topo.colors(6))
