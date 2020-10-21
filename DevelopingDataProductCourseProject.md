Course Project: Shiny Application and Reproducible Pitch
========================================================
author: Peihuan Meng
date: October 21, 2020
autosize: true

The Course Project
========================================================

This is the 2nd half of the course project for Developing Data Product in John Hopkins Data Science Certification series on Coursera. 

The 1st half of the project is to use Shiny to build an interactive app and have it hosted and available on the internet. 

The 2nd half of the project is this presentation to showcase the application we built. 

The Shiny Application
========================================================

The application shows a map of counts and rates of cumulative COVID-19 cases by zip codes in Santa Clara County, Carlifornia. Zip codes with higher rates of cases per 100,000 residents appear as a darker shade of green than zip codes with lower rates of cases. 

The application is available here: 

https://pmeng.shinyapps.io/DevelopingDataProductCourseProject/

The source of the data can be found here:

https://data.sccgov.org/COVID-19/COVID-19-cases-by-zip-code-of-residence/j2gj-bg6c

UI Code
========================================================


```r
library(shiny)
library(shiny)
library(tigris)
library(leaflet)
library(tidyverse)
library(dplyr)

shinyUI(fluidPage(
    titlePanel("Santa Clara County COVID Information"),
    helpText("Trace COVID 19 information for Santa Clara county in California."),
    helpText("The selected zip code will be highlighted in red in the map."),
    helpText("You can also hover over the map to see the infomation for each zip code."),
    
    sidebarLayout(
        sidebarPanel(
          selectInput("zipcode",
                      "Select Zipcode", choices = c(95020, 95124), selected = 95020),
          textOutput("info")
        ),

        mainPanel(
          leafletOutput("leaflet")
        )
    )
))
```

Server Code
========================================================


```r
library(shiny)
library(shiny)
library(tigris)
library(leaflet)
library(tidyverse)
library(dplyr)

options(tigris_use_cache = TRUE)

char_zips <- zctas(cb = TRUE)
char_zips$GEOID10 <- as.numeric(char_zips$GEOID10)
covid <- read.csv("COVID-19_cases_by_zip_code_of_residence.csv", colClasses=rep("numeric",4))

char_zips <- geo_join(char_zips, 
                      covid, 
                      by_sp = "GEOID10", 
                      by_df = "zipcode",
                      how = "inner")

pal <- colorNumeric(palette = "Greens", domain = char_zips$Rate)

colr <- function(rate, zipcode, selected) {
  res <- vector()
  for (i in 1:length(rate)) {
    if (zipcode[i] == selected)
      res <- c(res, "#FF0000")
    else
      res <- c(res, pal(rate[i]))  
  }
  res
}

shinyServer(function(input, output, session) {
  
  observe({
    zipcode = input$zipcode
    
    updateSelectInput(session, "zipcode", choices = as.list(char_zips$GEOID10), selected = zipcode)
    
    output$info <- renderText({
      p  <- char_zips %>% filter(GEOID10 == zipcode) 
      paste("Population:", p$Population, " | Cases:", p$Cases, " | Rate:", p$Rate)
    })
     
    output$leaflet <- renderLeaflet({
      char_zips %>%
        leaflet() %>%
        addTiles("COVID-19 by zipcode in Santa Clara County") %>%
        addPolygons(fillColor = ~colr(Rate, GEOID10, zipcode),
                  weight = 2,
                  opacity = 1,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7,
                  highlight = highlightOptions(weight = 2,
                                               color = "#666",
                                               dashArray = "",
                                               fillOpacity = 0.7,
                                               bringToFront = TRUE),
                  label = ~paste0("Zip:", char_zips$GEOID10, " | Population:", char_zips$Population, " | Cases:", char_zips$Cases))    
    })
  })
})
```
