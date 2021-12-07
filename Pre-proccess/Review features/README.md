# Hand_IRT_Auto_Ecxtraction Main Repository

This repository includes code, written mostly in MATLAB to help in performing some pre-proccessing of palm images in order to get usefull data fore forther analysis.
In this case, usefull data is the intence, entropy, histogram etc. of certain Region Of Interence (ROI) taken from the hand images.
Fof this project the hand ROIs are:
  - Finger tips for all five fingers
  - Finger base for all five fingers
  - Palm arche
  - Palm center square

The repository includes two folders:
1. Pre-proccess
    
    That includes 2 sub-folders:
		- The **Main** should be used in order to extract the usefull data from the ROIs.
		- The **Review features** folder  should be used to review the features extracted from the images. see further details below.
3. Feature-Analysis (Curerntly not in used and therfore not described)

## Pre-proccess- Review features
This folder includes some code that helps to review in a simple GUI the ROIs extracted from the IRF images.

**Instructions:**
1. Run the main GUI by running plotFeatures.m
2. This will open the following GUI


![alt text](https://github.com/mullerido/Hand_IRT_Auto_Ecxtraction/blob/master/Pre-proccess/Review%20features/plot_features_main_gui.png)

3. Use this GUI by:
  - 
