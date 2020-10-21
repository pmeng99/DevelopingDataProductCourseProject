#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


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
          # a select input for selecting zip code
          selectInput("zipcode",
                      "Select Zipcode", choices = c(95020, 95124), selected = 95020),
          textOutput("info")
        ),

        mainPanel(
          # a leaflet map of all zip code in Santa Clara County 
          # When hover over, COVID info for that zip code will be highlighted
          leafletOutput("leaflet")
        )
    )
))
