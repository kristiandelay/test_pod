//
//  UIImage+Extensions.h
//  FinalPhoneUniv
//
//  Created by David Artman on 1/10/12.
//  Copyright (c) 2012 Millicorp. All rights reserved.
//

#import <Foundation/Foundation.h>



#define MIME_IMAGE_MAX_PIXELS       1048576
#define MIME_THUMBNAIL_MAX_LENGTH   200

@interface UIImage (Extensions)

-(UIImage *)scaledImageForMMS;
-(UIImage *)scaledImageForThumbnail;

-(UIImage *)imageWithMaxPixels:(NSInteger)maxPixels;
-(UIImage *)imageWithMaxEdgeLength:(NSInteger)edgeLength;

-(NSData *)fileData;

- (UIImage *)fixOrientation;


+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)theData;
+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)theURL;

- (UIImage *)resize:(CGSize)size;

- (UIImage*)changeColor:(UIColor*)color;

+ (UIImage *)squareImageWithColor:(UIColor *)color dimension:(double)dimension;

- (UIImage *) makeThumbnailOfSize:(CGSize)size;

@end