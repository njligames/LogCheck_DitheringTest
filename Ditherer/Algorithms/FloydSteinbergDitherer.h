//
//  FloydSteinbergDitherer.h
//  Created on 2/13/19.
//

#ifndef FloydSteinbergDitherer_h
#define FloydSteinbergDitherer_h

#import "Ditherer.h"

@interface FloydSteinbergDitherer : Ditherer{}

+ (UInt8)algorithm:(UInt8*)pixelBuffer errorBuffer:(SInt8*)errorBuffer imageBounds:(CGRect)imageBounds x:(size_t)x y:(size_t)y;

@end

#endif /* FloydSteinbergDitherer_h */
