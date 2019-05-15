#  Development

## Image processing: 

### Using algorithms:

    
### Classes detected:


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

### TODO:
    - Logo
    - Improve the text generator

## Future:
    - Use persistent storage. Lower the memory usage by saving the UIImage in the persistent storage with 3 stages (High quality, Medium quality, and thumbnail)
    - Save to persistent storage liked photos with the found classes for it
    - Make a view to display all of the previous liked photos
