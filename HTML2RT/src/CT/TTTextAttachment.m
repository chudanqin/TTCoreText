//
//  TTTextAttachment.m
//  HTML2RT
//
//  Created by chudanqin on 2018/9/25.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "TTTextAttachment.h"

@implementation UIImage (TTTextAttachment)

- (void)tt_drawInRect:(CGRect)rect context:(CGContextRef)context {
    CGContextDrawImage(context, rect, self.CGImage);
}

@end

static CGFloat ascentCallback(void *ref){
    TTTextAttachment *ta = (__bridge TTTextAttachment *)ref;
    return ta.ascent;
}
static CGFloat descentCallback(void *ref){
    TTTextAttachment *ta = (__bridge TTTextAttachment *)ref;
    return ta.descent;
}
static CGFloat widthCallback(void *ref){
    TTTextAttachment *ta = (__bridge TTTextAttachment *)ref;
    return ta.width;
}

@implementation TTTextAttachment

@end

NSString *const TTTextAttachmentAttributeName = @"tt.text-attachment";

@implementation NSAttributedString (TTTextAttachment)

+ (NSAttributedString *)tt_attributedStringWithAttachment:(TTTextAttachment *)attachment {
    NSCParameterAssert(attachment != nil);
    
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateCurrentVersion;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)attachment);
    // 使用 0xFFFC 作为空白的占位符
    unichar objectReplacementChar = NSAttachmentCharacter;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:content attributes:@{TTTextAttachmentAttributeName: attachment}];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)placeholder,
                                   CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    
    return placeholder;
}

@end
