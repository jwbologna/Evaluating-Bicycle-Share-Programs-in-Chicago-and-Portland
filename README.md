# Evaluating Bicycle Share Programs in Chicago and Portland
GIS III Spring 2020 Final Project

#### Authorship Details
Justin Bologna  
University of Chicago, Class of 2022  
Environmental and Urban Studies, Public Policy Studies, and Geographical Sciences  
jwbologna@uchicago.edu

#### Background and Overview
Public bicycle sharing systems have been around since 1965, when a small number of unlocked white bicycles were distributed throughout Amsterdam for use by the public. This first experiment failed, as most of the bicycles were quickly stolen or vandalized, but bicycle sharing programs have since spread across the globe, becoming significantly larger and more advanced. Today the largest system, in Wuhan, China, has over 100,000 bicycles. These systems are seen by many as a way to encourage active transport, which has health benefits for riders, is environmentally friendly, and relieves congestion, all without requiring substantial public funding.  

Bicycle sharing systems may seem like a great idea at face value, but it is not clear that they operate as an efficient form of public transportation. The bicycles are often heavy and have limited docking locations, making riding a personal bicycle a more practical and attractive option for many. And in cities with efficient public transit systems, it might make more sense to ride a train or bus than to rent a bicycle. Municipal governments usually have a very limited budget for transportation, so knowing whether bicycle sharing systems are a genuinely useful mode of transit to work or just a novelty for tourists could be incredibly useful for policymakers. 

#### Goals & Objectives
In this project, I examine the bicycle sharing systems in Chicago (Divvy) and Portland, Oregon (BIKETOWN). Both have extensive bikeshare programs with docking stations both downtown and in residential neighborhoods. By comparing a large city with a highly developed transit system and a full metro to a smaller one with less transit availability, we may be able to determine if transit coverage affects bikeshare usage. Specifically, this project accomplishes the following:
*Retrieve and clean open source bicycle trip data for the year of 2019 in Chicago and Portland
*Retrieve and clean open source zoning data to define primarily residential and primarily non-residential zones in each city
*Define trips that are likely commuting trips based on their time, origin, and destination
*Determine the proportions of commuting trips in Chicago and Portland 
*Determine if these two proportions are statistically different

