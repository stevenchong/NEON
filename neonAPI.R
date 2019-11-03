library(httr)
library(jsonlite)
library(dplyr, quietly = T)
library(downloader)

req <- GET("http://data.neonscience.org/api/v0/products/DP1.10003.001")

req

req.content <- content(req, as = "parsed")
req.content

req.text <- content(req, as = "text")

avail <- fromJSON(req.text, simplifyDataFrame = T, flatten = T)
avail

bird.urls <- unlist(avail$data$siteCodes$availableDataUrls)
bird.urls

brd <- GET(bird.urls[grep("WOOD/2015-07", bird.urls)])
brd.files <- fromJSON(content(brd, as = "text"))

brd.files$data$files

brd.count <- read.delim(brd.files$data$files$url[intersect(grep("countdata", brd.files$data$files$name), grep("basic", brd.files$data$files$name))], sep = ",")

brd.point <- read.delim(brd.files$data$files$url[intersect(grep("perpoint", brd.files$data$files$name), grep("basic", brd.files$data$files$name))], sep = ",")

clusterBySp <- brd.count %>%
	group_by(scientificName) %>%
	summarize(total = sum(clusterSize))

clusterBySp <- clusterBySp[order(clusterBySp$total, decreasing = T), ]

barplot(clusterBySp$total, names.arg = clusterBySp$scientificName, ylab = "Total", cex.names = 0.5, las = 2)

req.soil <- GET("http://data.neonscience.org/api/v0/products/DP1.00041.001")

avail.soil <- fromJSON(content(req.soil, as = "text"), simplifyDataFrame = T, flatten = T)

temp.urls <- unlist(avail.soil$data$siteCodes$availableDataUrls)

tmp <- GET(temp.urls[grep("MOAB/2017-03", temp.urls)])
tmp.files <- fromJSON(content(tmp, as = "text"))
tmp.files$data$files$name

soil.temp <- read.delim(tmp.files$data$files$url[intersect(grep("002.504.030", tmp.files$data$files$name), grep("basic", tmp.files$data$files$name))], sep = ",")

plot(soil.temp$soilTempMean~as.POSIXct(soil.temp$startDateTime, format = "%Y-%m-%d T %H:%M:%S Z"), pch = "." , xlab = "Date", ylab = "T")

req.aop <- GET("http://data.neonscience.org/api/v0/products/DP1.30010.001")
avail.aop <- fromJSON(content(req.aop, as = "text"), simplifyDataFrame = T, flatten = T)

cam.urls <- unlist(avail.aop$data$siteCodes$availableDataUrls)

cam <- GET(cam.urls[intersect(grep("SJER", cam.urls), grep("2017", cam.urls))])

cam.files <- fromJSON(content(cam, as = "text"))

head(cam.files$data$files$name)

download(cam.files$data$files$url[grep("20170328192931", cam.files$data$files$name)], paste(getwd(), "/SJER_image.tif", sep = ""), mode = "wb")

head(brd.point$namedLocation)

req.loc <- GET("http://data.neonscience.org/api/v0/locations/WOOD_013.birdGrid.brd")

brd.WOOD_013 <- fromJSON(content(req.loc, as = "text"))
brd.WOOD_013

library(geoNEON)
brd.point.loc <- def.extr.geo.os(brd.point)

symbols(brd.point.loc$api.easting, brd.point.loc$api.northing, circles = brd.point.loc$coordinateUncertainty, xlab = "Easting", ylab = "Northing", tck = 0.01, inches = F)

brd.point.pt <- def.calc.geo.os(brd.point, "brd_perpoint")
symbols(brd.point.pt$easting, brd.point.pt$northing, circles = brd.point.pt$adjCoordinateUncertainty, xlab = "Easting", ylab = "Northing", tck = 0.01, inches = F)


loon.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?family=Gaviidae&offset=0&limit=500")
loon.list <- fromJSON(content(loon.req, as = "text"))

mam.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?taxonTypeCode=SMALL_MAMMAL&offset=0&limit=500&verbose=true")
mam.list <- fromJSON(content (mam.req, as = "text"))
mam.list$data[1:10, ]


am.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?scientificname=Abronia%20minor%20Standl.")
am.list <- fromJSON(content(am.req, as = "text"))
am.list$data
