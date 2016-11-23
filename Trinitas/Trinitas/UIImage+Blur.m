//
//  UIImage+Blur.m
//  
//  Created by Luke on 13-9-3.
//  Copyright (c) 2013年 LukeCheng. All rights reserved.
//

#import "UIImage+Blur.h"

@implementation UIImage (Blur)

- (UIImage *)blur:(CGFloat)radius
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [[CIImage alloc] initWithImage:self];
    // create gaussian blur filter
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    // blur image
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    result = [result imageByCroppingToRect:(CGRect){
        .origin.x = radius,
        .origin.y = radius,
        .size.width = inputImage.extent.size.width - radius*2,
        .size.height = inputImage.extent.size.height - radius*2
    }];
    
    CGImageRef cgImage = [context createCGImage:result
                                       fromRect:[result extent]];


    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (UIImage *)blur
{
    return [self blur:10.0f];
}

@end
