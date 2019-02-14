//
//  FloydSteinbergDitherer.m
//  Created on 2/13/19.
//

#import "FloydSteinbergDitherer.h"

@implementation FloydSteinbergDitherer

+ (UInt8)algorithm:(UInt8*)pixelBuffer errorBuffer:(SInt8*)errorBuffer imageBounds:(CGRect)imageBounds x:(size_t)x y:(size_t)y
{
    size_t width = imageBounds.size.width;
    size_t height = imageBounds.size.height;
    size_t xy = x + (y * width);
    UInt8 oldPixel = pixelBuffer[xy];
    UInt8 newPixel = (oldPixel + errorBuffer[xy]) < 0x80 ? 0x00 : 0xFF;
    
    // Error Diffusion Pattern:
    // ....  XXXX  7/16
    // 3/16  5/16  1/16
    SInt16 error_16 = (oldPixel - newPixel) / 16;
    if (x + 1 < width) errorBuffer[xy + 1] += 7 * error_16;
    if (y + 1 < height) {
        if (x > 0) errorBuffer[xy + width - 1] += 3 * error_16;
        errorBuffer[xy + width] += 5 * error_16;
        if (x + 1 < width) errorBuffer[xy + width + 1] += 1 * error_16;
    }
    
    return newPixel;
}

@end
