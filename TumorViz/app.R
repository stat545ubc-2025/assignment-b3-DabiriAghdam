library(shiny)
library(tidyverse)
library(datateachr)
library(ggplot2)
library(DT)
library(colourpicker)

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
      checkboxGroupInput("selected_diagnosis", "Filter by diagnosis:",
                    choices = c("B" = "B", "M" = "M"),
                    selected = c("B", "M")),
      selectInput("x_var", "First variable:",
                  choices = c("radius_mean", "texture_mean", "area_mean", "perimeter_mean", "smoothness_mean", "compactness_mean", "area_to_radius_ratio"),
                  selected = "radius_mean"),
      selectInput("y_var", "Second variable:",
                  choices = c("radius_mean", "texture_mean", "area_mean", "perimeter_mean", "smoothness_mean", "compactness_mean", "area_to_radius_ratio"),
                  selected = "area_mean"),
      uiOutput("sliders"),
      checkboxInput("x_log", "Log scale for X-axis", value = FALSE),
      checkboxInput("y_log", "Log scale for Y-axis", value = FALSE),
      colourInput("color_benign", "Benign (B) color:", value = "#00BCD4"),
      colourInput("color_malignant", "Malignant (M) color:", value = "#F8766D"),
      checkboxInput("minimal_theme", "Use minimal theme", value = TRUE),
      textOutput("summary"),
      checkboxGroupInput("selected_columns", "Columns to display:",
                         choices = c("ID", "diagnosis", "radius_mean", "texture_mean", "area_mean", "perimeter_mean", "smoothness_mean", "compactness_mean", "area_to_radius_ratio", "texture_mean_category"),
                         selected = c("ID", "diagnosis", "area_mean", "texture_mean_category")),
      downloadButton("downloadData", "Download Filtered Data as CSV")
    ),
    
   
    mainPanel(
      h3("TumorViz"),
      p("TumorViz is an interactive visualization tool for exploring a cleaned subset of Wisconsin Breast Cancer dataset (available in `datateachr` package). The app allows you to investigate relationships between various tumor characteristics (radius, area, etc.) and diagnosis outcomes (benign or malignant). Use the sidebar to filter by diagnosis type, select which variables to plot on each axis, apply log transformations if needed, adjust value ranges to focus on specific regions of interest, and customize point colors. The Plot tab displays your customized scatter plot, while the Data Table tab shows the filtered dataset based on your current selections, along with summary statistics. You can also download the filtered data as a PNG/CSV file."),
      plotOutput("scatterPlot"),
      downloadButton("downloadPlot", "Download Plot as PNG"),
      dataTableOutput("dataTable"),
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
    req(input$x_range, input$y_range, input$selected_diagnosis)
    cancer_data %>%
      filter(!!sym(input$x_var) >= input$x_range[1] & !!sym(input$x_var) <= input$x_range[2] &
             !!sym(input$y_var) >= input$y_range[1] & !!sym(input$y_var) <= input$y_range[2] &
             diagnosis %in% input$selected_diagnosis)
  })

  # Feature one: Scatter plot of selected variables
  plot_obj <- reactive({
    x_label <- if (input$x_log) paste("log10(", input$x_var, ")") else input$x_var
    y_label <- if (input$y_log) paste("log10(", input$y_var, ")") else input$y_var
    p <- ggplot(filtered_data(), aes_string(x = input$x_var, y = input$y_var, color = "diagnosis")) +
      geom_point() +
      labs(title = paste("Plot of", input$x_var, "vs", input$y_var),
           x = x_label, y = y_label)
    if (input$x_log) p <- p + scale_x_log10()
    if (input$y_log) p <- p + scale_y_log10()
    p <- p + scale_color_manual(values = c("B" = if(is.null(input$color_benign)) "#00BCD4" else input$color_benign,
                                           "M" = if(is.null(input$color_malignant)) "#F8766D" else input$color_malignant))
    if (input$minimal_theme) p <- p + theme_minimal()
    p
  })
  output$scatterPlot <- renderPlot({
    plot_obj()
  })

  # Feature two: Data table
  output$dataTable <- renderDataTable({
    datatable(filtered_data()[, input$selected_columns, drop = FALSE])
  })

  # Feature three: Summary statistics
  output$summary <- renderText({
    data <- filtered_data()
    malignant_count <- sum(data$diagnosis == "M")
    benign_count <- sum(data$diagnosis == "B")
    total_count <- nrow(data)
    paste("We found", malignant_count, "malignant and", benign_count, "benign tumors ( total", total_count, ").")
  })

  # Download handler
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("filtered_tumor_data_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(filtered_data()[, input$selected_columns, drop = FALSE], file, row.names = FALSE)
    }
  )

  # Download plot
  output$downloadPlot <- downloadHandler(
    filename = function() {
      paste("plot_", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      ggsave(file, plot = plot_obj(), device = "png")
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)