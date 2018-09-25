//
//  TTTextAttachment.h
//  HTML2RT
//
//  Created by chudanqin on 2018/9/25.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Drawable

@protocol TTDrawable

- (void)tt_drawInRect:(CGRect)rect context:(CGContextRef)context;

@end

@interface UIImage (TTDrawable) <TTDrawable>
@end

#pragma mark - Layoutable

@protocol TTLayoutable;

@protocol TTLayoutable <NSObject>

- (void)cc_addLayoutable:(id<TTLayoutable>)layoutable withFrame:(CGRect)frame;

@end

@interface CALayer (TTLayoutable) <TTLayoutable>
@end

@interface UIView (TTLayoutable) <TTLayoutable>
@end

@interface TTTextAttachment : NSObject

@property (nonatomic, strong) id<TTDrawable> drawable;

@property (nonatomic, strong) id<TTLayoutable> layoutable;

@property (nonatomic, assign) CGFloat ascent;

@property (nonatomic, assign) CGFloat descent;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat baselineOffset;

@end

#pragma mark - Categories

extern NSString *const TTTextAttachmentAttributeName;

@interface NSAttributedString (TTTextAttachment)

+ (NSAttributedString *)tt_attributedStringWithAttachment:(TTTextAttachment *)attachment;

@end
