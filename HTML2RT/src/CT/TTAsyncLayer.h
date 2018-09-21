//
//  TTAsyncLayer.h
//  HTML2RT
//
//  Created by chudanqin on 2018/9/20.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@protocol TTAsyncDisplayable

- (void)layerWillDisplay:(CALayer *)layer;

- (void)layer:(CALayer *)layer drawInRect:(CGRect)rect context:(CGContextRef)context isCancelled:(BOOL (^)(void))isCancelled;

- (void)layer:(CALayer *)layer didDisplay:(BOOL)finished;

@end

@interface TTAsyncLayer : CALayer

//@property (nonatomic, assign) BOOL asynchronous;

@end
