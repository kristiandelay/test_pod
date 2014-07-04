//
//  UIImage+Extensions.m
//  FinalPhoneUniv
//
//  Created by David Artman on 1/10/12.
//  Copyright (c) 2012 Millicorp. All rights reserved.
//

#import "UIImage+Extensions.h"
#import <ImageIO/ImageIO.h>


#if __has_feature(objc_arc)
#define toCF (__bridge CFTypeRef)
#define fromCF (__bridge id)
#else
#define toCF (CFTypeRef)
#define fromCF (id)
#endif


@implementation UIImage (Extensions)

-(UIImage *)scaledImageForMMS
{
    return [self imageWithMaxPixels:MIME_IMAGE_MAX_PIXELS];
}

-(UIImage *)scaledImageForThumbnail
{
    return [self imageWithMaxEdgeLength:MIME_THUMBNAIL_MAX_LENGTH];
}

-(UIImage *)imageWithMaxPixels:(NSInteger)maxPixels
{
    UIImage *returnValue = self;
    NSInteger pixelCount = self.size.height * self.size.width;
    if(pixelCount > maxPixels)
    {
        float lengthMultiplier = sqrt((float)pixelCount / (float)maxPixels);
        NSInteger maxLength = (NSInteger)MAX((float)self.size.height / lengthMultiplier, (float)self.size.width / lengthMultiplier);
        maxLength = maxLength - maxLength % 16;
        returnValue = [self imageWithMaxEdgeLength:maxLength];
    }
    return returnValue;
}

-(UIImage *)imageWithMaxEdgeLength:(NSInteger)edgeLength
{
    UIImage *returnValue = nil;
    if(edgeLength > 0)
    {
        // Calculate new size and initialize variables
        float resizeFactor = 0.0;
        if(self.size.width > self.size.height)
        {
            resizeFactor = (float)edgeLength / (float)self.size.width;
        }
        else
        {
            resizeFactor = (float)edgeLength / (float)self.size.height;
        }
        CGSize newSize;
        newSize.width = (NSInteger)((float)self.size.width * resizeFactor);
        newSize.height = (NSInteger)((float)self.size.height * resizeFactor);
        CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
        CGImageRef imageRef = self.CGImage;
        CGAffineTransform affineTransform = CGAffineTransformIdentity;
        NSInteger orientation = self.imageOrientation;
        BOOL drawTransposed = NO;
        
        // Create context
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                    newRect.size.width,
                                                    newRect.size.height,
                                                    8,
                                                    newRect.size.width * 4,
                                                    colorSpace,
                                                    (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
        
        // First round of transform changes
        if(orientation == UIImageOrientationDown || orientation == UIImageOrientationDownMirrored)
        {
            affineTransform = CGAffineTransformTranslate(affineTransform, newSize.width, newSize.height);
            affineTransform = CGAffineTransformRotate(affineTransform, M_PI);
        }
        else if(orientation == UIImageOrientationLeft || orientation == UIImageOrientationLeftMirrored)
        {
            affineTransform = CGAffineTransformTranslate(affineTransform, newSize.width, 0);
            affineTransform = CGAffineTransformRotate(affineTransform, M_PI_2);
            drawTransposed = YES;
        }
        else if(orientation == UIImageOrientationRight || orientation == UIImageOrientationRightMirrored)
        {
            affineTransform = CGAffineTransformTranslate(affineTransform, 0, newSize.height);
            affineTransform = CGAffineTransformRotate(affineTransform, -M_PI_2);
            drawTransposed = YES;
        }
        
        // Additional transform changes for mirrored images
        if(orientation == UIImageOrientationUpMirrored || orientation == UIImageOrientationDownMirrored)
        {
            affineTransform = CGAffineTransformTranslate(affineTransform, newSize.width, 0);
            affineTransform = CGAffineTransformScale(affineTransform, -1, 1);
        }
        else if(orientation == UIImageOrientationLeftMirrored || orientation == UIImageOrientationRightMirrored)
        {
            affineTransform = CGAffineTransformTranslate(affineTransform, newSize.height, 0);
            affineTransform = CGAffineTransformScale(affineTransform, -1, 1);
        }
        
        // Rotate/flip image if appropriate
        CGContextConcatCTM(bitmap, affineTransform);
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
        
        // Draw in context and scale
        if(drawTransposed)
        {
            newRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
        }
        CGContextDrawImage(bitmap, newRect, imageRef);

        // Get resized image from context
        CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
        returnValue = [UIImage imageWithCGImage:newImageRef];
        
        // Clean up
        CGContextRelease(bitmap);
        CGImageRelease(newImageRef);
        CGColorSpaceRelease(colorSpace);
    }
    return returnValue;
}

- (UIImage *)fixOrientation
{
    // return if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
            
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationRight:
        case UIImageOrientationLeft:
            break;
            
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

-(NSData *)fileData
{
    UIImage *sizedImage = [(UIImage *)self imageWithMaxPixels:MIME_IMAGE_MAX_PIXELS];
    return UIImageJPEGRepresentation((UIImage *)sizedImage, 0.9);
}

static int delayCentisecondsForImageAtIndex(CGImageSourceRef const source, size_t const i)
{
    int delayCentiseconds = 1;
    CFDictionaryRef const properties = CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
    if (properties) {
        CFDictionaryRef const gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        CFRelease(properties);
        if (gifProperties) {
            CFNumberRef const number = CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
            // Even though the GIF stores the delay as an integer number of centiseconds, ImageIO “helpfully” converts that to seconds for us.
            delayCentiseconds = (int)lrint([fromCF number doubleValue] * 100);
        }
    }
    return delayCentiseconds;
}

static void createImagesAndDelays(CGImageSourceRef source, size_t count, CGImageRef imagesOut[count], int delayCentisecondsOut[count]) {
    for (size_t i = 0; i < count; ++i) {
        imagesOut[i] = CGImageSourceCreateImageAtIndex(source, i, NULL);
        delayCentisecondsOut[i] = delayCentisecondsForImageAtIndex(source, i);
    }
}

static int sum(size_t const count, int const *const values) {
    int theSum = 0;
    for (size_t i = 0; i < count; ++i) {
        theSum += values[i];
    }
    return theSum;
}

static int pairGCD(int a, int b) {
    if (a < b)
        return pairGCD(b, a);
    while (true) {
        int const r = a % b;
        if (r == 0)
            return b;
        a = b;
        b = r;
    }
}

static int vectorGCD(size_t const count, int const *const values) {
    int gcd = values[0];
    for (size_t i = 1; i < count; ++i) {
        // Note that after I process the first few elements of the vector, `gcd` will probably be smaller than any remaining element.  By passing the smaller value as the second argument to `pairGCD`, I avoid making it swap the arguments.
        gcd = pairGCD(values[i], gcd);
    }
    return gcd;
}

static NSArray *frameArray(size_t const count, CGImageRef const images[count], int const delayCentiseconds[count], int const totalDurationCentiseconds) {
    int const gcd = vectorGCD(count, delayCentiseconds);
    size_t const frameCount = totalDurationCentiseconds / gcd;
    UIImage *frames[frameCount];
    for (size_t i = 0, f = 0; i < count; ++i) {
        UIImage *const frame = [UIImage imageWithCGImage:images[i]];
        for (size_t j = delayCentiseconds[i] / gcd; j > 0; --j) {
            frames[f++] = frame;
        }
    }
    return [NSArray arrayWithObjects:frames count:frameCount];
}

static void releaseImages(size_t const count, CGImageRef const images[count]) {
    for (size_t i = 0; i < count; ++i) {
        CGImageRelease(images[i]);
    }
}


static UIImage *animatedImageWithAnimatedGIFImageSource(CGImageSourceRef const source) {
    size_t const count = CGImageSourceGetCount(source);
    CGImageRef images[count];
    int delayCentiseconds[count]; // in centiseconds
    createImagesAndDelays(source, count, images, delayCentiseconds);
    int const totalDurationCentiseconds = sum(count, delayCentiseconds);
    NSArray *const frames = frameArray(count, images, delayCentiseconds, totalDurationCentiseconds);
    UIImage *const animation = [UIImage animatedImageWithImages:frames duration:(NSTimeInterval)totalDurationCentiseconds / 100.0];
    releaseImages(count, images);
    return animation;
}

static UIImage *animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceRef source) {
    if (source) {
        UIImage *const image = animatedImageWithAnimatedGIFImageSource(source);
        CFRelease(source);
        return image;
    } else {
        return nil;
    }
}

+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data {
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithData(toCF data, NULL));
}

