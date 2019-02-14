//
//  Ditherer.m
//  Created on 2/13/19.
//

#import "Ditherer.h"

@implementation Ditherer

+ (UIImage *)dither:(UIImage *)originalImage targetBounds:(CGRect)targetBounds
{
    CGRect imageBounds = CGRectIntegral(targetBounds);
    size_t width = imageBounds.size.width;
    size_t height = imageBounds.size.height;

    // To fill pixelBuffer with a grayscale version of the original image,
    // we create a bitmap context around it, and then use Core Graphics to
    // draw the image.

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 width, height,
                                                 8, // bitsPerComponent
                                                 width, // bytesPerRow
                                                 colorSpace,
                                                 kCGImageAlphaNone);

    CGContextDrawImage(context, imageBounds, [originalImage CGImage]);

    CGColorSpaceRelease(colorSpace);

    // Next, we scan our pixelBuffer, line by line, filling up the
    // ditheredPixelBuffer with a black-and-white version. We use the
    // errorBuffer to store the error values that we are diffusing to
    // later pixels, according to the selected error diffusion algorithm.

    UInt8 *pixelBuffer = CGBitmapContextGetData(context);
    UInt8 *ditheredPixelBuffer = malloc(width * height);
    SInt8 *errorBuffer = calloc(width * height, sizeof(SInt8));

    for (size_t y = 0; y < height; y++) {
        for (size_t x = 0; x < width; x++) {
            
            ditheredPixelBuffer[x + (y * width)] = [self algorithm:pixelBuffer errorBuffer:errorBuffer imageBounds:imageBounds x:x y:y];
        }
    }
    free(errorBuffer);
    CGContextRelease(context);

    // Finally, we convert our ditheredPixelBuffer into a CGImage, which
    // can be used to create a UIImage, which can be displayed in a
    // UIImageView.

    CFDataRef pixelData = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault,
                                                      ditheredPixelBuffer,
                                                      width * height,
                                                      kCFAllocatorMalloc);
    CGDataProviderRef pixelDataProvider = CGDataProviderCreateWithCFData(pixelData);
    CGImageRef image = CGImageCreate(width, height,
                                     8, 8, width,
                                     colorSpace,
                                     (CGBitmapInfo)kCGImageAlphaNone,
                                     pixelDataProvider,
                                     NULL,
                                     false,
                                     kCGRenderingIntentDefault);

    UIImage *ditheredImage = [UIImage
                              imageWithCGImage:image
                              scale:1.0
                              orientation:originalImage.imageOrientation];

    CGImageRelease(image);
    CGDataProviderRelease(pixelDataProvider);
    CFRelease(pixelData);

    return ditheredImage;
}

+ (UInt8)algorithm:(UInt8*)pixelBuffer errorBuffer:(SInt8*)errorBuffer imageBounds:(CGRect)imageBounds x:(size_t)x y:(size_t)y
{
    size_t width = imageBounds.size.width;
    size_t height = imageBounds.size.height;
    size_t xy = x + (y * width);
    UInt8 oldPixel = pixelBuffer[xy];
    
    return oldPixel;
}

@end
