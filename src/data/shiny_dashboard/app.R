ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      helpText("Uisng k-means, find the 'closest' country to the one selected"),
      
      selectInput("var1", 
                  label = "Select a country",
                  choices = sort(unique(kmeans_res$node)),
                  selected = "United Kingdom"),
      sliderInput("var2", "Number of clusters", min = 15, max = 25, value = 15)
    ),
    mainPanel(
      dataTableOutput("selected_var")
    )
  )
)

server <- function(input, output) {

  source("model_kmeans.R")

  mydata <- reactive({
    model_kmeans(all_info,input$var2,input$var1)
  })
  
  output$selected_var <- renderDataTable({
    mydata()
  })
  
}

shinyApp(ui, server)