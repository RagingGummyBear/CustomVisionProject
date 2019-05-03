//
//  OpenCVWrapper.m
//  OpenCVTutorial
//
//  Created by Seavus on 2/8/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

#ifdef __cplusplus
#pragma cland diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import <opencv2/core.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc/imgproc.hpp>
#include <opencv2/features2d.hpp>

#pragma clang pop
#endif

using namespace std;
using namespace cv;

#pragma mark - Private Declarations

@interface OpenCVWrapper ()

#ifdef __cplusplus

#endif

@end

@implementation OpenCVWrapper

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (UIImage *) makeGray: (UIImage *) image {
    Mat inputImage; UIImageToMat(image, inputImage);
    if (inputImage.channels() == 1) return image;
    Mat gray; cvtColor(inputImage, gray, COLOR_BGR2GRAY);
    
    return MatToUIImage(gray);
}

+ (UIImage *) find_contours: (UIImage *) image withThresh:(int) thresh {
    // Consts //
    //    int thresh = 60;
    RNG rng(12345);
    ////////////
    
    Mat src; Mat src_gray; UIImageToMat(image, src);
    cvtColor( src, src_gray, COLOR_BGR2GRAY );
    blur( src_gray, src_gray, cv::Size(3,3) );
    
    Mat canny_output;
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    // Detect edges using canny
    Canny( src_gray, canny_output, thresh, thresh*2, 3 );
    
    // Find contours
    findContours( canny_output, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    Mat temp; cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR);
    
    // Draw contours
    Mat drawing = Mat::zeros( canny_output.size(), CV_8UC3 );
    
    // Scalar color = Scalar( 32, 194, 14); // HACKERGREEN
    Scalar color = Scalar( 248, 152, 30); // COFFEEBROWN
    for( int i = 0; i< contours.size(); i++ )
    {
        // Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( src, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
    }
    return MatToUIImage(src);
}

+ (double) compareUsingContoursMatch: (UIImage *) src withImage:(UIImage *) compare {
    Mat img_1; UIImageToMat(src, img_1);
    Mat img_2; UIImageToMat(compare, img_2);
    cvtColor(img_1, img_1, COLOR_BGR2RGB);
    cvtColor(img_2, img_2, COLOR_BGR2RGB);
    
    Mat src_blurred1; GaussianBlur(img_1, src_blurred1, cv::Size(5,5), 0);
    Mat src_blurred2; GaussianBlur(img_2, src_blurred2, cv::Size(5,5), 0);
    
    Mat hsv1; cvtColor( src_blurred1, hsv1, COLOR_BGR2HSV );
    Mat hsv2; cvtColor( src_blurred2, hsv2, COLOR_BGR2HSV );
    
    Vec3b lowerC = cv::Vec3b(57,11,81); // BGR Values
    Vec3b upperC = cv::Vec3b(230,220,240); // BGR values
    
    Mat mask1; inRange(hsv1, lowerC, upperC, mask1);
    Mat mask2; inRange(hsv2, lowerC, upperC, mask2);
    
    ///////////////////////////////////////////////////////
    vector<Vec4i> hierarchy;
    vector<vector<cv::Point> > contours1;
    vector<vector<cv::Point> > contours2;
    
    findContours(mask1, contours1, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    findContours(mask2, contours2, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    
    //    cout << contours1.size() << "\n";
    //    cout << contours2.size() << "\n";
    //    double resut = matchShapes(contours1, contours2, CONTOURS_MATCH_I1, 0);
    //    double resut = matchShapes(contours1, contours2, CONTOURS_MATCH_I2, 0);
    //    double resut = matchShapes(contours1, contours2, CONTOURS_MATCH_I3, 0);
    //    double resut = matchShapes(contours1, contours2, CONTOURS_MATCH_I1, 0);
    double resut = matchShapes(mask1, mask2, CONTOURS_MATCH_I2, 0);
    //    double resut = matchShapes(contours1, contours2, CONTOURS_MATCH_I3, 0);
    
    return resut;
}

// USING
+ (NSMutableArray *) find_rgb_values: (UIImage *) image withBound: (CGRect) bound  {
    Mat src; UIImageToMat(image, src);
    
    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);
    
    cv::Mat maskedSrc = cv::Mat::zeros(src.rows, src.cols, CV_8U);
    src.copyTo(maskedSrc, boundMask);
    
    double r = 0;
    double g = 0;
    double b = 0;
    
    // Src is in BGR
    for (int x = 0 ; x < src.cols; ++x) {
        for (int y = 0 ; y < src.rows; ++y){
            b += maskedSrc.at<cv::Vec3b>(y,x)[0];
            g += maskedSrc.at<cv::Vec3b>(y,x)[1];
            r += maskedSrc.at<cv::Vec3b>(y,x)[2];
        }
    }
    
    NSMutableArray *result = [NSMutableArray array];
    
    [result addObject:@(r)];
    [result addObject:@(g)];
    [result addObject:@(b)];
    
    return result;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////

// /////////////////// //
// USING THIS FUNCTION //
// /////////////////// //

+ (UIImage *) find_contours: (UIImage *) image withBound:(CGRect) bound withThreshold:(int) max_thresh {
    // Consts //
    //    int thresh = 60;
    int min_thresh = 25;
    RNG rng(12345);
    ////////////
    
    Mat src; Mat src_gray; UIImageToMat(image, src);
    cvtColor( src, src_gray, COLOR_BGR2GRAY );
    blur( src_gray, src_gray, cv::Size(3,3) );
    
    Mat canny_output;
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    // cv::Mat::zeros(src.size, CV_8u)
    
    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);
    
    // Detect edges using canny
    Canny( src_gray, canny_output, min_thresh, max_thresh, 3 );
    // Find contours
    canny_output.copyTo(canny_output, boundMask);
    
    Mat temp; canny_output.copyTo(temp, boundMask);
    findContours( temp, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    // Draw contours
    Mat drawing = Mat::zeros( canny_output.size(), CV_8UC3 );
    
    
    cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR); // HACK for drawing colors
    
    
    // Scalar color = Scalar( 32, 194, 14); // HACKERGREEN
    Scalar color = Scalar( 248, 152, 30); // COFFEEBROWN
    for( int i = 0; i< contours.size(); i++ ){
        // Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( src, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
    }
    
    return MatToUIImage(src);
}

+ (NSString *) find_contours_count: (UIImage *) image withBound:(CGRect) bound withThreshold:(int) max_thresh {
    // Consts //
    //    int thresh = 60;
    int min_thresh = 25;
    RNG rng(12345);
    ////////////
    
    Mat src; Mat src_gray; UIImageToMat(image, src);
    cvtColor( src, src_gray, COLOR_BGR2GRAY );
    blur( src_gray, src_gray, cv::Size(3,3) );
    
    Mat canny_output;
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    // cv::Mat::zeros(src.size, CV_8u)
    
    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);
    
    // Detect edges using canny
    Canny( src_gray, canny_output, min_thresh, max_thresh, 3 );
    // Find contours
    canny_output.copyTo(canny_output, boundMask);
    
    Mat temp; canny_output.copyTo(temp, boundMask);
    findContours( temp, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    // Draw contours
    Mat drawing = Mat::zeros( canny_output.size(), CV_8UC3 );
    
    cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR); // HACK for drawing colors
    
    // Scalar color = Scalar( 32, 194, 14); // HACKERGREEN
    Scalar color = Scalar( 248, 152, 30); // COFFEEBROWN
    for( int i = 0; i< contours.size(); i++ ){
        // Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( src, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
    }
    
    if(contours.size() < bound.size.width && contours.size() < bound.size.height){
        return @"low_contour_complexity";
    } else {
        if(contours.size() > bound.size.width * 2 || contours.size() > bound.size.height * 2){
            return @"high_contour_complexity";
        } else {
            return @"medium_contour_complexity";
        }
    }
    
    // This be unreachable :D
    return @"contours.size()";
}

