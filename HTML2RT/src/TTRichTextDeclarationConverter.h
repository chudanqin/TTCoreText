//
//  TTRichTextDeclarationConverter.h
//  HTML2RT
//
//  Created by chudanqin on 2018/8/28.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "katana.h"
#import "TTRichTextConverterContext.h"

@protocol TTRichTextDeclarationConvertible <NSObject>

- (NSString *)property;

- (void)convertValues:(KatanaArray *)values inContext:(TTRichTextConverterContext *)context;

@end

@interface TTRichTextFontSizeConverter : NSObject <TTRichTextDeclarationConvertible>

@end
