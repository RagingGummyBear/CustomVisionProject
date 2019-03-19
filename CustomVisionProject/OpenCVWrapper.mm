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

+ (UIImage *) hist_and_Backproj: (UIImage *) image withX: (int) x withY: (int) y threshLow: (int) low threshUp: (int) up {
    
    //    int low = 20, up = 20;
    Mat src; UIImageToMat(image, src);
    Mat hsv, mask;
    /// Transform it to HSV
    cvtColor( src, hsv, COLOR_BGR2HSV );
    cvtColor( hsv, src, COLOR_HSV2BGR );
    // Fill and get the mask
    
    if (x < 0){
        x = 0;
    }
    if (x >= src.rows){
        x = src.rows - 1;
    }
    
    if (y < 0){
        y = 0;
    }
    if (y >= src.cols){
        y = src.cols - 1;
    }
    
    cv::Point seed = cv::Point( x, y );
    
    int newMaskVal = 255;
    Scalar newVal = Scalar( 120, 120, 120 );
    
    int connectivity = 8;
    int flags = connectivity + (newMaskVal << 8 ) + FLOODFILL_FIXED_RANGE + FLOODFILL_MASK_ONLY;
    
    Mat mask2 = Mat::zeros( src.rows + 2, src.cols + 2, CV_8U );
    floodFill( src, mask2, seed, newVal, 0, Scalar( low, low, low ), Scalar( up, up, up), flags );
    mask = mask2( Range( 1, mask2.rows - 1 ), Range( 1, mask2.cols - 1 ) );
    
    Mat hist;
    int h_bins = 30; int s_bins = 32;
    int histSize[] = { h_bins, s_bins };
    
    float h_range[] = { 0, 180 };
    float s_range[] = { 0, 256 };
    const float* ranges[] = { h_range, s_range };
    
    int channels[] = { 0, 1 };
    
    /// Get the Histogram and normalize it
    calcHist( &hsv, 1, channels, mask, hist, 2, histSize, ranges, true, false );
    
    normalize( hist, hist, 0, 255, NORM_MINMAX, -1, Mat() );
    
    /// Get Backprojection
    Mat backproj;
    calcBackProject( &hsv, 1, channels, hist, backproj, ranges, 1, true );
    
    return MatToUIImage(backproj);
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

+ (UIImage *) find_circles: (UIImage *) image withThresh:(int) thresh {
    
    cout << "Find circles function is not finished or tunned so it doesnt work...";
    
    Mat src; Mat src_gray; UIImageToMat(image, src);
    Mat temp; cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(src, src_gray, COLOR_BGR2GRAY);
    // Convert image to gray and blur it
    medianBlur(src_gray, src_gray, 5);
    
    
    vector<Vec3f> circles;
    HoughCircles(src_gray, circles, HOUGH_GRADIENT, 1,
                 1,  // change this value to detect circles with different distances to each other
                 100, 30, 350, 400 // change the last two parameters
                 // (min_radius & max_radius) to detect larger circles
                 );
    
    // cout << circles.size();
    for( size_t i = 0; i < circles.size(); i++ )
    {
        Vec3i c = circles[i];
        cv::Point center = cv::Point(c[0], c[1]);
        // circle center
        circle( src, center, 1, Scalar(0,100,100), 3, LINE_AA);
        // circle outline
        int radius = c[2];
        circle( src, center, radius, Scalar(255,0,255), 3, LINE_AA);
    }
    
    
    // return MatToUIImage(mask);
    return MatToUIImage(src);
}



+ (UIImage *) compareFeatures: (UIImage *) src withImage:(UIImage *) compare {
    Mat img_1; UIImageToMat(src, img_1);
    Mat img_2; UIImageToMat(compare, img_2);
    
    cvtColor(img_1, img_1, COLOR_BGR2GRAY);
    cvtColor(img_2, img_2, COLOR_BGR2GRAY);
    
    //-- Step 1: Detect the keypoints using SURF Detector, compute the descriptors
    Ptr<AKAZE> detector = AKAZE::create();
    
    std::vector<KeyPoint> keypoints_1, keypoints_2;
    Mat descriptors_1, descriptors_2;
    detector->detectAndCompute( img_1, Mat(), keypoints_1, descriptors_1 );
    detector->detectAndCompute( img_2, Mat(), keypoints_2, descriptors_2 );
    //-- Step 2: Matching descriptor vectors using FLANN matcher
    // FlannBasedMatcher matcher = FlannBasedMatcher();
    BFMatcher matcher = BFMatcher();
    std::vector< DMatch > matches;
    matcher.match( descriptors_1, descriptors_2, matches );
    double max_dist = 0; double min_dist = 300; // TODO: Tune this value. Default was 100. Also check if same size imgs give better results
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < matches.size(); i++ ){
        double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    // cout<< " Features max found: " << matches.size() << " W00p";
    //-- Draw only "good" matches (i.e. whose distance is less than 2*min_dist,
    //-- or a small arbitary value ( 0.02 ) in the event that min_dist is very
    //-- small)
    //-- PS.- radiusMatch can also be used here.
    std::vector< DMatch > good_matches;
    for( int i = 0; i < descriptors_1.rows; i++ ){
        if (i >= matches.size()){
            break;
        }
        if( matches[i].distance <= max(2*min_dist, 0.02) ){
            good_matches.push_back( matches[i]);
        }
    }
    
    //-- Draw only "good" matches
    Mat img_matches;
    drawMatches( img_1, keypoints_1, img_2, keypoints_2,
                good_matches, img_matches, Scalar::all(-1), Scalar::all(-1),
                vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
    
    //-- Show detected matches
    //    imshow( "Good Matches", img_matches );
    
    return MatToUIImage(img_matches);
}


+ (UIImage *) compareFeaturesHomography: (UIImage *) src withImage:(UIImage *) compare {
    
    Mat img_1; UIImageToMat(src, img_1);
    Mat img_2; UIImageToMat(compare, img_2);
    cvtColor(img_1, img_1, COLOR_BGR2GRAY);
    cvtColor(img_2, img_2, COLOR_BGR2GRAY);
    
    //-- Step 1: Detect the keypoints using SURF Detector, compute the descriptors
    Ptr<AKAZE> detector = AKAZE::create();
    
    std::vector<KeyPoint> keypoints_1, keypoints_2;
    Mat descriptors_1, descriptors_2;
    detector->detectAndCompute( img_1, Mat(), keypoints_1, descriptors_1 );
    detector->detectAndCompute( img_2, Mat(), keypoints_2, descriptors_2 );
    
    //-- Step 2: Matching descriptor vectors using FLANN matcher
    //    FlannBasedMatcher matcher = FlannBasedMatcher();
    BFMatcher matcher = BFMatcher();
    std::vector< DMatch > matches;
    matcher.match( descriptors_1, descriptors_2, matches );
    double max_dist = 0; double min_dist = 500;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors_1.rows; i++ )
    { double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    //    printf("-- Max dist : %f \n", max_dist );
    //    printf("-- Min dist : %f \n", min_dist );
    
    //-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
    std::vector< DMatch > good_matches;
    for( int i = 0; i < descriptors_1.rows; i++ ){
        if( matches[i].distance < 3*min_dist ){
            good_matches.push_back( matches[i]);
        }
    }
    Mat img_matches;
    drawMatches( img_1, keypoints_1, img_2, keypoints_2,
                good_matches, img_matches, Scalar::all(-1), Scalar::all(-1),
                std::vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
    //-- Localize the object
    std::vector<Point2f> obj;
    std::vector<Point2f> scene;
    for( size_t i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        obj.push_back( keypoints_1[ good_matches[i].queryIdx ].pt );
        scene.push_back( keypoints_2[ good_matches[i].trainIdx ].pt );
    }
    //    cout << good_matches.size(); // TODO: make handler for the case good_matches.size() == 0
    if (good_matches.size() == 0){
        return MatToUIImage(img_matches);
    }
    Mat H = findHomography( obj, scene, RANSAC );
    //-- Get the corners from the image_1 ( the object to be "detected" )
    std::vector<Point2f> obj_corners(4);
    obj_corners[0] = cv::Point(0,0); obj_corners[1] = cv::Point( img_1.cols, 0 );
    obj_corners[2] = cv::Point( img_1.cols, img_1.rows ); obj_corners[3] = cv::Point( 0, img_1.rows );
    std::vector<Point2f> scene_corners(4);
    
    //    cout << obj_corners.size() << " and scn corners: " << scene_corners.size() << " And homography: " << H.size;
    if (H.size == 0 ){
        return MatToUIImage(img_matches);
    }
    
    perspectiveTransform( obj_corners, scene_corners, H);
    //-- Draw lines between the corners (the mapped object in the scene - image_2 )
    line( img_matches, scene_corners[0] + Point2f( img_1.cols, 0), scene_corners[1] + Point2f( img_1.cols, 0), Scalar(0, 255, 0), 4 );
    line( img_matches, scene_corners[1] + Point2f( img_1.cols, 0), scene_corners[2] + Point2f( img_1.cols, 0), Scalar( 0, 255, 0), 4 );
    line( img_matches, scene_corners[2] + Point2f( img_1.cols, 0), scene_corners[3] + Point2f( img_1.cols, 0), Scalar( 0, 255, 0), 4 );
    line( img_matches, scene_corners[3] + Point2f( img_1.cols, 0), scene_corners[0] + Point2f( img_1.cols, 0), Scalar( 0, 255, 0), 4 );
    //-- Show detected matches
    //    imshow( "Good Matches", img_matches );
    //    for( int i = 0; i < (int)good_matches.size(); i++ )
    //    { printf( "-- Good Match [%d] Keypoint 1: %d  -- Keypoint 2: %d  \n", i, good_matches[i].queryIdx, good_matches[i].trainIdx ); }
    return MatToUIImage(img_matches);
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
    // copyTo(canny_output, canny_output, boundMask);
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
    
    cv::Mat boundMask = cv::Mat::ones(src.rows, src.cols, CV_8U); // all 0
    cv::Mat result = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(0,0,0);
    
    Vec3b lowerC = cv::Vec3b(1,1,1); // BGR Values
    Vec3b upperC = cv::Vec3b(255,255,255); // BGR values
    
    Mat maskPrep; hsv.copyTo(maskPrep, boundMask);
    Mat mask; inRange(maskPrep, lowerC, upperC, mask);
    
    cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR);
    cvtColor(src, temp, COLOR_BGR2GRAY);
    cvtColor(temp, temp, COLOR_GRAY2BGR);
    src.copyTo(result, mask);
    // boundMask.copyTo(temp);
    return MatToUIImage(result);
}

// USING
+ (NSMutableArray *) contour_python_bound_square: (UIImage *) image withThresh:(int) thresh {
    //////////////////////
//    int max_thresh = 255;
    RNG rng(12345);
    //////////////////////
    
//    cout << "CatchCode : ME being usefuler";
    
    Mat src; Mat src_gray; UIImageToMat(image, src);
    Mat temp; cvtColor(src, temp, COLOR_BGR2RGB);
    /// Convert image to gray and blur it
    Mat src_blurred; GaussianBlur(src, src_blurred, cv::Size(5,5), 0);
    Mat hsv; cvtColor( src_blurred, hsv, COLOR_BGR2HSV );
    //    Vec3b lowerC = cv::Vec3b(81,57,11); // RBG Values
    //    Vec3b upperC = cv::Vec3b(240,230,220); // RBG values
    
    Vec3b lowerC = cv::Vec3b(57,11,81); // BGR Values
    Vec3b upperC = cv::Vec3b(230,220,240); // BGR values
    
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
    //    MatToUIImage(src);
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
    //    normalize( hist_src, hist_src, 0, 1, NORM_MINMAX, -1, Mat() );
    
    calcHist( &hsv_compare, 1, channels, Mat(), hist_compare, 1, &histSize, &histRange, true, false );
    //    normalize( hist_compare, hist_compare, 0, 1, NORM_MINMAX, -1, Mat() );
    
    double src_compare = 0;
    double result = 0;
    
    /// Apply the histogram comparison methods
    for( int i = 0; i < 4; i++ ){
        int compare_method = i;
        src_compare = compareHist( hist_src, hist_compare, compare_method );
        //        printf( " Method [%d] : %f \n", i, src_compare);
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
    
    Vec3b lowerC = cv::Vec3b(57,11,81); // BGR Values
    Vec3b upperC = cv::Vec3b(230,220,240); // BGR values
    
    Mat maskPrep; hsv.copyTo(maskPrep, boundMask);
    Mat mask; inRange(maskPrep, lowerC, upperC, mask);
    
    cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR);
    cvtColor(src, temp, COLOR_BGR2GRAY);
    cvtColor(temp, temp, COLOR_GRAY2BGR);
    src.copyTo(temp, mask);
    //    boundMask.copyTo(temp);
    return MatToUIImage(temp);
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
    
    cv::Mat boundMask = cv::Mat::ones(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(0,0,0);
    
    Vec3b lowerC = cv::Vec3b(57,11,81); // BGR Values
    Vec3b upperC = cv::Vec3b(230,220,240); // BGR values
    
    Mat maskPrep; hsv.copyTo(maskPrep, boundMask);
    Mat mask; inRange(maskPrep, lowerC, upperC, mask);
    
    cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR);
    cvtColor(src, temp, COLOR_BGR2GRAY);
    cvtColor(temp, temp, COLOR_GRAY2BGR);
    src.copyTo(temp, mask);
    //    boundMask.copyTo(temp);
    return MatToUIImage(temp);
}

// USING FOR DEBUGING!!!
+ (UIImage *) draw_contour_python_bound_square: (UIImage *) image withThresh:(int) thresh {
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
    
    Vec3b lowerC = cv::Vec3b(57,11,81); // BGR Values
    Vec3b upperC = cv::Vec3b(230,220,240); // BGR values
    
    Mat mask; inRange(hsv, lowerC, upperC, mask);
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    findContours(mask, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    
    cvtColor(temp, src, COLOR_RGB2BGR);
    
    
    vector<vector<cv::Point> > contours_poly( contours.size() ); // Mark -- this too
    vector<cv::Rect> boundRect( contours.size() ); // Mark -- square
    
    for( int i = 0; i < contours.size(); i++ ) {
        approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
        boundRect[i] = boundingRect( Mat(contours_poly[i]) ); // MARK -- square
    }
    
    for( int i = 0; i< contours.size(); i++ ) {
        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        rectangle( src, boundRect[i].tl(), boundRect[i].br(), color, 2, 8, 0 ); // MARK -- square
    }
    
    return MatToUIImage(src);
}

// USING FOR TESTING
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
//    Scalar circleColor = Scalar( 32, 194, 14); // HACKERGREEN
    
    Scalar rectangleColor = Scalar( 248, 152, 30); // HACKERGREEN
    Scalar circleColor = Scalar( 248, 152, 30); // HACKERGREEN

    for( int i = 0; i< contours.size(); i++ )
    {
        rectangle( src, boundRect[i].tl(), boundRect[i].br(), rectangleColor, 2, 8, 0 );
        circle( src, center[i], (int)radius[i], circleColor, 2, 8, 0 );
    }
    return MatToUIImage(src);
}

// USING FOR TESTING
+ (UIImage *) bounding_circles_squares: (UIImage *) image withBound:(CGRect) bound withThresh:(int) thresh {
    //////////////////////
//    int max_thresh = 255;
    RNG rng(12345);
    //////////////////////
    
    Mat src; Mat src_gray; UIImageToMat(image, src);
    Mat temp; cvtColor(src, temp, COLOR_BGR2RGB);
    
    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);
    
    /// Convert image to gray and blur it
    cvtColor( src, src_gray, COLOR_BGR2GRAY );
    blur( src_gray, src_gray, cv::Size(3,3) );
    
    
    Mat threshold_output;
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    
    Mat croppedGray; src_gray.copyTo(croppedGray, boundMask);
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
    
    //    cout << "Double max: " << DBL_MAX << "\n";
    //    cout << "Image x: " << src.rows << " Image y: " << src.cols << "\n";
    
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

@end