// USING
+ (double) compareUsingHistograms: (UIImage *) src withImage:(UIImage *) compare {
    Mat src_img, hsv_src; UIImageToMat(src, src_img);
    Mat compare_img, hsv_compare; UIImageToMat(compare, compare_img);
    
    // Convert to HSV
    cvtColor( src_img, hsv_src, COLOR_BGR2HSV );
    cvtColor( compare_img, hsv_compare, COLOR_BGR2HSV );
    
    // Using 50 bins for hue and 60 for saturation
    int h_bins = 50; int s_bins = 60;
    int histSize[] = { h_bins, s_bins };
    
    // hue varies from 0 to 179, saturation from 0 to 255
    float h_ranges[] = { 0, 180 };
    float s_ranges[] = { 0, 256 };
    
    const float* ranges[] = { h_ranges, s_ranges };
    
    // Use the o-th and 1-st channels
    int channels[] = { 0, 1 };
    
    // Histograms
    MatND hist_src;
    MatND hist_compare;
    
    // Calculate the histograms for the HSV images
    calcHist( &hsv_src, 1, channels, Mat(), hist_src, 2, histSize, ranges, true, false );
    normalize( hist_src, hist_src, 0, 1, NORM_MINMAX, -1, Mat() );
    
    calcHist( &hsv_compare, 1, channels, Mat(), hist_compare, 2, histSize, ranges, true, false );
    normalize( hist_compare, hist_compare, 0, 1, NORM_MINMAX, -1, Mat() );
    
    double src_compare = 0;
    double result = 0;
    
    /// Apply the histogram comparison methods
    for( int i = 0; i < 4; i++ ){
        int compare_method = i;
        src_compare = compareHist( hist_src, hist_compare, compare_method );
        if (i == 0){
            result = src_compare;
        }
    }
    return result;
}

