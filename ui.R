library(DT)
library(shiny)
library(plyr)
library(shinydashboard)
library(ggplot2)
library(leaflet)
library(dplyr)
library(scales)
library(gridBase)
library(RColorBrewer)
library(plotly)
library(treemap)
library(tools)
library(leaflet.extras)
library(magrittr)

shinyUI(dashboardPage(
    dashboardHeader(title = "Sanjay Pamnani"),
    dashboardSidebar(
      sidebarUserPanel("NYC DSA",
                       image = "https://yt3.ggpht.com/-04uuTMHfDz4/AAAAAAAAAAI/AAAAAAAAAAA/Kjeupp-eNNg/s100-c-k-no-rj-c0xffffff/photo.jpg"),
  
      sidebarMenu(
        menuItem("Analysis", tabName = "stats", icon = icon("bar-chart-o")),
        menuItem("Map", tabName = "map", icon = icon("map")),
        menuItem("Summary", tabName = "summary", icon = icon("list-alt")),
        menuItem("Data", tabName = "data", icon = icon("database")),
        checkboxGroupInput("Borough", 
                           label = em("Select Borough",style="text-align:center;color:#FFA319;font-size:150%"),
                           c("Manhattan","Queens","Brooklyn",       
                             "Bronx","Staten Island"),selected = 'Manhattan'),
        sliderInput("tot_count1", label = em("Filter Tree Count: Neighborhood Treemap",style="text-align:center;color:#FFA319;font-size:120%"), 
                    min = 500, max = 12500, value=c(500, 7500),
                    step = 500, round = TRUE, width = '300px'),
        sliderInput("tot_count2", label = em("Tree Type",style="text-align:center;color:#FFA319;font-size:120%"), 
                min = 500, max = 25000, value=c(500, 10000),
                step = 500, round = TRUE, width = '300px'))),
        #selectizeInput("selected", "Select Item to Display", choice),  
        
    dashboardBody(
       tabItems(
        tabItem(tabName = "stats", h4("Impact on Tree Count from Changes in Population and Housing Stock", align = "center"), br(),
                fluidRow(infoBoxOutput("cBox"), infoBoxOutput("minBox"), infoBoxOutput("maxBox")),
                br(),
                fluidRow(box(plotOutput("bar1")), box(plotlyOutput("pie1"))),
                br(),
                fluidRow(box(plotOutput("bar2"), width = 12), br()),
                fluidRow(box(plotlyOutput("graph2"), width = 12), br()),
                fluidRow(box(plotlyOutput("graph1"), width = 12),br()),
                fluidRow(box(plotlyOutput("graph3"), width = 12))),
                #fluidRow(plotlyOutput("graph2"), br(), verbatimTextOutput("event"))),
        #fluidRow(infoBoxOutput("treecountBox"), infoBoxOutput("treechangeBox"), infoBoxOutput("healthBox")),
        tabItem(tabName = "map", h2("Map of NYC Trees", align = "center"),
                fluidRow(leafletOutput("mymap"), br())),
        tabItem(tabName = "summary", h2("Trees by Neighborhood", align = "center"),
                fluidRow(plotOutput(("treemap_borough_nta_name"), height = 350, width = "100%"),
                         h2("Trees by Tree Type", align = "center"),
                plotOutput(("treemap_borough_spc"), height = 350, width = "100%"))),
        tabItem(tabName = "data", h2("Data Table of NYC Trees", align = "center"),
                fluidRow(box(DT::dataTableOutput("table"), width = 12)))))
    ))


#tags$head(
#    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),



