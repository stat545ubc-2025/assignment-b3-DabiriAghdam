library(shiny)
library(tidyverse)
library(datateachr)
library(ggplot2)
library(DT)
library(colourpicker)

# Create a cleaner dataset (adapted from mini-data-analysis repository)
cancer_data <- datateachr::cancer_sample %>%
  dplyr::select(ID, diagnosis, radius_mean, texture_mean, area_mean, perimeter_mean, smoothness_mean, compactness_mean) %>%
  dplyr::mutate(area_to_radius_ratio = area_mean / radius_mean) %>%
  dplyr::mutate(texture_mean_category = dplyr::case_when(
    texture_mean < stats::quantile(texture_mean, 1/3) ~ "Low",
    texture_mean < stats::quantile(texture_mean, 2/3) ~ "Medium",
    TRUE ~ "High"
  ) %>% factor(levels = c("Low", "Medium", "High"), ordered = TRUE)) %>%
  dplyr::mutate(diagnosis = factor(diagnosis, 
                            levels = c("B", "M"),
                            labels = c("B", "M"))) %>%
  dplyr::filter(!dplyr::if_any(dplyr::everything(), is.na)) %>%
  dplyr::distinct()

# Define UI for application
ui <- fluidPage(

    # Include custom CSS
  includeCSS("www/styles.css"),
  
  # Application title
  titlePanel("TumorViz: Cancer Tumor Explorer"),
  
  # Sidebar with inputs for variable selection
  sidebarLayout(

    # Feature one: Scatter plot of selected variables
    sidebarPanel(
      h4("Filter Options"),
      checkboxGroupInput("selected_diagnosis", "Diagnosis Type:",
                    choices = c("Benign (B)" = "B", "Malignant (M)" = "M"),
                    selected = c("B", "M")),
      h5(strong("Variable Selection:")),
      selectInput("x_var", "First variable:",
                  choices = c("radius_mean", "texture_mean", "area_mean", "perimeter_mean", "smoothness_mean", "compactness_mean", "area_to_radius_ratio"),
                  selected = "radius_mean"),
      selectInput("y_var", "Second variable:",
                  choices = c("radius_mean", "texture_mean", "area_mean", "perimeter_mean", "smoothness_mean", "compactness_mean", "area_to_radius_ratio"),
                  selected = "area_mean"),
      checkboxInput("show_regression", "Show regression line", value = FALSE),
      uiOutput("sliders"),
      textOutput("summary"),
      actionButton("reset_filters", "Reset Filters", style = "padding: 4px 8px; font-size: 12px;"),
      conditionalPanel(
        condition = "input.tabs == 'Plot'",
        h4("Plot Customization"),
        actionButton("reset_plot", "Reset Customizations", style = "padding: 4px 8px; font-size: 12px;"),
        checkboxInput("x_log", "X-axis log scale", value = FALSE),
        checkboxInput("y_log", "Y-axis log scale", value = FALSE),
        h5(strong("Benign (B):")),
        colourInput("color_benign", "Color:", value = "#00BCD4"),
        sliderInput("alpha_benign", "Transparency:", min = 0.1, max = 1, value = 1, step = 0.1),
        sliderInput("size_benign", "Point size:", min = 1, max = 10, value = 1, step = 0.5),
        h5(strong("Malignant (M):")),
        colourInput("color_malignant", "Color:", value = "#F8766D"),
        sliderInput("alpha_malignant", "Transparency:", min = 0.1, max = 1, value = 1, step = 0.1),
        sliderInput("size_malignant", "Point size:", min = 1, max = 10, value = 1, step = 0.5),
        checkboxInput("minimal_theme", "Minimal theme", value = TRUE),
        downloadButton("downloadPlot", "Download Plot (PNG)")
      ),
      conditionalPanel(
        condition = "input.tabs == 'Table'",
        h4("Table Options"),
        actionButton("reset_table", "Reset Options", style = "padding: 4px 8px; font-size: 12px;"),
        checkboxGroupInput("selected_columns", "Columns to display:",
                           choices = c("ID", "diagnosis", "radius_mean", "texture_mean", "area_mean", "perimeter_mean", "smoothness_mean", "compactness_mean", "area_to_radius_ratio", "texture_mean_category"),
                           selected = c("ID", "diagnosis", "area_mean", "texture_mean_category")),
        downloadButton("downloadData", "Download Filtered Data (CSV)")
      )
    ),
    
   
    mainPanel(
      # Header image
      div(style = "text-align: center; margin-bottom: 0px;",
          img(src = "tumorviz_header.jpeg", width = "99%", style = "max-width: 800px; border-radius: 5px;")
      ),

      h3("TumorViz"),
      p("TumorViz is an interactive visualization tool for exploring a cleaned subset of Wisconsin Breast Cancer dataset (available in `datateachr` package). The app allows you to investigate relationships between various tumor characteristics (radius, area, etc.) and diagnosis outcomes (benign or malignant). Use the sidebar to filter by diagnosis type, select which variables to plot on each axis, apply log transformations if needed, adjust value ranges to focus on specific regions of interest, and customize point colors. The Plot tab displays your customized scatter plot, while the Table tab shows the filtered dataset based on your current selections, along with summary statistics. You can also download the filtered data as a PNG/CSV file."),
      tabsetPanel(id = "tabs",
        tabPanel("Plot",
                 plotOutput("scatterPlot")
        ),
        tabPanel("Table",
                 dataTableOutput("dataTable")
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {

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
      dplyr::filter(!!sym(input$x_var) >= input$x_range[1] & !!sym(input$x_var) <= input$x_range[2] &
             !!sym(input$y_var) >= input$y_range[1] & !!sym(input$y_var) <= input$y_range[2] &
             diagnosis %in% input$selected_diagnosis)
  })

  # Feature one: Scatter plot of selected variables
  plot_obj <- reactive({
    x_label <- if (input$x_log) paste("log10(", input$x_var, ")") else input$x_var
    y_label <- if (input$y_log) paste("log10(", input$y_var, ")") else input$y_var
    p <- ggplot2::ggplot(filtered_data(), ggplot2::aes_string(x = input$x_var, y = input$y_var, color = "diagnosis", alpha = "diagnosis", size = "diagnosis")) +
      ggplot2::geom_point() +
      ggplot2::labs(title = paste(input$x_var, "vs", input$y_var, "by diagnosis"),
           x = x_label, y = y_label)
    if (input$x_log) p <- p + ggplot2::scale_x_log10()
    if (input$y_log) p <- p + ggplot2::scale_y_log10()
    p <- p + ggplot2::scale_color_manual(values = c("B" = if(is.null(input$color_benign)) "#00BCD4" else input$color_benign,
                                           "M" = if(is.null(input$color_malignant)) "#F8766D" else input$color_malignant))
    p <- p + ggplot2::scale_alpha_manual(values = c("B" = input$alpha_benign, "M" = input$alpha_malignant))
    p <- p + ggplot2::scale_size_manual(values = c("B" = input$size_benign, "M" = input$size_malignant))
    if (input$minimal_theme) p <- p + ggplot2::theme_minimal()
    if (input$show_regression) p <- p + ggplot2::geom_smooth(method = "lm", se = FALSE, linewidth = 1)
    p
  })
  output$scatterPlot <- renderPlot({
    suppressWarnings(plot_obj()) # Suppress warnings??
  })

  # Reset observers
  observeEvent(input$reset_filters, {
    updateCheckboxGroupInput(session, "selected_diagnosis", selected = c("B", "M"))
    x_min <- min(cancer_data[[input$x_var]], na.rm = TRUE)
    x_max <- max(cancer_data[[input$x_var]], na.rm = TRUE)
    y_min <- min(cancer_data[[input$y_var]], na.rm = TRUE)
    y_max <- max(cancer_data[[input$y_var]], na.rm = TRUE)
    updateSliderInput(session, "x_range", value = c(x_min, x_max))
    updateSliderInput(session, "y_range", value = c(y_min, y_max))
  })

  observeEvent(input$reset_plot, {
    updateCheckboxInput(session, "x_log", value = FALSE)
    updateCheckboxInput(session, "y_log", value = FALSE)
    updateColourInput(session, "color_benign", value = "#00BCD4")
    updateColourInput(session, "color_malignant", value = "#F8766D")
    updateSliderInput(session, "alpha_benign", value = 1)
    updateSliderInput(session, "alpha_malignant", value = 1)
    updateSliderInput(session, "size_benign", value = 1)
    updateSliderInput(session, "size_malignant", value = 1)
    updateCheckboxInput(session, "minimal_theme", value = TRUE)
    updateCheckboxInput(session, "show_regression", value = FALSE)
  })

  observeEvent(input$reset_table, {
    updateCheckboxGroupInput(session, "selected_columns", selected = c("ID", "diagnosis", "area_mean", "texture_mean_category"))
  })

  # Feature two: Data table
  output$dataTable <- DT::renderDataTable({
    DT::datatable(filtered_data()[, input$selected_columns, drop = FALSE])
  })

  # Feature three: Summary statistics
  output$summary <- renderText({
    data <- filtered_data()
    malignant_count <- sum(data$diagnosis == "M")
    benign_count <- sum(data$diagnosis == "B")
    total_count <- nrow(data)
    paste("Total filtered data count:", total_count, "; malignant", malignant_count, "and benign", benign_count, "tumors.")
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
      ggplot2::ggsave(file, plot = plot_obj(), device = "png")
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)