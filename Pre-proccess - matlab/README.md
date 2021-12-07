# Hand_IRT_Auto_Ecxtraction Main Repository

This repository includes code, written mostly in MATLAB to help in performing some pre-proccessing to palm images in order to get usefull data fore forther analysis.
In this case, usefull data is the intence, entropy, histogram etc. of certain Region Of Interence (ROI) taken from the hand images.
Fof this project the hand ROIs are:
  - Finger tips for all five fingers
  - Finger base for all five fingers
  - Palm arche
  - Palm center square

The repository includes two folders:
1. Pre-proccess - matlab
    
    That includes 2 sub-folders. The **Main** folder is the one that should be used
3. Feature-Analysis- matlab (Curerntly not in used and therfore not described)

## Pre-proccess
This (main) folder includes some code that helps to preform segmentation and registration to a plam images. The segmentation should seperate between the fingeres and palm. The registration phase assumed that the segmented image is the first image in a series of match images. 

**Instructions:**
1. Run the main GUI by running RunExtractHandFeatures.m
2. This will open the following GUI


![alt text](https://github.com/mullerido/Hand_IRT_Auto_Ecxtraction/blob/master/Run%20Extract%20Hand%20Features-fig.png)

3. Use this GUI by:
  - Step I- Baseline image segmentation:
    - Entering palm image full path by copying the path or by pressing the 'Browse' button. 
      For example, try to use the path of the example image found inside '\Pre-proccess - matlab' folder:
      C:path\Pre-proccess - matlab\Demo_hand_image_left_1.jpg
    
      *Note:*
        
        *1. Make sure to use valid path- not including " or '.*
        
        *2. Choosing an imge using the browse buttom will open the original image inside a small figure on the top-right corner.* 
        
    - Pres 'Load image' button to load the image.
      This will load the original image, once as RGB image in the upper right corner and second time as a grey scale image in the center. 
    
    - Press the 'Auto segmentation' button to :
        - Segment the palm and fingeres from the background
        - Seperate between the fingeres and palm
         
      After this process the main grey scale image with BW image and a another image with the seperated palm (in red) and fingeres (in blue) should appear below.
    
    - 'Done' should appear to announce that the segmentation is done.
    
    *Note: The segmentation process may not success in seperating the palm and fingere from the original image. A refinment may be required.*
    
  
  -  Step II- Segmentation refining:
      -  Use the sliders to adjust the region of the fingers and palm.
      -  Rotate the image in case the auto-rotation did not suceed in rotating the image.
      -  Use the arrows to crop the image. 
        For example, pressing the right arrow will 'clear' the image from the right. This may help to re-do the auto segmentation process. Mainly in cases where the image include distruptions.
      - Press the 'Reset' button to revert the changes.
    
  - Step III- Get ROI:   
    - Press 'Find ROIs' to try and automaticaly find the relevant ROIs:
      - 5 circles on the fingers tips (proximal)
      - 5 circles on the finger base (distal)
      - One square in the center of the palm
      - One arche located above the centered square and below the fingers
      
      The ROIs will apear in the left bottom corner.
     
     *Note: The code may failed to find all 12 ROIs. In that case use the hand image and choose the desired ROI on that image. This will open the image with an option to choose the center of the choosen ROI. Pressing on the center of the ROI will close the image and create the best fit circle match to that ROI. Make sure to choose the right ROI and not confused between right and left hand. The choosen ROI will appear in the left bottom corner*
    
    - Press "Manual ROI' to open a GUI (see below) that allow the user to choose and sign the ROIs including to the ability to define the ROI radius (in case of fingers ROI). Press 'Save & Close' to save changes to ROIs. 


      ![alt text](https://github.com/mullerido/Hand_IRT_Auto_Ecxtraction/blob/master/Manual%20ROI%20Selection-%20Fig.png)
    
    - Press 'Extract Feature' to get all ROIs features and put them inside one table:
      - Average intence
      - Entropy
      - Kurtosis
      - Skewness
      - Histogram   
    
    -  Press 'Registration' button to start the registration over all other relevant hand images. The assumption is that the first image that was segmented, located inside a folder that includes more hand images that have same named with with continuos number. For example, segmenting the example image (Demo_hand_image_left_1) in the segmentation phase will open the registration GUI (see image below) with the second example image (Demo_hand_image_left_2). The GUI allows you to:
        -   Rotate the new image
        -   Crop the image using the arrows
        -   Run registration button- this will register the new image and align it with the bseline image. It will automatically sign all ROIs inside the new image after registartion.
        -   Extract feature button- to get all ROIs features and put them inside the same table
        -   Move to the next image button
        -   Approve & Next button- to extract all features and continue to the next image by pressing one button
        -   Manual ROI button- to open the manual ROI GUI in the new image
        -   Save feature button- to save the feature table inside the same directory as the images.


 ![alt text](https://github.com/mullerido/Hand_IRT_Auto_Ecxtraction/blob/master/Run%20Registration-%20Fig.png)
 
 Good luck!

