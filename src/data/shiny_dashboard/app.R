require(visNetwork)

# BEGINNING OF UI

ui <- navbarPage("FSA", fluid = TRUE,
        tabPanel("Basic overview",
                 fluidRow(h1("Select a commodity"),
                          column(3,
                                 selectInput("commodity", 
                                             label = "Commodities",
                                             choices = c("Cucumbers",
                                                         "Beer",
                                                         "Milk",
                                                         "Vanilla",
                                                         "Maple syrup"),
                                             selected = "Cucumbers",
                                             multiple = FALSE)
                          )),
                 fluidRow(h1("General overview"),
                          column(3,
                                 selectInput("go_country", 
                                             label = "Select a countries",
                                           choices = sort(unique(all_info$node)),
                                             selected = "United Kingdom",
                                             multiple = TRUE),
                                 selectInput("go_xaxis", 
                                             label = "Select a variable in x axis",
                                             choices = names(all_info),
                                             selected = "period_date",
                                             multiple = FALSE),
                                 selectInput("go_yaxis", 
                                             label = "Select a variable in y axis",
                                             choices = names(all_info),
                                             selected = "ratio",
                                             multiple = FALSE)                          
                          ),
                          column(9,
                                 plotOutput("go_plot")
                          )
                 )),
        tabPanel("Trade network",
          fluidRow(h1("The network"),
            column(3,
              sliderInput("date_network:", "Month from Jan. 2014", min = 1, max = length(unique(si$period)), value = 1, step = 1),
              sliderInput("threshold_network:", "Threshold",min = 0.3, max = 0.95, value = 0.9,step = 0.05)
                 ),
                 column(9,
                   visNetworkOutput("network_plot")
                 )
               )),
        tabPanel("Identifying Irregular Trading Patterns",
                 fluidRow(h1("Flagged Countries During Specifed Month"),
                          column(3,
                                 sliderInput("date_network:", "Month from Jan. 2014", min = 1, max = length(unique(si$period)), value = 1, step = 1
                                 )),
                          column(9,
                                 dataTableOutput("ad_table_all")
                          )
                 ),
                 fluidRow(h1("Country Trade Pattern and Irregularities"),
                          column(3,
                                 selectInput("ad_country", 
                                             label = "Select a country",
                                             choices = sort(unique(all_info$node)),
                                             selected = "United Kingdom")
                          ),
                          column(9,
                                 plotOutput("ad_plot")
                          )
                 )
        ),
        tabPanel("Classifying",
          fluidRow(h1("k-means classification of countries"),
            column(3,
              selectInput("km_country", 
                label = "Select a country",
                choices = sort(unique(all_info$node)),
                selected = "United Kingdom"),
              sliderInput("km_num_clust", "Number of clusters", min = 15, max = 25, value = 15)
            ),
            column(5,
              dataTableOutput("km_data")
            ),
            column(4,
              plotOutput("km_plot")
            )
          )),
        tabPanel("Modelling",
          fluidRow(h1("Linear model"),
            column(3,
              sliderInput("deginwei:", "Arriving links",
                       min = min(all_info$deg_in_wei),  max = max(all_info$deg_in_wei),  value = max(all_info$deg_in_wei),
                       step = 1),
              sliderInput("degoutwei:", "Leaving links",
                       min = min(all_info$deg_out_wei), max = max(all_info$deg_out_wei), value = floor(median(all_info$deg_out_wei)),
                       step = 1),
              sliderInput("betval:", "Betweeness",
                       min = min(all_info$bet_val),     max = max(all_info$bet_val),     value = floor(median(all_info$bet_val)),
                       step = 1),
              sliderInput("trino:", "Number of triangles",
                       min = min(all_info$tri_no),      max = max(all_info$tri_no),      value = floor(median(all_info$tri_no)),
                       step = 1),
              sliderInput("eigenval:", "Eigenvalue",
                       min = min(all_info$eigen_val),   max = max(all_info$eigen_val),   value = floor(median(all_info$eigen_val)),
                       step = 0.1),
              sliderInput("ratio:", "Ratio",
                       min = min(all_info$ratio), max = max(all_info$ratio),             value = floor(median(all_info$ratio)),
                       step = 0.1)),
            column(5,
              wellPanel(htmlOutput("lm_prediction")),
              h3("Residuals squared for each variable:"),
              wellPanel(textOutput("lm_fit"))),
            column(4,
              plotOutput("lm_plot")
            )
         )
      )
   )
# END OF UI

#BEGINNING OF SERVER

server <- function(input, output) {

#Functions
  
  source("model_kmeans.R")
  source("model_linear.R")
  source("build_network.R")
  source("anomaly_detection.R")
  source("anomaly_detection_all.R")

  
  #Kmeans function
  mydata_km <- reactive({
               model_kmeans(all_info,input$km_num_clust,input$km_country)
  })
  
  #Linear model function
  mydata_lm <- reactive({
               model_linear(all_info,
                 input$deginwei,
                 input$degoutwei,
                 input$betval,
                 input$trino,
                 input$eigenval,
                 input$ratio)
  })
  
#Generating output
  
  # kmeans
  output$km_data <- renderDataTable({
                    mydata_km()$km_data
  })
  output$km_plot <- renderPlot({
                    mydata_km()$km_plot
  })
  
  # Linear model
  output$lm_fit <- renderPrint({
                   mydata_lm()$lm_fit
  })
  output$lm_prediction <- renderText({
                          paste("Prediction of overall trade flux (M$US): ","<font color=\"#FF0000\"><b>",
                          mydata_lm()$lm_prediction,"</b></font>",sep="")
  })
  output$lm_plot <- renderPlot({
                    mydata_lm()$lm_plot
  })
  
  # Network plot
  output$network_plot <- renderVisNetwork({
     build_network(si,input$date_network,input$threshold_network)
  })

  # Anomalous countries at a point in time
  output$ad_table_all <- renderDataTable({
    anomaly_detection_all(all_info,input$date_network)
  })
  
  # Plot of trade pattern for specified country, with irregularities highlighted
  output$ad_plot <- renderPlot({
    anomaly_detection(all_info,input$ad_country)
  })
  
  # General overview plot
  output$go_plot <- renderPlot({
    ggplot(all_info %>% filter(node %in% input$go_country),
           aes_string(x=input$go_xaxis,y=input$go_yaxis)) +
           geom_point(aes(color=node), size=3, alpha = 0.75)
  })
}

#END OF SERVER

shinyApp(ui, server)
