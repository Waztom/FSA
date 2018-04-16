require(visNetwork)

# BEGINNING OF UI

ui <- navbarPage("FSA", fluid = TRUE,
        tabPanel("Basic overview",
                 fluidRow(h1("Select a commodity"),
                          column(3,
                                 selectInput("commodity", 
                                             label = "Commodities",
                                             choices = c("Cucumbers",
                                                         "Vanilla"),
                                             selected = "Cucumbers",
                                             multiple = FALSE)
                          )),
                 fluidRow(h1("General overview"),
                          column(3,
                                uiOutput("go_sel_country"),
                                uiOutput("go_sel_x"),
                                uiOutput("go_sel_y")
                                ),
                          column(9,
                                 plotOutput("go_plot")
                          )
                 ))
      ,
         tabPanel("Trade network",
           fluidRow(h1("The network"),
             column(3,
               uiOutput("ne_date"),
               sliderInput("threshold_network:", "Threshold",min = 0.3, max = 0.95, value = 0.9,step = 0.05)
                  ),
                  column(9,
                    visNetworkOutput("network_plot")
                  )
                ))
      ,
         tabPanel("Anomalies",          
           fluidRow(h1("Anomaly detection"),
                    column(3,
                           uiOutput("an_country")
                           ),
                    column(9,
                           plotOutput("ad_plot")
                           )
                )
              )
      ,
         tabPanel("Classifying",
           fluidRow(h1("k-means classification of countries"),
             column(3,
               uiOutput("km_sel"),
               sliderInput("km_num_clust", "Number of clusters", min = 15, max = 25, value = 15)
             ),
             column(5,
               dataTableOutput("km_data")
             ),
             column(4,
               plotOutput("km_plot")
             )
           ))
      ,
         tabPanel("Modelling",
           fluidRow(h1("Linear model"),
             column(3,
                uiOutput("lm_var1"),
                uiOutput("lm_var2"),
                uiOutput("lm_var3"),
                uiOutput("lm_var4"),
                uiOutput("lm_var5"),
                uiOutput("lm_var6")),
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
  source("get_all_info.R")
  source("get_si.R")
  
  all_info <- reactive({
    get_all_info(input$commodity)
    })
  
  si <- reactive({
    get_si(input$commodity)
  })
  
output$go_sel_country <- renderUI({
  all_info <- all_info()
  selectInput("go_country", 
              label = "Select a countries",
              choices = sort(unique(all_info$node)),
              selected = "United Kingdom",
              multiple = TRUE)
  })

output$go_sel_x <- renderUI({
  all_info <- all_info()
  selectInput("go_xaxis", 
              label = "Select a variable in x axis",
              choices = names(all_info),
              selected = "period_date",
              multiple = FALSE)
})

output$go_sel_y <- renderUI({
  all_info <- all_info()
  selectInput("go_yaxis", 
              label = "Select a variable in y axis",
              choices = names(all_info),
              selected = "ratio",
              multiple = FALSE)
})
  
output$lm_var1 <- renderUI({
  all_info <- all_info()
sliderInput("deginwei:", "Arriving links",
            min = min(all_info$deg_in_wei),  max = max(all_info$deg_in_wei),  value = max(all_info$deg_in_wei),
            step = 1)
})

output$lm_var2 <- renderUI({
  all_info <- all_info()
sliderInput("degoutwei:", "Leaving links",
            min = min(all_info$deg_out_wei), max = max(all_info$deg_out_wei), value = floor(median(all_info$deg_out_wei)),
            step = 1)
})

output$lm_var3 <- renderUI({
  all_info <- all_info()
sliderInput("betval:", "Betweeness",
            min = min(all_info$bet_val),     max = max(all_info$bet_val),     value = floor(median(all_info$bet_val)),
            step = 1)
})

output$lm_var4 <- renderUI({
  all_info <- all_info()
sliderInput("trino:", "Number of triangles",
            min = min(all_info$tri_no),      max = max(all_info$tri_no),      value = floor(median(all_info$tri_no)),
            step = 1)
})

output$lm_var5 <- renderUI({
  all_info <- all_info()
sliderInput("eigenval:", "Eigenvalue",
            min = min(all_info$eigen_val),   max = max(all_info$eigen_val),   value = floor(median(all_info$eigen_val)),
            step = 0.1)
})

output$lm_var6 <- renderUI({
  all_info <- all_info()
sliderInput("ratio:", "Ratio",
            min = min(all_info$ratio), max = max(all_info$ratio),             value = floor(median(all_info$ratio)),
            step = 0.1)
})

output$ne_date <- renderUI({
   si <- si()
   sliderInput("date_network:", "Month from Jan. 2014", min = 1, max = length(unique(si$period)), value = 1, step = 1)
   })

output$an_country <- renderUI({
  all_info <- all_info()
  selectInput("ad_country", 
            label = "Select a country",
            choices = sort(unique(all_info$node)),
            selected = "United Kingdom")
})

output$km_sel <- renderUI({
  all_info <- all_info()
   selectInput("km_country", 
            label = "Select a country",
            choices = sort(unique(all_info$node)),
            selected = "United Kingdom")
})

  #Kmeans function
  mydata_km <- reactive({
    all_info <- all_info()
               model_kmeans(all_info,input$km_num_clust,input$km_country)
  })

  #Linear model function
  mydata_lm <- reactive({
    all_info <- all_info()
               model_linear(all_info,
                 input$deginwei,
                 input$degoutwei,
                 input$betval,
                 input$trino,
                 input$eigenval,
                 input$ratio)
  })
#   
# #Generating output
#   
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
    si <- si()
    build_network(si,input$date_network,input$threshold_network)
  })

  # Anomaly detection plot
  output$ad_plot <- renderPlot({
    all_info <- all_info()
    anomaly_detection(all_info,input$ad_country)
  })

  # General overview plot
  output$go_plot <- renderPlot({
    all_info <- all_info()
    ggplot(all_info %>% filter(node %in% input$go_country),
           aes_string(x=input$go_xaxis,y=input$go_yaxis)) +
           geom_point(aes(color=node), size=3, alpha = 0.75)
  })
}

#END OF SERVER

shinyApp(ui, server)
