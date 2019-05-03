//
//  OpenCVWrapper.h
//  OpenCVTutorial
//
//  Created by Seavus on 2/8/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (NSString *)openCVVersionString;

+ (UIImage *) makeGray: (UIImage *) image;

+ (UIImage *) bounding_circles_squares: (UIImage *) image withThresh:(int) thresh;

+ (double) compareUsingContoursMatch: (UIImage *) src withImage:(UIImage *) compare;

+ (UIImage *) bounding_circles_squares: (UIImage *) image withBound:(CGRect) bound withThresh:(int) thresh;

+ (NSMutableArray *) find_rgb_values: (UIImage *) image withBound: (CGRect) bound; // USING
+ (NSMutableArray *) find_rgb_values: (UIImage *) image; // USING

+ (UIImage *) draw_color_mask: (UIImage *) image withBound:(CGRect) bound; // USING
+ (UIImage *) draw_color_mask_reversed: (UIImage *) image withBound:(CGRect) bound; // USING
+ (UIImage *) draw_color_mask_reversed_void: (UIImage *) image withBound:(CGRect) bound;

+ (UIImage *) find_contours: (UIImage *) image withThresh:(int) thresh; // USING
+ (UIImage *) find_contours: (UIImage *) image withBound:(CGRect) bound withThreshold:(int) max_thresh; // USING

+ (double) compareUsingHistograms: (UIImage *) src withImage:(UIImage *) compare; // USING
+ (double) compareUsingGrayScaleHistograms: (UIImage *) src withImage:(UIImage *) compare; // USING
+ (double) compareUsingHistograms: (UIImage *) src withBound:(CGRect) bound withImage:(UIImage *) compare; // USING

+ (double) compareUsingHistograms: (UIImage *) src withBound:(CGRect) bound withImage:(UIImage *) compare withBound:(CGRect) comapreBound; // USING, Maybe in future - expected use in background compare with coffee

+ (NSMutableArray *) contour_python_bound_square: (UIImage *) image withThresh:(int) thresh; // USING

+ (UIImage *) get_color_content: (UIImage *) image; // TESTING
+ (UIImage *) get_color_content_with_range: (UIImage *) image withLowRange: (NSMutableArray *) lowVector withHighRange: (NSMutableArray *) highVector; // TESTING

//+ (NSString *) get_color_content_class: (UIImage *) image withLowRange: (NSMutableArray *) lowVector withHighRange: (NSMutableArray *) highVector; // TESTING


+ (NSString *) find_contours_count: (UIImage *) image withBound:(CGRect) bound withThreshold:(int) max_thresh;


+ (NSString *) get_yeeted: (UIImage *) image withBound:(CGRect) bound;
+ (int) get_contour_size_light: (UIImage *) image withBound:(CGRect) bound;
+ (int) get_contour_size_casual: (UIImage *) image withBound:(CGRect) bound;
+ (int) get_contour_size_dark: (UIImage *) image withBound:(CGRect) bound;
+ (int) get_contour_size_fancy: (UIImage *) image withBound:(CGRect) bound;
+ (float) get_color_contour_size: (UIImage *) image withBound:(CGRect) bound withLowRange: (NSMutableArray *) lowVector withHighRange: (NSMutableArray *) highVector;

+ (NSString *) get_yeeted_background: (UIImage *) image withBound:(CGRect) bound;
+ (int) get_contour_size_background_red: (UIImage *) image withBound:(CGRect) bound;
+ (int) get_contour_size_background_green: (UIImage *) image withBound:(CGRect) bound;
+ (int) get_contour_size_background_blue: (UIImage *) image withBound:(CGRect) bound;
+ (int) get_contour_size_background_white: (UIImage *) image withBound:(CGRect) bound;
+ (int) get_contour_size_background_brown: (UIImage *) image withBound:(CGRect) bound;
+ (int) get_contour_size_background_dark: (UIImage *) image withBound:(CGRect) bound;
+ (float) get_color_contour_sizeR: (UIImage *) image withBound:(CGRect) bound withLowRange: (NSMutableArray *) lowVector withHighRange: (NSMutableArray *) highVector;

+ (UIImage *) get_color_contour_sizeRR: (UIImage *) image withBound:(CGRect) bound withLowRange: (NSMutableArray *) lowVector withHighRange: (NSMutableArray *) highVector;
+ (UIImage *) get_color_contour_sizeM: (UIImage *) image withBound:(CGRect) bound withLowRange: (NSMutableArray *) lowVector withHighRange: (NSMutableArray *) highVector;

@end

NS_ASSUME_NONNULL_END