// USING
+ (double) compareUsingHistograms: (UIImage *) src withBound:(CGRect) bound withImage:(UIImage *) compare {
    Mat src_img, hsv_src; UIImageToMat(src, src_img);
    Mat compare_img, hsv_compare; UIImageToMat(compare, compare_img);
    
    // Convert to HSV
    cvtColor( src_img, hsv_src, COLOR_BGR2HSV );
    cvtColor( compare_img, hsv_compare, COLOR_BGR2HSV );
    
    // Using 50 bins for hue and 60 for saturation
    int h_bins = 50; int s_bins = 60;
    int histSize[] = { h_bins, s_bins };
    
    // hue varies from 0 to 179, saturation from 0 to 255
    float h_ranges[] = { 0, 180 };
    float s_ranges[] = { 0, 256 };
    
    const float* ranges[] = { h_ranges, s_ranges };
    
    // Use the o-th and 1-st channels
    int channels[] = { 0, 1 };
    
    // Histograms
    MatND hist_src;
    MatND hist_compare;
    
    //////////////////////////////////////////////////////////////////////////////////
    
    cv::Mat boundMask = cv::Mat::ones(src_img.rows, src_img.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(0,0,0);
    
    Vec3b lowerC = cv::Vec3b(1,1,1); // BGR Values
    Vec3b upperC = cv::Vec3b(255,255,255); // BGR values
    
    Mat maskPrep; hsv_src.copyTo(maskPrep, boundMask);
    Mat src_mask; inRange(maskPrep, lowerC, upperC, src_mask);
    
    ///////////////////////////////////////////////////////////////////////////////////
    
    // Calculate the histograms for the HSV images
    calcHist( &hsv_src, 1, channels, src_mask, hist_src, 2, histSize, ranges, true, false );
    normalize( hist_src, hist_src, 0, 1, NORM_MINMAX, -1, Mat() );
    
    calcHist( &hsv_compare, 1, channels, Mat(), hist_compare, 2, histSize, ranges, true, false );
    normalize( hist_compare, hist_compare, 0, 1, NORM_MINMAX, -1, Mat() );
    
    double src_compare = 0;
    double result = 0;
    /// Apply the histogram comparison methods
    for( int i = 0; i < 4; i++ ){
        int compare_method = i;
        src_compare = compareHist( hist_src, hist_compare, compare_method );
        if (i == 0){
            result = src_compare;
        }
    }
    return result;
}

// USING
+ (double) compareUsingHistograms: (UIImage *) src withBound:(CGRect) bound withImage:(UIImage *) compare withBound:(CGRect) comapreBound {
    Mat src_img, hsv_src; UIImageToMat(src, src_img);
    Mat compare_img, hsv_compare; UIImageToMat(compare, compare_img);
    
    // Convert to HSV
    cvtColor( src_img, hsv_src, COLOR_BGR2HSV );
    cvtColor( compare_img, hsv_compare, COLOR_BGR2HSV );
    
    // Using 50 bins for hue and 60 for saturation
    int h_bins = 50; int s_bins = 60;
    int histSize[] = { h_bins, s_bins };
    
    // hue varies from 0 to 179, saturation from 0 to 255
    float h_ranges[] = { 0, 180 };
    float s_ranges[] = { 0, 256 };
    
    const float* ranges[] = { h_ranges, s_ranges };
    
    // Use the o-th and 1-st channels
    int channels[] = { 0, 1 };
    
    // Histograms
    MatND hist_src;
    MatND hist_compare;
    
    //////////////////////////////////////////////////////////////////////////////////
    
    cv::Mat boundMask = cv::Mat::ones(src_img.rows, src_img.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(0,0,0);
    
    Vec3b lowerC = cv::Vec3b(1,1,1); // BGR Values
    Vec3b upperC = cv::Vec3b(255,255,255); // BGR values
    
    Mat maskPrep; hsv_src.copyTo(maskPrep, boundMask);
    Mat src_mask; inRange(maskPrep, lowerC, upperC, src_mask);
    
    //////////////////////////////////////////////////////////////////////////////////
    
    boundMask = cv::Mat::ones(compare_img.rows, compare_img.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(0,0,0);

    maskPrep = Mat(); hsv_compare.copyTo(maskPrep, boundMask);
    Mat compare_mask; inRange(maskPrep, lowerC, upperC, compare_mask);
    
    ///////////////////////////////////////////////////////////////////////////////////
    
    // Calculate the histograms for the HSV images
    calcHist( &hsv_src, 1, channels, src_mask, hist_src, 2, histSize, ranges, true, false );
    normalize( hist_src, hist_src, 0, 1, NORM_MINMAX, -1, Mat() );
    
    calcHist( &hsv_compare, 1, channels, compare_mask, hist_compare, 2, histSize, ranges, true, false );
    normalize( hist_compare, hist_compare, 0, 1, NORM_MINMAX, -1, Mat() );
    
    
    double src_compare = 0;
    double result = 0;
    
    /// Apply the histogram comparison methods
    for( int i = 0; i < 4; i++ ){
        int compare_method = i;
        src_compare = compareHist( hist_src, hist_compare, compare_method );
        if (i == 0){
            result = src_compare;
        }
    }
    return result;
}

// USING
+ (UIImage *) draw_color_mask_reversed_void: (UIImage *) image withBound:(CGRect) bound {
    //////////////////////
    RNG rng(12345);
    //////////////////////
    
    Mat src; Mat src_gray; Mat temp; UIImageToMat(image, src);
    
    // Convert image to gray and blur it
    Mat src_blurred; GaussianBlur(src, src_blurred, cv::Size(5,5), 0);
    Mat hsv; cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    
    cv::Mat result = cv::Mat::ones(src.rows, src.cols, CV_8U); // all 0
    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);
    boundMask = 255 - boundMask;
    
    Vec3b lowerC = cv::Vec3b(1,1,1);
    Vec3b upperC = cv::Vec3b(180,255,255);
    
    Mat maskPrep; hsv.copyTo(maskPrep, boundMask);
    Mat mask; inRange(maskPrep, lowerC, upperC, mask);
    
    cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR);
    cvtColor(src, temp, COLOR_BGR2GRAY);
    cvtColor(temp, temp, COLOR_GRAY2BGR);
    
    src.copyTo(result, boundMask);
    return MatToUIImage(result);
}

// USING
+ (NSMutableArray *) contour_python_bound_square: (UIImage *) image withThresh:(int) thresh {
    //////////////////////
//    int max_thresh = 255;
    RNG rng(12345);
    //////////////////////
    
    Mat src; Mat src_gray; UIImageToMat(image, src);
    Mat temp; cvtColor(src, temp, COLOR_BGR2RGB);
    /// Convert image to gray and blur it
    Mat src_blurred; GaussianBlur(src, src_blurred, cv::Size(5,5), 0);
    Mat hsv; cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    //    Vec3b lowerC = cv::Vec3b(81,57,11); // RBG Values
    //    Vec3b upperC = cv::Vec3b(240,230,220); // RBG values
    
    Vec3b lowerC = cv::Vec3b(9,9,9); // BGR Values
    Vec3b upperC = cv::Vec3b(230,220,240); // BGR values
//    Vec3b upperC = cv::Vec3b(250,250,250); // BGR values
    
    Mat mask; inRange(hsv, lowerC, upperC, mask);
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    findContours(mask, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    
    vector<vector<cv::Point> > contours_poly( contours.size() ); // Mark -- this too
    vector<cv::Rect> boundRect( contours.size() ); // Mark -- square
    
    cvtColor(temp, src, COLOR_RGB2BGR); // HACK for drawing colors
    
    for( int i = 0; i < contours.size(); i++ ){
        approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
        boundRect[i] = boundingRect( Mat(contours_poly[i]) ); // MARK -- square
    }
    
    cv::Rect thirdBiggest = cv::Rect(0,0,1,1);
    cv::Rect secondBiggest = cv::Rect(0,0,1,1);
    cv::Rect biggest = cv::Rect(0,0,1,1);
    
    for( int i = 0; i< contours.size(); i++ ) {
        if (biggest.width * biggest.height < boundRect[i].width * boundRect[i].height) {
            thirdBiggest = secondBiggest;
            secondBiggest = biggest;
            biggest = boundRect[i];
        } else {
            if (secondBiggest.width * secondBiggest.height < boundRect[i].width * boundRect[i].height) {
                secondBiggest = boundRect[i];
            } else {
                if (thirdBiggest.width * thirdBiggest.height < boundRect[i].width * boundRect[i].height) {
                    thirdBiggest = boundRect[i];
                }
            }
        }
    }
    
    // Scalar color = Scalar( 32, 194, 14); // HACKERGREEN
    Scalar color = Scalar( 248, 152, 30); // COFFEEBROWN
    
    rectangle(src, biggest.tl(), biggest.br(), color, 2, 8, 0);
    rectangle(src, secondBiggest.tl(), secondBiggest.br(), color, 2, 8, 0);
    rectangle(src, thirdBiggest.tl(), thirdBiggest.br(), color, 2, 8, 0);
    
    NSMutableArray *result = [NSMutableArray array];
    
    [result addObject:[NSValue valueWithCGRect: CGRectMake(biggest.tl().x, biggest.tl().y, biggest.width, biggest.height)]];
    [result addObject:[NSValue valueWithCGRect: CGRectMake(secondBiggest.tl().x, secondBiggest.tl().y, secondBiggest.width, secondBiggest.height)]];
    [result addObject:[NSValue valueWithCGRect: CGRectMake(thirdBiggest.tl().x, thirdBiggest.tl().y, thirdBiggest.width, thirdBiggest.height)]];
    [result addObject:MatToUIImage(src)];
    
    return result;
}

// USING
+ (double) compareUsingGrayScaleHistograms: (UIImage *) src withImage:(UIImage *) compare {
    Mat src_img, hsv_src; UIImageToMat(src, src_img);
    Mat compare_img, hsv_compare; UIImageToMat(compare, compare_img);
    
    // Convert to HSV
    cvtColor( src_img, hsv_src, COLOR_BGR2GRAY );
    cvtColor( compare_img, hsv_compare, COLOR_BGR2GRAY );
    
    int histSize = 256;
    float range[] = { 0, 256 } ;
    const float* histRange = { range };
    
    // Use the o-th and 1-st channels
    int channels[] = { 0 };
    
    // Histograms
    MatND hist_src;
    MatND hist_compare;
    
    // Calculate the histograms for the HSV images
    calcHist( &hsv_src, 1, channels, Mat(), hist_src, 1, &histSize, &histRange, true, false );
    calcHist( &hsv_compare, 1, channels, Mat(), hist_compare, 1, &histSize, &histRange, true, false );
    
    double src_compare = 0;
    double result = 0;
    
    /// Apply the histogram comparison methods
    for( int i = 0; i < 4; i++ ){
        int compare_method = i;
        src_compare = compareHist( hist_src, hist_compare, compare_method );
        if (i == 0){
            result = src_compare;
        }
    }
    return result;
}

// USING
+ (UIImage *) draw_color_mask: (UIImage *) image withBound:(CGRect) bound {
    //////////////////////
    RNG rng(12345);
    //////////////////////
    
    Mat src; Mat src_gray; Mat temp; UIImageToMat(image, src);
    
    //    src.copyTo(temp);
    // Convert image to gray and blur it
    Mat src_blurred; GaussianBlur(src, src_blurred, cv::Size(5,5), 0);
    Mat hsv; cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    
    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);
    
    Vec3b lowerC = cv::Vec3b(1,1,1); // BGR Values
    Vec3b upperC = cv::Vec3b(255,255,255); // BGR values
    
    Mat maskPrep; hsv.copyTo(maskPrep, boundMask);
    Mat mask; inRange(maskPrep, lowerC, upperC, mask);
    
    cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR);
    cvtColor(src, temp, COLOR_BGR2GRAY);
    cvtColor(temp, temp, COLOR_GRAY2BGR);
    
    src.copyTo(temp, mask);
    return MatToUIImage(temp);
//    return MatToUIImage(mask);
}

