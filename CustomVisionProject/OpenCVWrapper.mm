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
+ (Mat)_grayFrom:(Mat)source;
+ (Mat)_matFrom:(UIImage *)source;
+ (UIImage *)_imageFrom:(Mat)source;

#endif

@end

@implementation OpenCVWrapper

const float nn_match_ratio = 0.8f;

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}


+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;

    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)

    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags

    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);

    return cvMat;
}


+ (UIImage *) makeGray: (UIImage *) image {
    Mat inputImage; UIImageToMat(image, inputImage);
    if (inputImage.channels() == 1) return image;
    Mat gray; cvtColor(inputImage, gray, COLOR_BGR2GRAY);

    return MatToUIImage(gray);
}

+ (UIImage *) makeEdges: (UIImage *) image maxThreshold:(int)maxThreshold minThreshold:(int)minThreshold {
    // Convert UIImage to cv::Mat
    Mat inputImage; UIImageToMat(image, inputImage);
    // If input image has only one channel, then return image.
    if (inputImage.channels() == 1) return image;
    // Convert the default OpenCV's BGR format to GrayScale.
    Mat gray; cvtColor(inputImage, gray, COLOR_BGR2GRAY);

    Mat edges; Canny(gray, edges, minThreshold, maxThreshold);

    Mat colorEdges;
    edges.copyTo(colorEdges);
    cvtColor(colorEdges, colorEdges, COLOR_GRAY2BGRA);

    Scalar newColor = Scalar(0,255,0, 1);    //this will be green
    colorEdges.setTo(newColor, edges);

    colorEdges.copyTo(inputImage, edges);

    return MatToUIImage(inputImage);
}

+ (NSMutableArray *) getRGBArray: (UIImage *) image {
    Mat inputImage; UIImageToMat(image, inputImage);

    NSMutableArray *vectors = [NSMutableArray array];

    for(int i = 0 ; i < inputImage.rows; ++i){
        [vectors addObject: [NSMutableArray array]];
        for(int j = 0; j < inputImage.cols; ++j){
            NSMutableArray *vector = [NSMutableArray array];
            [vector addObject: [NSNumber numberWithUnsignedChar:(inputImage.at<cv::Vec3b>(i,j)[0])]];
            [vector addObject: [NSNumber numberWithUnsignedChar:(inputImage.at<cv::Vec3b>(i,j)[1])]];
            [vector addObject: [NSNumber numberWithUnsignedChar:(inputImage.at<cv::Vec3b>(i,j)[2])]];
            //            cout << [NSNumber numberWithUnsignedChar:(inputImage.at<cv::Vec4b>(i,j)[3])];
            //            inputImage.at<cv::Vec4b>
            [vectors addObject:vector];
        }
    }
    return vectors;
}

+ (NSMutableArray *) detectAndComputeFeatures: (UIImage *) image1 withImage:(UIImage *)image2 {
    Mat img1; UIImageToMat(image1, img1);
    Mat img2; UIImageToMat(image2, img2);

    vector<KeyPoint> kpts1, kpts2;
    Mat desc1, desc2;
    
    Ptr<AKAZE> akaze = AKAZE::create();
    akaze->detectAndCompute(img1, noArray(), kpts1, desc1);
    akaze->detectAndCompute(img2, noArray(), kpts2, desc2);

    BFMatcher matcher(NORM_HAMMING);
    vector< vector<DMatch> > nn_matches;
    matcher.knnMatch(desc1, desc2, nn_matches, 2);

    vector<KeyPoint> matched1, matched2, inliers1, inliers2;
    vector<DMatch> good_matches;

    for(size_t i = 0; i < nn_matches.size(); i++) {
        DMatch first = nn_matches[i][0];
        float dist1 = nn_matches[i][0].distance;
        float dist2 = nn_matches[i][1].distance;

        if(dist1 < nn_match_ratio * dist2) {
            matched1.push_back(kpts1[first.queryIdx]);
            matched2.push_back(kpts2[first.trainIdx]);
        }
    }

    for(unsigned i = 0; i < matched1.size(); i++) {
        Mat col = Mat::ones(3, 1, CV_64F);
        col.at<double>(0) = matched1[i].pt.x;
        col.at<double>(1) = matched1[i].pt.y;

        Mat homography;

        col = homography * col;
        col /= col.at<double>(2);
//        double dist = sqrt( pow(col.at<double>(0) - matched2[i].pt.x, 2) + pow(col.at<double>(1) - matched2[i].pt.y, 2));
    }
    NSMutableArray *vectors = [NSMutableArray array];
    return vectors;
}

