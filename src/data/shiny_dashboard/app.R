# UI

ui = fluidPage(
        sidebarLayout(
          sidebarPanel(
            selectInput("gc", "Country:", sort(unique(kmeans_res$node)), selected = "Germany")),
        mainPanel(
          DT::dataTableOutput("kmeans")
                )
               )
              )

# SERVER

server <- function(input, output) {
  tmp <- reactive({kmeans_res %>% filter(node == input$gc)})
  output$kmeans = DT::renderDataTable({tmp})
}

shinyApp(ui, server)

