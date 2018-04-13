ui <- fluidPage(
  fluidRow(h1("k-means classification of countries"),
    column(3,
      selectInput("var1", 
                  label = "Select a country",
                  choices = sort(unique(all_info$node)),
                  selected = "United Kingdom"),
      sliderInput("var2", "Number of clusters", min = 15, max = 25, value = 15)
    ),
    column(5,
      dataTableOutput("selected_var")
          ),
    column(4,
      plotOutput("selected_plot")
    )
  ),
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
                       step = 1),
           sliderInput("ratio:", "Ratio",
                       min = min(all_info$ratio), max = max(all_info$ratio),             value = floor(median(all_info$ratio)),
                       step = 1)),
   column(5,
           wellPanel(htmlOutput("lm_pred")),
           h3("Residuals squared for each variable:"),
           wellPanel(textOutput("lm_fit"))),
   column(4,
           plotOutput("lm_plot")
   )
  )
)

server <- function(input, output) {

  source("model_kmeans.R")
  source("model_linear.R")

  #get kmeans data
  mydata_km <- reactive({
    model_kmeans(all_info,input$var2,input$var1)
  })
  
  #get linear model data
  mydata_lm <- reactive({
    model_linear(all_info,
                 input$deginwei,
                 input$degoutwei,
                 input$betval,
                 input$trino,
                 input$eigenval,
                 input$ratio)
  })
  
  #kmeans
  output$selected_var <- renderDataTable({
    mydata_km()$ddd
  })
  output$selected_plot <- renderPlot({
    mydata_km()$km_plot
  })
  
  #linear model
  output$lm_pred <- renderText({
    paste("Prediction of overall trade flux (M$US): ","<font color=\"#FF0000\"><b>",mydata_lm()$prediction,"</b></font>",sep="")
  })
  output$lm_plot <- renderPlot({
    mydata_lm()$lm_plot
  })
  output$lm_fit <- renderPrint({
    mydata_lm()$lm_fit
  })
  
}

shinyApp(ui, server)