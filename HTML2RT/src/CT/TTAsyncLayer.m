//
//  TTAsyncLayer.m
//  HTML2RT
//
//  Created by chudanqin on 2018/9/20.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import "TTAtomicDef.h"
#import "TTAsyncLayer.h"

static inline dispatch_queue_t _TTAsyncDisplayQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

@interface TTAsyncLayer ()

@property (atomic/* volatile */, assign) int32_t displaySentinel;

@end

@implementation TTAsyncLayer

- (void)dealloc {
    [self cancelDisplay];
}

- (void)cancelDisplay {
    TTAtomicIncrement32(&_displaySentinel);
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    [self cancelDisplay];
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self cancelDisplay];
}

- (void)display {
//    if (_asynchronous) {
        [self _displayAsync];
//    } else {
//        [self _display];
//    }
}

- (void)_display {
    CGSize size = self.bounds.size;
    BOOL opaque = self.opaque;
    CGFloat scale = self.contentsScale;
    CGColorRef backgroundColor = (opaque && self.backgroundColor) ? CGColorRetain(self.backgroundColor) : NULL;
    
    id<TTAsyncDisplayable> delegate = (id<TTAsyncDisplayable>)self.delegate;
    
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale); // any thread
    CGContextRef context = UIGraphicsGetCurrentContext(); // any thread
    if (opaque && context) {
        CGContextSaveGState(context); {
            if (backgroundColor != NULL || CGColorGetAlpha(backgroundColor) < 1) {
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                CGContextFillPath(context);
            }
            if (backgroundColor != NULL) {
                CGContextSetFillColorWithColor(context, backgroundColor);
                CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                CGContextFillPath(context);
            }
        } CGContextRestoreGState(context);
        CGColorRelease(backgroundColor);
    }
    [delegate layer:self drawInRect:rect context:context isCancelled:nil];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.contents = (__bridge id)(image.CGImage);
}

- (void)_displayAsync {
    typeof(self) __weak weakSelf = self;
    int32_t displaySentinel = _displaySentinel;
    BOOL (^isCancelled)(void) = ^{
        if (weakSelf == nil || weakSelf.displaySentinel != displaySentinel) {
            return YES;
        }
        return NO;
    };
    
    [(id<TTAsyncDisplayable>)self.delegate layerWillDisplay:self];
    
    CGSize size = self.bounds.size;
    BOOL opaque = self.opaque;
    CGFloat scale = self.contentsScale;
    CGColorRef backgroundColor = (opaque && self.backgroundColor) ? CGColorRetain(self.backgroundColor) : NULL;
    
    dispatch_async(_TTAsyncDisplayQueue(), ^{
        id<TTAsyncDisplayable> delegate = (id<TTAsyncDisplayable>)weakSelf.delegate;
        id layer = weakSelf;
        if (delegate == nil || layer == nil) {
            return;
        }
        
        if (isCancelled()) {
            CGColorRelease(backgroundColor);
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate layer:layer didDisplay:NO];
            });
            return;
        }
        CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale); // any thread
        CGContextRef context = UIGraphicsGetCurrentContext(); // any thread
        if (opaque && context) {
            CGContextSaveGState(context); {
                if (backgroundColor != NULL || CGColorGetAlpha(backgroundColor) < 1) {
                    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                    CGContextFillPath(context);
                }
                if (backgroundColor != NULL) {
                    CGContextSetFillColorWithColor(context, backgroundColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                    CGContextFillPath(context);
                }
            } CGContextRestoreGState(context);
            CGColorRelease(backgroundColor);
        }
        if (isCancelled()) {
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate layer:layer didDisplay:NO];
            });
            return;
        }
        [delegate layer:layer drawInRect:rect context:context isCancelled:isCancelled];
        if (isCancelled()) {
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate layer:layer didDisplay:NO];
            });
            return;
        }
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (isCancelled()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate layer:layer didDisplay:NO];
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isCancelled()) {
                [delegate layer:layer didDisplay:NO];
            } else {
                weakSelf.contents = (__bridge id)(image.CGImage);
                [delegate layer:layer didDisplay:YES];
            }
        });
    });
}

@end
