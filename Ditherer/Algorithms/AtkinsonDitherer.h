//
//  AtkinsonDitherer.h
//  Created on 2/13/19.
//

#ifndef AtkinsonDitherer_h
#define AtkinsonDitherer_h

#import "Ditherer.h"

@interface AtkinsonDitherer : Ditherer{}

+ (UInt8)algorithm:(UInt8*)pixelBuffer errorBuffer:(SInt8*)errorBuffer imageBounds:(CGRect)imageBounds x:(size_t)x y:(size_t)y;

@end

#endif /* AtkinsonDitherer_h */
