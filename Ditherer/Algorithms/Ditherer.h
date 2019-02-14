//
//  Ditherer.h
//  Created on 2/13/19.
//

#ifndef Ditherer_h
#define Ditherer_h

#import "DithererAlgo.h"

@interface Ditherer : NSObject<DithererAlgo> {}

+ (UIImage *)dither:(UIImage *)originalImage targetBounds:(CGRect)targetBounds;
+ (UInt8)algorithm:(UInt8*)pixelBuffer errorBuffer:(SInt8*)errorBuffer imageBounds:(CGRect)imageBounds x:(size_t)x y:(size_t)y;

@end

#endif /* Ditherer_h */