+ (NSMutableArray *) create_histogram_color: (UIImage *) image {

    Mat src_img, hsv_src; UIImageToMat(image, src_img);

    // Convert to HSV
    cvtColor( src_img, hsv_src, COLOR_BGR2HSV );

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
    Mat hist_src;

    // Calculate the histograms for the HSV images
    calcHist( &hsv_src, 1, channels, Mat(), hist_src, 2, histSize, ranges, true, false );
    normalize( hist_src, hist_src, 0, 1, NORM_MINMAX, -1, Mat() );

    NSMutableArray *vectors = [NSMutableArray array];
    NSMutableArray *vector = [NSMutableArray array];
    [vector addObject: [NSNumber numberWithUnsignedChar: hist_src.rows]];
    [vector addObject: [NSNumber numberWithUnsignedChar: hist_src.cols]];
    [vector addObject: [NSNumber numberWithUnsignedChar: hist_src.type()]];
    [vectors addObject:vector];


    for(int i = 0 ; i < hist_src.rows; ++i){
//        [vectors addObject: [NSMutableArray array]];
        NSMutableArray *innerVector = [NSMutableArray array];

        for(int j = 0; j < hist_src.cols; ++j){
            NSMutableArray *vector = [NSMutableArray array];
            [vector addObject: [NSNumber numberWithUnsignedChar:(hist_src.at<cv::Vec3b>(i,j)[0])]];
            [vector addObject: [NSNumber numberWithUnsignedChar:(hist_src.at<cv::Vec3b>(i,j)[1])]];
            [vector addObject: [NSNumber numberWithUnsignedChar:(hist_src.at<cv::Vec3b>(i,j)[2])]];
            //            cout << [NSNumber numberWithUnsignedChar:(inputImage.at<cv::Vec4b>(i,j)[3])];
            //            inputImage.at<cv::Vec4b>
            [innerVector addObject:vector];

        }
        [vectors addObject:innerVector];
    }
    return vectors;
}


+ (UIImage *) generate_histograms: (UIImage *) image {

    Mat src, dst;

    UIImageToMat(image, src);

    /// Separate the image in 3 places ( B, G and R )
    vector<Mat> bgr_planes;
    split( src, bgr_planes );

    /// Establish the number of bins
    int histSize = 256;

    /// Set the ranges ( for B,G,R) )
    float range[] = { 0, 256 } ;
    const float* histRange = { range };

    bool uniform = true; bool accumulate = false;

    Mat b_hist, g_hist, r_hist;

    /// Compute the histograms:
    calcHist( &bgr_planes[0], 1, 0, Mat(), b_hist, 1, &histSize, &histRange, uniform, accumulate );
    calcHist( &bgr_planes[1], 1, 0, Mat(), g_hist, 1, &histSize, &histRange, uniform, accumulate );
    calcHist( &bgr_planes[2], 1, 0, Mat(), r_hist, 1, &histSize, &histRange, uniform, accumulate );

    // Draw the histograms for B, G and R
    int hist_w = 512; int hist_h = 400;
    int bin_w = cvRound( (double) hist_w/histSize );

    Mat histImage( hist_h, hist_w, CV_8UC3, Scalar( 0,0,0) );

    /// Normalize the result to [ 0, histImage.rows ]
    normalize(b_hist, b_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
    normalize(g_hist, g_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
    normalize(r_hist, r_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
    /// Draw for each channel
    for( int i = 1; i < histSize; i++ )
    {
        line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(b_hist.at<float>(i-1)) ) ,
             cv::Point( bin_w*(i), hist_h - cvRound(b_hist.at<float>(i)) ),
             Scalar( 255, 0, 0), 2, 8, 0  );
        line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(g_hist.at<float>(i-1)) ) ,
             cv::Point( bin_w*(i), hist_h - cvRound(g_hist.at<float>(i)) ),
             Scalar( 0, 255, 0), 2, 8, 0  );
        line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(r_hist.at<float>(i-1)) ) ,
             cv::Point( bin_w*(i), hist_h - cvRound(r_hist.at<float>(i)) ),
             Scalar( 0, 0, 255), 2, 8, 0  );
    }
    return MatToUIImage(histImage);
}


