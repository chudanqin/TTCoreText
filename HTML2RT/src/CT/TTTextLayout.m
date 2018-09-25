//
//  TTTextLayout.m
//  HTML2RT
//
//  Created by chudanqin on 2018/9/6.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "TTTextAttachment.h"
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

+ (instancetype)loadWithText:(NSAttributedString *)text
                       range:(CFRange)range
               textContainer:(TTTextContainer *)textContainer {
    if (text == nil || textContainer == nil) {
        return nil;
    }
    TTTextLayout *textLayout = [[TTTextLayout alloc] initWithText:text
                                                            range:range
                                                    textContainer:textContainer];
    if (![textLayout reload]) {
        return nil;
    }
    return textLayout;
}

- (void)dealloc {
    CGPathRelease(_path);
    _path = NULL;
}

- (instancetype)initWithText:(NSAttributedString *)text
                       range:(CFRange)range
               textContainer:(TTTextContainer *)textContainer {
    self = [super init];
    if (self != nil) {
        _text = [text copy];
        _range = range;
        _textContainer = textContainer;
    }
    return self;
}

- (BOOL)reload {
    CGPathRelease(_path);
    _path = [_textContainer textPath:&_boundingRect];
    if (_path == NULL || _boundingRect.size.width <= 0.0 || _boundingRect.size.height <= 0.0) {
        return NO;
    }
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFTypeRef)_text);
    if (framesetter == NULL) {
        return NO;
    }
    _size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, _range, [self _frameAttributes], _boundingRect.size, &_visibleRange);
    CFRelease(framesetter);
    return YES;
}

- (BOOL)_createFramesetter:(CTFramesetterRef *)framesetter frame:(CTFrameRef *)frame {
    NSCParameterAssert(framesetter != NULL && frame != NULL);
    CTFramesetterRef fs = CTFramesetterCreateWithAttributedString((CFTypeRef)_text);
    if (fs == NULL) {
        *framesetter = NULL;
        return NO;
    }
    CFDictionaryRef frameAttrs = [self _frameAttributes];
    CFRange range = (_visibleRange.location == kCFNotFound || _visibleRange.length == 0) ? _range : _visibleRange;
    *frame = CTFramesetterCreateFrame(fs, range, _path, frameAttrs);
    if (*frame == NULL) {
        *framesetter = NULL;
        CFRelease(fs);
        return NO;
    }
    *framesetter = fs;
    return YES;
}

- (CFDictionaryRef)_frameAttributes {
    return NULL; // TODO
}

- (void)drawInContext:(CGContextRef)context
          isCancelled:(BOOL (^)(void))isCancelled {
    NSCParameterAssert(context);
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextAddRect(context, _boundingRect);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGFloat offsetY;
    if (_verticalAlignment  == TTTextVerticalAlignmentTop) {
        offsetY = 0.0;
    } else if (_verticalAlignment == TTTextVerticalAlignmentCenter) {
        offsetY = (_boundingRect.size.height - _size.height) * 0.5;
    } else {
        offsetY = _boundingRect.size.height - _size.height;
    }
    CGRect r = _boundingRect;
    CGContextTranslateCTM(context, r.origin.x, r.origin.y + offsetY);
    CGContextTranslateCTM(context, 0, r.size.height);
    
    CGContextScaleCTM(context, 1, -1);
    
    CTFramesetterRef framesetter;
    CTFrameRef frame;
    if (![self _createFramesetter:&framesetter frame:&frame]) {
        return;
    }
    CFArrayRef lines = CTFrameGetLines(frame);
    NSUInteger numberOfLines = CFArrayGetCount(lines);
    CGPoint lineOrigins[numberOfLines];
    
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    
    for (NSUInteger lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        if (isCancelled != nil && isCancelled()) {
            break;
        }
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        
        for (NSUInteger runIndex = 0, nRuns = CFArrayGetCount(runs); runIndex < nRuns; runIndex++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, runIndex);
            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
            
            TTTextAttachment *ta = attributes[TTTextAttachmentAttributeName];
            if (ta != nil) {
                CGFloat runAscent;
                CGFloat runDescent;
                CGFloat runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                
                CGRect runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runWidth, runAscent + runDescent);
                
                if (ta.drawable != nil) {
                    [ta.drawable tt_drawInRect:runRect context:context];
                }
                if (ta.layoutable != nil) {
                    // TODO
                }
            } else {
                CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
        }
    }
    CFRelease(framesetter);
    CFRelease(frame);
    CGContextRestoreGState(context);
}

@end
