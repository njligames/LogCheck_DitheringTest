//
//  Sierra3Ditherer.m
//  Created on 2/13/19.
//

#import "Sierra3Ditherer.h"

@implementation Sierra3Ditherer

+ (UInt8)algorithm:(UInt8*)pixelBuffer errorBuffer:(SInt8*)errorBuffer imageBounds:(CGRect)imageBounds x:(size_t)x y:(size_t)y
{
    size_t width = imageBounds.size.width;
    size_t height = imageBounds.size.height;
    size_t xy = x + (y * width);
    UInt8 oldPixel = pixelBuffer[xy];
    UInt8 newPixel = (oldPixel + errorBuffer[xy]) < 0x80 ? 0x00 : 0xFF;
    
    // Error Diffusion Pattern:
    // ....  ....  XXXX  5/32  3/32
    // 2/32  4/32  5/32  4/32  2/32
    // ....  2/32  3/32  2/32  ....
    SInt16 error_32 = (oldPixel - newPixel) / 32;
    if (x + 1 < width) errorBuffer[xy + 1] += 5 * error_32;
    if (x + 2 < width) errorBuffer[xy + 2] += 3 * error_32;
    if (y + 1 < height) {
        if (x > 1) errorBuffer[xy + width - 2] += 2 * error_32;
        if (x > 0) errorBuffer[xy + width - 1] += 4 * error_32;
        errorBuffer[xy + width] += 5 * error_32;
        if (x + 1 < width) errorBuffer[xy + width + 1] += 4 * error_32;
        if (x + 2 < width) errorBuffer[xy + width + 2] += 2 * error_32;
    }
    if (y + 2 < height) {
        if (x > 0) errorBuffer[xy + (2 * width) - 1] += 2 * error_32;
        errorBuffer[xy + (2 * width)] += 3 * error_32;
        if (x + 1 < width) errorBuffer[xy + (2 * width) + 1] += 2 * error_32;
    }
    
    return newPixel;
}

@end
