library(dplyr)
library(sf)
library(sp)
library(tmap)
library(rjson)
library(geojsonsf)
library(jsonlite)
library(SDraw)
library(tidyverse)
library(geojsonio)
library(rgdal)
library(raster)
library(maptools)
library(timeDate)
library(lubridate)
library(chron)

setwd("~/UChicago 19-20/Spring/GIS III/wd_final")

########## Import station data via APIs

##### Portland
PorSta <- fromJSON("http://biketownpdx.socialbicycles.com/opendata/station_information.json")
PorSta <- PorSta$data$stations
PorSta <- st_as_sf(PorSta, coords = c('lon','lat'), remove = TRUE)
st_crs(PorSta) <- 4326
PorSta <- st_transform(PorSta, 2163)


##### Chicago
ChiSta <- fromJSON("https://gbfs.divvybikes.com/gbfs/en/station_information.json")
ChiSta <- ChiSta$data$stations
ChiSta <- st_as_sf(ChiSta, coords = c('lon','lat'), remove = TRUE)
st_crs(ChiSta) <- 4326
ChiSta <- st_transform(ChiSta, 2163)

########## Import Trip Data via APIs

##### Chicago
temp <- tempfile()
download.file("https://divvy-tripdata.s3.amazonaws.com/Divvy_Trips_2019_Q1.zip",temp)
ChiTripsQ1 <- read.csv(unz(temp, "Divvy_Trips_2019_Q1"))
unlink(temp)

temp <- tempfile()
download.file("https://divvy-tripdata.s3.amazonaws.com/Divvy_Trips_2019_Q2.zip",temp)
ChiTripsQ2 <- read.csv(unz(temp, "Divvy_Trips_2019_Q2"))
unlink(temp)

temp <- tempfile()
download.file("https://divvy-tripdata.s3.amazonaws.com/Divvy_Trips_2019_Q3.zip",temp)
ChiTripsQ3 <- read.csv(unz(temp, "Divvy_Trips_2019_Q3.csv"))
unlink(temp)

temp <- tempfile()
download.file("https://divvy-tripdata.s3.amazonaws.com/Divvy_Trips_2019_Q4.zip",temp)
ChiTripsQ4 <- read.csv(unz(temp, "Divvy_Trips_2019_Q4.csv"))
unlink(temp)

#Fix slight descrepencies in column names
colnames(ChiTripsQ2) <- colnames(ChiTripsQ1)

#Combine each month into a single dataframe with all trips for 2019
ChiTrips <- rbind(ChiTripsQ1, ChiTripsQ2, ChiTripsQ3, ChiTripsQ4)

remove(ChiTripsQ1)
remove(ChiTripsQ2)
remove(ChiTripsQ3)
remove(ChiTripsQ4)


##### Portland
PorTrips01 <- read.csv("https://s3.amazonaws.com/biketown-tripdata-public/2019_01.csv")
PorTrips02 <- read.csv("https://s3.amazonaws.com/biketown-tripdata-public/2019_02.csv")
PorTrips03 <- read.csv("https://s3.amazonaws.com/biketown-tripdata-public/2019_03.csv")
PorTrips04 <- read.csv("https://s3.amazonaws.com/biketown-tripdata-public/2019_04.csv")
PorTrips05 <- read.csv("https://s3.amazonaws.com/biketown-tripdata-public/2019_05.csv")
PorTrips06 <- read.csv("https://s3.amazonaws.com/biketown-tripdata-public/2019_06.csv")
PorTrips07 <- read.csv("https://s3.amazonaws.com/biketown-tripdata-public/2019_07.csv")
PorTrips08 <- read.csv("https://s3.amazonaws.com/biketown-tripdata-public/2019_08.csv")
PorTrips09 <- read.csv("https://s3.amazonaws.com/biketown-tripdata-public/2019_09.csv")
PorTrips10 <- read.csv("https://s3.amazonaws.com/biketown-tripdata-public/2019_10.csv")
PorTrips11 <- read.csv("https://s3.amazonaws.com/biketown-tripdata-public/2019_11.csv")
PorTrips12 <- read.csv("https://s3.amazonaws.com/biketown-tripdata-public/2019_12.csv")

