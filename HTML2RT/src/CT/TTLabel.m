//
//  TTLabel.m
//  HTML2RT
//
//  Created by chudanqin on 2018/9/19.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import "TTAsyncLayer.h"
#import "TTLabel.h"

@interface TTLabel ()

@end

@implementation TTLabel

+ (Class)layerClass {
    return [TTAsyncLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    self.layer.contentsScale = [UIScreen mainScreen].scale;
}

- (void)setTextLayout:(TTTextLayout *)textLayout {
    _textLayout = textLayout;
    [self.layer setNeedsDisplay];
}

#pragma mark - Delegate

- (void)layerWillDisplay:(CALayer *)layer {
    [self.layer removeAnimationForKey:@"contents"];
}

- (void)layer:(CALayer *)layer drawInRect:(CGRect)rect context:(CGContextRef)context isCancelled:(BOOL (^)(void))isCancelled {
    [_textLayout drawInContext:UIGraphicsGetCurrentContext() isCancelled:isCancelled];
}

- (void)layer:(CALayer *)layer didDisplay:(BOOL)finished {
    if (_fadeDurationOnAayncDisplay > 0.0) {
        CATransition *transition = [CATransition animation];
        transition.duration = _fadeDurationOnAayncDisplay;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        transition.type = kCATransitionFade;
        [layer addAnimation:transition forKey:@"contents"];
    }
}

@end