#### Data Description
Listed below are data sources, grouped by what memory object they were used to create. Exclamation marks (!) indicate newly calculated objects or fields.  
1. PorSta  
**Description:** All bicycle docks in Portland  
**Variables:** "station_id"     "name"    "region_id"    "address"      "rental_methods" "geometry"  
**Temporal resolution:** N/A  
**Spatial Resolution:** Point  
**File format:** sf POINT  
**Source:**  
BIKETOWN (2020). station_information [JSON]. Retrieved from http://biketownpdx.socialbicycles.com/opendata/station_information.json
1. ChiSta  
**Description:** All bicycle docks in Chicago  
**Variables:** "name"        "station_id"            "geometry"  "layer"! (Proportion of the station’s service area covered by residential development)    "res"!(Boolean variable indicating whether or not the staion’s service area is covered primarily by residential development)  
**Temporal resolution:** N/A  
**Spatial Resolution:** Point  
**File format:** sf POINT  
**Sources:**  
Divvy (2020). station_information [JSON]. Retrieved from https://gbfs.divvybikes.com/gbfs/en/station_information.json
1. PorTrips  
**Description:** All trips within Portland’s bikeshare system during 2019  
**Variables:** "StartLatitude"    "StartLongitude"  "StartDate"    "StartTime"     "EndLatitude"      "EndLongitude"     "EndDate" "EndTime"   "weekday"! (Boolean variable indicating whether or not the trip began on a day M-F)    "StartTD"! (Start time and date, reformatted)          "morning"! (Boolean variable indicating whether or not the trip began between between 5AM and 10AM)   "afternoon"! (Boolean variable indicating whether or not the trip began between between 3PM and 7PM)           "o_res_level"! (Proportion of the origin station’s service area covered by residential development)     "o_res"!(Boolean variable indicating whether or not the origin staion’s service area is covered primarily by residential development)     "d_res_level"! (Proportion of the destination station’s service area covered by residential development)           "d_res"!(Boolean variable indicating whether or not the destination staion’s service area is covered primarily by residential development)       "commute"! (Boolean variable indicating whether or not the trip can be classified as a commute trip)  
**Temporal resolution:** Minute  
**Spatial Resolution:** Point  
**File format:** Dataframe  
**Sources:**  
BIKETOWN (2019). 2019_01 [CSV]. Retrieved from https://s3.amazonaws.com/biketown-tripdata-public/2019_01.csv  
BIKETOWN (2019). 2019_02 [CSV]. Retrieved from https://s3.amazonaws.com/biketown-tripdata-public/2019_02.csv  
BIKETOWN (2019). 2019_03 [CSV]. Retrieved from https://s3.amazonaws.com/biketown-tripdata-public/2019_03.csv  
BIKETOWN (2019). 2019_04 [CSV]. Retrieved from https://s3.amazonaws.com/biketown-tripdata-public/2019_04.csv  
BIKETOWN (2019). 2019_05 [CSV]. Retrieved from https://s3.amazonaws.com/biketown-tripdata-public/2019_05.csv  
BIKETOWN (2019). 2019_06 [CSV]. Retrieved from https://s3.amazonaws.com/biketown-tripdata-public/2019_06.csv  
BIKETOWN (2019). 2019_07 [CSV]. Retrieved from https://s3.amazonaws.com/biketown-tripdata-public/2019_07.csv  
BIKETOWN (2019). 2019_08 [CSV]. Retrieved from https://s3.amazonaws.com/biketown-tripdata-public/2019_08.csv  
BIKETOWN (2020). 2019_09 [CSV]. Retrieved from https://s3.amazonaws.com/biketown-tripdata-public/2019_09.csv  
BIKETOWN (2020). 2019_10 [CSV]. Retrieved from https://s3.amazonaws.com/biketown-tripdata-public/2019_10.csv  
BIKETOWN (2020). 2019_11 [CSV]. Retrieved from https://s3.amazonaws.com/biketown-tripdata-public/2019_11.csv  
BIKETOWN (2020). 2019_12 [CSV]. Retrieved from https://s3.amazonaws.com/biketown-tripdata-public/2019_12.csv  
1. ChiTrips  
**Description:** All trips within Chicago’s bikeshare system during 2019  
**Variables:** "start_time"        "end_time"       "from_station_id"     "to_station_id"   "weekday"! (Boolean variable indicating whether or not the trip began on a day M-F)      "morning"! (Boolean variable indicating whether or not the trip began between between 5AM and 10AM)   "afternoon"! (Boolean variable indicating whether or not the trip began between between 3PM and 7PM)           "o_res_level"! (Proportion of the origin station’s service area covered by residential development)     "o_res"!(Boolean variable indicating whether or not the origin staion’s service area is covered primarily by residential development)     "d_res_level"! (Proportion of the destination station’s service area covered by residential development)           "d_res"!(Boolean variable indicating whether or not the destination staion’s service area is covered primarily by residential development)       "commute"! (Boolean variable indicating whether or not the trip can be classified as a commute trip)  
**Temporal resolution:** Second  
**Spatial Resolution:** Point  
**File format:** Dataframe  
**Sources:**  
Divvy (2020). Divvy_Trips_2019_Q1 [CSV]. Retrieved from https://divvy-tripdata.s3.amazonaws.com/Divvy_Trips_2019_Q1.zip  
Divvy (2020). Divvy_Trips_2019_Q2 [CSV]. Retrieved from https://divvy-tripdata.s3.amazonaws.com/Divvy_Trips_2019_Q2.zip  
Divvy (2020). Divvy_Trips_2019_Q3 [CSV]. Retrieved from https://divvy-tripdata.s3.amazonaws.com/Divvy_Trips_2019_Q3.zip  
Divvy (2020). Divvy_Trips_2019_Q4 [CSV]. Retrieved from https://divvy-tripdata.s3.amazonaws.com/Divvy_Trips_2019_Q4.zip  
1. PorZon  
**Description:** Zoning designations in the City of Portland  
**Variables:** "Shape_Leng" "Shape_Area" "res"! (Boolean variable indicating whether or not a zone is primarily residential)  "geometry"  
**Temporal resolution:** N/A  
**Spatial Resolution:** Zone polygon  
**File format:** sf MULTIPOLYGON  
**Sources:**  
City of Portland (2020). 6b26f2ccb71d431f9ce8f34fd8ec1558_16 [Shapefile]. Retrieved from https://opendata.arcgis.com/datasets/6b26f2ccb71d431f9ce8f34fd8ec1558_16.zip
1. ChiZon  
**Description:** Zoning designations in the City of Chicago  
**Variables:** "shape_area" "shape_len" "res""! (Boolean variable indicating whether or not a zone is primarily residential)  "geometry"  
**Temporal resolution:** N/A  
**Spatial Resolution:** Zone polygon  
**File format:** sf MULTIPOLYGON  
**Sources:**  
City of Chicago (2020). Boundaries - Zoning Districts (current) [GeoJSON]. Retrieved from https://data.cityofchicago.org/api/geospatial/7cve-jgbp?method=export&format=GeoJSON
1. PorVor!
**Description:** Voronoi Polygons indicating service areas for BIKETOWN docks  
**Variables:** "ID"  "x"   "y"   "area"   "layer"! (Proportion of the service area covered by residential development)    "res"!(Boolean variable indicating whether or not the service area is covered primarily by residential development)    "geometry"  
**Temporal resolution:** N/A  
**Spatial Resolution:** Voronoi polygon  
**File format:** sf POLYGON  
**Sources:** N/A  
1. ChiVor!
**Description:** Voronoi Polygons indicating service areas for Divvy docks  
**Variables:**   "ID"   "x"    "y"    "area"  "layer"! (Proportion of the station’s service area covered by residential development)    "res"!(Boolean variable indicating whether or not the station’s service area is covered primarily by residential development)"   "geometry"  
**Temporal resolution:** N/A  
**Spatial Resolution:** Voronoi polygon  
**File format:** sf POLYGON  
**Sources:** N/A  