// USING
+ (UIImage *) draw_color_mask_reversed: (UIImage *) image withBound:(CGRect) bound {
    //////////////////////
    RNG rng(12345);
    //////////////////////
    
    Mat src; Mat src_gray; Mat temp; UIImageToMat(image, src);
    
    // Convert image to gray and blur it
    Mat src_blurred; GaussianBlur(src, src_blurred, cv::Size(5,5), 0);
    Mat hsv; cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    
    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);
    boundMask = 255 - boundMask;
    
    Vec3b lowerC = cv::Vec3b(1,1,1); // BGR Values
    Vec3b upperC = cv::Vec3b(255,255,255); // BGR values
    
    Mat maskPrep; hsv.copyTo(maskPrep, boundMask);
    Mat mask; inRange(maskPrep, lowerC, upperC, mask);
    
    cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR);
    cvtColor(src, temp, COLOR_BGR2GRAY);
    cvtColor(temp, temp, COLOR_GRAY2BGR);
    src.copyTo(temp, mask);
    return MatToUIImage(temp);
}

+ (UIImage *) bounding_circles_squares: (UIImage *) image withThresh:(int) thresh {
    //////////////////////
//    int max_thresh = 255;
    RNG rng(12345);
    //////////////////////
    
    Mat src; Mat src_gray; UIImageToMat(image, src);
    Mat temp; cvtColor(src, temp, COLOR_BGR2RGB);
    /// Convert image to gray and blur it
    cvtColor( src, src_gray, COLOR_BGR2GRAY );
    blur( src_gray, src_gray, cv::Size(3,3) );
    
    Mat threshold_output;
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    /// Detect edges using Threshold
    threshold( src_gray, threshold_output, thresh, 255, THRESH_BINARY );
    /// Find contours
    findContours( threshold_output, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    /// Approximate contours to polygons + get bounding rects and circles
    vector<vector<cv::Point> > contours_poly( contours.size() ); // Mark -- this too
    vector<cv::Rect> boundRect( contours.size() ); // Mark -- square
    vector<Point2f>center( contours.size() );
    vector<float>radius( contours.size() );
    
    for( int i = 0; i < contours.size(); i++ ){
        approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
        boundRect[i] = boundingRect( Mat(contours_poly[i]) ); // MARK -- square
        minEnclosingCircle( (Mat)contours_poly[i], center[i], radius[i] );
    }
    
    /// Draw polygonal contour + bonding rects + circles
    cvtColor(temp, src, COLOR_RGB2BGR);
    Mat drawing = Mat::zeros( threshold_output.size(), CV_8UC3 );
    
//    Scalar rectangleColor = Scalar( 32, 194, 14); // HACKERGREEN
    Scalar rectangleColor = Scalar( 248, 152, 30);
    Scalar circleColor = Scalar( 248, 152, 30);

    for( int i = 0; i< contours.size(); i++ )
    {
        rectangle( src, boundRect[i].tl(), boundRect[i].br(), rectangleColor, 2, 8, 0 );
        circle( src, center[i], (int)radius[i], circleColor, 2, 8, 0 );
    }
    return MatToUIImage(src);
}

+ (UIImage *) bounding_circles_squares: (UIImage *) image withBound:(CGRect) bound withThresh:(int) thresh {
    //////////////////////
//    int max_thresh = 255;
    RNG rng(12345);
    //////////////////////
    
    Mat src; Mat src_gray; UIImageToMat(image, src);
    Mat temp; cvtColor(src, temp, COLOR_BGR2RGB);
    
    cout << "src.rows: " << src.rows << " src.cols: " << src.cols << endl;
    cout << " origin.y: " << bound.origin.x << " origin.y: " << bound.origin.y << " size.width: " << bound.size.width << " size.height: " << bound.size.height << endl;
    
    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);
    
    /// Convert image to gray and blur it
    cvtColor( src, src_gray, COLOR_BGR2GRAY );
    blur( src_gray, src_gray, cv::Size(3,3) );
    
    Mat threshold_output;
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
        
    Mat croppedGray; src_gray.copyTo(croppedGray, boundMask);
//    return MatToUIImage(croppedGray);
    /// Detect edges using Threshold
    threshold( croppedGray, threshold_output, thresh, 255, THRESH_BINARY );
    /// Find contours
    findContours( threshold_output, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    /// Approximate contours to polygons + get bounding rects and circles
    vector<vector<cv::Point> > contours_poly( contours.size() ); // Mark -- this too
    vector<cv::Rect> boundRect( contours.size() ); // Mark -- square
    vector<Point2f>center( contours.size() );
    vector<float>radius( contours.size() );
    
    for( int i = 0; i < contours.size(); i++ ){
        approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
        boundRect[i] = boundingRect( Mat(contours_poly[i]) ); // MARK -- square
        minEnclosingCircle( (Mat)contours_poly[i], center[i], radius[i] );
    }
    
    /// Draw polygonal contour + bonding rects + circles
    cvtColor(temp, src, COLOR_RGB2BGR);
    Mat drawing = Mat::zeros( threshold_output.size(), CV_8UC3 );
    for( int i = 0; i< contours.size(); i++ )
    {
        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( src, contours_poly, i, color, 1, 8, vector<Vec4i>(), 0, cv::Point() );
        rectangle( src, boundRect[i].tl(), boundRect[i].br(), color, 2, 8, 0 ); // MARK -- square
        circle( src, center[i], (int)radius[i], color, 2, 8, 0 );
    }
    return MatToUIImage(src);
}

// USING FOR TESTING
// https://pysource.com/2018/03/01/find-and-draw-contours-opencv-3-4-with-python-3-tutorial-19/
+ (UIImage *) draw_contour_python: (UIImage *) image withThresh:(int) thresh {
    //////////////////////
//    int max_thresh = 255;
    RNG rng(12345);
    //////////////////////
    
    Mat src; Mat src_gray; UIImageToMat(image, src);
    Mat temp; cvtColor(src, temp, COLOR_BGR2RGB);
    // Convert image to gray and blur it
    Mat src_blurred; GaussianBlur(src, src_blurred, cv::Size(5,5), 0);
    Mat hsv; cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    
    //    Vec3b lowerC = cv::Vec3b(81,57,11); // RBG Values
    //    Vec3b upperC = cv::Vec3b(240,230,220); // RBG values
    
    Vec3b lowerC = cv::Vec3b(57,11,81); // BGR Values
    Vec3b upperC = cv::Vec3b(230,220,240); // BGR values
    
    Mat mask; inRange(hsv, lowerC, upperC, mask);
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    //    findContours(mask, contours, RETR_TREE, CHAIN_APPROX_SIMPLE);
    findContours(mask, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    //    findContours( hsv, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    cvtColor(temp, src, COLOR_RGB2BGR);
    for( int i = 0; i< contours.size(
        ); i++ ){
        if( cv::contourArea(contours[i]) > 5000){
            Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
            //            cv::drawContours(src, contours[i], -1, color, 3);
            drawContours( src, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
        }
    }
    
    // return MatToUIImage(mask);
    return MatToUIImage(src);
}


// USING
+ (NSMutableArray *) find_rgb_values: (UIImage *) image {
    Mat src; UIImageToMat(image, src);
    
    double r = 0;
    double g = 0;
    double b = 0;
    
    // Src is in BGR
    for (int x = 0 ; x < src.cols; ++x) {
        for (int y = 0 ; y < src.rows; ++y){
            b += src.at<cv::Vec3b>(y,x)[0];
            g += src.at<cv::Vec3b>(y,x)[1];
            r += src.at<cv::Vec3b>(y,x)[2];
        }
    }
    
    NSMutableArray *result = [NSMutableArray array];
    [result addObject:@(r)];
    [result addObject:@(g)];
    [result addObject:@(b)];
    return result;
}

// ///////////////////////// //
// /// Testing functions /// //
// ///////////////////////// //

+ (UIImage *) get_color_content: (UIImage *) image {
    // https://www.learnopencv.com/invisibility-cloak-using-color-detection-and-segmentation-with-opencv/
    
    //////////////////////
    //    int max_thresh = 255;
    RNG rng(12345);
    //////////////////////
    
    Mat src; Mat src_gray; UIImageToMat(image, src);
    Mat temp; cvtColor(src, temp, COLOR_BGR2RGB);
    // Convert image to gray and blur it
    Mat src_blurred; GaussianBlur(src, src_blurred, cv::Size(5,5), 0);
    Mat hsv; cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    
    //    Vec3b lowerC = cv::Vec3b(81,57,11); // RBG Values
    //    Vec3b upperC = cv::Vec3b(240,230,220); // RBG values
    
    Vec3b lowerC = cv::Vec3b(26,0,0); // BGR Values
    Vec3b upperC = cv::Vec3b(48,255,255); // BGR values
    
    Mat mask; inRange(hsv, lowerC, upperC, mask);
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    //    findContours(mask, contours, RETR_TREE, CHAIN_APPROX_SIMPLE);
    findContours(mask, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    //    findContours( hsv, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    cvtColor(temp, src, COLOR_RGB2BGR);
    for( int i = 0; i< contours.size(
        ); i++ ){
        if( cv::contourArea(contours[i]) > 5000){
            Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
            //            cv::drawContours(src, contours[i], -1, color, 3);
            drawContours( src, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
        }
    }
    
    // return MatToUIImage(mask);
    return MatToUIImage(src);
}

+ (UIImage *) get_color_content_with_range: (UIImage *) image withLowRange: (NSMutableArray *) lowVector withHighRange: (NSMutableArray *) highVector {
    // https://www.learnopencv.com/invisibility-cloak-using-color-detection-and-segmentation-with-opencv/
    
    //////////////////////
    // int max_thresh = 255;
    RNG rng(12345);
    //////////////////////
    
    Mat src; Mat src_gray; UIImageToMat(image, src);
    Mat temp; cvtColor(src, temp, COLOR_BGR2RGB);
    // Convert image to gray and blur it
    Mat src_blurred; GaussianBlur(src, src_blurred, cv::Size(5,5), 0);
    Mat hsv; cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    
    //    Vec3b lowerC = cv::Vec3b(81,57,11); // RBG Values
    //    Vec3b upperC = cv::Vec3b(240,230,220); // RBG values
    
    NSNumber *lowH = [lowVector objectAtIndex:0];
    NSNumber *lowS = [lowVector objectAtIndex:1];
    NSNumber *lowV = [lowVector objectAtIndex:2];
    
    NSNumber *highH = [highVector objectAtIndex:0];
    NSNumber *highS = [highVector objectAtIndex:1];
    NSNumber *highV = [highVector objectAtIndex:2];
    
    [lowH integerValue];

    Vec3b lowerC = cv::Vec3b([lowH integerValue],[lowS integerValue],[lowV integerValue]); // BGR Values
    Vec3b upperC = cv::Vec3b([highH integerValue],[highS integerValue],[highV integerValue]); // BGR values
    
    Mat mask; inRange(hsv, lowerC, upperC, mask);
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    //    findContours(mask, contours, RETR_TREE, CHAIN_APPROX_SIMPLE);
    findContours(mask, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    //    findContours( hsv, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
//    cout << "Found contours with area: " << cv::contourArea(contours) << endl;
    float contoursSize = 0;
    cvtColor(temp, src, COLOR_RGB2BGR);
    for( int i = 0; i< contours.size(
        ); i++ ){
        contoursSize += cv::contourArea(contours[i]);
        if( cv::contourArea(contours[i]) > 5000){
            Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
            //            cv::drawContours(src, contours[i], -1, color, 3);
            drawContours( src, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
        }
    }
//    cout << "Found contours size:" << contoursSize << endl;
    // return MatToUIImage(mask);
    return MatToUIImage(mask);
}

+ (NSString *) get_yeeted: (UIImage *) image withBound:(CGRect) bound {
//    cout << [self get_contour_size_light()];
//    float light_size = [self get_contour_size_light:image withBound:bound];
//    float casual_size = [self get_contour_size_casual:image withBound:bound];
//    float dark_size = [self get_contour_size_dark:image withBound:bound];
//    float fancy_size = [self get_contour_size_fancy:image withBound:bound];
    
    // TODO: adjust it
    float size_threshold = 2; // TEMP!
    
    float light_coffee_size = [self get_contour_size_light_coffee:image withBound:bound];
    float dark_coffee_size = [self get_contour_size_dark_coffee:image withBound:bound];
    
//    cout << "Coffee color results: Light: " << light_coffee_size << " Dark: " << dark_coffee_size << endl;
    
//    cout << light_coffee_size << " " << dark_coffee_size << " " << endl;
    if (light_coffee_size < size_threshold && dark_coffee_size < size_threshold) {
        return @"yeet";
    }
    
    if (light_coffee_size < size_threshold){
        return @"coffee_class_dark";
    }
    
    if (dark_coffee_size < size_threshold){
        return @"coffee_class_light";
    }
    
    if (light_coffee_size < dark_coffee_size){
        return @"coffee_class_dark";
    }
    
    if (dark_coffee_size < light_coffee_size){
        return @"coffee_class_light";
    }
    
    return @"coffee_class_empty_notfound";
}

+ (NSString *) get_yeeted_background: (UIImage *) image withBound:(CGRect) bound {
    //    cout << [self get_contour_size_light()];
    float red_size = [self get_contour_size_background_red:image withBound:bound ];
    float blue_size = [self get_contour_size_background_blue: image withBound:bound];
    float green_size = [self get_contour_size_background_green:image withBound:bound];
    float white_size = [self get_contour_size_background_white:image withBound:bound];
    float dark_size = [self get_contour_size_background_dark: image withBound: bound];
    float brown_size = [self get_contour_size_background_brown:image withBound:bound];
    
    if (red_size > brown_size && red_size > white_size && red_size > green_size && red_size > blue_size && red_size > dark_size) {
        return @"red_size";
    }

    if (blue_size > red_size && blue_size > brown_size && blue_size > white_size && blue_size > green_size && blue_size > dark_size) {
        return @"blue_size";
    }
    
    if (green_size > red_size && green_size > brown_size && green_size > white_size && green_size > blue_size && green_size  > dark_size) {
        return @"green_size";
    }
    
    if (white_size > red_size && white_size > brown_size && white_size > green_size && white_size > blue_size && white_size > dark_size) {
        return @"white_size";
    }
    
    if (dark_size > red_size && dark_size > brown_size && dark_size > white_size && dark_size > green_size && dark_size > blue_size) {
        return @"dark_size";
    }
    
    if (brown_size > red_size && brown_size > white_size && brown_size > green_size && brown_size > blue_size && brown_size > dark_size) {
        return @"brown_size";
    }
    
//    cout << "Was its ze Problim?!" << endl
//    << "red_size: " << red_size << endl
//    << "blue_size: " << blue_size << endl
//    << "green_size: " << green_size << endl
//    << "white_size: " << white_size << endl
//    << "dark_size: " << dark_size << endl
//    << "brown_size: " << brown_size << endl
//    << "Maybe whole picture is selected with the bounding rect?" << endl;
    
    cout << "Error? Hmmm 🤔🤔🤔" << endl;
    
    return @"yeeted";
}

+ (int) get_contour_size_light: (UIImage *) image withBound:(CGRect) bound  {
    NSMutableArray *highEnd = [NSMutableArray array];
    [highEnd addObject:@(108)];
    [highEnd addObject:@(124)];
    [highEnd addObject:@(220)];
    
    NSMutableArray *lowEnd = [NSMutableArray array];
    [lowEnd addObject:@(92)];
    [lowEnd addObject:@(65)];
    [lowEnd addObject:@(89)];
    
    float result = [self get_color_contour_size:image withBound: bound  withLowRange:lowEnd withHighRange:highEnd];
    
    return result;
}

+ (int) get_contour_size_casual: (UIImage *) image withBound:(CGRect) bound {
    NSMutableArray *highEnd = [NSMutableArray array];
    [highEnd addObject:@(120)];
    [highEnd addObject:@(243)];
    [highEnd addObject:@(210)];
    
    NSMutableArray *lowEnd = [NSMutableArray array];
    [lowEnd addObject:@(92)];
    [lowEnd addObject:@(156)];
    [lowEnd addObject:@(93)];
    
    float result = [self get_color_contour_size:image withBound: bound  withLowRange:lowEnd withHighRange:highEnd];
    
    return result;
}

+ (int) get_contour_size_dark: (UIImage *) image withBound:(CGRect) bound  {
    NSMutableArray *highEnd = [NSMutableArray array];
    [highEnd addObject:@(180)];
    [highEnd addObject:@(255)];
    [highEnd addObject:@(133)];
    
    NSMutableArray *lowEnd = [NSMutableArray array];
    [lowEnd addObject:@(0)];
    [lowEnd addObject:@(0)];
    [lowEnd addObject:@(0)];
    
    float result = [self get_color_contour_size:image withBound: bound  withLowRange:lowEnd withHighRange:highEnd];
    
    return result;
}

+ (int) get_contour_size_fancy: (UIImage *) image withBound:(CGRect) bound  {
    NSMutableArray *highEnd = [NSMutableArray array];
    [highEnd addObject:@(113)];
    [highEnd addObject:@(186)];
    [highEnd addObject:@(255)];
    
    NSMutableArray *lowEnd = [NSMutableArray array];
    [lowEnd addObject:@(101)];
    [lowEnd addObject:@(44)];
    [lowEnd addObject:@(56)];
    
    float result = [self get_color_contour_size:image withBound: bound  withLowRange:lowEnd withHighRange:highEnd];
    
    return result;
}

//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////

+ (int) get_contour_size_light_coffee: (UIImage *) image withBound:(CGRect) bound  {
    NSMutableArray *highEnd = [NSMutableArray array];
    [highEnd addObject:@(115)];
    [highEnd addObject:@(255)];
    [highEnd addObject:@(220)];
    
    NSMutableArray *lowEnd = [NSMutableArray array];
    [lowEnd addObject:@(80)];
    [lowEnd addObject:@(90)];
    [lowEnd addObject:@(72)];
    
    float result = [self get_color_contour_size:image withBound: bound  withLowRange:lowEnd withHighRange:highEnd];
    
    return result;
}

+ (int) get_contour_size_dark_coffee: (UIImage *) image withBound:(CGRect) bound  {
    NSMutableArray *highEnd = [NSMutableArray array];
    [highEnd addObject:@(140)];
    [highEnd addObject:@(220)];
    [highEnd addObject:@(100)];
    
    NSMutableArray *lowEnd = [NSMutableArray array];
    [lowEnd addObject:@(102)];
    [lowEnd addObject:@(10)];
    [lowEnd addObject:@(2)];
    
    float result = [self get_color_contour_size:image withBound: bound  withLowRange:lowEnd withHighRange:highEnd];
    
    return result;
}

//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////

+ (int) get_contour_size_background_blue: (UIImage *) image withBound:(CGRect) bound  {
    NSMutableArray *highEnd = [NSMutableArray array];
    [highEnd addObject:@(40)];
    [highEnd addObject:@(255)];
    [highEnd addObject:@(255)];
    
    NSMutableArray *lowEnd = [NSMutableArray array];
    [lowEnd addObject:@(10)];
    [lowEnd addObject:@(0)];
    [lowEnd addObject:@(0)];
    
    float result = [self get_color_contour_sizeR:image withBound: bound  withLowRange:lowEnd withHighRange:highEnd];
    return result;
}

+ (int) get_contour_size_background_green: (UIImage *) image withBound:(CGRect) bound {
    NSMutableArray *highEnd = [NSMutableArray array];
    [highEnd addObject:@(70)];
    [highEnd addObject:@(255)];
    [highEnd addObject:@(255)];
    
    NSMutableArray *lowEnd = [NSMutableArray array];
    [lowEnd addObject:@(40)];
    [lowEnd addObject:@(0)];
    [lowEnd addObject:@(0)];
    
    float result = [self get_color_contour_sizeR:image withBound: bound  withLowRange:lowEnd withHighRange:highEnd];
    return result;
}

+ (int) get_contour_size_background_red: (UIImage *) image withBound:(CGRect) bound  {
    NSMutableArray *highEnd = [NSMutableArray array];
    [highEnd addObject:@(130)];
    [highEnd addObject:@(255)];
    [highEnd addObject:@(255)];
    
    NSMutableArray *lowEnd = [NSMutableArray array];
    [lowEnd addObject:@(116)];
    [lowEnd addObject:@(40)];
    [lowEnd addObject:@(40)];
    
    float result = [self get_color_contour_sizeR:image withBound: bound  withLowRange:lowEnd withHighRange:highEnd];
    
    return result;
}

+ (int) get_contour_size_background_brown: (UIImage *) image withBound:(CGRect) bound  {
    NSMutableArray *highEnd = [NSMutableArray array];
    [highEnd addObject:@(115)];
    [highEnd addObject:@(255)];
    [highEnd addObject:@(255)];
    
    NSMutableArray *lowEnd = [NSMutableArray array];
    [lowEnd addObject:@(100)];
    [lowEnd addObject:@(40)];
    [lowEnd addObject:@(40)];
    
    float result = [self get_color_contour_sizeR:image withBound: bound  withLowRange:lowEnd withHighRange:highEnd];
    
    return result;
}

+ (int) get_contour_size_background_white: (UIImage *) image withBound:(CGRect) bound  {
    NSMutableArray *highEnd = [NSMutableArray array];
    [highEnd addObject:@(180)];
    [highEnd addObject:@(40)];
    [highEnd addObject:@(255)];
    
    NSMutableArray *lowEnd = [NSMutableArray array];
    [lowEnd addObject:@(0)];
    [lowEnd addObject:@(0)];
    [lowEnd addObject:@(180)];
    
    float result = [self get_color_contour_sizeR:image withBound: bound  withLowRange:lowEnd withHighRange:highEnd];
    
    return result;
}

+ (int) get_contour_size_background_dark: (UIImage *) image withBound:(CGRect) bound {
    NSMutableArray *highEnd = [NSMutableArray array];
    [highEnd addObject:@(180)];
    [highEnd addObject:@(255)];
    [highEnd addObject:@(82)];
    
    NSMutableArray *lowEnd = [NSMutableArray array];
    [lowEnd addObject:@(0)];
    [lowEnd addObject:@(0)];
    [lowEnd addObject:@(1)];
    
    float result = [self get_color_contour_sizeR:image withBound: bound  withLowRange:lowEnd withHighRange:highEnd];
    
    return result;
}


//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////


+ (float) get_color_contour_sizeR: (UIImage *) image withBound:(CGRect) bound withLowRange: (NSMutableArray *) lowVector withHighRange: (NSMutableArray *) highVector {
    
    Mat src; Mat src_gray; Mat temp; UIImageToMat(image, src);
    
    // Convert image to gray and blur it
    Mat src_blurred; GaussianBlur(src, src_blurred, cv::Size(5,5), 0);
    Mat hsv; cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    
    cv::Mat result = cv::Mat::ones(src.rows, src.cols, CV_8U); // all 0
    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);
    boundMask = 255 - boundMask;
    
    Vec3b lowerC = cv::Vec3b(1,1,1);
    Vec3b upperC = cv::Vec3b(180,255,255);
    
    Mat maskPrep; hsv.copyTo(maskPrep, boundMask);
    Mat mask; inRange(maskPrep, lowerC, upperC, mask);
    
    cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR);
    cvtColor(src, temp, COLOR_BGR2GRAY);
    cvtColor(temp, temp, COLOR_GRAY2BGR);
    
    src.copyTo(result, boundMask);
    
    NSNumber *lowH = [lowVector objectAtIndex:0];
    NSNumber *lowS = [lowVector objectAtIndex:1];
    NSNumber *lowV = [lowVector objectAtIndex:2];
    
    NSNumber *highH = [highVector objectAtIndex:0];
    NSNumber *highS = [highVector objectAtIndex:1];
    NSNumber *highV = [highVector objectAtIndex:2];
    
    [lowH integerValue];
    
    lowerC = cv::Vec3b([lowH integerValue],[lowS integerValue],[lowV integerValue]); // BGR Values
    upperC = cv::Vec3b([highH integerValue],[highS integerValue],[highV integerValue]); // BGR values
    
    cvtColor( result, hsv, COLOR_BGR2HSV );
    inRange(hsv, lowerC, upperC, mask);
    
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    findContours(mask, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    float contoursSize = 0;
    cvtColor(temp, src, COLOR_RGB2BGR);
    
    for( int i = 0; i< contours.size(); i++ ){
        contoursSize += cv::contourArea(contours[i]);
    }
    
//    cout << "Found contours size:" << contoursSize << endl;
    return contoursSize;
}

+ (float) get_color_contour_size: (UIImage *) image withBound:(CGRect) bound withLowRange: (NSMutableArray *) lowVector withHighRange: (NSMutableArray *) highVector {
    
    Mat src; Mat src_gray; Mat temp; UIImageToMat(image, src);
    
    // Convert image to gray and blur it
    Mat src_blurred; GaussianBlur(src, src_blurred, cv::Size(5,5), 0);
    Mat hsv; cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    
    cv::Mat result = cv::Mat::ones(src.rows, src.cols, CV_8U); // all 0
    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);
    
    Vec3b lowerC = cv::Vec3b(1,1,1);
    Vec3b upperC = cv::Vec3b(180,255,255);
    
    cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR);
    cvtColor(src, temp, COLOR_BGR2GRAY);
    cvtColor(temp, temp, COLOR_GRAY2BGR);
    
    src.copyTo(result, boundMask);
    GaussianBlur(result, src_blurred, cv::Size(5,5), 0);
    cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    
    NSNumber *lowH = [lowVector objectAtIndex:0];
    NSNumber *lowS = [lowVector objectAtIndex:1];
    NSNumber *lowV = [lowVector objectAtIndex:2];
    
    NSNumber *highH = [highVector objectAtIndex:0];
    NSNumber *highS = [highVector objectAtIndex:1];
    NSNumber *highV = [highVector objectAtIndex:2];
    
    [lowH integerValue];
    
    lowerC = cv::Vec3b([lowH integerValue],[lowS integerValue],[lowV integerValue]); // BGR Values
    upperC = cv::Vec3b([highH integerValue],[highS integerValue],[highV integerValue]); // BGR values
    
    Mat maskPrep; hsv.copyTo(maskPrep, boundMask);
    Mat mask; inRange(maskPrep, lowerC, upperC, mask);
    
    inRange(hsv, lowerC, upperC, mask);
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    findContours(mask, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    float contoursSize = 0;
    cvtColor(temp, src, COLOR_RGB2BGR);
    
    for( int i = 0; i< contours.size(); i++ ){
        contoursSize += cv::contourArea(contours[i]);
    }
 
    if (contoursSize < bound.size.width * bound.size.height * 0.1) {
        return 0;
    }
    
    return contoursSize;
//    return MatToUIImage(src_blurred);
}

//////////////////////////////////////////
+ (UIImage *) get_color_contour_sizeRR: (UIImage *) image withBound:(CGRect) bound withLowRange: (NSMutableArray *) lowVector withHighRange: (NSMutableArray *) highVector {
    
    Mat src; Mat src_gray; Mat temp; UIImageToMat(image, src);
    
    // Convert image to gray and blur it
    Mat src_blurred; GaussianBlur(src, src_blurred, cv::Size(5,5), 0);
    Mat hsv; cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    
    cv::Mat result = cv::Mat::ones(src.rows, src.cols, CV_8U); // all 0
    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);
    boundMask = 255 - boundMask;
    
    Vec3b lowerC = cv::Vec3b(1,1,1);
    Vec3b upperC = cv::Vec3b(180,255,255);
    
    Mat maskPrep; hsv.copyTo(maskPrep, boundMask);
    Mat mask; inRange(maskPrep, lowerC, upperC, mask);
    
    cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR);
    cvtColor(src, temp, COLOR_BGR2GRAY);
    cvtColor(temp, temp, COLOR_GRAY2BGR);
    
    src.copyTo(result, boundMask);
    
    NSNumber *lowH = [lowVector objectAtIndex:0];
    NSNumber *lowS = [lowVector objectAtIndex:1];
    NSNumber *lowV = [lowVector objectAtIndex:2];
    
    NSNumber *highH = [highVector objectAtIndex:0];
    NSNumber *highS = [highVector objectAtIndex:1];
    NSNumber *highV = [highVector objectAtIndex:2];
    
    [lowH integerValue];
    
    lowerC = cv::Vec3b([lowH integerValue],[lowS integerValue],[lowV integerValue]); // BGR Values
    upperC = cv::Vec3b([highH integerValue],[highS integerValue],[highV integerValue]); // BGR values
    
    cvtColor( result, hsv, COLOR_BGR2HSV );
    inRange(hsv, lowerC, upperC, mask);
    
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    findContours(mask, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    float contoursSize = 0;
    cvtColor(temp, src, COLOR_RGB2BGR);
    
    for( int i = 0; i< contours.size(); i++ ){
        contoursSize += cv::contourArea(contours[i]);
    }
    
    //    cout << "Found contours size:" << contoursSize << endl;
//    return contoursSize;
    return MatToUIImage(boundMask);
}


+ (UIImage *) get_color_contour_sizeM: (UIImage *) image withBound:(CGRect) bound withLowRange: (NSMutableArray *) lowVector withHighRange: (NSMutableArray *) highVector {
    // https://www.learnopencv.com/invisibility-cloak-using-color-detection-and-segmentation-with-opencv/
    
    Mat src; Mat src_gray; Mat temp; UIImageToMat(image, src);
    
    // Convert image to gray and blur it
    Mat src_blurred; GaussianBlur(src, src_blurred, cv::Size(5,5), 0);
    Mat hsv; cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    
    cv::Mat result = cv::Mat::ones(src.rows, src.cols, CV_8U); // all 0
    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);
    
    Vec3b lowerC = cv::Vec3b(1,1,1);
    Vec3b upperC = cv::Vec3b(180,255,255);
    

    
    cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR);
    cvtColor(src, temp, COLOR_BGR2GRAY);
    cvtColor(temp, temp, COLOR_GRAY2BGR);
    
    src.copyTo(result, boundMask);
    GaussianBlur(result, src_blurred, cv::Size(5,5), 0);
    cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    
    NSNumber *lowH = [lowVector objectAtIndex:0];
    NSNumber *lowS = [lowVector objectAtIndex:1];
    NSNumber *lowV = [lowVector objectAtIndex:2];
    
    NSNumber *highH = [highVector objectAtIndex:0];
    NSNumber *highS = [highVector objectAtIndex:1];
    NSNumber *highV = [highVector objectAtIndex:2];
    
    [lowH integerValue];
    
    lowerC = cv::Vec3b([lowH integerValue],[lowS integerValue],[lowV integerValue]); // BGR Values
    upperC = cv::Vec3b([highH integerValue],[highS integerValue],[highV integerValue]); // BGR values
    
    Mat maskPrep; hsv.copyTo(maskPrep, boundMask);
    Mat mask; inRange(maskPrep, lowerC, upperC, mask);
    
    inRange(hsv, lowerC, upperC, mask);
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    findContours(mask, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    float contoursSize = 0;
    cvtColor(temp, src, COLOR_RGB2BGR);
    
    for( int i = 0; i< contours.size(); i++ ){
        contoursSize += cv::contourArea(contours[i]);
    }
//    cout << " THis be a wild thing : D " << contoursSize << endl;
//    return contoursSize;
    return MatToUIImage(src_blurred);
}

@end
