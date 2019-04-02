#  Development

## Image processing: 

### Using algorithms:
    - Use find contour bounds to get 3 images crops to get the cup best +
    - Use histogram/feature detection/or other to determine best image crop + ( histogram score: 7/10 )
    - Use multiple additional algorithms to get the subclasses for the image:
        * HU Moments ~ semi good. Might be used to determine the possition of the mugg in the image
        * Feature matching ~ not very good, either doesnt detect or it detects not relateable features
        * Image simple thresholding ??? (Not sure how to use) 
        * Image back propagation ??? (Not sure how to sue)
        * Image histogram compare on best bound and on whole image
        * Image grayscale histogram compare on best bound and on whole image
        * Use RGB overall values for random prediction ~ for this algorithm cut coffee images required
    - Use edge contours, grayscale, bounding contours, color range contours as animations to the original image during the processing 

## Project structure:

### Screens:
    - Mainscreen
        * Cool message on the top
        * Button for transition to the camera page
        * Button for transition to the settings (About) page
        
    - Camera page
        * ImageView to display the camera
        * Label/image/or ImageView animation to notify the user when the MLModel found coffee
        * Capture button ( Take photo + transition to the image processing page )
        
    - Processing page // With displaying the processing
        * Big imageView with animations ( not necessarily the Real processing animations but some cool looking anims )
        * Label/progression bar to notify the user of current processing progression
        
    - Fortune view 
        * Scroll View
        * ImageView with original image
        * Short description label
        * Long description about the fortune label
        * Share button top right??? (allows the user to share the image with the short fortune text)
        * Send like button on the bottom

## Additional assets:

### CoreTraingingAssets:
    - Make better recognition of coffee. Make a better guess if they are filled with coffee, out of coffee or clean muggs

### ComparingAssets:
    - Make assets with only coffee color from the top, side, angled
    - Make assets with clean coffee mug too aid the CoreML?
    - Make assets with better textures for comparison ???
    - Get background assets with coffee on them

## TODO:
    - Try to make better detection for the coffee color using OpenCV ( so we can remove the comparison and reduce the cpu stress )
    - if the above is successful then try to implement it for the backgrounds ( this will also reduce the cpu stress ) 
    - Acquisition of new images for the classifier and new images for the histogram bounds compare
    - Acquire images for background with coffee compare --- BIG MUST
    
## BUGS:
