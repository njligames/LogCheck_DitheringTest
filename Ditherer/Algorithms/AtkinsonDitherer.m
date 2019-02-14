//
//  AtkinsonDitherer.m
//  Created on 2/13/19.
//

#import "AtkinsonDitherer.h"

@implementation AtkinsonDitherer

+ (UInt8)algorithm:(UInt8*)pixelBuffer errorBuffer:(SInt8*)errorBuffer imageBounds:(CGRect)imageBounds x:(size_t)x y:(size_t)y
{
    size_t width = imageBounds.size.width;
    size_t height = imageBounds.size.height;
    size_t xy = x + (y * width);
    UInt8 oldPixel = pixelBuffer[xy];
    UInt8 newPixel = (oldPixel + errorBuffer[xy]) < 0x80 ? 0x00 : 0xFF;
    
    // Error Diffusion Pattern:
    // ...  XXX  1/8  1/8
    // 1/8  1/8  1/8  ...
    // ...  1/8  ...  ...
    SInt16 error_8 = (oldPixel - newPixel) / 8;
    if (x + 1 < width) errorBuffer[xy + 1] += 1 * error_8;
    if (x + 2 < width) errorBuffer[xy + 2] += 1 * error_8;
    if (y + 1 < height) {
        if (x > 0) errorBuffer[xy + width - 1] += 1 * error_8;
        errorBuffer[xy + width] += 1 * error_8;
        if (x + 1 < width) errorBuffer[xy + width + 1] += 1 * error_8;
    }
    
    if (y + 2 < height) {
        errorBuffer[xy + (2 * width)] += 1 * error_8;
    }
    
    return newPixel;
}

@end
