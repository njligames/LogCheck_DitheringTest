//
//  JarvisJudiceNinkeDitherer.h
//  Created on 2/13/19.
//

#ifndef JarvisJudiceNinkeDitherer_h
#define JarvisJudiceNinkeDitherer_h

#import "Ditherer.h"

@interface JarvisJudiceNinkeDitherer : Ditherer{}

+ (UInt8)algorithm:(UInt8*)pixelBuffer errorBuffer:(SInt8*)errorBuffer imageBounds:(CGRect)imageBounds x:(size_t)x y:(size_t)y;

@end

#endif /* JarvisJudiceNinkeDitherer_h */
