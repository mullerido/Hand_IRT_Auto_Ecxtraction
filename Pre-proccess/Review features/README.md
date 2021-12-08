# Pre-proccess- Review features
This folder includes some code that helps to review in a simple GUI the ROIs extracted from the IRF images.

**Instructions:**
1. Run the main GUI by running plotFeatures.m
2. This will open the following GUI


![alt text](https://github.com/mullerido/Hand_IRT_Auto_Ecxtraction/blob/master/Pre-proccess/Review%20features/plot_features_main_gui.png)

3. Use this GUI by:
  - Add the path into the text box that includes the features xlsx files. Each subject shold have seperate file that includes times and relevant features.
  - Press 'Load' in order to load all xlsx files into the files drop-down window
  - From the drop down window, choose the desired subject feature file
  - From the hand image, choose the desired ROIs. By default, they are all marked, remove the mark from the ROI you wish to ignore or use the 'dist'/ 'proxy' radio button to mark/ unmark from ROIs from all fingers at ones.
  - Mark 'Use Moving Average' if you want to use moving average to smooth the graphs.
  - Mark 'Zoom Per Image' to resize figure using default limits for the Y axis or per image.
  - Choose the feature you would like to review from the feature list: 
  	- Intensity
  	- Entropy
  	- Kurtosis
  	- Skeweness
  - Press 'Plot' to load the file and create the figure based on the choose parameters, as described above.
  - After loading the subject and ploting the first plot, you can change the choosen parameters and press the 'Refresh Fig.' in order to re-generate the figures using the new parameters.
  	Note: You must enter 'Plot' in order to change figure between subject.
  - Press 'Save Fig.' to save the current viewed figures.