#Fix slight descrepencies in column names
colnames(PorTrips06) <- colnames(PorTrips01)
colnames(PorTrips07) <- colnames(PorTrips01)
colnames(PorTrips08) <- colnames(PorTrips01)

#Combine each month into a single dataframe with all trips for 2019
PorTrips <- rbind(PorTrips01, PorTrips02, PorTrips03, PorTrips04, PorTrips05, PorTrips06, 
                  PorTrips07, PorTrips08, PorTrips09, PorTrips10, PorTrips11, PorTrips12)

remove(PorTrips01)
remove(PorTrips02)
remove(PorTrips03)
remove(PorTrips04)
remove(PorTrips05)
remove(PorTrips06)
remove(PorTrips07)
remove(PorTrips08)
remove(PorTrips09)
remove(PorTrips10)
remove(PorTrips11)
remove(PorTrips12)
gc()


########## Import Zoning Data via APIs

##### Portland
temp <- tempfile()
temp2 <- tempfile()
download.file("https://opendata.arcgis.com/datasets/6b26f2ccb71d431f9ce8f34fd8ec1558_16.zip",temp)
unzip(zipfile = temp, exdir = temp2)
PorZon <- list.files(temp2, pattern = "Zoning.shp$", full.names=TRUE)
PorZon <- st_read(PorZon)
unlink(temp)
unlink(temp2)


##### Chicago
download.file("https://data.cityofchicago.org/api/geospatial/7cve-jgbp?method=export&format=GeoJSON", "tempzon.geojson")
ChiZon<-geojson_sf("tempzon.geojson")
unlink("tempzon.geojson")


########## Add commercial/residential designation to zoning data

##### Portland
PorZon <- transform(PorZon, res = ifelse(ZONE=='RX' | ZONE=='CM1' | ZONE=='RH' | ZONE=='IR' | ZONE=='R10' | 
                                            ZONE=='R2.5' | ZONE=='R20' | ZONE=='R5' | ZONE=='R7' | ZONE=='RF' | 
                                            ZONE=='RMP' | ZONE=='RM1' | ZONE=='RM2' | ZONE=='RM3' | ZONE=='RM4' 
                                          , TRUE, FALSE))
#Remove rows deemed neither residencial nor commercial
PorZon <- PorZon[!(PorZon$ZONE=='OS' | PorZon$ZONE=='CL' | PorZon$ZONE=='MC'),] 



##### Chicago
ChiZon <- transform(ChiZon, res = ifelse(zone_type=='9' | zone_type=='4' , TRUE, FALSE))
ChiZon$res[
  ChiZon$pd_prefix=='R' | ChiZon$pd_prefix=='RB' | ChiZon$pd_prefix=='RI' | ChiZon$pd_prefix=='RBT' | 
    ChiZon$pd_prefix=='RC' | ChiZon$pd_prefix=='RES' | ChiZon$pd_prefix=='R-B' | ChiZon$pd_prefix=='RCAP' | 
    ChiZon$pd_prefix=='RM' | ChiZon$pd_prefix=='RMI' | ChiZon$pd_prefix=='RBI' | ChiZon$pd_prefix=='RIB' | 
    ChiZon$pd_prefix=='RIC'
] <- TRUE
#Remove rows deemed neither residencial nor commercial
ChiZon <- ChiZon[!(ChiZon$zone_type=='12' | ChiZon$zone_type=='11'),] 


########## Create vornoi polygons

##### Portland
#Second clause sets bounding polygon to be a 2414.02m (1.5mi) buffer around the station be casue we assume 
#stations don't serve areas more then 1.5 miles away
PorVor <- SDraw::voronoi.polygons(as_Spatial(PorSta), st_buffer(PorSta, 2414.02) %>% summarise() %>% as_Spatial())

writeOGR(PorVor, layer = 'PorVor', 'PorVor.shp', driver = 'ESRI Shapefile')
PorVor <- st_read('PorVor.shp')
unlink('PorVor.shp')
unlink('PorVor.shx')
unlink('PorVor.dbf')
unlink('PorVor.prj')

##### Chicago
ChiVor <- SDraw::voronoi.polygons(as_Spatial(ChiSta), st_buffer(ChiSta, 2414.02) %>% summarise() %>% as_Spatial())

