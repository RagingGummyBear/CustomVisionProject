#  Development

## Image processing: 

### Using algorithms:
    - Use find contour bounds to get 3 images crops to get the cup best +
    - Use histogram/feature detection/or other to determine best image crop + ( histogram score: 7/10 )
    - Use multiple additional algorithms to get the subclasses for the image:
        * HU Moments ~ semi good. Might be used to determine the possition of the mugg in the image
        * Feature matching ~ not very good, either doesnt detect or it detects not relateable features
        * Image simple thresholding ??? (Not sure how to use) 
        * Image histogram compare on best bound and on whole image
        * Image grayscale histogram compare on best bound and on whole image
        * Use RGB overall values for random prediction ~ for this algorithm cut coffee images required
    - Use edge contours, grayscale, bounding contours, color range contours as animations to the original image during the processing 
    
### Classes detected:

    - Coffee color density
    - Background color
    - Coffee texture complexity
    - Coffee position in the image // based of the drawing bound
    - Coffee bound size // based of drawing bound size
    - RGB in the whole image // a random factor
    - RGB in the bound image // abit less random factor ( r > g > b bias )

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
        * Like + share buttons

## Additional assets:

### CoreTraingingAssets:
    - Make better recognition of coffee.
    - Requires images from far, angled and different cup color 

## TODO:
    - Acquire images for better coffee recognition
    - Fix the quotes to change on swipe
    - Fix the memory leak UGH!!!
## BUGS:
