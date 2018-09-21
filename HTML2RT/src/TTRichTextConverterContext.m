//
//  TTRichTextConverterContext.m
//  HTML2RT
//
//  Created by chudanqin on 2018/8/28.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import "TTRichTextConverterContext.h"

@implementation TTRichTextConverterContext

+ (instancetype)defaultInstance {
    TTRichTextConverterContext *ins = [[TTRichTextConverterContext alloc] init];
    ins->_initialFont = [UIFont systemFontOfSize:16.0];
    ins->_initialTextColor = [UIColor blackColor];
    ins->_fontSize = 16.0;
    return ins;
}

@end