writeOGR(ChiVor, layer = 'ChiVor', 'ChiVor.shp', driver = 'ESRI Shapefile')
ChiVor <- st_read('ChiVor.shp')
unlink('ChiVor.shp')
unlink('ChiVor.shx')
unlink('ChiVor.dbf')
unlink('ChiVor.prj')


########## Designate service areas as primarily residential or commerical

#####Portland

#Rasterize zoning by 'res'
r <- raster(ncol=800, nrow=700)
extent(r) <- extent(PorZon)
PorZonRast <- rasterize(PorZon %>% as_Spatial(), r, 'res')

#extract raster cell count (sum) within each polygon area (poly)
ex <- raster::extract(PorZonRast, PorVor, fun=mean, na.rm=TRUE, df=TRUE)
ex <- transform(ex, res = ifelse(layer > 0.5, TRUE, FALSE))

#Merge 
PorVor$ID <- seq.int(nrow(PorVor))
PorVor <- merge(PorVor, ex, by = "ID")

#Remove momery objects
remove(PorZonRast)
remove(ex)
remove(r)
gc()

#####Chicago

#Rasterize zoning by 'res'
r <- raster(ncol=500, nrow=1000)
extent(r) <- extent(ChiZon)
ChiZonRast <- rasterize(ChiZon %>% as_Spatial(), r, 'res')

#Extract raster cell count (sum) within each polygon area (poly)
ex <- raster::extract(ChiZonRast, ChiVor, fun=mean, na.rm=TRUE, df=TRUE)
ex <- transform(ex, res = ifelse(layer > 0.5, TRUE, FALSE))

#Merge 
ChiVor$ID <- seq.int(nrow(ChiVor))
ChiVor <- merge(ChiVor, ex, by = "ID")

#Remove momery objects
remove(ChiZonRast)
remove(ex)
remove(r)
gc()

#Mark the 4 lakefront NA polygons non-residential. The Evanston ones will be left NA and filtered out later
ChiVor[31,5:6] <- c(0,0)
ChiVor[161,5:6] <- c(0,0)
ChiVor[229,5:6] <- c(0,0)
ChiVor[90,5:6] <- c(0,0)


########## Mark stations residential or commercial

##### Portland
#Unnecessary becasue we will be using the Voronoi polygons directly

##### Chicago

ChiVor <- st_transform(ChiVor, crs = st_crs(ChiSta))
ChiSta <- st_join(ChiSta, ChiVor, join = st_within)
ChiSta <- ChiSta[c('name','station_id','layer','res')]


########## Add work trip condition columns to trips dataframes


##### Portland
##Weekday
PorTrips$weekday <- PorTrips$StartDate %>% mdy() %>% isWeekday()

##Time
PorTrips$StartTD <-  paste(PorTrips$StartDate %>% mdy(), paste0(PorTrips$StartTime, ":00"))
breaks <- hour(hm("00:00", "4:00", "09:00", "23:59"))
labels <- c('FALSE', 'TRUE', 'FALSE')
PorTrips$morning <- cut(x=hour(PorTrips$StartTD), breaks = breaks, labels = labels, include.lowest=TRUE)

breaks <- hour(hm("00:00", "14:00", "18:00", "23:59"))
labels <- c('FALSE', 'TRUE', 'FALSE')
PorTrips$afternoon <- cut(x=hour(PorTrips$StartTD), breaks = breaks, labels = labels, include.lowest=TRUE)


##Origin and destination types
#Note: The portland system differs from the chicago system in that bikes can be left or picked up on the street, 
#whereas Divvy bikes MUST originate and terminate at a docking station. Thus, we now must spatially associate 
#every trip with a voronoi polygon. 
PorTrips <- na.omit(PorTrips, cols=c('StartLongitude', 'StartLatitude', 'EndLongitude', 'EndLatitude'))

#Geocode portland trips by origin point
PorTrips <- st_as_sf(PorTrips, coords = c('StartLongitude', 'StartLatitude'), crs = 4326)
PorTrips <- st_transform(PorTrips, crs = st_crs(PorVor))
PorTrips <- st_join(PorTrips, PorVor, join = st_within)

names(PorTrips)[c(26,27)] <- c('o_res_level', 'o_res')
PorTrips <- PorTrips %>% subset(select = -c(ID, x, y, area))

