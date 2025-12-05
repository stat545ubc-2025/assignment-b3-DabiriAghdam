library(shiny)
library(datateachr)
library(ggplot2)
library(DT)

# Create a cleaner dataset (adapted from mini-data-analysis repository)
cancer_data <- cancer_sample %>%
  select(ID, diagnosis, radius_mean, texture_mean, area_mean, perimeter_mean, smoothness_mean, compactness_mean) %>%
  mutate(area_to_radius_ratio = area_mean / radius_mean) %>%
  mutate(texture_mean_category = case_when(
    texture_mean < quantile(texture_mean, 1/3) ~ "Low",
    texture_mean < quantile(texture_mean, 2/3) ~ "Medium",
    TRUE ~ "High"
  ) %>% factor(levels = c("Low", "Medium", "High"), ordered = TRUE)) %>%
  mutate(diagnosis = factor(diagnosis, 
                            levels = c("B", "M"),
                            labels = c("B", "M"))) %>%
  filter(!if_any(everything(), is.na)) %>%
  distinct()

# Define UI for application
ui <- fluidPage(
  
  # Application title
  titlePanel("TumorViz: Cancer Tumor Explorer"),
  
  # Sidebar with inputs for variable selection
  sidebarLayout(

    # Feature one: Scatter plot of selected variables
    sidebarPanel(
      selectInput("x_var", "First variable:",
                  choices = c("radius_mean", "texture_mean", "area_mean", "perimeter_mean", "smoothness_mean", "compactness_mean", "area_to_radius_ratio"),
                  selected = "radius_mean"),
      selectInput("y_var", "Second variable:",
                  choices = c("radius_mean", "texture_mean", "area_mean", "perimeter_mean", "smoothness_mean", "compactness_mean", "area_to_radius_ratio"),
                  selected = "texture_mean"),
      uiOutput("sliders")
    ),
    
   
    mainPanel(
      h3("TumorViz"),
      p("TumorViz is an interactive visualization tool for exploring a cleaned subset of Wisconsin Breast Cancer dataset (available in `datateachr` package). The app allows you to investigate relationships between various tumor characteristics (radius, area, etc.) and diagnosis outcomes (benign or malignant)."),
      plotOutput("scatterPlot"),
      dataTableOutput("dataTable"),
      textOutput("summary")
    )
  )
)

# Define server logic
server <- function(input, output) {

  # Dynamic sliders for filtering
  output$sliders <- renderUI({
    req(input$x_var, input$y_var)
    x_min <- min(cancer_data[[input$x_var]], na.rm = TRUE)
    x_max <- max(cancer_data[[input$x_var]], na.rm = TRUE)
    y_min <- min(cancer_data[[input$y_var]], na.rm = TRUE)
    y_max <- max(cancer_data[[input$y_var]], na.rm = TRUE)
    tagList(
      sliderInput("x_range", paste("Range for", input$x_var), min = x_min, max = x_max, value = c(x_min, x_max), step = (x_max - x_min)/100),
      sliderInput("y_range", paste("Range for", input$y_var), min = y_min, max = y_max, value = c(y_min, y_max), step = (y_max - y_min)/100)
    )
  })

  # Filtered data reactive
  filtered_data <- reactive({
    req(input$x_range, input$y_range)
    cancer_data %>%
      filter(!!sym(input$x_var) >= input$x_range[1] & !!sym(input$x_var) <= input$x_range[2] &
             !!sym(input$y_var) >= input$y_range[1] & !!sym(input$y_var) <= input$y_range[2])
  })

  # Feature one: Scatter plot of selected variables
  output$scatterPlot <- renderPlot({
    ggplot(filtered_data(), aes_string(x = input$x_var, y = input$y_var, color = "diagnosis")) +
      geom_point() +
      labs(title = paste("Scatter plot of", input$x_var, "vs", input$y_var),
           x = input$x_var, y = input$y_var)
  })

  # Feature two: Data table
  output$dataTable <- renderDataTable({
    filtered_data()
  })

  # Summary statistics
  output$summary <- renderText({
    data <- filtered_data()
    malignant_count <- sum(data$diagnosis == "M")
    benign_count <- sum(data$diagnosis == "B")
    total_count <- nrow(data)
    paste("We found", malignant_count, "malignant and", benign_count, "benign tumors ( total", total_count, ")")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)