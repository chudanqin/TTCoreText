//
//  TTTextLayout.h
//  HTML2RT
//
//  Created by chudanqin on 2018/9/6.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTTextContainer : NSObject

@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) UIEdgeInsets padding;

@property (nonatomic, strong) UIBezierPath *path;

@property (nonatomic, strong) NSArray<UIBezierPath *> *exclusionPaths;

- (CGPathRef)textPath:(CGRect *)boundingRect;

@end

typedef NS_ENUM(NSInteger, TTTextVerticalAlignment) {
    TTTextVerticalAlignmentCenter = 0,
    TTTextVerticalAlignmentTop,
    TTTextVerticalAlignmentBottom,
};

@interface TTTextLayout : NSObject

@property (nonatomic, readonly) TTTextContainer *textContainer;

@property (nonatomic, readonly) CGPathRef path;

@property (nonatomic, readonly) CGRect boundingRect;

@property (nonatomic, readonly) NSAttributedString *text;

@property (nonatomic, readonly) CFRange range;

@property (nonatomic, readonly) CFRange visibleRange;

@property (nonatomic, readonly) CGSize size;

@property (nonatomic, assign) TTTextVerticalAlignment verticalAlignment;

+ (instancetype)loadWithText:(NSAttributedString *)text
                       range:(CFRange)range
               textContainer:(TTTextContainer *)textContainer;

- (BOOL)reload;

- (void)drawInContext:(CGContextRef)context
          isCancelled:(BOOL (^)(void))isCancelled;

@end
