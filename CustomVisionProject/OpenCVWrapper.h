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

@end

NS_ASSUME_NONNULL_END
