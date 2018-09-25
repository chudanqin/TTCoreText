//
//  TTLayoutManager.m
//  HTML2RT
//
//  Created by chudanqin on 2018/9/25.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import "TTLayoutManager.h"

@interface TTLayoutManager ()

@property (nonatomic) TTTextContainer *textContainer;

@end

@implementation TTLayoutManager

+ (instancetype)textLayoutWithText:(NSAttributedString *)text
                             range:(CFRange)range
                          delegate:(id<TTLayoutManagerDelegate>)delegate {
    NSCParameterAssert(text != nil);
    NSCParameterAssert(range.location + range.length <= text.length);
    
    TTLayoutManager *layoutManager = [[TTLayoutManager alloc] init];
    if (layoutManager == nil) {
        return nil;
    }
    layoutManager->_text = [text copy];
    layoutManager->_range = range;
    layoutManager->_delegate = delegate;
    return layoutManager;
}

+ (instancetype)loadWithTextContainer:(TTTextContainer *)textContainer
                                 text:(NSAttributedString *)text {
    CFRange range = CFRangeMake(0, (CFIndex)text.length);
    TTLayoutManager *layoutManager = [self textLayoutWithText:text range:range delegate:nil];
    layoutManager.textContainer = textContainer;
    if (![layoutManager reload]) {
        return nil;
    }
    return layoutManager;
}

- (BOOL)reload {
    CFRange range = _range;
    CFRange subrange = range;
    NSAttributedString *text = _text;
    
    NSMutableArray<TTTextLayout *> *textLayouts = [NSMutableArray arrayWithCapacity:10];
    // NSTimeInterval d = 0.0;
    for (NSInteger pageIndex = 0; ; pageIndex++) {
        @autoreleasepool {
            // NSTimeInterval t1 = [[NSDate date] timeIntervalSince1970];
            TTTextContainer *textContainer = [self _textContainerAtPageIndex:pageIndex range:subrange];
            TTTextLayout *textLayout = [TTTextLayout loadWithText:text range:subrange textContainer:textContainer];
            // NSTimeInterval t2 = [[NSDate date] timeIntervalSince1970];
            // NSLog(@"%ld: %f", subrange.location, t2 - t1);
            // d += t2 - t1;
            if (textLayout == nil) {
                return NO;
            }
            [textLayouts addObject:textLayout];
            
            subrange = textLayout.visibleRange;
            CFIndex location = subrange.location + subrange.length;
            if (location >= range.length) {
                break;
            }
            subrange.location = location;
            subrange.length = range.length - location;
        }
    }
    _textLayouts = [textLayouts copy];
    // NSLog(@"total: %f", d);
    return YES;
}

- (TTTextContainer *)_textContainerAtPageIndex:(NSInteger)pageIndex range:(CFRange)range {
    TTTextContainer *tc = [_delegate layoutManager:self willLoadText:_text range:range pageIndex:pageIndex];
    if (tc == nil) {
        tc = _textContainer;
    }
    return tc;
}

@end
