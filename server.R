
library(shiny)
library(shiny)
library(tigris)
library(leaflet)
library(tidyverse)
library(dplyr)

options(tigris_use_cache = TRUE)

char_zips <- zctas(cb = TRUE)                           # get zip code polygon info
char_zips$GEOID10 <- as.numeric(char_zips$GEOID10)
covid <- read.csv("COVID-19_cases_by_zip_code_of_residence.csv", colClasses=rep("numeric",4)) # get covid info by zip code

# join above 2 info
char_zips <- geo_join(char_zips,               
                      covid, 
                      by_sp = "GEOID10", 
                      by_df = "zipcode",
                      how = "inner")

# create a color palltte with shades of green
pal <- colorNumeric(palette = "Greens", domain = char_zips$Rate)

# color function to return color per zip code:
# non-selected: shades of green based on COVID rates
# selected: red
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
    # get selected zip code
    zipcode = input$zipcode                          
    
    # update the selection on UI
    updateSelectInput(session, "zipcode", choices = as.list(char_zips$GEOID10), selected = zipcode)
    
    # render information text on UI
    output$info <- renderText({
      p  <- char_zips %>% filter(GEOID10 == zipcode) 
      paste("Population:", p$Population, " | Cases:", p$Cases, " | Rate:", p$Rate)
    })
     
    # render leaflet map
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