- (Mat) calculateHistogram: (Mat) src {
    Mat hsv;
    cvtColor(src, hsv, COLOR_BGR2HSV);

    // Quantize the hue to 30 levels
    // and the saturation to 32 levels
    int hbins = 30, sbins = 32;
    int histSize[] = {hbins, sbins};
    // hue varies from 0 to 179, see cvtColor
    float hranges[] = { 0, 180 };
    // saturation varies from 0 (black-gray-white) to
    // 255 (pure spectrum color)
    float sranges[] = { 0, 256 };
    const float* ranges[] = { hranges, sranges };
    MatND hist;
    // we compute the histogram from the 0-th and 1-st channels
    int channels[] = {0, 1};

    calcHist( &hsv, 1, channels, Mat(), // do not use mask
             hist, 2, histSize, ranges,
             true, // the histogram is uniform
             false );
    double maxVal=0;
    minMaxLoc(hist, 0, &maxVal, 0, 0);

    int scale = 10;
    Mat histImg = Mat::zeros(sbins*scale, hbins*10, CV_8UC3);

    for( int h = 0; h < hbins; h++ )
        for( int s = 0; s < sbins; s++ )
        {
            float binVal = hist.at<float>(h, s);
            int intensity = cvRound(binVal*255/maxVal);
            rectangle( histImg, cv::Point(h*scale, s*scale),
                      cv::Point( (h+1)*scale - 1, (s+1)*scale - 1),
                      Scalar::all(intensity),
                      FILLED );
        }

    return histImg;
}

+ (UIImage *) generate_hs_histogram: (UIImage *) image {
    Mat src, hsv; UIImageToMat(image, src);
    cvtColor(src, hsv, COLOR_BGR2HSV);

    // Quantize the hue to 30 levels
    // and the saturation to 32 levels
    int hbins = 30, sbins = 32;
    int histSize[] = {hbins, sbins};
    // hue varies from 0 to 179, see cvtColor
    float hranges[] = { 0, 180 };
    // saturation varies from 0 (black-gray-white) to
    // 255 (pure spectrum color)
    float sranges[] = { 0, 256 };
    const float* ranges[] = { hranges, sranges };
    MatND hist;
    // we compute the histogram from the 0-th and 1-st channels
    int channels[] = {0, 1};

    calcHist( &hsv, 1, channels, Mat(), // do not use mask
             hist, 2, histSize, ranges,
             true, // the histogram is uniform
             false );
    double maxVal=0;
    minMaxLoc(hist, 0, &maxVal, 0, 0);

    int scale = 10;
    Mat histImg = Mat::zeros(sbins*scale, hbins*10, CV_8UC3);

    for( int h = 0; h < hbins; h++ )
        for( int s = 0; s < sbins; s++ )
        {
            float binVal = hist.at<float>(h, s);
            int intensity = cvRound(binVal*255/maxVal);
            rectangle( histImg, cv::Point(h*scale, s*scale),
                      cv::Point( (h+1)*scale - 1, (s+1)*scale - 1),
                      Scalar::all(intensity),
                      FILLED );
        }

    return MatToUIImage(histImg);
}

