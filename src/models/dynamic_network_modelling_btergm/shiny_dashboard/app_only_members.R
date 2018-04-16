# BEGINNING OF UI

ui <- navbarPage("FSA", fluid = TRUE,
        tabPanel("Community analysis",
                 fluidRow(h1("Trade communities"),
                          column(3,
                                 sliderInput("date_network:", "Month from Jan. 2014", min = 1, max = length(unique(si$period)), value = 1, step = 1
                                  )
                                ),
                          column(9,
                                 plotOutput("members_plot")
                          )
                )
        )
    )  
# END OF UI

#BEGINNING OF SERVER

server <- function(input, output) {

#Functions

  source("community_analysis.R")

#Generating output
  
  #Community plot
  output$members_plot <- renderPlot({
    community_analysis(si,input$date_network)
    })
}

#END OF SERVER

shinyApp(ui, server)