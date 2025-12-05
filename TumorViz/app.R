library(shiny)
library(datateachr)

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
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      
    ),
    
   
    mainPanel(
      h3("TumorViz"),
      p("TumorViz is an interactive visualization tool for exploring a cleaned subset of Wisconsin Breast Cancer dataset (available in `datateachr` package). The app allows you to investigate relationships between various tumor characteristics (radius, area, etc.) and diagnosis outcomes (benign or malignant)."),
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
}

# Run the application 
shinyApp(ui = ui, server = server)