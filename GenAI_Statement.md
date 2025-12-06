# Generative AI Use Statement

## Prompts Used

Below is a list of prompts I provided to the Gen AI chatbot (Grok) while creating this Shiny app:

### Enhancing Core Functionality
- I’m building a Shiny app that creates a plot and also has a table view. Here is my code: [...] Can you help me add checkboxes to choose the columns of the table so the table doesn't expand outside of screen.
- I want the user to be able to choose the color of the points using shinnyjs:colourinput, but I cannot make it work I am getting this warning: `colourInput() has been moved to the 'colourpicker' package.`
- I want to add a checkbox for each diagnonsis to filter them. Where should I change in this code: [...]
- Now, I want to add a checkbox for log scale for each axis. I have this code but it is not working. What should I change in this code: [...]
- I am currently using tabset panels. can you change the code such that the table options are only visible when the user clicks on the data table tab? Also the log scale, color options should only be visible when in plot tab.

### Technical Troubleshooting
- I have this code for a table but I don't see any tables and see no erros: [...]
- Can you help me with this error in my shiny app:`Error: Insufficient values in manual scale. 2 needed but only 0 provided.`
- Here is my code to add a color picker, it shows up but when I select a color nothing happens: [...]
- what is `reactive` in the context of Shiny R apps?
- I'm trying to add a download button for my plot. Why can't we directly use `output$scatterPlot`, I am getting this error about `reactive`: [...]
- What does this error mean? `Error in observe: object 'session' not found`
- Help me troubleshoot this warning: `Warning in file(con, 'r') : cannot open file 'styles.css': No such file or directory`
- I am using `includeCSS()` function, but I see no visual changes. For example, I changed the fontsize of `summary` to 20 in CSS file but nothing changes! Help me: [...]
- it seems like the changes to css takes effect with a delay, why is that the case?
- Help me understand and resolve these warnings: `Warning: No shared levels found between names(values) of the manual scale and the data's colour values.`, `Warning: No shared levels found between names(values) of the manual scale and the data's alpha values.`, `Warning: No shared levels found between names(values) of the manual scale and the data's size values.`

### Adding Customization Features
- can you help me add a second slider that adjusts the transparency of the points?
- How to add a reset button for filter options, plot costumizaotions and table options
- How to make my buttons smaller, here is the related code: [...]

### Organizing UI
- how to swap the colors of benign and malignant classes here in this plot: [...]
- I was familiar with css files in high school. Can you remind me of it structure?

### Image Generation
-  I think I can include an image to make our app more visually appealing. can you generate an image headr for this code: [...]

## Reflection on Gen AI Use

Using Gen AI changed how I worked on this assignment. It let me use a so-called "vibe coding" style, where I focused on the overall design and user experience while the AI handled most of the technical coding details. This helped me prototype ideas quickly and build a polished app much faster than with traditional coding based on documentation.

This method kept me in a creative mindset instead of worrying about syntax. I could try features like log-scale axes, conditional panels, and custom color pickers without fully understanding all the technical parts at the beginning. The process was iterative: I described a feature that I didn't know how to implement, learned how to implement it from the AI, tested it, and improved it through follow-up prompts.

Even though the AI wrote much of the code, I still learned Shiny development by reading the code and asking questions. I stayed critical and did not just accept every suggestion. For example, I compared `textOutput()` and `verbatimTextOutput()` to see which worked better for showing summary statistics. Also, regarding a few warnings (about no shared levels), AI suggested to just suppress them, which I was skeptical. At first I added the suggested warning suppress code but then commented it out. Overall, I made my own decisions about which features to add, which code to use, how to structure the UI, and how to improve the user experience. The AI was a tool, but I was still in control.

Sometimes the AI’s solutions did not work right away, such as problems with CSS file paths, etc. Troubleshooting these issues forced me to understand the underlying problems instead of just copying and pasting. These challenges actually helped me learn more.

I also used AI beyond coding, asking it to create a header image for TumorViz. It generated an abstract data visualization with blue and red scatter points that matched the theme of my app and made it look more professional.