#### Results
I found that in 2019, 9.98478% of Portland BIKETOWN trips and 13.52575% of Chicago Divvy trips were work commutes, as I have classified them. A chi-squared test for equality of proportions returned a chi-squared of 3240, corresponding to a p-value of < 2.2e-16. There is essentially total certainty that the difference in proportions is statistically significant. 

A higher proportion of bicycle share trips in Chicago were commutes to work than in Portland. This was contrary to my hypothesis that Chicago’s greater size and more extensive transit network would result in fewer Divvy trips to work. 

#### Future Work
The greatest methodological flaw in this project is the definition of “commute trips.” I had to infer which trips were commutes to work based only on their origin, destination, day of the week, and time of departure. This data is insufficient to accurately predict the purpose of a trip; countless workers live in areas defined as primarily non-residential and countless others work in areas defined as primarily residential. Many do not have traditional Monday-Friday, 9:00-5:00 hours. Additionally, white-collar jobs are the ones most likely to have these hours, and white-collar workers are more likely to have access to a car for commuting, or a personal bicycle. Thus, we may have missed a relatively large proportion of individuals who use bikeshare systems for commuting by focusing on traditional work hours. 

A handful of Divvy stations are in Evanston, IL, just north of Chicago. I cut trips originating or terminating in Evanston from the trips data, since I did not examine Evanston’s zoning data, and thus was unable to classify those docks are residential or non-residential. Future work could incorporate Evanston’s zoning data to include those trips. 

In terms of more technical refinements, network distance could be used to determine service areas for bicycle docks. The Voronoi polygons created for this project use Euclidian distance, which does not accurately represent movement in an urban setting; people must move along streets, between buildings. 

In classifying service areas as primarily residential or non-residential, I converted the zoning data from polygon vector objects to raster objects. Since large rasters can be very computationally intensive, I used relatively small rasters (500x1000 for Chicago and 800x700 for Portland). This large resolution may have resulted in some accuracy issues, marking residential service areas non-residential and vice-versa. In the future, larger rasters could increase accuracy. Better yet, a method for summarizing vector data by other polygons would ensure complete accuracy. I was unable to find a method for doing this. 