+ (NSMutableArray *) extract_features: (UIImage *) image {
    Mat inputImage; UIImageToMat(image, inputImage);
    vector<KeyPoint> kpts;

    Ptr<AKAZE> alg = AKAZE::create();
    Mat desc;
    //    alg->detectAndCompute(inputImage, noArray(), kpts1, desc1);
    alg->detect(inputImage, kpts);

    alg->detectAndCompute(inputImage, noArray(), kpts, desc);

    NSMutableArray *vectors = [NSMutableArray array];

    for(int i = 0 ; i < desc.rows; ++i){
        [vectors addObject: [NSMutableArray array]];
        for(int j = 0; j < desc.cols; ++j){
//            NSMutableArray *vector = [NSMutableArray array];
        }
    }
    return vectors;
}

+ (double) compareHistograms: (UIImage *) src withHistogramArray:(nonnull NSMutableArray *)compare {
    Mat src_img, hsv_src; UIImageToMat(src, src_img);

    // Convert to HSV
    cvtColor( src_img, hsv_src, COLOR_BGR2HSV );

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
    Mat hist_src;

//    Mat hist_compare; UIImageToMat(compare, hist_compare);
    [[[compare objectAtIndex:0] objectAtIndex:0] unsignedCharValue];
    Mat hist_compare; hist_compare = Mat([[[compare objectAtIndex:0] objectAtIndex:0] unsignedCharValue], [[[compare objectAtIndex:0] objectAtIndex:1] unsignedCharValue], [[[compare objectAtIndex:0] objectAtIndex:2] unsignedCharValue], Scalar(0,0, 0));

    for (int i = 1; i < [compare count]; ++i) {
        NSMutableArray *vector = [NSMutableArray arrayWithArray: [compare objectAtIndex: i]];
        for (int y = 0; y < [vector count]; ++y){

            NSMutableArray *rgb = [NSMutableArray arrayWithArray:  [vector objectAtIndex: y]];
            hist_compare.at<cv::Vec3b>(i,y) = cv::Vec3b();
            hist_compare.at<cv::Vec3b>(i,y) = cv::Vec3b([[rgb objectAtIndex: 0] unsignedCharValue],[[rgb objectAtIndex: 1] unsignedCharValue],[[rgb objectAtIndex: 2] unsignedCharValue]);
        }
    }

    // Calculate the histograms for the HSV images
    calcHist( &hsv_src, 1, channels, Mat(), hist_src, 2, histSize, ranges, true, false );
    normalize( hist_src, hist_src, 0, 1, NORM_MINMAX, -1, Mat() );

//    calcHist( &hsv_compare, 1, channels, Mat(), hist_compare, 2, histSize, ranges, true, false );
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
//    printf( "Done \n" );
    return result;
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
    int min_thresh = 25;
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
    
    Scalar color = Scalar( 32, 194, 14);
    for( int i = 0; i< contours.size(); i++ )
    {
//        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( src, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
    }
    return MatToUIImage(src);
}

