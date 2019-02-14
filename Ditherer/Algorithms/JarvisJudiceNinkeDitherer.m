//
//  JarvisJudiceNinkeDitherer.m
//  Created on 2/13/19.
//

#import "JarvisJudiceNinkeDitherer.h"

@implementation JarvisJudiceNinkeDitherer

+ (UInt8)algorithm:(UInt8*)pixelBuffer errorBuffer:(SInt8*)errorBuffer imageBounds:(CGRect)imageBounds x:(size_t)x y:(size_t)y
{
    size_t width = imageBounds.size.width;
    size_t height = imageBounds.size.height;
    size_t xy = x + (y * width);
    UInt8 oldPixel = pixelBuffer[xy];
    UInt8 newPixel = (oldPixel + errorBuffer[xy]) < 0x80 ? 0x00 : 0xFF;
    
    // Error Diffusion Pattern:
    // ....  ....  XXXX  7/48  5/48
    // 3/48  5/48  7/48  5/48  3/48
    // 1/48  3/48  5/48  3/48  1/48
    SInt16 error_48 = (oldPixel - newPixel) / 48;
    if (x + 1 < width) errorBuffer[xy + 1] += 7 * error_48;
    if (x + 2 < width) errorBuffer[xy + 2] += 5 * error_48;
    if (y + 1 < height) {
        if (x > 1) errorBuffer[xy + width - 2] += 3 * error_48;
        if (x > 0) errorBuffer[xy + width - 1] += 5 * error_48;
        errorBuffer[xy + width] += 7 * error_48;
        if (x + 1 < width) errorBuffer[xy + width + 1] += 5 * error_48;
        if (x + 2 < width) errorBuffer[xy + width + 2] += 3 * error_48;
    }
    if (y + 2 < height) {
        if (x > 1) errorBuffer[xy + (2 * width) - 2] += 1 * error_48;
        if (x > 0) errorBuffer[xy + (2 * width) - 1] += 3 * error_48;
        errorBuffer[xy + (2 * width)] += 5 * error_48;
        if (x + 1 < width) errorBuffer[xy + (2 * width) + 1] += 3 * error_48;
        if (x + 2 < width) errorBuffer[xy + (2 * width) + 2] += 1 * error_48;
    }
    return newPixel;
}

@end
