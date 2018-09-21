//
//  TTRichTextConverterContext.h
//  HTML2RT
//
//  Created by chudanqin on 2018/8/28.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTRichTextConverterContext : NSObject

@property (nonatomic, strong) UIFont *initialFont;

@property (nonatomic, strong) UIColor *initialTextColor;

@property (nonatomic, assign) CGFloat fontSize;

+ (instancetype)defaultInstance;

@end
