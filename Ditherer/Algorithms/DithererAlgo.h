//
//  Ditherer.h
//  Created on 2/13/19.
//

#ifndef DithererAlgo_h
#define DithererAlgo_h

#import <UIKit/UIKit.h>

@protocol DithererAlgo
@required
+ (UInt8)algorithm:(UInt8*)pixelBuffer errorBuffer:(SInt8*)errorBuffer imageBounds:(CGRect)imageBounds x:(size_t)x y:(size_t)y;
@end

#endif /* DithererAlgo_h */

