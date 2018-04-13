ui <- fluidPage(titlePanel("K-means classification of countries"),
  fluidRow(
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
    br(),
    column(4,
      plotOutput("selected_plot")
    )
  )
)

server <- function(input, output) {

  source("model_kmeans.R")

  mydata <- reactive({
    model_kmeans(all_info,input$var2,input$var1)
  })
  
  output$selected_var <- renderDataTable({
    mydata()$ddd
  })
  
  output$selected_plot <- renderPlot({
    mydata()$km_plot
  })
  
}

shinyApp(ui, server)