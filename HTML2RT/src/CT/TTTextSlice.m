//
//  TTTextSlice.m
//  HTML2RT
//
//  Created by chudanqin on 2018/9/20.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import "TTAtomicDef.h"
#import "TTTextSlice.h"

@interface TTTextSlice ()

@property (nonatomic, strong) dispatch_semaphore_t lock;

@end

@implementation TTTextSlice

- (void)dealloc {
    [self releaseFrame];
}

+ (instancetype)textSliceWithText:(NSAttributedString *)text
                            range:(CFRange)range
                             path:(CGPathRef)path
                     boundingRect:(CGRect)boundingRect {
    if (text == nil || path == NULL || boundingRect.size.width < 0.0 || boundingRect.size.height <= 0.0) {
        return nil;
    }
    
    TTTextSlice *textSlice = [[TTTextSlice alloc] init];
    if (textSlice != nil) {
        textSlice->_text = [text copy];
        textSlice->_range = range;
        textSlice->_path = CGPathCreateCopy(path);
        textSlice->_boundingRect = boundingRect;
        if (![textSlice _preloadLayoutInfo]) {
            return nil;
        }
    }
    return textSlice;
}

- (BOOL)_preloadLayoutInfo {
    _lock = dispatch_semaphore_create(1);
    _visibleRange = CFRangeMake(kCFNotFound, 0);
    if (![self _createFrameIfNecessary_nolock]) {
        return NO;
    }
    _visibleRange = CTFrameGetVisibleStringRange(_frame);
    [self _releaseFrame_nolock];
    return YES;
}

- (BOOL)_createFrameIfNecessary_nolock {
    if (_framesetter == NULL) {
        [self _releaseFrame_nolock];
        _framesetter = CTFramesetterCreateWithAttributedString((CFTypeRef)_text);
        if (_framesetter == NULL) {
            return NO;
        }
        NSMutableAttributedString *frameAttrs = nil; // TODO
        CFRange range = (_visibleRange.location == kCFNotFound || _visibleRange.length == 0) ? _range : _visibleRange;
        _frame = CTFramesetterCreateFrame(_framesetter, range, _path, (CFTypeRef)frameAttrs);
        if (_frame == NULL) {
            [self _releaseFrame_nolock];
            return NO;
        }
    }
    return YES;
}

- (void)_releaseFrame_nolock {
    if (_frame != NULL) {
        CFRelease(_frame);
        _frame = NULL;
    }
    if (_framesetter != NULL) {
        CFRelease(_framesetter);
        _framesetter = NULL;
    }
}

- (void)releaseFrame {
    TTSemaphoreLock(_lock, {
        [self _releaseFrame_nolock];
    });
}

- (void)drawInContext:(CGContextRef)context
          isCancelled:(BOOL (^)(void))isCancelled {
    NSCParameterAssert(context);
    // 2.转换坐标系,CoreText的原点在左下角，UIKit原点在左上角
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGRect r = _boundingRect;
    CGContextTranslateCTM(context, r.origin.x, r.origin.y);
    CGContextTranslateCTM(context, 0, r.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    CTFramesetterRef framesetter;
    CTFrameRef frame;
    TTSemaphoreLock(_lock, {
        if (![self _createFrameIfNecessary_nolock]) {
            return;
        }
        framesetter = CFRetain(_framesetter);
        frame = CFRetain(_frame);
    });
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    
    for (NSUInteger lineIndex = 0, nLines = CFArrayGetCount(lines); lineIndex < nLines; lineIndex++) {
        if (isCancelled != nil && isCancelled()) {
            break;
        }
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        
        for (NSUInteger runIndex = 0, nRuns = CFArrayGetCount(runs); runIndex < nRuns; runIndex++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, runIndex);
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
            CTRunDraw(run, context, CFRangeMake(0, 0));
        }
    }
    CFRelease(framesetter);
    CFRelease(frame);
    [self releaseFrame];
    CGContextRestoreGState(context);
}

@end
