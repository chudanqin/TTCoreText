//
//  TTTextSlice.h
//  HTML2RT
//
//  Created by chudanqin on 2018/9/20.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface TTTextSlice : NSObject

@property (nonatomic, readonly) NSAttributedString *text;

@property (nonatomic, readonly) CFRange range;

@property (nonatomic, readonly) CFRange visibleRange;

@property (nonatomic, readonly) CGPathRef path;

@property (nonatomic, readonly) CGRect boundingRect;

@property (nonatomic, readonly) CTFramesetterRef framesetter;

@property (nonatomic, readonly) CTFrameRef frame;

+ (instancetype)textSliceWithText:(NSAttributedString *)text
                            range:(CFRange)range
                             path:(CGPathRef)path
                     boundingRect:(CGRect)boundingRect;

- (void)drawInContext:(CGContextRef)context
          isCancelled:(BOOL (^)(void))isCancelled;

- (void)releaseFrame;

@end
