//
//  TTRichTextDeclarationConverter.m
//  HTML2RT
//
//  Created by chudanqin on 2018/8/28.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import "TTRichTextDeclarationConverter.h"

@implementation TTRichTextFontSizeConverter

- (NSString *)property {
    return @"font-size";
}

- (void)convertValues:(KatanaArray *)values inContext:(TTRichTextConverterContext *)context {
    CGFloat fontSize = context.initialFont.pointSize;
    if (values->length > 0) {
        KatanaValue *value = values->data[0];
        switch (value->unit) {
            case KATANA_VALUE_EMS:
                fontSize = fontSize * (value->isInt ? value->iValue : value->fValue);
                break;
                
            default:
                break;
        }
    }
    context.fontSize = fontSize;
}

@end
