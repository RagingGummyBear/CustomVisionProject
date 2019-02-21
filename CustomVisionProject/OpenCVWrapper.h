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

+ (UIImage *) makeEdges: (UIImage *) image maxThreshold:(int)maxThreshold minThreshold:(int)minThreshold;
+ (NSMutableArray *) getRGBArray: (UIImage *) image;

+ (NSMutableArray *) extract_features: (UIImage *) image;

//+ (UIImage *) create_histogram_color: (UIImage *) image;
+ (NSMutableArray *) create_histogram_color: (UIImage *) image;
+ (UIImage *) generate_histograms: (UIImage *) image;
+ (UIImage *) generate_hs_histogram: (UIImage *) image;

+ (double) compareHistograms: (UIImage *) src withHistogramArray:(NSMutableArray *) compare;
+ (double) compareHistograms: (UIImage *) src withHistogram:(UIImage *) compare;
+ (double) compareHistograms: (UIImage *) src withImage:(UIImage *) compare;

+ (UIImage *) hist_and_Backproj: (UIImage *) image withX: (int) x withY: (int) y threshLow: (int) low threshUp: (int) up;

+ (UIImage *) find_contours: (UIImage *) image withThresh:(int) thresh;
+ (UIImage *) bounding_circles_squares: (UIImage *) image withThresh:(int) thresh;
+ (UIImage *) image_moments: (UIImage *) image withThresh:(int) thresh;

+ (UIImage *) contours_bounding_circles_squares: (UIImage *) image withThresh:(int) thresh;

+ (UIImage *) draw_contour_python: (UIImage *) image withThresh:(int) thresh;
+ (UIImage *) draw_contour_python_bound_square: (UIImage *) image withThresh:(int) thresh;
+ (NSMutableArray *) contour_python_bound_square: (UIImage *) image withThresh:(int) thresh;


@end

NS_ASSUME_NONNULL_END