+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)url {
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithURL(toCF url, NULL));
}

- (UIImage *)resize:(CGSize)size
{
    CGRect newRect = CGRectIntegral(CGRectMake(0.0f, 0.0f, size.width, size.height));
    CGImageRef imageRef = self.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, size.height);
    
    CGContextConcatCTM(contextRef, flipVertical);
    CGContextDrawImage(contextRef, newRect, imageRef);
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(contextRef);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage*)changeColor:(UIColor*)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, YES, [[UIScreen mainScreen] scale]);
    
    CGRect contextRect;
    contextRect.origin.x = 0.0f;
    contextRect.origin.y = 0.0f;
    contextRect.size = [self size];
    
    // Retrieve source image and begin image context
    CGSize itemImageSize = [self size];
    CGPoint itemImagePosition;
    itemImagePosition.x = ceilf((contextRect.size.width - itemImageSize.width) / 2);
    itemImagePosition.y = ceilf((contextRect.size.height - itemImageSize.height) );
    
    UIGraphicsBeginImageContextWithOptions(contextRect.size, NO, [[UIScreen mainScreen] scale]);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // Setup shadow
    // Setup transparency layer and clip to mask
    CGContextBeginTransparencyLayer(c, NULL);
    CGContextScaleCTM(c, 1.0, -1.0);
    CGContextClipToMask(c, CGRectMake(itemImagePosition.x, -itemImagePosition.y, itemImageSize.width, -itemImageSize.height), [self CGImage]);
    // Fill and end the transparency layer
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(color.CGColor);
    CGColorSpaceModel model = CGColorSpaceGetModel(colorSpace);
    const CGFloat* colors = CGColorGetComponents(color.CGColor);
    
    if(model == kCGColorSpaceModelMonochrome)
    {
        CGContextSetRGBFillColor(c, colors[0], colors[0], colors[0], colors[1]);
    }else{
        CGContextSetRGBFillColor(c, colors[0], colors[1], colors[2], colors[3]);
    }
    contextRect.size.height = -contextRect.size.height;
    contextRect.size.height -= 15;
    CGContextFillRect(c, contextRect);
    CGContextEndTransparencyLayer(c);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)squareImageWithColor:(UIColor *)color dimension:(double)dimension
{
    CGRect rect = CGRectMake(0, 0, dimension, dimension);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *) makeThumbnailOfSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    // draw scaled image into thumbnail context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil)
        NSLog(@"could not scale image");
    return newThumbnail;
}

@end
