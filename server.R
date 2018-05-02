library(DT)
library(DBI)
library(shiny)
library(plyr)
library(shinydashboard)
library(ggplot2)
library(leaflet)
library(dplyr)
library(gridBase)
library(RColorBrewer)
library(plotly)
library(scales)
library(treemap)
library(maps)
library(tools)
library(leaflet.extras)
library(magrittr)

server <- function(input, output, session){

  conn = dbConnector(session, dbname)
  tdf <-reactive({ dbGetData(conn, tablename = "tree2015_clean_dt") })

  # Treemap 1st map --> # of Trees by Borough by Neighorhood
  observeEvent(input$Borough, {
    #r1 <- tree_2015_data %>% filter(., borough == input$Borough) %>% group_by(.,borough) %>% 
    #  summarise(., max1 = max(total_count), min1 = min(total_count))
    min1_ = round_any(min(tree_2015_data[tree_2015_data[,'borough']==input$Borough,'total_count']),-100)
    max1_ = round_any(min(tree_2015_data[tree_2015_data[,'borough']==input$Borough,'total_count']),-100) 
    updateSliderInput(session, inputId = input$tot_count1, label = em("Filter Tree Count",style="text-align:center;color:#FFA319;font-size:150%"), 
                      min = min1_, max = max1_, step = 500)
  })
  
  # select data for Treemap 1st map --> # of Trees by Borough by Neighorhood
  data_selected_borough<-reactive({
    tree_2015_data[tree_2015_data$borough %in% input$Borough & 
                     tree_2015_data$total_count >= input$tot_count1[1] &
                     tree_2015_data$total_count <= input$tot_count1[2],]
  })
  
  # 2nd map --> # of Trees by Borough by Tree Type
  observeEvent(input$Borough, {
    min2_ = round_any(min(tree_2015_data2[tree_2015_data2[,'borough']==input$Borough,'total_count']),-100)
    max2_ = round_any(min(tree_2015_data2[tree_2015_data2[,'borough']==input$Borough,'total_count']),-100) 
    updateSliderInput(session, inputId = input$tot_count2, label = em("Filter Tree Count",style="text-align:center;color:#FFA319;font-size:150%"), 
                      min = min2_, max = max2_, step = 500)
  })
  
  # select data for Treemap 2nd map --> # of Trees by Borough by Tree Type
  data_selected_borough_spc<-reactive({
    tree_2015_data2[tree_2015_data2$borough %in% input$Borough & 
                     tree_2015_data2$total_count >= input$tot_count2[1] &
                     tree_2015_data2$total_count <= input$tot_count2[2],]
  })
  
  # Creating 2 Treemaps; 1st map --> # of Trees by Borough by Neighorhood
  #                     2nd map --> # of Trees by Borough by Tree Type
  
  #  1st map --> # of Trees by Borough by Neighorhood
  output$treemap_borough_nta_name <- renderPlot({ 
     par(mar=c(0,0,0,0), xaxs='i', yaxs='i') 
     plot(c(0,1), c(0,1),axes=F, col="white")
     vps <- baseViewports()
     
  #  1st map --> # of Trees by Borough by Neighorhood  
    temp=data_selected_borough()
    .tm <<- treemap(temp, index="nta_name", vSize="total_count", vColor="total_count", type="value",
                    title = "", palette = "RdYlGn", border.col ="white", position.legend="right",
                    fontsize.labels = 16, title.legend="Tree Count")
  })
  
  # select data for Treemap 2nd map --> # of Trees by Borough by Tree Type
  data_selected_borough_spc<-reactive({
    tree_2015_data2[tree_2015_data2$borough %in% input$Borough & 
                      tree_2015_data2$total_count >= input$tot_count2[1] &
                      tree_2015_data2$total_count <= input$tot_count2[2],]
  })
  
  # # of Trees by Borough by Tree Type
  output$treemap_borough_spc <- renderPlot({ 
    temp2=data_selected_borough_spc()
    .tm2 <<- treemap(temp2, index="spc_common", vSize="total_count", vColor="total_count", type="value",
                     title = "", palette = "RdYlGn", border.col ="white", position.legend="right",
                     fontsize.labels = 16, title.legend="Tree Count")
  })
  
  # show data using DataTable
  output$table <- DT::renderDataTable({ 
    tdf() %>% 
      datatable() %>% 
      formatStyle(input$selected2, background="skyblue", fontWeight='bold')
  })
  
    # leaflet Map Output
    output$mymap <- renderLeaflet({
        leaflet(tdf()) %>% 
      # Base group
        addProviderTiles(providers$CartoDB.Positron, 
                         options = providerTileOptions(noWrap = TRUE), group = "CartoDB (default)") %>% 
        addProviderTiles(providers$Esri.NatGeoWorldMap,
                         options = providerTileOptions(noWrap = TRUE), group = "ESRI World Map") %>% 
      # Overlay groups 
       addMarkers(~longitude, ~latitude, 
                  clusterOptions = markerClusterOptions(), group = "Lat Long Tree Plot") %>% 
        addHeatmap(.,~longitude, ~latitude, intensity = ~tree_id, group = "Heat Map",
                    max = 0.05, radius = 20, gradient = "BuGn") %>% 
      # Layers control
      addLayersControl(
        baseGroups = c("CartoDB (default)", "ESRI World Map"),
        overlayGroups = c("Lat Long Tree Plot", "Heat Map"),
        options = layersControlOptions(collapsed = FALSE), position = "topleft")
      })


    # ggplot Bar chart output
    
    graph1 = ggplot(nyc_trees, aes(x=borough, y = Total_trees), width = )
    graph1 = graph1 + geom_bar(aes(fill = borough), stat = 'identity') + 
      theme(axis.text.x = element_text(angle = 15, hjust=1)) + 
      scale_y_continuous(labels = comma) +
      xlab("Borough") + ylab("Number of Trees in Borough") + 
      ggtitle("Trees by Borough") + theme(plot.title = element_text(hjust = 0.5)) +
      theme(legend.position="none", plot.title = element_text(size=15)) + 
      geom_text(aes(label = Total_trees), size = 5, vjust=1.6, color="white", labels = comma)
    
    output$bar1 = renderPlot(graph1, height="auto")
    
    
    graph2 = ggplot(health_g, aes(x=borough, y = prop), color = borough)
    graph2 = graph2 + geom_bar(aes(fill = borough), stat = 'identity') + facet_wrap(~health) + 
            scale_y_continuous(labels = percent_format()) + 
            theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
            xlab("Borough") + ylab("Proportion of Trees in Borough") + 
            ggtitle("Health of Trees by Borough") + theme(plot.title = element_text(hjust = 0.5)) +
            theme(legend.position="none", plot.title = element_text(size=20))
    
    output$bar2 = renderPlot(graph2)
    
    
    # pie chart
    pie1 <- plot_ly(nyc_trees, labels = ~borough, values = ~Total_trees, type = 'pie',
                 textposition = 'inside',
                 textinfo = 'label+percent',
                 insidetextfont = list(color = '#FFFFFF'),
                 hoverinfo = 'text',
                 text = ~paste("Tree count:", Total_trees),
                 marker = list(colors = colors,
                 line = list(color = '#FFFFFF', width = 1)),
                 showlegend = FALSE) %>%
              layout(title = 'Proportion of Trees by Borough',
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)) %>% 
              layout(autosize = F, width = 300, height = 300)
    
    output$pie1 = renderPlotly(pie1)
    
    # Plotyly Bubble charts output
        l <- list(orientation = 'h', font = list(family = "sans-serif", size = 14, color = "#000"),
          bgcolor = "#E2E2E2", bordercolor = "#FFFFFF", borderwidth = 2, x = 0.1, y = -0.3)
       
        f1 <- list(family = "Arial, sans-serif", size = 18, color = "black")
        
        f2 <- list(family = "Old Standard TT, serif", size = 14, color = "black")
        
        xax <- list( title = "Change in Population (2000-2010)", titlefont = f1, showticklabels = TRUE, 
                     tickangle = 45, tickfont = f2, showgrid = FALSE, tickformat = "%")
        
        yax <- list(title = "Change in Tree Count (2005-2015)", titlefont = f1, showticklabels = TRUE, 
                    tickangle = 45, tickfont = f2, showgrid = FALSE, tickformat = "%")
        
        xax2 <- list( title = "Population Density per acre (2010)", titlefont = f1, showticklabels = TRUE, 
                     tickangle = 45, tickfont = f2, showgrid = FALSE, tickformat = "0.0")
        
        yax2 <- list(title = "Tree Density per acre (2015)", titlefont = f1, showticklabels = TRUE, 
                    tickangle = 45, tickfont = f2, showgrid = FALSE, tickformat = "0.0")
        
        
        p1 <- plot_ly(pop_tree_comp, x = ~per_change_pop, y = ~per_change_trees, type = 'scatter', mode = 'markers', size = ~pop_2010, color = ~borough, colors = 'Paired',
                                 sizes = c(10, 100), marker = list(opacity = 0.5, sizemode = 'diameter'), hoverinfo = 'text',
                                 text = ~paste('Borough:', borough, '<br>Population growth:', scales::percent(per_change_pop), 
                                               '<br>Tree growth:', scales::percent(per_change_trees))) %>%
          layout(title = 'Growth: Population vs. Trees (bubble size = 2010 population)', xaxis = xax, yaxis = yax, showlegend = T, legend = l)
        
          output$graph1 <- renderPlotly({p1})
          
          p2 <- plot_ly(pop_tree_comp, x = ~person_acre, y = ~tree_acre, type = 'scatter', mode = 'markers', size = ~acre, color = ~borough, colors = 'Paired',
                       sizes = c(10, 100), marker = list(opacity = 0.5, sizemode = 'diameter'), hoverinfo = 'text',
                       text = ~paste('Borough:', borough, '<br>Population Density per acre:', person_acre, 
                                     '<br>Tree Density per acre:', tree_acre)) %>%
            layout(title = 'Density: People vs. Trees (bubble size = acres in borough)', xaxis = xax2, yaxis = yax2, showlegend = T, legend = l)
          
          output$graph2 <- renderPlotly({p2})

          
          xax3 <- list( title = "Change in Housing Stock (2000-2010)", titlefont = f1, showticklabels = TRUE, 
                       tickangle = 45, tickfont = f2, showgrid = FALSE, tickformat = "%")
          
          yax3 <- list(title = "Change in Tree Count (2005-2015)", titlefont = f1, showticklabels = TRUE, 
                      tickangle = 45, tickfont = f2, showgrid = FALSE, tickformat = "%")
          
          p3 <- plot_ly(pop_tree_comp, x = ~change_in_house_2010, y = ~per_change_trees, type = 'scatter', mode = 'markers', size = ~house_2010, color = ~borough, colors = 'Paired',
                        sizes = c(10, 100), marker = list(opacity = 0.5, sizemode = 'diameter'), hoverinfo = 'text',
                        text = ~paste('Borough:', borough, '<br>Housing stock growth:', scales::percent(change_in_house_2010), 
                                      '<br>Tree growth:', scales::percent(per_change_trees))) %>%
            layout(title = 'Growth: Housing Stock vs. Trees (bubble size = 2010 housing stock)', xaxis = xax3, yaxis = yax3, showlegend = T, legend = l, diplayModeBar = F)
          
          output$graph3 <- renderPlotly({p3})

          output$cBox <- renderInfoBox({
            change_val <- pop_tree_comp %>% 
              summarise(., sum(total_2015)/sum(total_2005)-1) 
            change_val = percent(change_val[[1]])
            infoBox("2005-15 NYC Change", change_val, icon = icon("hand-o-up"), width = 400)
          })
          output$minBox <- renderInfoBox({
           result_min_max <- pop_tree_comp %>% 
            arrange(., per_change_trees) 
            min_borough = paste("2005-15",result_min_max[[2]][1])
            min_value = result_min_max[[8]][1]
            min_value = sprintf("%1.1f%%", min_value * 100)
            infoBox(min_borough, min_value, icon = icon("hand-o-down"), width = 400)
           })
          output$maxBox <- renderInfoBox({
          max_borough = paste('2005-15',result_min_max[[2]][5])
          max_value = percent(result_min_max[[8]][5])
          infoBox(max_borough, max_value, icon = icon("hand-o-up"), width = 400)
          })
}