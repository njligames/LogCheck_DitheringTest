//
//  Sierra3Ditherer.h
//  Created on 2/13/19.
//

#ifndef Sierra3Ditherer_h
#define Sierra3Ditherer_h

#import "Ditherer.h"

@interface Sierra3Ditherer : Ditherer{}

+ (UInt8)algorithm:(UInt8*)pixelBuffer errorBuffer:(SInt8*)errorBuffer imageBounds:(CGRect)imageBounds x:(size_t)x y:(size_t)y;

@end

#endif /* Sierra3Ditherer_h */