PorTrips <- st_drop_geometry(PorTrips)

#Geocode portland trips by destination point
PorTrips <- st_as_sf(PorTrips, coords = c('EndLongitude', 'EndLatitude'), crs = 4326)
PorTrips <- st_transform(PorTrips, crs = st_crs(PorVor))
PorTrips <- st_join(PorTrips, PorVor, join = st_within)

names(PorTrips)[c(26,27)] <- c('d_res_level', 'd_res')
PorTrips <- PorTrips %>% subset(select = -c(ID, x, y, area))

PorTrips <- st_drop_geometry(PorTrips)


##### Chicago

##Weekday
ChiTrips$weekday <- ChiTrips$start_time %>% as.Date() %>% isWeekday()
  
##Time
breaks <- hour(hm("00:00", "4:00", "09:00", "23:59"))
labels <- c('FALSE', 'TRUE', 'FALSE')
ChiTrips$morning <- cut(x=hour(ChiTrips$start_time), breaks = breaks, labels = labels, include.lowest=TRUE)

breaks <- hour(hm("00:00", "14:00", "18:00", "23:59"))
labels <- c('FALSE', 'TRUE', 'FALSE')
ChiTrips$afternoon <- cut(x=hour(ChiTrips$start_time), breaks = breaks, labels = labels, include.lowest=TRUE)



##Origin and destination types

#Origin
names(ChiTrips)[6] <- "station_id"
ChiTrips['station_id'] <- ChiTrips['station_id'] %>% unlist(use.names=FALSE) %>% as.character()
ChiTrips <- left_join(ChiTrips, ChiSta, by = "station_id")
names(ChiTrips)[c(6, 17, 18)] <- c('from_station_id', 'o_res_level', 'o_res')
#Destination
names(ChiTrips)[8] <- "station_id"
ChiTrips['station_id'] <- ChiTrips['station_id'] %>% unlist(use.names=FALSE) %>% as.character()
ChiTrips <- left_join(ChiTrips, ChiSta, by = "station_id")
names(ChiTrips)[c(8, 21, 22)] <- c('to_station_id', 'd_res_level', 'd_res')
#Drop unnecessary columns
ChiTrips <- ChiTrips %>% subset(select = -c(name.x, geometry.x, name.y, geometry.y))


########## Clean data and identify work trips

##### Portland

PorTrips2 <- PorTrips[,c(16, 18:23)] %>% na.omit() #na.omit filters out trips with NA values for any res column

PorTrips2$commute <- NA
PorTrips2$commute[
  PorTrips2$weekday==TRUE & PorTrips2$morning==TRUE & PorTrips2$o_res==1 & PorTrips2$d_res==0
  ] <- TRUE
PorTrips2$commute[
  PorTrips2$weekday==TRUE & PorTrips2$afternoon==TRUE & PorTrips2$o_res==0 & PorTrips2$d_res==1
  ] <- TRUE
PorTrips2$commute[is.na(PorTrips2$commute)==TRUE] <- FALSE


count(PorTrips2, commute)
32212/322611
#0.0998478 is the proportion of BIKETOWN trips that are work commutes

##### Chicago

ChiTrips2 <- ChiTrips[,c(13:19)] %>% na.omit() #na.omit filters out trips with NA values for any res column (Evanston)

ChiTrips2$commute <- NA
ChiTrips2$commute[
  ChiTrips2$weekday==TRUE & ChiTrips2$morning==TRUE & ChiTrips2$o_res==1 & ChiTrips2$d_res==0
] <- TRUE
ChiTrips2$commute[
  ChiTrips2$weekday==TRUE & ChiTrips2$afternoon==TRUE & ChiTrips2$o_res==0 & ChiTrips2$d_res==1
  ] <- TRUE
ChiTrips2$commute[is.na(ChiTrips2$commute)==TRUE] <- FALSE


count(ChiTrips2, commute)
503725/3724192
#0.1352575 is the proportion of Chicago-Chicago Divvy trips that are work commutes


########## Preform a Chi2 test for equality of proportions to determine if the two proportions are significantly different
prop.test(x = c(32212, 503725), n = c(322611, 3724192), correct=FALSE)
#X-squared = 3240, df = 1, p-value < 2.2e-16
#The two proportions are significantly different at any commonly used significance level

