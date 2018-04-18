require(visNetwork)

# BEGINNING OF UI

ui <- fluidPage(titlePanel(title = "FSA - Global Trade Patterns and Networks"),
  sidebarLayout(
  sidebarPanel(selectizeInput("commodity",
                            "Select a food product", 
                            selected="Milk", 
                            choices = c("Cucumbers",
                                        "Vanilla",
                                        "Beer",
                                        "Milk",
                                        "Maple Syrup"),
                            multiple = FALSE)
               , width = 2),
  mainPanel(navbarPage("Select a tab to explore", fluid = TRUE,
                tabPanel("Introduction",
                           fluidRow(wellPanel(
                             h4("This dashboard allows to explore the International trade flows according to UN Comtrade database.
                                Restricted to food commodities, the goal is to obtain a detailed overview of the goods exchage between
                                countries, detect anomalous events and provide the user with tools to predict the dynamics of the trade network."),
                             h4("Specifically the items presented here are:"),
                             h5(" * Network analysis: a general overview of the data including the trade network."),
                             h5(" * Anomaly detection: analysis of anomaluous data in trade temporal series."),
                             h5(" * Country classification: clustering of the countries based on combined network metrics and trade data."),
                             h5(" * Trade modelling:"),
                             h6("       - A linear model to predict the effect of network disturbaces"),
                             h6("       - Temporal Exponential Random Graph Models aimed to predict a trade likelyhood")
                             ))),
                tabPanel("Understanding Trade Patterns",
                 fluidRow(h1("Country Trade Patterns"),
                          h4("Helps understanding of how country trade patterns have changed over time"),
                          h6("Select a country and what you want to plot on the x and y axis"),
                          column(3,
                                uiOutput("go_sel_country"),
                                uiOutput("go_sel_x"),
                                uiOutput("go_sel_y")
                                ),
                          column(9,
                                 plotOutput("go_plot", width = "1200px", height = "350px")
                          )
                 ))
      ,
         tabPanel("The Wider Network",
           fluidRow(h1("Trade Network"),
                    h4("Visualises trade network over time, to help understanding of patterns and connectivity"),
                    h6("Adjust the time dial to see changes to the network over time and simplify the network with the complexity dial. Select a country to see their trade network"),
             column(3,
               uiOutput("ne_date"),
               sliderInput("threshold_network:", "Network Complexity",min = 0.3, max = 0.95, value = 0.9,step = 0.05)
                  ),
                  column(9,
                    visNetworkOutput("network_plot", width = "1200px", height = "650px")
                  )
                ))
      ,
      tabPanel("Irregular Trading Patterns",
               fluidRow(h1("Flagged Countries During Specifed Month"),
                        h4("Identifies countries which deviate from their normal trade patterns for the month specified, to help identify potential risks"),
                        h6("Select a month on the time dial"),
                        column(3,
                               uiOutput("ad_date")
                               )
                               ,
                        column(6,
                              dataTableOutput("ad_table_all")
                        )
               )
               ,
                fluidRow(h1("Country Trade Pattern and Irregularities"),
                         h4("Shows regular trade pattern for the country selected, including seasonal and overall trends. Plus detects deviations from normal trend to help highlight potential risks"),
                         h6("Select a country in the drop down menu"),
                         column(3,
                                uiOutput("ad_sel_country")
                         ),
                         column(9,
                                plotOutput("ad_plot", width = "1200px", height = "650px")
                         )
                )
      ),
         tabPanel("Classifying Countries",
           fluidRow(h1("Identifying Similar Countries"),
                    h4("Identifies countries which have similar trade patterns to the country selected. Incorporates value of trade and network connectivity"),
                    h6("Select a country in the drop down menu"),
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
         tabPanel("Predictive Model 1",
           fluidRow(h1("Predicting the Impact of Adding/Removing Connections"),
                    h4("Predicts the trade value if connections are added/removed, to help understand the financial impact of changes to trade connectivity"),
                    h6("Adjust the number of connections with the dial"),
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
       ),
      tabPanel("Predictive Model 2",          
               fluidRow(h1("Predicting the Probability of Network Connections"),
                        h4("Predicts the probability that trade occured between two countries"),
                        h6("Enter the name of two countries and the probability will be returned"),
                        column(3,
                                sliderInput("month_model:", "Month from Jan.", min = 1, max = 12, value = 1, step = 1),
                                uiOutput("pm_origin"),
                                uiOutput("pm_destin")
                        ),
                        column(9,
                               textOutput("probability_link")
                        )
                      ),
               fluidRow(h4("Predicts the probability that trade occured via connected nodes, to assess likelihood of trade along path"),
                        h6("Enter the names of the countries and the probability will be returned"),
                        column(3,
                               sliderInput("month_model:", "Month from Jan.", min = 1, max = 12, value = 1, step = 1),
                               uiOutput("pm_origin_1"),
                               uiOutput("pm_middle"),
                               uiOutput("pm_destin_1")
                        ),
                        column(9,
                               textOutput("probability_links")
                        )
               ) 
      ),
      tabPanel("Help",
               fluidRow(h1("Dashboard Demonstration")))
   ))))

# END OF UI

#BEGINNING OF SERVER

server <- function(input, output) {

#Functions
  
  source("model_kmeans.R")
  source("model_linear.R")
  source("build_network.R")
  source("anomaly_detection.R")
  source("network_model.R")
  source("get_all_info.R")
  source("get_si.R")
  source("get_model.R")
  source("get_ad.R")
  source("anomaly_detection_all.R")
  source("anomaly_detection_all_preloaded.R")
  
  all_info <- reactive({
    get_all_info(input$commodity)
    })
  
  si <- reactive({
    get_si(input$commodity)
  })
  
  model <- reactive({
    get_model(input$commodity)
  })
  
  ad <- reactive({
    get_ad(input$commodity)
  })
  
output$go_sel_country <- renderUI({
  all_info <- all_info()
  selectInput("go_country", 
              label = "Select a country",
              choices = sort(unique(all_info$node)),
              selected = "United Kingdom",
              multiple = TRUE)
  })


output$go_sel_x <- renderUI({
  all_info <- all_info()
  selectInput("go_xaxis", 
              label = "Select a variable in x axis",
              choices = names(all_info %>% select(deg_out_wei,deg_in_wei,ratio,degree_val,bet_val,overall_flux,period_date) %>%
                                rename(leaving_links   = deg_out_wei,
                                       arriving_links  = deg_in_wei,
                                       total_links     = degree_val,
                                       betweenness     = bet_val,
                                       total_trade_USd = overall_flux)
                                ),
              selected = "period_date",
              multiple = FALSE)
})

output$go_sel_y <- renderUI({
  all_info <- all_info()
  selectInput("go_yaxis", 
              label = "Select a variable in y axis",
              choices = names(all_info %>% select(deg_out_wei,deg_in_wei,ratio,degree_val,bet_val,overall_flux,period_date) %>%
                                rename(leaving_links   = deg_out_wei,
                                       arriving_links  = deg_in_wei,
                                       total_links     = degree_val,
                                       betweenness     = bet_val,
                                       total_trade_USd = overall_flux)
                                ),
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

output$ad_date <- renderUI({
  all_info <- all_info()
  sliderInput("ad_date:", "Month from Jan. 2014", min = 1, max = length(unique(all_info$period)), value = 1, step = 1)
})

output$ad_sel_country <- renderUI({
  all_info <- all_info()
  selectInput("ad_sel_country:",
            label = "Select a country",
            choices = sort(unique(all_info$node)),
            selected = "Germany")
})

output$pm_origin <- renderUI({
  all_info <- all_info()
selectInput("from_country", 
            label = "Select from country",
            choices = sort(unique(all_info$node)),
            selected = "Spain")
})

output$pm_origin_1 <- renderUI({
  all_info <- all_info()
  selectInput("link_from_country", 
              label = "Select from country",
              choices = sort(unique(all_info$node)),
              selected = "Spain")
})

output$pm_middle <- renderUI({
  all_info <- all_info()
  selectInput("link_middle_country", 
              label = "Select connecting country",
              choices = sort(unique(all_info$node)),
              selected = "Netherlands")
})

output$pm_destin <- renderUI({
  all_info <- all_info()
selectInput("to_country", 
            label = "Select to country",
            choices = sort(unique(all_info$node)),
            selected = "United Kingdom")
})

output$pm_destin_1 <- renderUI({
  all_info <- all_info()
  selectInput("link_to_country", 
              label = "Select to country",
              choices = sort(unique(all_info$node)),
              selected = "United Kingdom")
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

  # Anomalous countries at a point in time
  output$ad_table_all <-  renderDataTable({
    ad <- ad()
    anomaly_detection_all_preloaded(ad,input$ad_date)
  })
  
  # Plot of trade pattern for specified country, with irregularities highlighted
  output$ad_plot <- renderPlot({
    all_info <- all_info()
    anomaly_detection(all_info,input$ad_sel_country)
  })

  # General overview plot
  output$go_plot <- renderPlot({
    all_info <- all_info()
    ggplot(all_info %>% filter(node %in% input$go_country) %>%
             rename(leaving_links   = deg_out_wei,
                    arriving_links  = deg_in_wei,
                    total_links     = degree_val,
                    betweenness     = bet_val,
                    total_trade_USd = overall_flux),
           aes_string(x=input$go_xaxis,y=input$go_yaxis)) +
           geom_point(aes(color=node), size=3, alpha = 0.75) +
      theme(axis.text=element_text(size=12), 
            axis.title=element_text(size=14,face="bold"), 
            legend.text=element_text(size=14), 
            legend.title=element_text(size=14))
  })
  
  # Network model output
  output$probability_link <- renderText({
    si <- si()
    model <- model()
    paste("Probability of trade link: ", 
    network_model(model,si, input$month_model,input$from_country, 0, input$to_country),"%",sep="")
  })
  
  # Network model links output
  output$probability_links <- renderText({
    si <- si()
    model <- model()
    paste("Probability of trade via link: ", 
          network_model(model,si,input$month_model,input$link_from_country,input$link_middle_country, input$link_to_country),"%",sep="")
  })
}

#END OF SERVER

shinyApp(ui, server)
