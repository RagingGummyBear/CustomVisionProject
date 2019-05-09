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

+ (UIImage *) bounding_circles_squares: (UIImage *) image withBound:(CGRect) bound withThresh:(int) thresh;

+ (NSMutableArray *) find_rgb_values: (UIImage *) image withBound: (CGRect) bound;
+ (NSMutableArray *) find_rgb_values: (UIImage *) image;

+ (UIImage *) draw_color_mask: (UIImage *) image withBound:(CGRect) bound;
+ (UIImage *) draw_color_mask_reversed: (UIImage *) image withBound:(CGRect) bound;
+ (UIImage *) draw_color_mask_reversed_void: (UIImage *) image withBound:(CGRect) bound;

+ (UIImage *) find_contours: (UIImage *) image withThresh:(int) thresh;
+ (UIImage *) find_contours: (UIImage *) image withBound:(CGRect) bound withThreshold:(int) max_thresh;

+ (UIImage *) get_color_content: (UIImage *) image;
+ (UIImage *) get_color_content_with_range: (UIImage *) image withLowRange: (NSMutableArray *) lowVector withHighRange: (NSMutableArray *) highVector;

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
