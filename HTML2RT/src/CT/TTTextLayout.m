//
//  TTTextLayout.m
//  HTML2RT
//
//  Created by chudanqin on 2018/9/6.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "TTTextLayout.h"

@implementation TTTextContainer

- (CGPathRef)textPath:(CGRect *)boundingRect {
    CGMutablePathRef path = CGPathCreateMutable();
    if (_path != NULL) {
        CGPathAddPath(path, NULL, _path.CGPath);
    } else {
        CGPathAddRect(path, NULL, UIEdgeInsetsInsetRect(CGRectMake(0.0, 0.0, _size.width, _size.height), _padding));
    }
    for (UIBezierPath *bp in _exclusionPaths) {
        CGPathAddPath(path, NULL, bp.CGPath);
    }
    if (boundingRect != NULL) {
        *boundingRect = CGPathGetBoundingBox(path);
    }
    CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
    CGPathRef transPath = CGPathCreateCopyByTransformingPath(path, &transform);
    CGPathRelease(path);
    return transPath;
}

@end

@implementation TTTextLayout

+ (instancetype)textLayoutWithTextContainer:(TTTextContainer *)textContainer
                                       text:(NSAttributedString *)text {
    NSCParameterAssert(textContainer != nil && text != nil);
    CFRange range = CFRangeMake(0, (CFIndex)text.length);
    CFRange subrange = range;
    CGRect boundingRect;
    CGPathRef path = [textContainer textPath:&boundingRect];
    NSMutableArray<TTTextSlice *> *textSlices = [NSMutableArray arrayWithCapacity:10];
    NSTimeInterval d = 0.0;
    while (YES) {
        NSTimeInterval t1 = [[NSDate date] timeIntervalSince1970];
        TTTextSlice *textSlice = [TTTextSlice textSliceWithText:text range:subrange path:path boundingRect:boundingRect];
        NSTimeInterval t2 = [[NSDate date] timeIntervalSince1970];
        NSLog(@"%ld: %f", subrange.location, t2 - t1);
        d += t2 - t1;
        if (textSlice == nil) {
            break;
        }
        [textSlices addObject:textSlice];
        
        subrange = textSlice.visibleRange;
        CFIndex location = subrange.location + subrange.length;
        if (location >= range.length) {
            break;
        }
        subrange.location = location;
        subrange.length = range.length - location;
    }
    NSLog(@"total: %f", d);
    TTTextLayout *textLayout = [[TTTextLayout alloc] init];
    if (textLayout != nil) {
        textLayout->_textContainer = textContainer;
        textLayout->_text = [text copy];
        textLayout->_textSlices = [textSlices copy];
        
        [[NSNotificationCenter defaultCenter] addObserver:textLayout selector:@selector(receiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return textLayout;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)receiveMemoryWarning:(NSNotification *)notification {
    for (TTTextSlice *textSlice in _textSlices) {
        [textSlice releaseFrame];
    }
}

@end
