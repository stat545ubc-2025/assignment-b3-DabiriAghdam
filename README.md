[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/h1fiJa_i)

# TumorViz: Cancer Tumor Explorer

## Description

TumorViz is an interactive R Shiny application for exploring a cleaned subset of Wisconsin Breast Cancer dataset (`cancer_sample` dataset from `datateachr` package). The app enables users to investigate relationships between various tumor characteristics (radius, area, etc.) and diagnosis outcomes (benign or malignant) through a scatter plot and a table view.

<p align="center">
<img width="70%" alt="image" src="https://github.com/user-attachments/assets/636bcdec-b059-45aa-b925-4682c8102958" />
</p>

## Features

This Shiny app includes the following three main features:

### FEATURE 1: Interactive Scatter Plot
A dynamic scatter plot that updates based on user input. Users can:
- Select X and Y axis variables from dropdown menus
- Apply log scale transformations to either axis
- Customize colors for diagnosis groups
- Download the plot as a PNG file

### FEATURE 2: Interactive Data Table
A filterable data table that updates dynamically with user selections. Users can:
- Choose which columns to display in the table
- View only the data that matches the current filter criteria
- Download the filtered data as a CSV file

### FEATURE 3: Tab-based interface
- Plot and data table are organized in separate tabs for better user experience (UX)
- Plot and table options only appear when their respective tabs are active (the app has dynamic UI elements)

## Additional Features
Beyond the main features above, this app also includes:
- **Diagnosis filtering**: Checkbox inputs to filter by benign and/or malignant samples
- **Summary statistics**: Automatic display of number of results found after filtering for each diagnosis group, in a css-styled textbox.
- **Custom CSS styling**: Professional appearance with custom color scheme and styling
- **Header image**: Visual enhancement with a data visualization themed header image
- **Other**: Many other small details added to improve UX

## How to Use
1. **Filter by Diagnosis**: Use the checkboxes to include or exclude benign and malignant samples
2. **Select Variables**: Choose which measurements to display on the X and Y axes
3. **Adjust Ranges**: Use the sliders to filter data within specific value ranges
4. **Customize Visualization** (Plot tab): 
   - Toggle log scales for better visualization of skewed data
   - Choose custom colors for each diagnosis group (+ size and transparency of each data point)
   - Switch between minimal and standard themes
5. **Explore Data** (Table tab): 
   - Select which columns to view in the table
   - Search for specific values using the search box
   - Sort by your column of choice (ascending or descending)
6. **Download**: Export your customized plot or filtered data for further analysis

## Running the App

You can access the deployed app at: [https://dabiriaghdam.shinyapps.io/TumorViz/](https://dabiriaghdam.shinyapps.io/TumorViz/)

To run locally:

The analysis relies on the following R packages:

 `shiny`,  `tidyverse`,  `datateachr`,  `DT`,  `ggplot2`,  `colourpicker`

Ensure these packages are installed before running the app (shiny::runApp()).

## Files in this Repository

- `app.R`: Main application file containing UI and server logic
- `www/`: Directory containing static assets (Custom CSS styling for the app and header image)
- `README.md`: This file
- `GenAI_Statement.md`: Statement of generative AI use and reflection on it (as required)

## Author

Amirhossein Dabiriaghdam  

Created for STAT 545B Assignment B3

If you have any questions or issues, please feel free to reach out to me by raising an issue on GitHub.

