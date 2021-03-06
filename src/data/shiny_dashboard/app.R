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
                                Restricted to food commodities, the goal is to obtain a detailed overview of the trade between
                                countries, detect anomalous events and provide the user with tools to predict the dynamics of the trade network."),
                             h4("Specifically the items presented here are:"),
                             h5(" * Network analysis: a general overview of the data including the trade network."),
                             h5(" * Anomaly detection: analysis of anomalous data in trade temporal series."),
                             h5(" * Country classification: clustering of the countries based on combined network metrics and trade data."),
                             h5(" * Trade modelling:"),
                             h6("       - A linear model to predict the effect of network disturbances"),
                             h6("       - Temporal Exponential Random Graph Models aimed to estimate a trade likelihood")
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
                                 plotOutput("go_plot", width = "800px", height = "350px")
                          ),
                          h5("Legend: Normalized_net_trade is defined as (Imports - Exports) / (Imports + Exports) in trade value.
                             It is possible to classify a country according to this parameter as:"),
                          h5("Consumer:    ~(+1)"),
                          h5("Producer:    ~(-1)"),
                          h5("Distributor: ~ 0  ")
                 ))
      ,
         tabPanel("The Wider Network",
           fluidRow(h1("Trade Network"),
                    h4("Visualises trade network over time, to help understanding of patterns and connectivity"),
                    h6("Adjust the time dial to see changes to the network over time and simplify the network with the complexity dial. Select a country to see their trade network"),
             column(3,
               uiOutput("ne_date"),
               sliderInput("threshold_network:", "Level of detail",min = 5, max = 75, value = 20,step = 2.5, post="%", ticks=FALSE)
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
           fluidRow(h1("Country classification based on trade variables and network metrics"),
                    h4("The clustering algorithm allows to determine what countries are the most similar to our candidate in terms of both trade characteristics and
                       network metrics. The potential uses for this tool could be:"),
                    h4("* What is the best potential replacement for a given supplier?"),
                    h4("* How many countries share a given trade pattern?"),
                    h6("Select a country in the drop down menu"),
             column(3,
               uiOutput("km_sel")
               #,
               #sliderInput("km_num_clust", "Number of clusters", min = 15, max = 25, value = 15)
             ),
             column(9,
                    h4("For your selection, the most similar countries are:"),
                    wellPanel(
               dataTableOutput("km_data")
                    )
             )
             #,
             #column(4,
             #  plotOutput("km_plot")
             #)
           ))
      ,
         tabPanel("Country Trade Flow Prediction",
           fluidRow(h1("We used a linear model to characterize the impact of a perturbation on the total trade."),
                    h4("Use the dials to perturb the trade."),
                    h6("Type of perturbations include the number of arriving connections, ratio, centrality in the trade network..."),
             column(3,
                uiOutput("lm_country"),
                uiOutput("lm_date"),
                uiOutput("lm_var1"),
                uiOutput("lm_var2")),
             column(5,
               wellPanel(htmlOutput("lm_prediction"))
               ,
               wellPanel(htmlOutput("lm_observed"))
               #,
               #h3("Residuals squared for each variable:"),
               #wellPanel(textOutput("lm_fit")))
             #,
             #column(4,
             #   plotOutput("lm_plot")
             )
          )
       ),
      tabPanel("Estimate Trade Probability",          
               fluidRow(h1("Estimating the Probability of Trade Connections"),
                        h4("Estimate the probability of trade between two countries"),
                        h6("*Enter the name of two countries and select a month"),
                        h6("*An estimate for the probability of trade for that month will be returned"),
                        column(3,
                                sliderInput("month_model:", "Month from Jan.", min = 1, max = 12, value = 1, step = 1),
                                uiOutput("pm_origin"),
                                uiOutput("pm_destin")
                        ),
                        column(9,
                               textOutput("probability_link")
                        )
                      ),
               fluidRow(h4("Estimate the probability of trade via connected nodes"),
                        h6("*Enter the names of the countries and select a month"),
                        h6("*An estimate for the probability of trade for that month along the linked countries will be returned"),
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
              choices = names(all_info %>% select(period_date)
                                ),
              selected = "period_date",
              multiple = FALSE)
})

output$go_sel_y <- renderUI({
  all_info <- all_info()
  selectInput("go_yaxis", 
              label = "Select a variable in y axis",
              choices = names(all_info %>% select(deg_out_wei,deg_in_wei,ratio,tot_out_wei,tot_in_wei) %>%
                                rename(Leaving_trade_routes  = deg_out_wei,
                                       Arriving_trade_routes = deg_in_wei,
                                       Total_Exports_USD         = tot_out_wei,
                                       Total_Imports_USD         = tot_in_wei,
                                       Normalized_net_trade      = ratio)
                                ),
              selected = "Normalized_net_trade",
              multiple = FALSE)
})
  
output$lm_var1 <- renderUI({
  all_info <- all_info()
  all_months_lm <- sort(unique(all_info$period))
  x1 <- all_info %>% filter(period == all_months_lm[input$lm_date]) %>% filter(node==input$lm_country)
sliderInput("deginwei", "Number of arriving routes",
            min = min(all_info$deg_in_wei),  max = max(all_info$deg_in_wei),  value = x1$deg_in_wei,
            step = 1)
})

output$lm_var2 <- renderUI({
  all_info <- all_info()
  all_months_lm <- sort(unique(all_info$period))
  x2 <- all_info %>% filter(period == all_months_lm[input$lm_date]) %>% filter(node==input$lm_country) %>% select(deg_out_wei)
sliderInput("degoutwei", "Number of leaving routes",
            min = min(all_info$deg_out_wei), max = max(all_info$deg_out_wei), value = x2$deg_out_wei,
            step = 1)
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

##
output$lm_date <- renderUI({
  si <- si()
  sliderInput("lm_date", "Month from Jan. 2014", min = 1, max = length(unique(si$period)), value = 1, step = 1)
})

output$lm_country <- renderUI({
  all_info <- all_info()
  selectInput("lm_country", 
              label = "Select a country",
              choices = sort(unique(all_info$node)),
              selected = "Czech Rep.")
})
###

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
               model_kmeans(all_info,15,input$km_country)
  })

  #Linear model function
  mydata_lm <- reactive({
    all_info <- all_info()
#
    all_months_lm <- sort(unique(all_info$period))
    x3 <- all_info %>% filter(period == all_months_lm[input$lm_date]) %>% filter(node==input$lm_country)
                 model_linear(all_info,
                 input$deginwei,
                 input$degoutwei,x3$bet_val,x3$tri_no,x3$eigen_val,x3$ratio)
  })
#   
# #Generating output
#   
  # kmeans
  output$km_data <- renderDataTable({
                    mydata_km()$km_data
  })
  #output$km_plot <- renderPlot({
  #                  mydata_km()$km_plot
  #})

  # Linear model
  #output$lm_fit <- renderPrint({
  #                 mydata_lm()$lm_fit
  #})
  output$lm_prediction <- renderText({
                          paste("Prediction of overall trade flux (M$US): ","<font color=\"#FF0000\"><b>",
                          round(mydata_lm()$lm_prediction,digits=2),"</b></font>",sep="")
  })
  
  ####
  #Linear model function
  mydata_lmo <- reactive({
    all_info <- all_info()
    all_months_lm <- sort(unique(all_info$period))
    all_info %>% filter(period == all_months_lm[input$lm_date]) %>%
                                  filter(node==input$lm_country) %>%
                                  mutate(overall_flux_musd = overall_flux/1e6) %>%
                                  select(overall_flux_musd)
  })
  
  output$lm_observed <- renderText({
    paste("Observed overall trade flux (M$US): ","<font color=\"#FF0000\"><b>",
          round(mydata_lmo(),digits=2),"</b></font>",sep="")
  })
  ####
  #output$lm_plot <- renderPlot({
  #                  mydata_lm()$lm_plot
  #})

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
             rename(Leaving_trade_routes  = deg_out_wei,
                    Arriving_trade_routes = deg_in_wei,
                    Total_Exports_USD         = tot_out_wei,
                    Total_Imports_USD         = tot_in_wei,
                    Normalized_net_trade      = ratio),
           aes_string(x=input$go_xaxis,y=input$go_yaxis)) +
           geom_point(aes(color=node), size=5, alpha = 0.75) +
           geom_line(aes(color=node), size=3, alpha = 0.75) +
      theme(axis.text=element_text(size=17), 
            axis.title=element_text(size=20,face="bold"), 
            legend.text=element_text(size=20), 
            legend.title=element_text(size=20))
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