+ (UIImage *) contours_bounding_circles_squares: (UIImage *) image withThresh:(int) thresh {
    //////////////////////
    int max_thresh = 255;
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
    vector<vector<cv::Point> > contours_poly( contours.size() );
    vector<cv::Rect> boundRect( contours.size() );
    vector<Point2f>center( contours.size() );
    vector<float>radius( contours.size() );

    for( int i = 0; i < contours.size(); i++ )
    { approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
        boundRect[i] = boundingRect( Mat(contours_poly[i]) );
        minEnclosingCircle( (Mat)contours_poly[i], center[i], radius[i] );
    }

    /// Draw polygonal contour + bonding rects + circles
    cvtColor(temp, src, COLOR_RGB2BGR);
    //    Mat drawing = Mat::zeros( threshold_output.size(), CV_8UC3 );
    
    Scalar color = Scalar( 32, 194, 14);
    for( int i = 0; i< contours.size(); i++ )
    {
//        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( src, contours_poly, i, color, 1, 8, vector<Vec4i>(), 0, cv::Point() );
        rectangle( src, boundRect[i].tl(), boundRect[i].br(), color, 2, 8, 0 );
        circle( src, center[i], (int)radius[i], color, 2, 8, 0 );
        color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( src, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
    }

    return MatToUIImage(src);
}


+ (UIImage *) image_moments: (UIImage *) image withThresh:(int) thresh {
    //////////////////////
    int max_thresh = 255;
    RNG rng(12345);
    //////////////////////

    Mat src; Mat src_gray; Mat outputImg; UIImageToMat(image, src);
    /// Convert image to gray and blur it
    cvtColor( src, src_gray, COLOR_BGR2GRAY );
    blur( src_gray, src_gray, cv::Size(3,3) );

    Mat canny_output;
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;

    /// Detect edges using canny
    Canny( src_gray, canny_output, thresh, thresh * 2, 3);
    /// Find contours
    findContours( canny_output, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );

    /// Get the moments
    vector<Moments> mu(contours.size() );
    for( int i = 0; i < contours.size(); i++ )
    { mu[i] = moments( contours[i], false ); }

    ///  Get the mass centers:
    vector<Point2f> mc( contours.size() );
    for( int i = 0; i < contours.size(); i++ )
    { mc[i] = Point2f( mu[i].m10/mu[i].m00 , mu[i].m01/mu[i].m00 ); }

    /// Draw contours
    Scalar color = Scalar( 32, 194, 14);
    for( int i = 0; i< contours.size(); i++ )
    {
//        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( src, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
        circle( src, mc[i], 4, color, -1, 8, 0 );
    }

    cvtColor(src, outputImg, COLOR_BGR2RGB);
    cvtColor(outputImg, outputImg, COLOR_RGB2BGR);
//    Scalar color = Scalar( 32, 194, 14);
    for( int i = 0; i< contours.size(); i++ ){
//        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( outputImg, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
        circle( outputImg, mc[i], 4, color, -1, 8, 0 );
    }


    /// Calculate the area with the moments 00 and compare with the result of the OpenCV function
    //    printf("\t Info: Area and Contour Length \n");
    for( int i = 0; i< contours.size(); i++ )
    {
        //        printf(" * Contour[%d] - Area (M_00) = %.2f - sArea OpenCV: %.2f - Length: %.2f \n", i, mu[i].m00, contourArea(contours[i]), arcLength( contours[i], true ) );
        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( src, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
        circle( src, mc[i], 4, color, -1, 8, 0 );
    }
    return MatToUIImage(outputImg);
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

//    cout << circles.size();
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
//    FlannBasedMatcher matcher = FlannBasedMatcher();
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
    cvtColor(img_1, img_1, COLOR_BGR2GRAY);
    cvtColor(img_2, img_2, COLOR_BGR2GRAY);

    threshold(img_1, img_1, 128, 255, THRESH_BINARY);

    double d1 = matchShapes(img_1, img_2, CONTOURS_MATCH_I1, 0);
//    double d2 = matchShapes(img_1, img_2, CONTOURS_MATCH_I2, 0);
//    double d3 = matchShapes(img_1, img_2, CONTOURS_MATCH_I3, 0);

    return d1;
}


// USING ???? Really?
+ (NSMutableArray *) draw_contour_python_bound_square: (UIImage *) image withBound:(CGRect) bound withThresh:(int) thresh {
    //////////////////////
    int max_thresh = 255;
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

    //    findContours(mask, contours, RETR_TREE, CHAIN_APPROX_SIMPLE);
    findContours(mask, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);

    vector<vector<cv::Point> > contours_poly( contours.size() ); // Mark -- this too
    vector<cv::Rect> boundRect( contours.size() ); // Mark -- square


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

    NSMutableArray *result = [NSMutableArray array];

    [result addObject:[NSValue valueWithCGRect: CGRectMake(biggest.tl().x, biggest.tl().y, biggest.width, biggest.height)]];
    [result addObject:[NSValue valueWithCGRect: CGRectMake(secondBiggest.tl().x, secondBiggest.tl().y, secondBiggest.width, secondBiggest.height)]];
    [result addObject:[NSValue valueWithCGRect: CGRectMake(thirdBiggest.tl().x, thirdBiggest.tl().y, thirdBiggest.width, thirdBiggest.height)]];

    return result;
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

    //    cout << "Double max: " << DBL_MAX << "\n";
    //    cout << "Image x: " << src.rows << " Image y: " << src.cols << "\n";

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

// USING THIS FUNCTION
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

//    cv::Mat::zeros(src.size, CV_8u)

    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);

    // Detect edges using canny
    Canny( src_gray, canny_output, min_thresh, max_thresh, 3 );
    // Find contours
//    copyTo(canny_output, canny_output, boundMask);
    canny_output.copyTo(canny_output, boundMask);

    Mat temp; canny_output.copyTo(temp, boundMask);
    findContours( temp, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    // Draw contours
    Mat drawing = Mat::zeros( canny_output.size(), CV_8UC3 );


    cvtColor(src, temp, COLOR_BGR2RGB);
    cvtColor(temp, src, COLOR_RGB2BGR); // HACK for drawing colors

    
    Scalar color = Scalar( 32, 194, 14);
    for( int i = 0; i< contours.size(); i++ ){
//        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( src, contours, i, color, 1, 8, hierarchy, 0, cv::Point() );
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
        //        printf( " Method [%d] : %f \n", i, src_compare);
        if (i == 0){
            result = src_compare;
        }
    }
    //    printf( "Done \n" );
    return result;
}

// USING
+ (NSMutableArray *) contour_python_bound_square: (UIImage *) image withThresh:(int) thresh {
    //////////////////////
    int max_thresh = 255;
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

    Scalar color = Scalar( 32, 194, 14);
    
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


// YELLOW PORSCHE SERIOUS USE!
+ (UIImage *) draw_color_maskPorsche: (UIImage *) image withBound:(CGRect) bound withThresh:(int) thresh {
    //////////////////////
    int max_thresh = 255;
    RNG rng(12345);
    //////////////////////

    Mat src; Mat src_gray; Mat temp; UIImageToMat(image, src);

    //    src.copyTo(temp);
    // Convert image to gray and blur it
    Mat src_blurred; GaussianBlur(src, src_blurred, cv::Size(5,5), 0);
    Mat hsv; cvtColor( src_blurred, hsv, COLOR_BGR2HSV );

    cv::Mat boundMask = cv::Mat::zeros(src.rows, src.cols, CV_8U); // all 0
    boundMask(cv::Rect(bound.origin.x, bound.origin.y, bound.size.width, bound.size.height)) = Scalar(255,255,255);

    Vec3b lowerC = cv::Vec3b(0,100,0); // BGR Values
    Vec3b upperC = cv::Vec3b(200,255,255); // BGR values

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
    int max_thresh = 255;
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
    int max_thresh = 255;
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

    Scalar rectangleColor = Scalar( 32, 194, 14);
    Scalar circleColor = Scalar( 32, 194, 14);
    
    
//    Scalar color = Scalar( 32, 194, 14); // HAKAR COLOR
    

//    rgb(12, 104, 252)

    for( int i = 0; i< contours.size(); i++ )
    {
        rectangle( src, boundRect[i].tl(), boundRect[i].br(), rectangleColor, 1, 8, 0 );
        circle( src, center[i], (int)radius[i], circleColor, 1, 8, 0 );
    }
    return MatToUIImage(src);
}

// USING FOR TESTING
+ (UIImage *) bounding_circles_squares: (UIImage *) image withBound:(CGRect) bound withThresh:(int) thresh {
    //////////////////////
    int max_thresh = 255;
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
    int max_thresh = 255;
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
            drawContours( src, contours, i, color, 1, 8, hierarchy, 0, cv::Point() );
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
