library(shiny)
library(ggplot2)

source("../temp_alex/model_get_data.R")
pathname <- "../"
filename <- "Comtrade_all.csv"
route    <- paste(pathname,filename,sep="")
all_info <- model_get_data(route)
list_of_countries <- sort(unique(all_info$node))

# Define UI for miles per gallon app ----

ui <- fluidPage(

  # App title ----
  titlePanel("A first test"),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(

      # Input: Selector for variable to plot against mpg ----
      selectInput("var1", "x-axis:", c("Time" = "period_date",
                                       "Month" = "month",
                                       "Ratio" = "ratio"), selected = "period_date"),

      # Input: Selector for variable to plot against mpg ----
      selectInput("var2", "y-axis:", c("Degrees" = "degree_val",
                                       "Triangles" = "tri_no",
                                       "Ratio" = "ratio",
                                       "Betweeness" = "bet_val"), selected = "ratio"),
      
      # Input: Selector for variable to plot against mpg ----
      selectInput("var3", "Country:", sort(unique(all_info$node)), selected = "Germany")
      
    ),

    # Main panel for displaying outputs ----
    mainPanel(

      # Output: Plot of the requested variable against mpg ----
      plotOutput("mpgPlot")

    )
  )
)

# Define server logic to plot various variables against mpg ----



# Define server logic to plot various variables against mpg ----
server <- function(input, output) {
  
  # Generate a plot of the requested variable against mpg ----
  # and only exclude outliers if requested
  output$mpgPlot <- renderPlot({
    ggplot(all_info %>% filter(node == input$var3),aes_string(x=input$var1, y=input$var2)) + geom_point() + geom_line()
  })

}

shinyApp(ui, server)
